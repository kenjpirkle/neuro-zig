const warn = @import("std").debug.warn;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const TitleBar = @import("title_bar.zig").TitleBar;
const Rectangle = @import("../gl/rectangle.zig").Rectangle;
const Quad = @import("../gl/quad.zig").Quad;
const Colour = @import("../gl/colour.zig").Colour;
const Colours = @import("widget_colours.zig").TitleBar.CloseButton;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const element = @import("../widget_components.zig").TitleBar.CloseButton;
usingnamespace @import("../c.zig");

pub const CloseButton = struct {
    const Self = @This();

    const icon_width: u16 = @divTrunc(TitleBar.button_width, 4);
    const icon_left: u16 = TitleBar.button_width - @divTrunc(TitleBar.button_width, 2) + @divTrunc(icon_width, 2);
    const icon_top: u16 = @divTrunc(TitleBar.titlebar_height, 2) - @divTrunc(icon_width, 2);

    parent: ?*Widget = null,

    pub fn init(self: *Self, ui: *UserInterface) !void {
        element.Body.colour_reference.init(ui, Colours.Body.Default);
        element.Body.mesh.init(ui);
        element.Body.mesh.setTransform(.{
            .position = .{
                .x = ui.width - TitleBar.button_width,
                .y = 0,
            },
            .width = TitleBar.button_width,
            .height = TitleBar.titlebar_height,
            .layer = 3,
        });
        element.Body.mesh.setSolidColour(element.Body.colour_reference);
        element.Body.mesh.setMaterial(0);

        element.Icon.colour_reference.init(ui, Colours.Icon.Default);
        element.Icon.Left.mesh.init(ui);
        const ic_left: u16 = ui.width - icon_left;
        element.Icon.Left.mesh.setTransform(.{
            .top_left = .{
                .x = ic_left,
                .y = icon_top,
            },
            .top_right = .{
                .x = ic_left + 1,
                .y = icon_top,
            },
            .bottom_left = .{
                .x = ic_left + icon_width,
                .y = icon_top + icon_width,
            },
            .bottom_right = .{
                .x = ic_left + icon_width + 1,
                .y = icon_top + icon_width,
            },
            .layer = 4,
        });
        element.Icon.Left.mesh.setSolidColour(element.Icon.colour_reference);
        element.Icon.Left.mesh.setMaterial(0);

        element.Icon.Right.mesh.init(ui);
        element.Icon.Right.mesh.setTransform(.{
            .top_left = .{
                .x = ic_left + icon_width,
                .y = icon_top,
            },
            .top_right = .{
                .x = ic_left + icon_width + 1,
                .y = icon_top,
            },
            .bottom_left = .{
                .x = ic_left,
                .y = icon_top + icon_width,
            },
            .bottom_right = .{
                .x = ic_left + 1,
                .y = icon_top + icon_width,
            },
            .layer = 4,
        });
        element.Icon.Right.mesh.setSolidColour(element.Icon.colour_reference);
        element.Icon.Right.mesh.setMaterial(0);
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
        glfwSetWindowShouldClose(ui.window, GLFW_TRUE);
        ui.widget_with_cursor = null;
        ui.input_handled = true;
    }

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {
        element.Body.mesh.translateX(ui.width - TitleBar.button_width);

        const ic_left: u16 = ui.width - icon_left;
        element.Icon.Left.mesh.translateX(ic_left);
        element.Icon.Right.mesh.translateX(ic_left + icon_width);
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        if (ui.isMaximized()) {
            return element.Body.mesh.contains(ui.cursor_x, ui.cursor_y);
        } else {
            return (ui.cursor_y >= 6 and ui.cursor_y < 29) and (ui.cursor_x >= element.Body.mesh.originX() and ui.cursor_x < ui.width - 6);
        }
    }
};
