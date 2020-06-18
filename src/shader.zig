const std = @import("std");
usingnamespace @import("c.zig");

const IdList = std.ArrayList(GLuint);

pub const ShaderSource = struct {
    shader_type: c_uint,
    source: []const u8,
};

pub const Shader = struct {
    program: GLuint,

    pub fn init(shaders: var) !Shader {
        var ids = IdList.init(std.heap.page_allocator);
        defer ids.deinit();
        const program = glCreateProgram();
        for (shaders) |shader| {
            const id = try ids.addOne();
            id.* = try loadShader(shader);
            glAttachShader(program, id.*);
        }

        glLinkProgram(program);

        for (ids.items) |id| {
            glDetachShader(program, id);
            glDeleteShader(id);
        }

        return Shader{ .program = program };
    }

    fn loadShader(shader_source: ShaderSource) !GLuint {
        const data = try std.fs.cwd().readFileAlloc(std.heap.page_allocator, shader_source.source, 1024 * 1024 * 1024);

        const shader_id = glCreateShader(shader_source.shader_type);
        glShaderSource(shader_id, 1, @ptrCast([*c]const [*c]const u8, &data), null);
        glCompileShader(shader_id);

        return shader_id;
    }
};
