const Shader = @import("shader.zig").Shader;
const ShaderSource = @import("shader.zig").ShaderSource;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const MapBuffer = @import("../map_buffer.zig").MapBuffer;
usingnamespace @import("../c.zig");
usingnamespace @import("../print.zig");

pub const QuadShader = struct {
    shader: Shader,
    vertex_array_object: GLuint,
    vertex_buffer_objects: [5]GLuint,
    window_height_location: GLint,
    resolution_multi_location: GLint,
    draw_command_data: MapBuffer(DrawArraysIndirectCommand, 256),

    pub fn init(window_width: c_int, window_height: c_int) !QuadShader {
        var qs = QuadShader{
            .shader = try Shader.init([_]ShaderSource{
                .{
                    .shader_type = GL_VERTEX_SHADER,
                    .source = "shaders/vertex.glsl",
                },
                .{
                    .shader_type = GL_FRAGMENT_SHADER,
                    .source = "shaders/fragment.glsl",
                },
            }),
            .vertex_array_object = undefined,
            .vertex_buffer_objects = undefined,
            .window_height_location = undefined,
            .resolution_multi_location = undefined,
            .draw_command_data = undefined,
        };

        glUseProgram(qs.shader.program);
        glCreateVertexArrays(1, &qs.vertex_array_object);
        glCreateBuffers(5, &qs.vertex_buffer_objects);

        try qs.setUniforms(window_width, window_height);

        try qs.draw_command_data.init(qs.vertex_buffer_objects[0], GL_DRAW_INDIRECT_BUFFER);

        return qs;
    }

    pub fn setUniforms(self: *QuadShader, window_width: c_int, window_height: c_int) !void {
        const p = self.shader.program;
        self.window_height_location = try self.shader.getUniformLocation("window_height");
        self.resolution_multi_location = try self.shader.getUniformLocation("res_multi");
        const h = @intToFloat(f32, window_height);
        const w = @intToFloat(f32, window_width);
        glProgramUniform1f(p, self.window_height_location, h);
        glProgramUniform2f(p, self.resolution_multi_location, (1.0 / w) * 2.0, (1.0 / h) * 2.0);
    }
};
