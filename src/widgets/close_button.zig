const warn = @import("std").debug.warn;
const builtin = @import("std").builtin;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const TitleBar = @import("title_bar.zig").TitleBar;
const Quad = @import("../gl/quad.zig").Quad;
const QuadTransform = @import("../gl/quad_transform.zig").QuadTransform;
const QuadColourIndices = @import("../gl/quad_colour_indices.zig").QuadColourIndices;
const Colour = @import("../gl/colour.zig").Colour;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const Index = @import("../buffer_indices.zig").TitleBar.CloseButton;

pub const CloseButton = struct {
    const Self = @This();

    parent: ?*Widget = null,

    pub fn insertIntoUi(self: *Self, ui: *UserInterface) !void {
        Index.Quad = ui.quad_shader.quad_data.data.len;
        ui.quad_shader.quad_data.append(&[_]Quad{
            .{
                .transform = .{
                    .x = ui.width - TitleBar.button_width,
                    .y = 0,
                    .width = TitleBar.button_width,
                    .height = TitleBar.titlebar_height,
                },
                .layer = 3,
                .character = 1,
            },
        });
        Index.Colour = @intCast(u8, ui.quad_shader.colour_data.data.len);
        ui.quad_shader.colour_data.append(&[_]Colour{
            .{
                .red = 1.0,
                .green = 0.0,
                .blue = 0.0,
                .alpha = 1.0,
            },
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

    pub fn onCursorEnter(self: *Self) void {}

    pub fn onCursorLeave(self: *Self) void {}

    pub fn onLeftMouseDown(self: *Self) void {}

    pub fn onFocus(self: *Self) void {}

    pub fn onUnfocus(self: *Self) void {}

    pub fn onKeyEvent(self: *Self, widget: *Widget, ui: *UserInterface) void {}

    pub fn onCharacterEvent(self: *Self, widget: *Widget, ui: *UserInterface, codepoint: u32) void {}

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {
        // const t = &ui.quad_shader.quad_data.data[Index.QuadId].transform;
        // t.width = ui.width;
        // t.height = ui.height;
    }

    pub fn containsPoint(self: *Self, x: u16, y: u16) bool {
        return false;
    }
};
