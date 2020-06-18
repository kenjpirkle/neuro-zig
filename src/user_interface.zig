const std = @import("std");
const allocator = std.heap.c_allocator;
const warn = std.debug.warn;
usingnamespace @import("c.zig");
const shader = @import("shader.zig");

const UserInterfaceState = packed struct {

};

pub const UserInterface = struct {
    window: *GLFWwindow,
    cursor: ?*GLFWcursor,
    widgets: std.SegmentedList(u64, 32),
    shader: shader.Shader,

    pub fn init() !UserInterface {
        if (glfwInit() == 0) {
            warn("could not initialize glfw\n", .{});
            return error.GLFWInitFailed;
        }

        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

        const vm = glfwGetVideoMode(glfwGetPrimaryMonitor());
        const width = @divTrunc(vm.*.width, 2);
        const height = @divTrunc(vm.*.height, 2);
        const win = glfwCreateWindow(width, height, "neuro-zig", null, null) orelse return error.GlfwCreateWindowFailed;

        var ui = UserInterface{
            .window = win,
            .cursor = glfwCreateStandardCursor(GLFW_ARROW_CURSOR),
            .widgets = std.SegmentedList(u64, 32).init(allocator),
            .shader = undefined,
        };

        glfwSetWindowUserPointer(win, ui.window);
        glfwMakeContextCurrent(win);

        if (gladLoadGLLoader(@ptrCast(GLADloadproc, glfwGetProcAddress)) == 0) {
            warn("could not initialize glad\n", .{});
            return error.GladLoadProcsFailed;
        }

        const s = try shader.Shader.init([_]shader.ShaderSource{
            .{
                .shader_type = GL_VERTEX_SHADER,
                .source = "shaders/vertex.glsl",
            },
            .{
                .shader_type = GL_FRAGMENT_SHADER,
                .source = "shaders/fragment.glsl",
            },
        });

        ui.shader = s;

        glfwSwapInterval(1);
        glViewport(0, 0, width, height);
        glfwSetWindowSizeLimits(win, 500, 200, GLFW_DONT_CARE, GLFW_DONT_CARE);

        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);
        glEnable(GL_DEPTH_TEST);
        glClearDepth(0.0);
        glDepthFunc(GL_GEQUAL);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glClearColor(0.25, 0.23, 0.25, 1.0);

        return ui;
    }

    pub fn deinit(self: *UserInterface) void {
        glfwDestroyWindow(self.window);
        glfwTerminate();
        self.widgets.deinit();
    }

    pub fn display(self: UserInterface) void {
        glUseProgram(self.shader.program);
        glClearColor(0.25, 0.22, 0.25, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        glfwSwapBuffers(self.window);
        glfwPollEvents();
    }
};
