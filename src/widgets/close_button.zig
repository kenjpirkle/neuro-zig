const warn = @import("std").debug.warn;
const builtin = @import("std").builtin;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const TitleBar = @import("title_bar.zig").TitleBar;
const Quad = @import("../gl/quad.zig").Quad;
const QuadTransform = @import("../gl/quad_transform.zig").QuadTransform;
const QuadColourIndices = @import("../gl/quad_colour_indices.zig").QuadColourIndices;
const Colour = @import("../gl/colour.zig").Colour;
const Colours = @import("widget_colours.zig");
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const Index = @import("../buffer_indices.zig").TitleBar.CloseButton;
usingnamespace @import("../c.zig");

pub const CloseButton = struct {
    const Self = @This();

    parent: ?*Widget = null,

    pub fn insertIntoUi(self: *Self, ui: *UserInterface) !void {
        Index.Quad = ui.quad_shader.quad_data.data.len;
        ui.quad_shader.quad_data.append(&[_]Quad{
            Quad.make(.{
                .x = ui.width - TitleBar.button_width,
                .y = 0,
                .width = TitleBar.button_width,
                .height = TitleBar.titlebar_height,
                .layer = 3,
                .character = 1,
            }),
        });
        Index.Colour = @intCast(u8, ui.quad_shader.colour_data.data.len);
        ui.quad_shader.colour_data.append(&[_]Colour{
            Colours.TitleBar.CloseButton.Body.Default,
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

    pub fn onCursorEnter(self: *Self, ui: *UserInterface) void {
        if (ui.mouse_state.button == GLFW_MOUSE_BUTTON_LEFT and ui.mouse_state.action == GLFW_PRESS) {
            ui.colourAt(Index.Colour).alpha = Colours.TitleBar.CloseButton.Body.Pressed.alpha;
        } else {
            ui.colourAt(Index.Colour).alpha = Colours.TitleBar.CloseButton.Body.Hover.alpha;
        }
        ui.widget_with_cursor = Widget.fromChild(self);
        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        ui.colourAt(Index.Colour).alpha = Colours.TitleBar.CloseButton.Body.Default.alpha;
        ui.widget_with_cursor = null;
        ui.draw_required = true;
    }

    pub fn onLeftMouseDown(self: *Self, ui: *UserInterface) void {
        ui.colourAt(Index.Colour).alpha = Colours.TitleBar.CloseButton.Body.Pressed.alpha;
        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onLeftMouseUp(self: *Self, ui: *UserInterface) void {
        ui.colourAt(Index.Colour).alpha = Colours.TitleBar.CloseButton.Body.Default.alpha;
        glfwSetWindowShouldClose(ui.window, GLFW_TRUE);
        ui.widget_with_cursor = null;
        ui.input_handled = true;
    }

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {
        ui.quadAt(Index.Quad).transform.x = ui.width - TitleBar.button_width;
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        return ui.quadAt(Index.Quad).contains(ui.cursor_x, ui.cursor_y);
    }
};
