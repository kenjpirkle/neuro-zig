const std = @import("std");
const allocator = std.heap.c_allocator;
usingnamespace @import("../print.zig");
usingnamespace @import("../c.zig");

const IdList = std.ArrayList(GLuint);

pub const ShaderSource = struct {
    shader_type: c_uint,
    source: []const u8,
};

pub const Shader = struct {
    program: GLuint,

    pub fn init(shaders: var) !Shader {
        var ids = IdList.init(allocator);
        defer ids.deinit();

        const program = glCreateProgram();
        for (shaders) |shader| {
            const id = try ids.addOne();
            id.* = try loadShader(shader);
            glAttachShader(program, id.*);
        }

        glLinkProgram(program);
        try printProgramLog(program);

        for (ids.items) |id| {
            glDetachShader(program, id);
            glDeleteShader(id);
        }

        return Shader{ .program = program };
    }

    fn loadShader(shader_source: ShaderSource) !GLuint {
        const data = try std.fs.cwd().readFileAlloc(allocator, shader_source.source, 1024 * 1024 * 1024);

        const shader_id = glCreateShader(shader_source.shader_type);
        glShaderSource(shader_id, 1, @ptrCast([*c]const [*c]const u8, &data), null);
        glCompileShader(shader_id);

        try printShaderLog(shader_id);
        return shader_id;
    }

    pub fn checkOpenGLError() bool {
        var found_error = false;
        var gl_error = glGetError();
        while (gl_error != GL_NO_ERROR) : (gl_error = glGetError()) {
            print("glError: ");
            printLine(gl_error);
            found_error = true;
        }

        return found_error;
    }

    fn printShaderLog(shader: GLuint) !void {
        var len: c_int = undefined;
        var chars_written: c_int = undefined;

        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &len);
        if (len > 0) {
            var log = try allocator.alloc(u8, @intCast(usize, len));
            defer allocator.free(log);
            glGetShaderInfoLog(shader, len, &chars_written, log.ptr);
            print("shader info log: ");
            printLine(log);
        }
    }

    fn printProgramLog(program: GLuint) !void {
        var len: c_int = undefined;
        var chars_written: c_int = undefined;

        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &len);
        if (len > 0) {
            var log = try allocator.alloc(u8, @intCast(usize, len));
            defer allocator.free(log);
            glGetProgramInfoLog(program, len, &chars_written, log.ptr);
            print("program info log: ");
            printLine(log);
        }
    }

    pub fn getUniformLocation(self: Shader, name: [*]const u8) !c_int {
        const id = glGetUniformLocation(self.program, name);
        if (id == -1)
            return error.GlUniformNotFound;
        return id;
    }
};