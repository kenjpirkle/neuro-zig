const std = @import("std");
const c = @cImport({
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("stdio.h");
    @cInclude("glad.h");
    @cInclude("glfw3.h");
});

pub fn main() anyerror!void {
    _ = c.printf("hello\n");

    if (c.glfwInit() == 0) {
        std.debug.warn("could not initialize glfw\n", .{});
        return error.GLFWInitFailed;
    }
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 6);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const vid_mode = c.glfwGetVideoMode(c.glfwGetPrimaryMonitor());

    const window = c.glfwCreateWindow(
        @divTrunc(vid_mode.*.width, 2),
        @divTrunc(vid_mode.*.height, 2),
        "neuro-zig",
        null,
        null
    ) orelse return error.GlfwCreateWindowFailed;
    defer c.glfwDestroyWindow(window);

    while (c.glfwWindowShouldClose(window) == 0) {
        c.glfwPollEvents();
    }
}
