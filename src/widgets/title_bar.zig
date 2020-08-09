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
usingnamespace @import("../c.zig");
const Index = @import("../buffer_indices.zig").TitleBar;
const WidgetIndex = @import("widget_index.zig");

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
                ui.widgetAt(WidgetIndex.MinimizeButton).onCursorEnter(ui, ui.cursor_x, ui.cursor_y);
            } else if (ui.quadAt(Index.MaximizeRestoreButton.Body.Quad).containsX(ui.cursor_x)) {
                // cursor over MaximizeRestoreButton
                ui.widgetAt(WidgetIndex.MaximizeRestoreButton).onCursorEnter(ui, ui.cursor_x, ui.cursor_y);
            } else if (ui.quadAt(Index.CloseButton.Quad).containsX(ui.cursor_x)) {
                // cursor over CloseButton
            } else {
                // cursor over TitleBar body
                ui.widget_with_cursor = Widget.fromChild(self);
                ui.input_handled = true;
            }
        }
    }

    pub fn onCursorEnter(self: *Self, ui: *UserInterface, x: u16, y: u16) void {}

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {}

    pub fn onDrag(self: *Self, ui: *UserInterface, x: u16, y: u16) void {
        const cursor_delta_x: i32 = @intCast(i32, x) - @intCast(i32, self.cursor_x);
        const cursor_delta_y: i32 = @intCast(i32, y) - @intCast(i32, self.cursor_y);
        glfwSetWindowPos(ui.window, ui.window_position_x + cursor_delta_x, ui.window_position_y + cursor_delta_y);
    }

    pub fn onLeftMouseDown(self: *Self, widget: *Widget, ui: *UserInterface, x: u16, y: u16) void {
        if (builtin.mode == .Debug) {
            warn("left mouse button down on TitleBar\n", .{});
        }

        const minimize_quad = &ui.quad_shader.quad_data.data[Index.MinimizeButton.Body.Quad];
        const maximize_quad = &ui.quad_shader.quad_data.data[Index.MaximizeRestoreButton.Body.Quad];
        const close_quad = &ui.quad_shader.quad_data.data[Index.CloseButton.Quad];

        if (minimize_quad.containsX(x)) {
            glfwIconifyWindow(ui.window);
        } else if (maximize_quad.containsX(x)) {
            const is_maximized = glfwGetWindowAttrib(ui.window, GLFW_MAXIMIZED);
            if (is_maximized == 0) {
                glfwMaximizeWindow(ui.window);
            } else {
                glfwRestoreWindow(ui.window);
            }
        } else if (close_quad.containsX(x)) {
            glfwSetWindowShouldClose(ui.window, GLFW_TRUE);
        } else {
            ui.widget_with_mouse = widget;
            var xpos: f64 = undefined;
            var ypos: f64 = undefined;
            glfwGetCursorPos(ui.window, &xpos, &ypos);
            self.cursor_x = @floatToInt(u16, xpos);
            self.cursor_y = @floatToInt(u16, ypos);
        }
    }

    pub fn onLeftMouseUp(self: *Self, widget: *Widget, ui: *UserInterface, x: u16, y: u16) void {
        ui.widget_with_mouse = null;
    }

    pub fn onFocus(self: *Self, widget: *Widget, ui: *UserInterface) void {
        if (builtin.mode == .Debug) {
            warn("TitleBar focus\n", .{});
        }
    }

    pub fn onUnfocus(self: *Self, widget: *Widget, ui: *UserInterface) void {
        if (builtin.mode == .Debug) {
            warn("TitleBar unfocus\n", .{});
        }
    }

    pub fn onKeyEvent(self: *Self, widget: *Widget, ui: *UserInterface) void {}

    pub fn onCharacterEvent(self: *Self, widget: *Widget, ui: *UserInterface, codepoint: u32) void {}

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {}

    pub fn containsPoint(self: *Self, ui: *UserInterface, x: u16, y: u16) bool {
        return (y >= 0) and (y <= titlebar_height);
    }

    pub fn animate(self: *Self, widget: *Widget, ui: *UserInterface, time_delta: u64) void {}
};
