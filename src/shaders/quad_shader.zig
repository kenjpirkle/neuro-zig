const std = @import("std");
const Shader = @import("shader.zig").Shader;
const ShaderSource = @import("shader.zig").ShaderSource;
const Quad = @import("../gl/quad.zig").Quad;
const QuadColourIndices = @import("../gl/quad_colour_indices.zig").QuadColourIndices;
const Colour = @import("../gl/colour.zig").Colour;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const Font = @import("../font/font.zig").Font;
const MapBuffer = @import("../map_buffer.zig").MapBuffer;
usingnamespace @import("../c.zig");

const BufferType = packed enum(u8) {
    Quad,
    ColourIndex,
    Colour,
    DrawCommand,
    TextureHandle,
};

const ShaderLocation = packed enum(u8) {
    Transform,
    Layer,
    Character,
    ColourIndex,
};

pub const QuadShader = struct {
    const Self = @This();

    shader: Shader,
    vertex_array_object: GLuint = undefined,
    vertex_buffer_objects: [5]GLuint = undefined,
    window_height_location: GLint = undefined,
    resolution_multi_location: GLint = undefined,
    texture_transforms_location: GLint = undefined,
    font: Font(128, 16) = undefined,
    quad_data: MapBuffer(Quad, 4096) = undefined,
    colour_index_data: MapBuffer(QuadColourIndices, 4096) = undefined,
    colour_data: MapBuffer(Colour, 128) = undefined,
    draw_command_data: MapBuffer(DrawArraysIndirectCommand, 64) = undefined,
    texture_handle_data: MapBuffer(GLuint64, 128) = undefined,

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
        };

        glUseProgram(qs.shader.program);
        glCreateVertexArrays(1, &qs.vertex_array_object);
        glCreateBuffers(5, &qs.vertex_buffer_objects);

        try qs.setUniforms(window_width, window_height);

        qs.quad_data.init(qs.vertex_buffer_objects[@enumToInt(BufferType.Quad)], GL_ARRAY_BUFFER);
        setAttribute(Quad, ShaderLocation.Transform, 4, GL_UNSIGNED_SHORT, false, "transform", 1);
        setAttribute(Quad, ShaderLocation.Layer, 1, GL_UNSIGNED_BYTE, true, "layer", 1);
        setIntAttribute(Quad, ShaderLocation.Character, 1, GL_UNSIGNED_BYTE, "character", 1);

        qs.colour_index_data.init(qs.vertex_buffer_objects[@enumToInt(BufferType.ColourIndex)], GL_ARRAY_BUFFER);
        setIntAttribute(QuadColourIndices, ShaderLocation.ColourIndex, 4, GL_UNSIGNED_BYTE, "top_left", 1);

        qs.colour_data.init(qs.vertex_buffer_objects[@enumToInt(BufferType.Colour)], GL_SHADER_STORAGE_BUFFER);
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, qs.vertex_buffer_objects[@enumToInt(BufferType.Colour)]);

        qs.draw_command_data.init(qs.vertex_buffer_objects[@enumToInt(BufferType.DrawCommand)], GL_DRAW_INDIRECT_BUFFER);

        qs.texture_handle_data.init(qs.vertex_buffer_objects[@enumToInt(BufferType.TextureHandle)], GL_UNIFORM_BUFFER);
        glBindBufferBase(GL_UNIFORM_BUFFER, 0, qs.vertex_buffer_objects[@enumToInt(BufferType.TextureHandle)]);

        try qs.font.init(std.heap.c_allocator, "fonts/Lato/Lato-Regular.ttf");

        qs.texture_handle_data.beginModify();

        var texture_handle = qs.font.createTexture();
        qs.texture_handle_data.append(@ptrCast([*]GLuint64, &texture_handle)[0..1]);

        qs.texture_handle_data.endModify();

        return qs;
    }

    pub fn deinit(self: *Self) void {
        self.font.deinit();
    }

    pub fn setUniforms(self: *QuadShader, window_width: c_int, window_height: c_int) !void {
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
