const warn = @import("std").debug.warn;
const builtin = @import("std").builtin;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const TitleBar = @import("title_bar.zig").TitleBar;
const QuadTransform = @import("../gl/quad_transform.zig").QuadTransform;
const QuadColourIndices = @import("../gl/quad_colour_indices.zig").QuadColourIndices;
const Colour = @import("../gl/colour.zig").Colour;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const Index = @import("../buffer_indices.zig").TitleBar.MaximizeRestoreButton;
usingnamespace @import("../gl/quad.zig");

pub const MaximizeRestoreButton = struct {
    const Self = @This();

    const icon_width: u16 = @divTrunc(TitleBar.button_width, 4);

    parent: ?*Widget = null,

    pub fn insertIntoUi(self: *Self, ui: *UserInterface) !void {
        Index.Body.Quad = ui.quad_shader.quad_data.data.len;
        Index.Icon.Top.Quad = Index.Body.Quad + 1;
        Index.Icon.Left.Quad = Index.Icon.Top.Quad + 1;
        Index.Icon.Right.Quad = Index.Icon.Left.Quad + 1;
        Index.Icon.Bottom.Quad = Index.Icon.Right.Quad + 1;
        ui.quad_shader.quad_data.append(&[_]Quad{
            // body
            Quad.make(.{
                .x = ui.width - (TitleBar.button_width * 2),
                .y = 0,
                .width = TitleBar.button_width,
                .height = TitleBar.titlebar_height,
                .layer = 3,
                .character = 1,
            }),
            // icon
            // top
            Quad.make(.{
                .x = ui.width - (TitleBar.button_width * 2) + (@divTrunc(TitleBar.button_width, 2) - @divTrunc(icon_width, 2)),
                .y = @divTrunc(TitleBar.titlebar_height, 2) - @divTrunc(icon_width, 2),
                .width = icon_width,
                .height = 1,
                .layer = 4,
                .character = 1,
            }),
            // left
            Quad.make(.{
                .x = ui.width - (TitleBar.button_width * 2) + (@divTrunc(TitleBar.button_width, 2) - @divTrunc(icon_width, 2)),
                .y = @divTrunc(TitleBar.titlebar_height, 2) - @divTrunc(icon_width, 2) + 1,
                .width = 1,
                .height = icon_width - 2,
                .layer = 4,
                .character = 1,
            }),
            // right
            Quad.make(.{
                .x = ui.width - (TitleBar.button_width * 2) + @divTrunc(TitleBar.button_width, 2) + @divTrunc(icon_width, 2),
                .y = @divTrunc(TitleBar.titlebar_height, 2) - @divTrunc(icon_width, 2) + 1,
                .width = 1,
                .height = icon_width - 2,
                .layer = 4,
                .character = 1,
            }),
            // bottom
            Quad.make(.{
                .x = ui.width - (TitleBar.button_width * 2) + (@divTrunc(TitleBar.button_width, 2) - @divTrunc(icon_width, 2)),
                .y = @divTrunc(TitleBar.titlebar_height, 2) + @divTrunc(icon_width, 2),
                .width = icon_width,
                .height = 1,
                .layer = 4,
                .character = 1,
            }),
        });
        Index.Body.Colour = @intCast(u8, ui.quad_shader.colour_data.data.len);
        Index.Icon.Colour = Index.Body.Colour + 1;
        ui.quad_shader.colour_data.append(&[_]Colour{
            // body
            Colour.fromRgbaInt(120, 120, 120, 0),
            // icon
            // top
            Colour.fromRgbaInt(255, 255, 255, 125),
            // left
            Colour.fromRgbaInt(255, 255, 255, 125),
            // right
            Colour.fromRgbaInt(255, 255, 255, 125),
            // bottom
            Colour.fromRgbaInt(255, 255, 255, 125),
        });
        Index.Body.ColourIndices = ui.quad_shader.colour_index_data.data.len;
        Index.Icon.Top.ColourIndices = Index.Body.ColourIndices + 1;
        Index.Icon.Left.ColourIndices = Index.Icon.Top.ColourIndices + 1;
        Index.Icon.Right.ColourIndices = Index.Icon.Left.ColourIndices + 1;
        Index.Icon.Bottom.ColourIndices = Index.Icon.Right.ColourIndices + 1;
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            // body
            .{
                .top_left = Index.Body.Colour,
                .bottom_left = Index.Body.Colour,
                .top_right = Index.Body.Colour,
                .bottom_right = Index.Body.Colour,
            },
            // icon
            // top
            .{
                .top_left = Index.Icon.Colour,
                .bottom_left = Index.Icon.Colour,
                .top_right = Index.Icon.Colour,
                .bottom_right = Index.Icon.Colour,
            },
            // left
            .{
                .top_left = Index.Icon.Colour,
                .bottom_left = Index.Icon.Colour,
                .top_right = Index.Icon.Colour,
                .bottom_right = Index.Icon.Colour,
            },
            // right
            .{
                .top_left = Index.Icon.Colour,
                .bottom_left = Index.Icon.Colour,
                .top_right = Index.Icon.Colour,
                .bottom_right = Index.Icon.Colour,
            },
            // bottom
            .{
                .top_left = Index.Icon.Colour,
                .bottom_left = Index.Icon.Colour,
                .top_right = Index.Icon.Colour,
                .bottom_right = Index.Icon.Colour,
            },
        });
    }

    pub fn onCursorEnter(self: *Self, ui: *UserInterface) void {
        ui.colourAt(Index.Body.Colour).alpha = Colour.intVal(80);
        ui.widget_with_cursor = Widget.fromChild(self);
        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        ui.colourAt(Index.Body.Colour).alpha = Colour.intVal(0);
        ui.widget_with_cursor = null;
        ui.draw_required = true;
    }

    pub fn onLeftMouseDown(self: *Self) void {}

    pub fn onFocus(self: *Self) void {}

    pub fn onUnfocus(self: *Self) void {}

    pub fn onKeyEvent(self: *Self, widget: *Widget, ui: *UserInterface) void {}

    pub fn onCharacterEvent(self: *Self, widget: *Widget, ui: *UserInterface, codepoint: u32) void {}

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {}

    pub fn containsPoint(self: *Self, x: u16, y: u16) bool {
        return false;
    }
};