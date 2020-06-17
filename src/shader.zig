const std = @import("std");
usingnamespace @import("c.zig");
const Allocator = std.mem.Allocator;

const ShaderList = std.ArrayList(ShaderSource);
const IdList = std.ArrayList(GLuint);

const ShaderType = enum {
    Vertex,
    Fragment,
};

const ShaderSource = struct {
    type: ShaderType,
    source: []const u8,
};

pub const Shader = struct {
    pub fn init(shaders: ShaderList) Shader {
        var ids = IdList.init(allocator);
        defer ids.deinit();
        const program = glCreateProgram();
        for (shaders.toSlice()) |shader| {
            const new_id = ids.addOne();
        }
        return Shader {

        };
    }

    pub fn loadShader(file: []const u8, shader_type: GLenum) !GLuint {
        std.debug.warn("path: {}\n", .{file});
        const data = try std.fs.cwd().readFileAlloc(
            std.heap.page_allocator,
            file,
            std.math.maxInt(u64)
        );

        const shader_id = glCreateShader(shader_type);
        glShaderSource(shader_id, 1, @ptrCast([*c]const [*c]const u8, &data), null);
        glCompileShader(shader_id);

        return shader_id;
    }
};