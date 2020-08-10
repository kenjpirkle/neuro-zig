const warn = @import("std").debug.warn;
const builtin = @import("std").builtin;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const TitleBar = @import("title_bar.zig").TitleBar;
const QuadTransform = @import("../gl/quad_transform.zig").QuadTransform;
const QuadColourIndices = @import("../gl/quad_colour_indices.zig").QuadColourIndices;
const Colour = @import("../gl/colour.zig").Colour;
const Colours = @import("widget_colours.zig");
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const Index = @import("../buffer_indices.zig").TitleBar.MinimizeButton;
usingnamespace @import("../gl/quad.zig");
usingnamespace @import("../c.zig");

pub const MinimizeButton = struct {
    const Self = @This();

    const icon_width: u16 = @divTrunc(TitleBar.button_width, 4);

    parent: ?*Widget = null,

    pub fn insertIntoUi(self: *Self, ui: *UserInterface) !void {
        Index.Body.Quad = ui.quad_shader.quad_data.data.len;
        Index.Icon.Quad = Index.Body.Quad + 1;
        ui.quad_shader.quad_data.append(&[_]Quad{
            // body
            Quad.make(.{
                .x = ui.width - (TitleBar.button_width * 3),
                .y = 0,
                .width = TitleBar.button_width,
                .height = TitleBar.titlebar_height,
                .layer = 3,
                .character = 1,
            }),
            // icon
            Quad.make(.{
                .x = ui.width - (TitleBar.button_width * 3) + (@divTrunc(TitleBar.button_width, 2) - @divTrunc(icon_width, 2)),
                .y = @divTrunc(TitleBar.titlebar_height, 2),
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
            Colours.TitleBar.MinimizeButton.Body.Default,
            // icon
            Colours.TitleBar.MinimizeButton.Icon.Default,
        });
        Index.Body.ColourIndices = ui.quad_shader.colour_index_data.data.len;
        Index.Icon.ColourIndices = Index.Body.ColourIndices + 1;
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            // body
            .{
                .top_left = Index.Body.Colour,
                .bottom_left = Index.Body.Colour,
                .top_right = Index.Body.Colour,
                .bottom_right = Index.Body.Colour,
            },
            // icon
            .{
                .top_left = Index.Icon.Colour,
                .bottom_left = Index.Icon.Colour,
                .top_right = Index.Icon.Colour,
                .bottom_right = Index.Icon.Colour,
            },
        });
    }

    pub fn onCursorEnter(self: *Self, ui: *UserInterface) void {
        if (ui.mouse_state.button == GLFW_MOUSE_BUTTON_LEFT and ui.mouse_state.action == GLFW_PRESS) {
            ui.colourAt(Index.Body.Colour).alpha = Colours.TitleBar.MinimizeButton.Body.Pressed.alpha;
            ui.colourAt(Index.Icon.Colour).alpha = Colours.TitleBar.MinimizeButton.Icon.Pressed.alpha;
        } else {
            ui.colourAt(Index.Body.Colour).alpha = Colours.TitleBar.MinimizeButton.Body.Hover.alpha;
            ui.colourAt(Index.Icon.Colour).alpha = Colours.TitleBar.MinimizeButton.Icon.Hover.alpha;
        }
        ui.widget_with_cursor = Widget.fromChild(self);
        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        ui.colourAt(Index.Body.Colour).alpha = Colours.TitleBar.MinimizeButton.Body.Default.alpha;
        ui.colourAt(Index.Icon.Colour).alpha = Colours.TitleBar.MinimizeButton.Icon.Default.alpha;
        ui.widget_with_cursor = null;
        ui.draw_required = true;
    }

    pub fn onLeftMouseDown(self: *Self, ui: *UserInterface) void {
        ui.colourAt(Index.Body.Colour).alpha = Colours.TitleBar.MinimizeButton.Body.Pressed.alpha;
        ui.colourAt(Index.Icon.Colour).alpha = Colours.TitleBar.MinimizeButton.Icon.Pressed.alpha;
        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onLeftMouseUp(self: *Self, ui: *UserInterface) void {
        ui.colourAt(Index.Body.Colour).alpha = Colours.TitleBar.MinimizeButton.Body.Default.alpha;
        ui.colourAt(Index.Icon.Colour).alpha = Colours.TitleBar.MinimizeButton.Icon.Default.alpha;
        glfwIconifyWindow(ui.window);
        ui.widget_with_cursor = null;
        ui.input_handled = true;
    }

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {
        ui.quadAt(Index.Body.Quad).transform.x = ui.width - (TitleBar.button_width * 3);
        ui.quadAt(Index.Icon.Quad).transform.x = ui.width - (TitleBar.button_width * 3) + (@divTrunc(TitleBar.button_width, 2) - @divTrunc(icon_width, 2));
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        return ui.quadAt(Index.Body.Quad).contains(ui.cursor_x, ui.cursor_y);
    }
};
