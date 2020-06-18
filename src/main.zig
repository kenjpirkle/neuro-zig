const std = @import("std");
const warn = std.debug.warn;
const shader = @import("shader.zig");
usingnamespace @import("database.zig");
usingnamespace @import("c.zig");

pub fn main() anyerror!void {
    _ = printf("hello\n");

    var database = try Database.init("C:/Users/kenny/Desktop/neuro.db");
    defer database.deinit();

    if (glfwInit() == 0) {
        warn("could not initialize glfw\n", .{});
        return error.GLFWInitFailed;
    }
    defer glfwTerminate();

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    const vid_mode = glfwGetVideoMode(glfwGetPrimaryMonitor());

    const window = glfwCreateWindow(@divTrunc(vid_mode.*.width, 2), @divTrunc(vid_mode.*.height, 2), "neuro-zig", null, null) orelse return error.GlfwCreateWindowFailed;
    defer glfwDestroyWindow(window);

    glfwMakeContextCurrent(window);

    if (gladLoadGLLoader(@ptrCast(GLADloadproc, glfwGetProcAddress)) == 0) {
        warn("could not initialize glad\n", .{});
        return;
    }

    const shader_source = [_]shader.ShaderSource{
        .{
            .shader_type = GL_VERTEX_SHADER,
            .source = "shaders/vertex.glsl",
        },
        .{
            .shader_type = GL_FRAGMENT_SHADER,
            .source = "shaders/fragment.glsl",
        },
    };

    const s = try shader.Shader.init(shader_source);
    warn("shader program id: {}\n", .{s.program});

    while (glfwWindowShouldClose(window) == 0) {
        glUseProgram(s.program);
        glClearColor(0.25, 0.22, 0.25, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
}
