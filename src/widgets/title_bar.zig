const std = @import("std");
const math = std.math;
const warn = std.debug.warn;
const builtin = std.builtin;
const mem = std.mem;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const MinimizeButton = @import("minimize_button.zig").MinimizeButton;
const MaximizeRestoreButton = @import("maximize_restore_button.zig").MaximizeRestoreButton;
const Rectangle = @import("../gl/rectangle.zig").Rectangle;
const Colour = @import("../gl/colour.zig").Colour;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const element = @import("../widget_components.zig").TitleBar;
const WidgetIndex = @import("widget_index.zig");
usingnamespace @import("../c.zig");

pub const TitleBar = packed struct {
    const Self = @This();

    pub const titlebar_height: u16 = 29;
    pub const button_width: u16 = 46;

    elapsed_ns: u64 = 0,
    cursor_x: u16 = 0,
    cursor_y: u16 = 0,

    pub fn init(self: *Self, ui: *UserInterface) !void {
        element.MainRect.colour_reference.init(
            ui,
            Colour.fromRgbaInt(255, 255, 255, 0),
        );

        element.MainRect.mesh.init(ui);
        element.MainRect.mesh.setTransform(.{
            .position = .{ .x = 0, .y = 0 },
            .width = ui.width - (button_width * 3),
            .height = titlebar_height,
            .layer = 2,
        });
        element.MainRect.mesh.setSolidColour(element.MainRect.colour_reference);
        element.MainRect.mesh.setMaterial(0);
    }

    pub fn onCursorPositionChanged(self: *Self, ui: *UserInterface) void {
        const curx = ui.cursor_x;

        if (ui.isMaximized()) {
            if (ui.cursor_y >= 0 and ui.cursor_y < titlebar_height and curx >= 0) {
                if (curx < element.MinimizeButton.Body.mesh.originX()) {
                    ui.widget_with_cursor = Widget.fromChild(self);
                    ui.input_handled = true;
                } else if (curx < element.MaximizeRestoreButton.Body.mesh.originX()) {
                    ui.widgetAt(WidgetIndex.MinimizeButton).onCursorEnter(ui);
                } else if (curx < element.CloseButton.Body.mesh.originX()) {
                    ui.widgetAt(WidgetIndex.MaximizeRestoreButton).onCursorEnter(ui);
                } else if (curx < ui.width) {
                    ui.widgetAt(WidgetIndex.CloseButton).onCursorEnter(ui);
                }
            }
        } else {
            if (ui.cursor_y >= 4 and ui.cursor_y < titlebar_height and curx >= 4) {
                if (curx < element.MinimizeButton.Body.mesh.originX()) {
                    ui.widget_with_cursor = Widget.fromChild(self);
                    ui.input_handled = true;
                } else if (curx < element.MaximizeRestoreButton.Body.mesh.originX()) {
                    ui.widgetAt(WidgetIndex.MinimizeButton).onCursorEnter(ui);
                } else if (curx < element.CloseButton.Body.mesh.originX()) {
                    ui.widgetAt(WidgetIndex.MaximizeRestoreButton).onCursorEnter(ui);
                } else if (curx < ui.width - 4) {
                    ui.widgetAt(WidgetIndex.CloseButton).onCursorEnter(ui);
                }
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

    pub fn onLeftMouseDown(self: *Self, ui: *UserInterface) void {
        ui.widget_with_mouse = Widget.fromChild(self);
        var xpos: f64 = undefined;
        var ypos: f64 = undefined;
        glfwGetCursorPos(ui.window, &xpos, &ypos);
        self.cursor_x = @floatToInt(u16, xpos);
        self.cursor_y = @floatToInt(u16, ypos);
    }

    pub fn onLeftMouseUp(self: *Self, ui: *UserInterface) void {
        ui.widget_with_mouse = null;
    }

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {
        element.MainRect.mesh.setWidth(ui.width - (button_width * 3));
        ui.widgetAt(WidgetIndex.MinimizeButton).onWindowSizeChanged(ui);
        ui.widgetAt(WidgetIndex.MaximizeRestoreButton).onWindowSizeChanged(ui);
        ui.widgetAt(WidgetIndex.CloseButton).onWindowSizeChanged(ui);
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        return element.MainRect.mesh.contains(ui.cursor_x, ui.cursor_y);
    }
};
