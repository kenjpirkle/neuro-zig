const warn = @import("std").debug.warn;
const builtin = @import("std").builtin;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const BufferIndices = @import("../gl/buffer_indices.zig").BufferIndices;
const Quad = @import("../gl/quad.zig").Quad;
const QuadTransform = @import("../gl/quad_transform.zig").QuadTransform;
const QuadColourIndices = @import("../gl/quad_colour_indices.zig").QuadColourIndices;
const Colour = @import("../gl/colour.zig").Colour;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;

const Index = struct {
    pub const QuadId = 0;
    pub const ColourId = 0;
    pub const ColourIndicesId = 0;
};

pub const Rectangle = struct {
    parent: ?*Widget = null,

    pub fn insertIntoUi(self: *Rectangle, ui: *UserInterface()) !void {
        ui.quad_shader.quad_data.beginModify();
        ui.quad_shader.colour_data.beginModify();
        ui.quad_shader.colour_index_data.beginModify();

        ui.quad_shader.quad_data.append(&[_]Quad{
            .{
                .transform = .{
                    .x = 0,
                    .y = 0,
                    .width = ui.width,
                    .height = ui.height,
                },
                .layer = 1,
                .character = 0,
            },
        });
        ui.quad_shader.colour_data.append(&[_]Colour{
            .{
                .red = 40.0 / 255.0,
                .green = 44.0 / 255.0,
                .blue = 52.0 / 255.0,
                .alpha = 1.0,
            },
        });
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = 0,
                .bottom_left = 0,
                .top_right = 0,
                .bottom_right = 0,
            },
        });

        ui.quad_shader.quad_data.endModify();
        ui.quad_shader.colour_data.endModify();
        ui.quad_shader.colour_index_data.endModify();
    }

    pub fn onCursorEnter(self: *Rectangle) void {}

    pub fn onCursorLeave(self: *Rectangle) void {}

    pub fn onLeftMouseDown(self: *Rectangle) void {
        if (builtin.mode == .Debug) {
            warn("left mouse button down on Rectangle\n", .{});
        }
    }

    pub fn onFocus(self: *Rectangle) void {
        if (builtin.mode == .Debug) {
            warn("Rectangle focus\n", .{});
        }
    }

    pub fn onUnfocus(self: *Rectangle) void {
        if (builtin.mode == .Debug) {
            warn("Rectangle unfocus\n", .{});
        }
    }

    pub fn onWindowSizeChanged(self: *Rectangle, ui: *UserInterface()) void {
        const t = &ui.quad_shader.quad_data.data[Index.QuadId].transform;
        t.width = ui.width;
        t.height = ui.height;
    }

    pub fn containsPoint(self: *Rectangle, x: u16, y: u16) bool {
        return false;
    }
};
