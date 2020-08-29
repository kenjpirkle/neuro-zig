const warn = @import("std").debug.warn;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const TitleBar = @import("title_bar.zig").TitleBar;
const Rectangle = @import("../gl/rectangle.zig").Rectangle;
const Colour = @import("../gl/colour.zig").Colour;
const Colours = @import("widget_colours.zig").TitleBar.MinimizeButton;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const element = @import("../widget_components.zig").TitleBar.MinimizeButton;
usingnamespace @import("../c.zig");

pub const MinimizeButton = struct {
    const Self = @This();

    const icon_width: u16 = @divTrunc(TitleBar.button_width, 4);
    const icon_left: u16 = (TitleBar.button_width * 3) - (@divTrunc(TitleBar.button_width, 2) - @divTrunc(icon_width, 2));

    parent: ?*Widget = null,

    pub fn init(self: *Self, ui: *UserInterface) !void {
        element.Body.colour_reference.init(
            ui,
            Colours.Body.Default,
        );
        element.Body.mesh.init(ui);
        element.Body.mesh.setTransform(.{
            .position = .{
                .x = ui.width - (TitleBar.button_width * 3),
                .y = 0,
            },
            .width = TitleBar.button_width,
            .height = TitleBar.titlebar_height,
            .layer = 3,
        });
        element.Body.mesh.setSolidColour(element.Body.colour_reference);
        element.Body.mesh.setMaterial(0);

        element.Icon.colour_reference.init(
            ui,
            Colours.Icon.Default,
        );
        element.Icon.mesh.init(ui);
        element.Icon.mesh.setTransform(.{
            .position = .{
                .x = ui.width - icon_left,
                .y = @divTrunc(TitleBar.titlebar_height, 2),
            },
            .width = icon_width,
            .height = 1,
            .layer = 4,
        });
        element.Icon.mesh.setSolidColour(element.Icon.colour_reference);
        element.Icon.mesh.setMaterial(0);
    }

    pub fn onCursorEnter(self: *Self, ui: *UserInterface) void {
        if (ui.mouse_state.button == GLFW_MOUSE_BUTTON_LEFT and ui.mouse_state.action == GLFW_PRESS) {
            element.Body.colour_reference.reference.alpha = Colours.Body.Pressed.alpha;
            element.Icon.colour_reference.reference.alpha = Colours.Icon.Pressed.alpha;
        } else {
            element.Body.colour_reference.reference.alpha = Colours.Body.Hover.alpha;
            element.Icon.colour_reference.reference.alpha = Colours.Icon.Hover.alpha;
        }
        ui.widget_with_cursor = Widget.fromChild(self);
        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        element.Body.colour_reference.reference.alpha = Colours.Body.Default.alpha;
        element.Icon.colour_reference.reference.alpha = Colours.Icon.Default.alpha;
        ui.widget_with_cursor = null;
        ui.draw_required = true;
    }

    pub fn onLeftMouseDown(self: *Self, ui: *UserInterface) void {
        element.Body.colour_reference.reference.alpha = Colours.Body.Pressed.alpha;
        element.Icon.colour_reference.reference.alpha = Colours.Icon.Pressed.alpha;
        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onLeftMouseUp(self: *Self, ui: *UserInterface) void {
        element.Body.colour_reference.reference.alpha = Colours.Body.Default.alpha;
        element.Icon.colour_reference.reference.alpha = Colours.Icon.Default.alpha;
        glfwIconifyWindow(ui.window);
        ui.widget_with_cursor = null;
        ui.input_handled = true;
    }

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {
        element.Body.mesh.translateX(ui.width - (TitleBar.button_width * 3));
        element.Icon.mesh.translateX(ui.width - icon_left);
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        return element.Body.mesh.contains(ui.cursor_x, ui.cursor_y);
    }
};
