const std = @import("std");
const builtin = std.builtin;
const warn = std.debug.warn;
const allocator = std.heap.c_allocator;
const SegmentedList = std.SegmentedList;
const Timer = std.time.Timer;
const QuadShader = @import("shaders/quad_shader.zig").QuadShader;
const DrawArraysIndirectCommand = @import("gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const Widget = @import("widgets/widget.zig").Widget;
const WidgetTag = @import("widgets/widget.zig").WidgetTag;
const SearchBar = @import("widgets/search_bar.zig").SearchBar;
const Rectangle = @import("widgets/rectangle.zig").Rectangle;
usingnamespace @import("c.zig");

pub fn checkOpenGLError() bool {
    var found_error = false;
    var gl_error = glGetError();
    while (gl_error != GL_NO_ERROR) : (gl_error = glGetError()) {
        warn("glError: {}\n", .{gl_error});
        found_error = true;
    }

    return found_error;
}

pub const KeyboardState = struct {
    key: c_int,
    scan_code: c_int,
    action: c_int,
    modifiers: c_int,
};

pub const UserInterface = struct {
    const Self = @This();

    window: *GLFWwindow = undefined,
    keyboard_state: KeyboardState = undefined,
    width: u16 = undefined,
    height: u16 = undefined,
    video_mode: *const GLFWvidmode = undefined,
    cursor: ?*GLFWcursor = undefined,
    quad_shader: QuadShader(.{}) = undefined,
    widget_with_cursor: ?*Widget = undefined,
    widget_with_focus: ?*Widget = undefined,
    widgets: [2]Widget,
    animating_widgets: SegmentedList(?*Widget, 4) = undefined,
    timer: Timer = undefined,
    before_frame: u64 = 0,
    time_delta: u64 = 0,
    draw_required: bool,
    animating: bool,
    animating_locked: bool,

    pub fn init(self: *Self) !void {
        self.widgets = .{
            .{
                .Rectangle = .{},
            },
            .{
                .SearchBar = .{},
            },
        };
        self.animating_widgets = SegmentedList(?*Widget, 4).init(allocator);
        self.timer = try Timer.start();

        if (glfwInit() == 0) {
            warn("could not initialize glfw\n", .{});
            return error.GLFWInitFailed;
        }

        setWindowHints();

        self.video_mode = glfwGetVideoMode(glfwGetPrimaryMonitor());
        self.width = @intCast(u16, @divTrunc(self.video_mode.*.width, 2));
        self.height = @intCast(u16, @divTrunc(self.video_mode.*.height, 2));
        self.window = glfwCreateWindow(self.width, self.height, "neuro-zig", null, null) orelse return error.GlfwCreateWindowFailed;
        self.cursor = glfwCreateStandardCursor(GLFW_ARROW_CURSOR) orelse return error.GlfwCreateCursorFailed;
        self.widget_with_cursor = null;
        self.widget_with_focus = null;

        glfwMakeContextCurrent(self.window);
        try self.setGlfwState();

        if (builtin.mode == .Debug) {
            glEnable(GL_DEBUG_OUTPUT);
            glDebugMessageCallback(debugMessageCallback, null);
        }

        try self.quad_shader.init(self.width, self.height);
        setGlState(self.width, self.height);

        for (self.widgets) |*w| {
            try w.insertIntoUi(self);
        }
    }

    pub fn deinit(self: *Self) void {
        glfwDestroyCursor(self.cursor);
        glfwDestroyWindow(self.window);
        glfwTerminate();
        self.animating_widgets.deinit();
        self.quad_shader.deinit();
    }

    pub fn start(self: *Self) void {
        self.draw_required = true;

        while (glfwWindowShouldClose(self.window) == 0) {
            if (self.animating) {
                self.before_frame = self.timer.read();

                self.draw_required = false;
                self.animating = false;
                self.animating_locked = false;

                self.animateWidgets(self.time_delta);

                glfwPollEvents();
                self.display();

                self.time_delta = self.timer.lap() - self.before_frame;
            } else {
                glfwWaitEvents();
                if (self.draw_required) {
                    self.display();
                    self.draw_required = false;
                    self.animating = false;
                    self.animating_locked = false;
                }
            }
        }
    }

    pub fn display(self: *Self) void {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        const count = @intCast(c_int, self.quad_shader.draw_command_data.data.len);
        // FIXED GL_INVALID_OPERATION error generated. Bound draw indirect buffer is not large enough. BECAUSE THE SECOND ARGUMENT IN glMultiDrawArraysIndirect SHOULD BE 0 (null) AND NOT!!! THE ADDRESS OF THE MAPPED BUFFER
        glMultiDrawArraysIndirect(GL_TRIANGLE_STRIP, null, count, 0);
        glfwSwapBuffers(self.window);
    }

    inline fn setWindowHints() void {
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    }

    inline fn setGlState(window_width: c_int, window_height: c_int) void {
        if (builtin.mode == .Debug) {
            const version: [*:0]const u8 = glGetString(GL_VERSION);
            warn("OpenGL version: {}\n", .{version});
        }

        glViewport(0, 0, window_width, window_height);
        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);
        glEnable(GL_DEPTH_TEST);
        glClearDepth(0.0);
        glDepthFunc(GL_GEQUAL);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glClearColor(0.25, 0.23, 0.25, 1.0);
    }

    inline fn setGlfwState(self: *Self) !void {
        glfwSwapInterval(1);
        glfwSetWindowSizeLimits(self.window, 500, 200, GLFW_DONT_CARE, GLFW_DONT_CARE);
        glfwSetWindowUserPointer(self.window, @ptrCast(*c_void, self));
        _ = glfwSetWindowSizeCallback(self.window, onWindowSizeChanged);
        _ = glfwSetMouseButtonCallback(self.window, onMouseButtonEvent);
        _ = glfwSetCursorPosCallback(self.window, onCursorPositionChanged);
        _ = glfwSetKeyCallback(self.window, onKeyEvent);
        _ = glfwSetCharCallback(self.window, onCharacterEvent);
        _ = glfwSetDropCallback(self.window, onDrop);

        if (gladLoadGLLoader(@ptrCast(GLADloadproc, glfwGetProcAddress)) == 0) {
            warn("could not initialize glad\n", .{});
            return error.GladLoadProcsFailed;
        }

        if (builtin.mode == .Debug) {
            if (glfwExtensionSupported("GL_ARB_bindless_texture") == GLFW_TRUE) {
                warn("GL_ARB_bindless_texture is supported!\n", .{});
            }
        }
    }

    fn debugMessageCallback(source: GLenum, error_type: GLenum, id: GLuint, severity: GLenum, length: GLsizei, message: [*c]const u8, user_param: ?*const GLvoid) callconv(.C) void {
        warn("ERROR: {s}\n", .{message});
    }

    fn onWindowSizeChanged(win: ?*GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
        const ui = @ptrCast(*Self, @alignCast(@alignOf(Self), glfwGetWindowUserPointer(win)));
        ui.width = @intCast(u16, width);
        ui.height = @intCast(u16, height);
        ui.quad_shader.updateWindowSize(ui.width, ui.height);
        glViewport(0, 0, width, height);

        // change this to tree navigation through the scene graph
        for (ui.widgets) |*w| {
            w.onWindowSizeChanged(ui);
        }
        ui.display();
    }

    fn onCursorPositionChanged(win: ?*GLFWwindow, x_pos: f64, y_pos: f64) callconv(.C) void {
        const ui = @ptrCast(*Self, @alignCast(@alignOf(Self), glfwGetWindowUserPointer(win)));
        const x = @floatToInt(u16, x_pos);
        const y = @floatToInt(u16, y_pos);

        if (ui.widget_with_cursor) |w| {
            if (w.containsPoint(ui, x, y)) {
                // animations here
            } else {
                w.onCursorLeave(ui);
                ui.widget_with_cursor = ui.findWidgetWithCursor(x, y);
                if (ui.widget_with_cursor) |new_w| {
                    new_w.onCursorEnter(ui);
                }
            }
        } else {
            ui.widget_with_cursor = ui.findWidgetWithCursor(x, y);
            if (ui.widget_with_cursor) |new_w| {
                new_w.onCursorEnter(ui);
            }
        }
    }

    inline fn findWidgetWithCursor(self: *Self, x: u16, y: u16) ?*Widget {
        for (self.widgets) |*w| {
            if (w.containsPoint(self, x, y)) {
                return w;
            }
        }

        return null;
    }

    fn onKeyEvent(win: ?*GLFWwindow, key: c_int, scan_code: c_int, action: c_int, modifiers: c_int) callconv(.C) void {
        const ui = @ptrCast(*Self, @alignCast(@alignOf(Self), glfwGetWindowUserPointer(win)));
        if (key == GLFW_KEY_ESCAPE and action == GLFW_RELEASE) {
            glfwSetWindowShouldClose(win, GL_TRUE);
        } else if (key == GLFW_KEY_C and action != GLFW_RELEASE and modifiers == (GLFW_MOD_CONTROL | GLFW_MOD_SHIFT)) {
            var win_width_h: c_int = undefined;
            var win_height_h: c_int = undefined;
            glfwGetWindowSize(win, &win_width_h, &win_height_h);

            const new_x = blk: {
                win_width_h = @divTrunc(win_width_h, 2);
                const mon_width_h = @divTrunc(ui.video_mode.*.width, 2);
                break :blk mon_width_h - win_width_h;
            };
            const new_y = blk: {
                win_height_h = @divTrunc(win_height_h, 2);
                const mon_height_h = @divTrunc(ui.video_mode.*.height, 2);
                break :blk mon_height_h - win_height_h;
            };

            glfwSetWindowPos(win, new_x, new_y);
        } else if (key == GLFW_KEY_S and action != GLFW_RELEASE and modifiers == GLFW_MOD_CONTROL) {
            // TODO: don't use magic number for SearchBar index
            ui.widget_with_focus = &ui.widgets[1];
            ui.widget_with_focus.?.onFocus(ui);
        } else {
            ui.keyboard_state = .{
                .key = key,
                .scan_code = scan_code,
                .action = action,
                .modifiers = modifiers,
            };

            if (ui.widget_with_focus) |wwf| {
                wwf.onKeyEvent(ui);
            }
        }
    }

    fn onCharacterEvent(win: ?*GLFWwindow, codepoint: u32) callconv(.C) void {
        const ui = @ptrCast(*Self, @alignCast(@alignOf(Self), glfwGetWindowUserPointer(win)));

        if (ui.widget_with_focus) |wwf| {
            wwf.onCharacterEvent(ui, codepoint);
        }
    }

    fn onMouseButtonEvent(win: ?*GLFWwindow, button: c_int, action: c_int, modifiers: c_int) callconv(.C) void {
        const ui = @ptrCast(*Self, @alignCast(@alignOf(Self), glfwGetWindowUserPointer(win)));
        if (button == GLFW_MOUSE_BUTTON_LEFT and action == GLFW_PRESS) {
            if (ui.widget_with_cursor) |wwc| {
                if (ui.widget_with_focus) |wwf| {
                    if (wwc != wwf) {
                        wwf.onUnfocus(ui);
                    }

                    wwc.onLeftMouseDown(ui);
                } else {
                    if (builtin.mode == .Debug) {
                        warn("widget with cursor: {}\n", .{wwc.SearchBar});
                    }
                    // this needs to be more generic
                    wwc.onLeftMouseDown(ui);
                    // the widget type itself needs to handle this logic
                    ui.widget_with_focus = ui.widget_with_cursor;
                }
            } else if (ui.widget_with_focus) |wwf| {
                wwf.onUnfocus(ui);
                ui.widget_with_focus = null;
            }
        }
    }

    fn onDrop(win: ?*GLFWwindow, count: c_int, paths: [*c][*c]const u8) callconv(.C) void {
        const ui = @ptrCast(*Self, @alignCast(@alignOf(Self), glfwGetWindowUserPointer(win)));
        var i: usize = 0;
        while (i < count) : (i += 1) {
            warn("file: {s}\n", .{paths[i]});
        }
    }

    inline fn animateWidgets(self: *Self, time_delta: u64) void {
        var i: usize = 0;
        while (i < self.animating_widgets.len) : (i += 1) {
            var animating_widget = self.animating_widgets.uncheckedAt(i);
            if (animating_widget.*) |w| {
                w.animate(self, time_delta);
            }
        }
    }
};
