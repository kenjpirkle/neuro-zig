const std = @import("std");
const warn = std.debug.warn;
const allocator = @import("std").heap.c_allocator;
const SegmentedList = @import("std").SegmentedList;
const QuadShader = @import("shaders/quad_shader.zig").QuadShader;
const Widget = @import("widgets/widget.zig").Widget;
const SearchBar = @import("widgets/search_bar.zig").SearchBar;
usingnamespace @import("c.zig");

const UserInterfaceState = packed struct {
    draw_required: bool,
    animating: bool,
    animating_locked: bool,
};

pub var window: *GLFWwindow = undefined;
var video_mode: *const GLFWvidmode = undefined;
var cursor: *GLFWcursor = undefined;
var widgets: SegmentedList(Widget, 32) = undefined;
var search_bar: u16 = undefined;
var quad_shader: QuadShader = undefined;

var widget_with_cursor: ?*Widget = undefined;
var widget_with_focus: ?*Widget = undefined;

pub fn init() !void {
    if (glfwInit() == 0) {
        warn("could not initialize glfw\n", .{});
        return error.GLFWInitFailed;
    }

    setWindowHints();

    video_mode = glfwGetVideoMode(glfwGetPrimaryMonitor());
    const width = @divTrunc(video_mode.*.width, 2);
    const height = @divTrunc(video_mode.*.height, 2);
    window = glfwCreateWindow(width, height, "neuro-zig", null, null) orelse return error.GlfwCreateWindowFailed;
    cursor = glfwCreateStandardCursor(GLFW_ARROW_CURSOR) orelse return error.GlfwCreateCursorFailed;
    widgets = SegmentedList(Widget, 32).init(allocator);
    widget_with_cursor = null;
    widget_with_focus = null;
    try widgets.push(Widget{ .SearchBar = SearchBar{ .parent = null } });

    glfwMakeContextCurrent(window);

    setGlfwState();

    if (gladLoadGLLoader(@ptrCast(GLADloadproc, glfwGetProcAddress)) == 0) {
        warn("could not initialize glad\n", .{});
        return error.GladLoadProcsFailed;
    }

    const version: [*:0]const u8 = glGetString(GL_VERSION);

    warn("OpenGL version: {}\n", .{version});

    if (glfwExtensionSupported("GL_ARB_bindless_texture") == GLFW_TRUE) {
        warn("GL_ARB_bindless_texture is supported!\n", .{});
    }

    quad_shader = try QuadShader.init(width, height);
    setGlState(width, height);
}

pub fn deinit() void {
    glfwDestroyWindow(window);
    glfwTerminate();
    widgets.deinit();
    quad_shader.deinit();
}

pub fn display() void {
    glClear(GL_COLOR_BUFFER_BIT);
    glfwSwapBuffers(window);
    glfwPollEvents();
}

inline fn setWindowHints() void {
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
}

inline fn setGlState(window_width: c_int, window_height: c_int) void {
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

inline fn setGlfwState() void {
    glfwSwapInterval(1);
    glfwSetWindowSizeLimits(window, 500, 200, GLFW_DONT_CARE, GLFW_DONT_CARE);
    _ = glfwSetWindowSizeCallback(window, onWindowSizeChanged);
    _ = glfwSetCursorPosCallback(window, onCursorPositionChanged);
    _ = glfwSetKeyCallback(window, onKeyEvent);
    _ = glfwSetDropCallback(window, onDrop);
}

fn onWindowSizeChanged(win: ?*GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    glViewport(0, 0, width, height);

    // change this to tree navigation through the scene graph
    var iter = widgets.iterator(0);
    while (iter.next()) |widget| {
        widget.onWindowSizeChanged(width, height);
    }
}

fn onCursorPositionChanged(win: ?*GLFWwindow, x_pos: f64, y_pos: f64) callconv(.C) void {
    const x = @floatToInt(u16, x_pos);
    const y = @floatToInt(u16, y_pos);

    if (widget_with_cursor) |w| {
        if (w.containsPoint(x, y)) {
            // animations here
        } else {
            w.onCursorLeave();
            widget_with_cursor = findWidgetWithCursor(x, y);
            if (widget_with_cursor) |new_w| {
                new_w.onCursorEnter();
            }
        }
    } else {
        widget_with_cursor = findWidgetWithCursor(x, y);
        if (widget_with_cursor) |new_w| {
            new_w.onCursorEnter();
        }
    }
}

fn findWidgetWithCursor(x: u16, y: u16) ?*Widget {
    var i: usize = 0;
    while (i < widgets.len) : (i += 1) {
        var w = widgets.uncheckedAt(i).*;
        if (w.containsPoint(x, y)) {
            return &w;
        }
    }

    return null;
}

fn onKeyEvent(win: ?*GLFWwindow, key: c_int, scan_code: c_int, action: c_int, modifiers: c_int) callconv(.C) void {
    if (key == GLFW_KEY_ESCAPE and action == GLFW_RELEASE) {
        glfwSetWindowShouldClose(win, GL_TRUE);
    } else if (key == GLFW_KEY_C and action != GLFW_RELEASE and modifiers == (GLFW_MOD_CONTROL | GLFW_MOD_SHIFT)) {
        var win_width_h: c_int = undefined;
        var win_height_h: c_int = undefined;
        glfwGetWindowSize(win, &win_width_h, &win_height_h);

        const new_x = blk: {
            win_width_h = @divTrunc(win_width_h, 2);
            const mon_width_h = @divTrunc(video_mode.*.width, 2);
            break :blk mon_width_h - win_width_h;
        };
        const new_y = blk: {
            win_height_h = @divTrunc(win_height_h, 2);
            const mon_height_h = @divTrunc(video_mode.*.height, 2);
            break :blk mon_height_h - win_height_h;
        };

        glfwSetWindowPos(win, new_x, new_y);
    }
}

fn onMouseButtonEvent(win: ?*GLFWwindow, button: c_int, action: c_int, modifiers: c_int) callconv(.C) void {
    if (button == GLFW_MOUSE_BUTTON_LEFT and action == GLFW_PRESS) {
        if (widget_with_cursor) |wwc| {
            if (widget_with_focus) |wwf| {
                if (wwc != wwf) {
                    wwf.onUnfocus();
                }

                // this needs to be more generic
                wwc.onLeftMouseDown();
                // the widget type itself needs to handle this logic
                widget_with_focus = widget_with_cursor;
            }
        } else if (widget_with_focus) |wwf| {
            wwf.onUnfocus();
            widget_with_focus = null;
        }
    }
}

fn onDrop(win: ?*GLFWwindow, count: c_int, paths: [*c][*c]const u8) callconv(.C) void {
    var i: usize = 0;
    while (i < count) : (i += 1) {
        warn("file: {s}\n", .{paths[i]});
    }
}
