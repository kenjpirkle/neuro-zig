const warn = @import("std").debug.warn;
const builtin = @import("std").builtin;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const Quad = @import("../gl/quad.zig").Quad;
const QuadTransform = @import("../gl/quad_transform.zig").QuadTransform;
const QuadColourIndices = @import("../gl/quad_colour_indices.zig").QuadColourIndices;
const Colour = @import("../gl/colour.zig").Colour;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const buffer_indices = @import("../buffer_indices.zig");
const Index = buffer_indices.Background;

pub const Background = struct {
    const Self = @This();

    parent: ?*Widget = null,

    pub fn insertIntoUi(self: *Self, ui: *UserInterface) !void {
        Index.Quad = ui.quad_shader.quad_data.data.len;
        ui.quad_shader.quad_data.append(&[_]Quad{
            Quad.make(.{
                .x = 0,
                .y = 0,
                .width = ui.width,
                .height = ui.height,
                .layer = 1,
                .character = 0,
            }),
        });
        Index.Colour = @intCast(u8, ui.quad_shader.colour_data.data.len);
        ui.quad_shader.colour_data.append(&[_]Colour{
            Colour.fromRgbaInt(40, 44, 52, 255),
        });
        Index.ColourIndices = ui.quad_shader.colour_index_data.data.len;
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = Index.Colour,
                .bottom_left = Index.Colour,
                .top_right = Index.Colour,
                .bottom_right = Index.Colour,
            },
        });
    }

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {
        const t = &ui.quadAt(Index.Quad).transform;
        t.width = ui.width;
        t.height = ui.height;
    }
};
