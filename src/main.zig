const std = @import("std");
const shader = @import("shader.zig");
usingnamespace @import("c.zig");

pub fn main() anyerror!void {
    _ = printf("hello\n");

    if (glfwInit() == 0) {
        std.debug.warn("could not initialize glfw\n", .{});
        return error.GLFWInitFailed;
    }
    defer glfwTerminate();

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    const vid_mode = glfwGetVideoMode(glfwGetPrimaryMonitor());

    const window = glfwCreateWindow(
        @divTrunc(vid_mode.*.width, 2),
        @divTrunc(vid_mode.*.height, 2),
        "neuro-zig",
        null,
        null
    ) orelse return error.GlfwCreateWindowFailed;
    defer glfwDestroyWindow(window);

    glfwMakeContextCurrent(window);

    if (gladLoadGLLoader(@ptrCast(GLADloadproc, glfwGetProcAddress)) == 0) {
        std.debug.warn("could not initialize glad\n", .{});
        return;
    }

    const id = shader.Shader.loadShader(
        "shaders\\vertex.glsl",
        GL_VERTEX_SHADER
    );

    std.debug.warn("shader id: {} \n", .{id});

    while (glfwWindowShouldClose(window) == 0) {
        glfwPollEvents();
    }
}
