const allocator = @import("std").heap.c_allocator;
const SegmentedList = @import("std").SegmentedList;
const Shader = @import("shader.zig").Shader;
const ShaderSource = @import("shader.zig").ShaderSource;
const Widget = @import("widgets/widget.zig").Widget;
usingnamespace @import("print.zig");
usingnamespace @import("c.zig");

const UserInterfaceState = packed struct {};

pub var window: *GLFWwindow = undefined;
var video_mode: *const GLFWvidmode = undefined;
var cursor: ?*GLFWcursor = undefined;
var widgets: SegmentedList(Widget, 32) = undefined;
var search_bar: u16 = undefined;
var shader: Shader = undefined;

pub fn init() !void {
    if (glfwInit() == 0) {
        printLine("could not initialize glfw");
        return error.GLFWInitFailed;
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    video_mode = glfwGetVideoMode(glfwGetPrimaryMonitor());
    const width = @divTrunc(video_mode.*.width, 2);
    const height = @divTrunc(video_mode.*.height, 2);
    window = glfwCreateWindow(width, height, "neuro-zig", null, null) orelse return error.GlfwCreateWindowFailed;
    cursor = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
    widgets = SegmentedList(Widget, 32).init(allocator);

    glfwMakeContextCurrent(window);

    if (gladLoadGLLoader(@ptrCast(GLADloadproc, glfwGetProcAddress)) == 0) {
        printLine("could not initialize glad");
        return error.GladLoadProcsFailed;
    }

    shader = try Shader.init([_]ShaderSource{
        .{
            .shader_type = GL_VERTEX_SHADER,
            .source = "shaders/vertex.glsl",
        },
        .{
            .shader_type = GL_FRAGMENT_SHADER,
            .source = "shaders/fragment.glsl",
        },
    });

    glfwSwapInterval(1);
    glViewport(0, 0, width, height);
    glfwSetWindowSizeLimits(window, 500, 200, GLFW_DONT_CARE, GLFW_DONT_CARE);
    _ = glfwSetWindowSizeCallback(window, onWindowSizeChanged);
    _ = glfwSetKeyCallback(window, onKeyEvent);

    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glEnable(GL_DEPTH_TEST);
    glClearDepth(0.0);
    glDepthFunc(GL_GEQUAL);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glClearColor(0.25, 0.23, 0.25, 1.0);
}

pub fn deinit() void {
    glfwDestroyWindow(window);
    glfwTerminate();
    widgets.deinit();
}

pub fn display() void {
    glClear(GL_COLOR_BUFFER_BIT);
    glfwSwapBuffers(window);
    glfwPollEvents();
}

fn onWindowSizeChanged(win: ?*GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    glViewport(0, 0, width, height);

    // change this to tree navigation through the scene graph
    var iter = widgets.iterator(0);
    while (iter.next()) |widget| {
        widget.onWindowSizeChanged(width, height);
    }
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