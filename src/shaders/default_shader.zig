const std = @import("std");
const warn = std.debug.warn;
const Shader = @import("shader.zig").Shader;
const ShaderSource = @import("shader.zig").ShaderSource;
const vertex = @import("../gl/vertex.zig");
const Colour = @import("../gl/colour.zig").Colour;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const Font = @import("../font/font.zig").Font;
const MapBuffer = @import("../map_buffer.zig").MapBuffer;
usingnamespace @import("../c.zig");

const BufferType = struct {
    pub const VertexBuffer: c_uint = 0;
    pub const LayerBuffer: c_uint = 1;
    pub const ColourBuffer: c_uint = 2;
    pub const DrawCommandBuffer: c_uint = 3;
    pub const TextureHandleBuffer: c_uint = 4;
};

const ShaderLocation = struct {
    pub const Layer: c_uint = 0;
};

pub const DefaultShader = struct {
    const Self = @This();
    const shaders = [_]ShaderSource{
        .{
            .shader_type = GL_VERTEX_SHADER,
            .source = "shaders/default_vertex.glsl",
        },
        .{
            .shader_type = GL_FRAGMENT_SHADER,
            .source = "shaders/default_fragment.glsl",
        },
    };
    const num_buffers = 5;

    shader: Shader,
    vertex_array_object: GLuint,
    vertex_buffer_objects: [num_buffers]GLuint,
    window_height_location: GLint,
    resolution_multi_location: GLint,
    font_tex_transforms_location: GLint,
    font: Font(128, 15),
    vertex_data: MapBuffer(vertex.Vertex, 2048),
    layer_data: MapBuffer(u16, 1024),
    colour_data: MapBuffer(Colour, 256),
    draw_command_data: MapBuffer(DrawArraysIndirectCommand, 64),
    texture_handle_data: MapBuffer(GLuint64, 2),

    pub fn init(self: *Self, window_width: c_int, window_height: c_int) !void {
        self.shader = try Shader.init(shaders[0..]);

        glUseProgram(self.shader.program);
        glCreateVertexArrays(1, &self.vertex_array_object);
        glBindVertexArray(self.vertex_array_object);
        glCreateBuffers(num_buffers, &self.vertex_buffer_objects[0]);

        self.vertex_data.init(self.vertex_buffer_objects[BufferType.VertexBuffer], GL_SHADER_STORAGE_BUFFER);
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, self.vertex_buffer_objects[BufferType.VertexBuffer]);

        // Layer
        self.layer_data.init(self.vertex_buffer_objects[BufferType.LayerBuffer], GL_ARRAY_BUFFER);
        glVertexAttribPointer(ShaderLocation.Layer, 1, GL_UNSIGNED_SHORT, GL_TRUE, @sizeOf(u16), @intToPtr(?*GLvoid, 0));
        glVertexAttribDivisor(ShaderLocation.Layer, 1);
        glEnableVertexAttribArray(ShaderLocation.Layer);

        // Colour
        self.colour_data.init(self.vertex_buffer_objects[BufferType.ColourBuffer], GL_SHADER_STORAGE_BUFFER);
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, self.vertex_buffer_objects[BufferType.ColourBuffer]);

        // Draw Command
        self.draw_command_data.init(self.vertex_buffer_objects[BufferType.DrawCommandBuffer], GL_DRAW_INDIRECT_BUFFER);

        // Texture Handle
        self.texture_handle_data.init(self.vertex_buffer_objects[BufferType.TextureHandleBuffer], GL_UNIFORM_BUFFER);
        glBindBufferBase(GL_UNIFORM_BUFFER, 0, self.vertex_buffer_objects[BufferType.TextureHandleBuffer]);

        try self.font.init(std.heap.c_allocator, "fonts/Noto_Sans_JP/NotoSansJP-Light.otf");

        self.texture_handle_data.beginModify();
        const h = self.font.createTexture();
        var texture_handle = [_]GLuint64{h};
        self.texture_handle_data.append(&texture_handle);
        try self.setUniforms(window_width, window_height);
        self.texture_handle_data.endModify();
    }

    pub fn deinit(self: *Self) void {
        self.font.deinit();
    }

    pub fn updateWindowSize(self: *Self, window_width: u16, window_height: u16) void {
        const h = @intToFloat(f32, window_height);
        const w = @intToFloat(f32, window_width);
        glProgramUniform1f(self.shader.program, self.window_height_location, h);
        glProgramUniform2f(self.shader.program, self.resolution_multi_location, (1.0 / w) * 2.0, (1.0 / h) * 2.0);
    }

    pub inline fn beginModify(self: *Self) void {
        self.vertex_data.beginModify();
        self.layer_data.beginModify();
        self.colour_data.beginModify();
        self.draw_command_data.beginModify();
        self.texture_handle_data.beginModify();
    }

    pub inline fn endModify(self: *Self) void {
        self.vertex_data.endModify();
        self.layer_data.endModify();
        self.colour_data.endModify();
        self.draw_command_data.endModify();
        self.texture_handle_data.endModify();
    }

    pub fn setUniforms(self: *Self, window_width: c_int, window_height: c_int) !void {
        const p = self.shader.program;
        self.window_height_location = try self.shader.getUniformLocation("window_height");
        self.resolution_multi_location = try self.shader.getUniformLocation("res_multi");
        self.font_tex_transforms_location = try self.shader.getUniformLocation("font_tex_coords");
        const h = @intToFloat(f32, window_height);
        const w = @intToFloat(f32, window_width);
        glProgramUniform1f(p, self.window_height_location, h);
        glProgramUniform2f(p, self.resolution_multi_location, (1.0 / w) * 2.0, (1.0 / h) * 2.0);
        const t_ptr = @ptrCast([*]f32, @alignCast(@alignOf([*]f32), &self.font.texture_transforms[0]));
        glProgramUniform4fv(p, self.font_tex_transforms_location, self.font.glyphs.len, t_ptr);
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
