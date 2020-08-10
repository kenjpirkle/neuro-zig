const std = @import("std");
const math = std.math;
const warn = std.debug.warn;
const builtin = std.builtin;
const mem = std.mem;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const MinimizeButton = @import("minimize_button.zig").MinimizeButton;
const MaximizeRestoreButton = @import("maximize_restore_button.zig").MaximizeRestoreButton;
const Quad = @import("../gl/quad.zig").Quad;
const QuadTransform = @import("../gl/quad_transform.zig").QuadTransform;
const QuadColourIndices = @import("../gl/quad_colour_indices.zig").QuadColourIndices;
const Colour = @import("../gl/colour.zig").Colour;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const Index = @import("../buffer_indices.zig").TitleBar;
const WidgetIndex = @import("widget_index.zig");
usingnamespace @import("../c.zig");

pub const TitleBar = packed struct {
    const Self = @This();

    pub const titlebar_height: u16 = 29;
    pub const button_width: u16 = 46;

    elapsed_ns: u64 = 0,
    cursor_x: u16 = 0,
    cursor_y: u16 = 0,

    pub fn insertIntoUi(self: *Self, ui: *UserInterface) !void {
        Index.MainRect.Quad = ui.quad_shader.quad_data.data.len;
        ui.quad_shader.quad_data.append(&[_]Quad{
            Quad.make(.{
                .x = 0,
                .y = 0,
                .width = ui.width - (button_width * 3),
                .height = titlebar_height,
                .layer = 2,
                .character = 1,
            }),
        });
        Index.MainRect.Colour = @intCast(u8, ui.quad_shader.colour_data.data.len);
        ui.quad_shader.colour_data.append(&[_]Colour{
            Colour.fromRgbaInt(255, 255, 255, 0),
        });
        Index.MainRect.ColourIndices = ui.quad_shader.colour_index_data.data.len;
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = Index.MainRect.Colour,
                .bottom_left = Index.MainRect.Colour,
                .top_right = Index.MainRect.Colour,
                .bottom_right = Index.MainRect.Colour,
            },
        });
    }

    pub fn onCursorPositionChanged(self: *Self, ui: *UserInterface) void {
        if (ui.quadAt(Index.MainRect.Quad).containsY(ui.cursor_y)) {
            if (ui.quadAt(Index.MinimizeButton.Body.Quad).containsX(ui.cursor_x)) {
                // cursor in MinimizeButton
                ui.widgetAt(WidgetIndex.MinimizeButton).onCursorEnter(ui);
            } else if (ui.quadAt(Index.MaximizeRestoreButton.Body.Quad).containsX(ui.cursor_x)) {
                // cursor over MaximizeRestoreButton
                ui.widgetAt(WidgetIndex.MaximizeRestoreButton).onCursorEnter(ui);
            } else if (ui.quadAt(Index.CloseButton.Quad).containsX(ui.cursor_x)) {
                // cursor over CloseButton
                ui.widgetAt(WidgetIndex.CloseButton).onCursorEnter(ui);
            } else {
                // cursor over TitleBar body
                ui.widget_with_cursor = Widget.fromChild(self);
                ui.input_handled = true;
            }
        }
    }

    pub fn onDrag(self: *Self, ui: *UserInterface) void {
        const cursor_delta_x: i32 = ui.cursor_x - @intCast(i32, self.cursor_x);
        const cursor_delta_y: i32 = ui.cursor_y - @intCast(i32, self.cursor_y);
        glfwSetWindowPos(ui.window, ui.window_position_x + cursor_delta_x, ui.window_position_y + cursor_delta_y);
        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onLeftMouseDown(self: *Self, widget: *Widget, ui: *UserInterface) void {
        ui.widget_with_mouse = widget;
        var xpos: f64 = undefined;
        var ypos: f64 = undefined;
        glfwGetCursorPos(ui.window, &xpos, &ypos);
        self.cursor_x = @floatToInt(u16, xpos);
        self.cursor_y = @floatToInt(u16, ypos);
    }

    pub fn onLeftMouseUp(self: *Self, ui: *UserInterface) void {
        ui.widget_with_mouse = null;
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        return ui.quadAt(Index.MainRect.Quad).containsY(ui.cursor_y);
    }
};
