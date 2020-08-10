const std = @import("std");
const builtin = std.builtin;
const warn = std.debug.warn;
const allocator = std.heap.c_allocator;
const SegmentedList = std.SegmentedList;
const Timer = std.time.Timer;
const QuadShader = @import("shaders/quad_shader.zig").QuadShader;
const Quad = @import("gl/quad.zig").Quad;
const Colour = @import("gl/colour.zig").Colour;
const QuadColourIndices = @import("gl/quad_colour_indices.zig").QuadColourIndices;
const DrawArraysIndirectCommand = @import("gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const Widget = @import("widgets/widget.zig").Widget;
const WidgetIndex = @import("widgets/widget_index.zig");
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

pub const MouseState = struct {
    button: c_int,
    action: c_int,
    modifiers: c_int,
};

pub const KeyboardState = struct {
    key: c_int,
    scan_code: c_int,
    action: c_int,
    modifiers: c_int,
};

pub const UserInterface = struct {
    const Self = @This();

    window: *GLFWwindow,
    keyboard_state: KeyboardState,
    mouse_state: MouseState,
    width: u16,
    height: u16,
    window_position_x: i32,
    window_position_y: i32,
    video_mode: *const GLFWvidmode,
    cursor: ?*GLFWcursor,
    cursor_x: i32,
    cursor_y: i32,
    quad_shader: QuadShader,
    widget_with_cursor: ?*Widget,
    widget_with_focus: ?*Widget,
    widget_with_mouse: ?*Widget,
    widgets: SegmentedList(Widget, 8),
    root_widgets: SegmentedList(*Widget, 4),
    animating_widgets: SegmentedList(?*Widget, 4),
    timer: Timer,
    before_frame: u64 = 0,
    time_delta: u64 = 0,
    draw_required: bool,
    animating: bool,
    animating_locked: bool,
    input_handled: bool,

    pub fn init(self: *Self, widgets: []const Widget, root_widgets: []*Widget) !void {
        self.widgets = SegmentedList(Widget, 8).init(allocator);
        try self.widgets.pushMany(widgets);

        self.root_widgets = SegmentedList(*Widget, 4).init(allocator);
        try self.root_widgets.pushMany(root_widgets);

        self.animating_widgets = SegmentedList(?*Widget, 4).init(allocator);

        self.timer = try Timer.start();

        if (glfwInit() == 0) {
            warn("could not initialize glfw\n", .{});
            return error.GLFWInitFailed;
        }

        setWindowHints();

        self.video_mode = glfwGetVideoMode(glfwGetPrimaryMonitor());
        const half_width = @intCast(u16, @divTrunc(self.video_mode.*.width, 2));
        const half_height = @intCast(u16, @divTrunc(self.video_mode.*.height, 2));
        self.width = half_width;
        self.height = half_height;
        self.window = glfwCreateWindow(self.width, self.height, "neuro-zig", null, null) orelse return error.GlfwCreateWindowFailed;
        self.window_position_x = half_width - @divTrunc(self.width, 2);
        self.window_position_y = half_height - @divTrunc(self.height, 2);
        glfwSetWindowPos(self.window, self.window_position_x, self.window_position_y);
        self.cursor = glfwCreateStandardCursor(GLFW_ARROW_CURSOR) orelse return error.GlfwCreateCursorFailed;
        self.widget_with_cursor = null;
        self.widget_with_focus = null;
        self.widget_with_mouse = null;

        glfwMakeContextCurrent(self.window);
        try self.setGlfwState();

        if (builtin.mode == .Debug) {
            glEnable(GL_DEBUG_OUTPUT);
            glDebugMessageCallback(debugMessageCallback, null);
        }

        try self.quad_shader.init(self.width, self.height);
        setGlState(self.width, self.height);

        self.quad_shader.beginModify();
        var widget = self.widgets.iterator(0);
        while (widget.next()) |w| {
            try w.insertIntoUi(self);
        }
        self.quad_shader.endModify();
    }

    pub fn deinit(self: *Self) void {
        glfwDestroyCursor(self.cursor);
        glfwDestroyWindow(self.window);
        glfwTerminate();
        self.animating_widgets.deinit();
        self.widgets.deinit();
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

    pub inline fn quadAt(self: *Self, index: usize) *Quad {
        return &self.quad_shader.quad_data.data[index];
    }

    pub inline fn colourAt(self: *Self, index: usize) *Colour {
        return &self.quad_shader.colour_data.data[index];
    }

    pub inline fn quadColourIndicesAt(self: *Self, index: usize) *QuadColourIndices {
        return &self.quad_shader.colour_index_data.data[index];
    }

    pub inline fn drawCommandAt(self: *Self, index: usize) *DrawArraysIndirectCommand {
        return &self.quad_shader.draw_command_data.data[index];
    }

    inline fn setWindowHints() void {
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
        glfwWindowHint(GLFW_DOUBLEBUFFER, GLFW_TRUE);
        glfwWindowHint(GLFW_RED_BITS, 16);
        glfwWindowHint(GLFW_GREEN_BITS, 16);
        glfwWindowHint(GLFW_BLUE_BITS, 16);
        glfwWindowHint(GLFW_ALPHA_BITS, 16);
        glfwWindowHint(GLFW_DECORATED, GLFW_FALSE);
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
        _ = glfwSetWindowPosCallback(self.window, onWindowPosChanged);
        _ = glfwSetMouseButtonCallback(self.window, onMouseButtonEvent);
        _ = glfwSetCursorPosCallback(self.window, onCursorPositionChanged);
        _ = glfwSetCursorEnterCallback(self.window, onCursorEnterWindow);
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
        const is_iconifed = glfwGetWindowAttrib(win, GLFW_ICONIFIED);
        if (is_iconifed == 1) {
            return;
        }

        const ui = getUserPointer(win);

        ui.width = @intCast(u16, width);
        ui.height = @intCast(u16, height);
        ui.quad_shader.updateWindowSize(ui.width, ui.height);
        glViewport(0, 0, width, height);

        // change this to tree navigation through the scene graph
        var widget = ui.widgets.iterator(0);
        while (widget.next()) |w| {
            w.onWindowSizeChanged(ui);
        }
        ui.display();
    }

    fn onWindowPosChanged(win: ?*GLFWwindow, x_pos: i32, y_pos: i32) callconv(.C) void {
        const ui = getUserPointer(win);

        ui.window_position_x = x_pos;
        ui.window_position_y = y_pos;
    }

    fn onCursorPositionChanged(win: ?*GLFWwindow, x_pos: f64, y_pos: f64) callconv(.C) void {
        const ui = getUserPointer(win);

        ui.cursor_x = @floatToInt(i32, x_pos);
        ui.cursor_y = @floatToInt(i32, y_pos);

        ui.input_handled = false;

        // check cached widgets
        if (ui.widget_with_mouse) |wwm| {
            // pass cursor position changed event down
            // TODO: pass down signed cursor position for off window dragging
            wwm.onDrag(ui);
        } else if (ui.cursor_x >= 0 or ui.cursor_y >= 0) {
            if (ui.widget_with_cursor) |wwc| {
                if (!wwc.containsPoint(ui)) {
                    wwc.onCursorLeave(ui);
                }
            }
        }

        if (!ui.input_handled) {
            var widgets = ui.root_widgets.iterator(0);
            while (widgets.next()) |w| {
                // pass cursor position changed logic down
                w.*.onCursorPositionChanged(ui);
                if (ui.input_handled) {
                    break;
                }
            }
        }
    }

    fn onCursorEnterWindow(win: ?*GLFWwindow, entered: c_int) callconv(.C) void {
        if (entered == GLFW_TRUE) {
            return;
        }

        const ui = getUserPointer(win);

        ui.input_handled = false;

        if (ui.widget_with_mouse) |wwm| {
            wwm.onDrag(ui);
        } else if (ui.widget_with_cursor) |wwc| {
            wwc.onCursorLeave(ui);
        }
    }

    inline fn findWidgetWithCursor(self: *Self, x: u16, y: u16) ?*Widget {
        var widget = self.widgets.iterator(0);
        while (widget.next()) |w| {
            if (w.containsPoint(self, x, y)) {
                return w;
            }
        }

        return null;
    }

    fn onKeyEvent(win: ?*GLFWwindow, key: c_int, scan_code: c_int, action: c_int, modifiers: c_int) callconv(.C) void {
        const ui = getUserPointer(win);

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
            if (ui.widget_with_focus != ui.widgets.uncheckedAt(WidgetIndex.SearchBar)) {
                ui.widget_with_focus = ui.widgets.uncheckedAt(WidgetIndex.SearchBar);
                ui.widget_with_focus.?.onFocus(ui);
            }
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
        const ui = getUserPointer(win);

        if (ui.widget_with_focus) |wwf| {
            wwf.onCharacterEvent(ui, codepoint);
        }
    }

    fn onMouseButtonEvent(win: ?*GLFWwindow, button: c_int, action: c_int, modifiers: c_int) callconv(.C) void {
        var xpos: f64 = undefined;
        var ypos: f64 = undefined;
        glfwGetCursorPos(win, &xpos, &ypos);

        if (xpos < 0.0 or ypos < 0.0) {
            return;
        }

        const x = @floatToInt(u16, xpos);
        const y = @floatToInt(u16, ypos);

        const ui = getUserPointer(win);

        ui.mouse_state = .{
            .button = button,
            .action = action,
            .modifiers = modifiers,
        };

        if (button == GLFW_MOUSE_BUTTON_LEFT) {
            switch (action) {
                GLFW_PRESS => {
                    if (ui.widget_with_cursor) |wwc| {
                        if (ui.widget_with_focus) |wwf| {
                            if (wwc != wwf) {
                                wwf.onUnfocus(ui);
                            }

                            wwc.onLeftMouseDown(ui);
                        } else {
                            // this needs to be more generic
                            wwc.onLeftMouseDown(ui);
                            // the widget type itself needs to handle this logic
                            ui.widget_with_focus = ui.widget_with_cursor;
                        }
                    } else if (ui.widget_with_focus) |wwf| {
                        wwf.onUnfocus(ui);
                        ui.widget_with_focus = null;
                    }
                },
                GLFW_RELEASE => {
                    if (ui.widget_with_cursor) |wwc| {
                        wwc.onLeftMouseUp(ui);
                    }
                },
                else => {},
            }
        }
    }

    fn onDrop(win: ?*GLFWwindow, count: c_int, paths: [*c][*c]const u8) callconv(.C) void {
        const ui = getUserPointer(win);

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

    inline fn getUserPointer(window: ?*GLFWwindow) *Self {
        return @ptrCast(*Self, @alignCast(@alignOf(Self), glfwGetWindowUserPointer(window)));
    }

    pub inline fn widgetAt(self: *Self, index: usize) *Widget {
        return self.widgets.uncheckedAt(index);
    }
};
