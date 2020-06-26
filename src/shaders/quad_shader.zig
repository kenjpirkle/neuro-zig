const std = @import("std");
const warn = std.debug.warn;
const Shader = @import("shader.zig").Shader;
const ShaderSource = @import("shader.zig").ShaderSource;
const Quad = @import("../gl/quad.zig").Quad;
const QuadTransform = @import("../gl/quad_transform.zig").QuadTransform;
const QuadColourIndices = @import("../gl/quad_colour_indices.zig").QuadColourIndices;
const Colour = @import("../gl/colour.zig").Colour;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const Font = @import("../font/font.zig").Font;
const MapBuffer = @import("../map_buffer.zig").MapBuffer;
usingnamespace @import("../c.zig");

const BufferType = struct {
    pub const QuadBuffer: c_uint = 0;
    pub const ColourIndexBuffer: c_uint = 1;
    pub const ColourBuffer: c_uint = 2;
    pub const DrawCommandBuffer: c_uint = 3;
    pub const TextureHandleBuffer: c_uint = 4;
};

const ShaderLocation = struct {
    pub const Transform: c_uint = 0;
    pub const Layer: c_uint = 1;
    pub const Character: c_uint = 2;
    pub const ColourIndex: c_uint = 3;
};

pub fn QuadShader(comptime buffer_sizes: var) type {
    return struct {
        const Self = @This();

        shader: Shader = undefined,
        vertex_array_object: GLuint = undefined,
        vertex_buffer_objects: [4]GLuint = undefined,
        window_height_location: GLint = undefined,
        resolution_multi_location: GLint = undefined,
        texture_transforms_location: GLint = undefined,
        font: Font(128, 16) = undefined,
        quad_data: MapBuffer(Quad, 1024) = undefined,
        draw_command_data: MapBuffer(DrawArraysIndirectCommand, 64) = undefined,
        colour_index_data: MapBuffer(QuadColourIndices, 1024) = undefined,
        colour_data: MapBuffer(Colour, 128) = undefined,
        //texture_handle_data: MapBuffer(GLuint64, 128) = undefined,

        pub fn init(self: *Self, window_width: c_int, window_height: c_int) !void {
            self.shader = try Shader.init([_]ShaderSource{
                .{
                    .shader_type = GL_VERTEX_SHADER,
                    .source = "shaders\\vertex.glsl",
                },
                .{
                    .shader_type = GL_FRAGMENT_SHADER,
                    .source = "shaders\\fragment.glsl",
                },
            });

            glUseProgram(self.shader.program);
            glCreateVertexArrays(1, &self.vertex_array_object);
            glBindVertexArray(self.vertex_array_object);
            glGenBuffers(4, &self.vertex_buffer_objects[0]);

            try self.setUniforms(window_width, window_height);

            self.quad_data.init(self.vertex_buffer_objects[BufferType.QuadBuffer], GL_ARRAY_BUFFER);

            // Transform
            glVertexAttribPointer(ShaderLocation.Transform, 4, GL_UNSIGNED_SHORT, GL_FALSE, @sizeOf(Quad), @intToPtr(?*GLvoid, @byteOffsetOf(Quad, "transform")));
            glVertexAttribDivisor(0, 1);
            glEnableVertexAttribArray(0);

            // Layer
            glVertexAttribPointer(ShaderLocation.Layer, 1, GL_UNSIGNED_BYTE, GL_TRUE, @sizeOf(Quad), @intToPtr(?*GLvoid, @byteOffsetOf(Quad, "layer")));
            glVertexAttribDivisor(1, 1);
            glEnableVertexAttribArray(1);

            // Character
            glVertexAttribIPointer(ShaderLocation.Character, 1, GL_UNSIGNED_BYTE, @sizeOf(Quad), @intToPtr(?*GLvoid, @byteOffsetOf(Quad, "character")));
            glVertexAttribDivisor(ShaderLocation.Character, 1);
            glEnableVertexAttribArray(ShaderLocation.Character);

            // Colour Indices
            self.colour_index_data.init(self.vertex_buffer_objects[BufferType.ColourIndexBuffer], GL_ARRAY_BUFFER);
            glVertexAttribIPointer(ShaderLocation.ColourIndex, 4, GL_UNSIGNED_BYTE, 0, null);
            glVertexAttribDivisor(ShaderLocation.ColourIndex, 1);
            glEnableVertexAttribArray(ShaderLocation.ColourIndex);

            self.colour_data.init(self.vertex_buffer_objects[BufferType.ColourBuffer], GL_SHADER_STORAGE_BUFFER);
            glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, self.vertex_buffer_objects[BufferType.ColourBuffer]);

            self.draw_command_data.init(self.vertex_buffer_objects[BufferType.DrawCommandBuffer], GL_DRAW_INDIRECT_BUFFER);

            // self.texture_handle_data.init(self.vertex_buffer_objects[@enumToInt(BufferType.TextureHandle)], GL_UNIFORM_BUFFER);
            // glBindBufferBase(GL_UNIFORM_BUFFER, 0, self.vertex_buffer_objects[@enumToInt(BufferType.TextureHandle)]);

            try self.font.init(std.heap.c_allocator, "fonts/Lato/Lato-Regular.ttf");

            // self.texture_handle_data.beginModify();

            // var texture_handle = self.font.createTexture();
            // self.texture_handle_data.append(@ptrCast([*]GLuint64, &texture_handle)[0..1]);

            // warn("buffered texture handle: {}\n", .{self.texture_handle_data.data[0]});

            // self.texture_handle_data.endModify();
        }

        pub fn deinit(self: *Self) void {
            self.font.deinit();
        }

        pub fn setUniforms(self: *Self, window_width: c_int, window_height: c_int) !void {
            const p = self.shader.program;
            self.window_height_location = try self.shader.getUniformLocation("window_height");
            self.resolution_multi_location = try self.shader.getUniformLocation("res_multi");
            self.texture_transforms_location = try self.shader.getUniformLocation("texture_transforms");
            const h = @intToFloat(f32, window_height);
            const w = @intToFloat(f32, window_width);
            glProgramUniform1f(p, self.window_height_location, h);
            glProgramUniform2f(p, self.resolution_multi_location, (1.0 / w) * 2.0, (1.0 / h) * 2.0);
        }

        inline fn setAttribute(comptime T: type, comptime shader_location: ShaderLocation, comptime count: GLint, comptime gl_type: GLenum, comptime normalized: bool, comptime field_name: []const u8, comptime divisor: usize) void {
            comptime const offset = @byteOffsetOf(T, field_name);
            comptime const p_offset = if (offset == 0) null else @intToPtr(*c_void, offset);
            glVertexAttribPointer(@enumToInt(shader_location), count, gl_type, @boolToInt(normalized), @sizeOf(T), p_offset);
            glVertexAttribDivisor(@enumToInt(shader_location), divisor);
            glEnableVertexAttribArray(@enumToInt(shader_location));
        }

        inline fn setIntAttribute(comptime T: type, comptime shader_location: ShaderLocation, comptime count: GLint, comptime gl_type: GLenum, comptime field_name: []const u8, comptime divisor: usize) void {
            comptime const offset = @byteOffsetOf(T, field_name);
            comptime const p_offset = if (offset == 0) null else @intToPtr(*c_void, offset);
            glVertexAttribIPointer(@enumToInt(shader_location), count, gl_type, @sizeOf(T), p_offset);
            glVertexAttribDivisor(@enumToInt(shader_location), divisor);
            glEnableVertexAttribArray(@enumToInt(shader_location));
        }
    };
}
