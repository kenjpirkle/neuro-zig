const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const ColourReference = @import("../gl/colour_reference.zig").ColourReference;
const Rectangle = @import("../gl/rectangle.zig").Rectangle;
const Colour = @import("../gl/colour.zig").Colour;
const Colours = @import("widget_colours.zig");
const WidgetIndex = @import("widget_index.zig");
const element = @import("../widget_components.zig").Window;
usingnamespace @import("../c.zig");

pub const Window = struct {
    const Self = @This();

    pub fn init(self: *Self, ui: *UserInterface) !void {
        element.Background.colour_reference.init(
            ui,
            Colours.Window.Background.Default,
        );
        element.Background.mesh.init(ui);
        element.Background.mesh.setTransform(.{
            .position = .{ .x = 0, .y = 0 },
            .width = ui.width,
            .height = ui.height,
            .layer = 1,
        });
        element.Background.mesh.setSolidColour(element.Background.colour_reference);
        element.Background.mesh.setMaterial(1);
    }

    pub fn onCursorPositionChanged(self: *Self, ui: *UserInterface) void {
        if (!ui.isMaximized()) {
            const x = ui.cursor_x;
            const y = ui.cursor_y;

            if (y >= 0) {
                if (y < 6) {
                    if (x >= 0 and x < 6) {
                        ui.widgetAt(WidgetIndex.BorderTopLeft).onCursorEnter(ui);
                    } else if (x < ui.width - 6) {
                        ui.widgetAt(WidgetIndex.BorderTop).onCursorEnter(ui);
                    } else if (x < ui.width) {
                        ui.widgetAt(WidgetIndex.BorderTopRight).onCursorEnter(ui);
                    }
                } else if (y < ui.height - 6) {
                    if (x >= 0 and x < 6) {
                        ui.widgetAt(WidgetIndex.BorderLeft).onCursorEnter(ui);
                    } else if (x >= ui.width - 6 and x < ui.width) {
                        ui.widgetAt(WidgetIndex.BorderRight).onCursorEnter(ui);
                    }
                } else if (y < ui.height) {
                    if (x >= 0 and x < 6) {
                        ui.widgetAt(WidgetIndex.BorderBottomLeft).onCursorEnter(ui);
                    } else if (x < ui.width - 6) {
                        ui.widgetAt(WidgetIndex.BorderBottom).onCursorEnter(ui);
                    } else if (x < ui.width) {
                        ui.widgetAt(WidgetIndex.BorderBottomRight).onCursorEnter(ui);
                    }
                }
            }
        }
    }

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {
        element.Background.mesh.resize(ui.width, ui.height);
    }
};

pub const BorderTopLeft = struct {
    const Self = @This();

    pub fn onCursorEnter(self: *Self, widget: *Widget, ui: *UserInterface) void {
        ui.widget_with_cursor = widget;

        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_RESIZE_NWSE_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.widget_with_cursor = null;
        ui.draw_required = true;
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        return ui.cursor_x >= 0 and ui.cursor_x < 6 and ui.cursor_y >= 0 and ui.cursor_y < 6;
    }
};

pub const BorderTop = struct {
    const Self = @This();

    pub fn onCursorEnter(self: *Self, widget: *Widget, ui: *UserInterface) void {
        ui.widget_with_cursor = widget;

        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_RESIZE_NS_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.widget_with_cursor = null;
        ui.draw_required = true;
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        return ui.cursor_x >= 6 and ui.cursor_x < ui.width - 6 and ui.cursor_y >= 0 and ui.cursor_y < 6;
    }
};

pub const BorderTopRight = struct {
    const Self = @This();

    pub fn onCursorEnter(self: *Self, widget: *Widget, ui: *UserInterface) void {
        ui.widget_with_cursor = widget;

        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_RESIZE_NESW_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.widget_with_cursor = null;
        ui.draw_required = true;
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        return ui.cursor_x >= ui.width - 6 and ui.cursor_x < ui.width and ui.cursor_y >= 0 and ui.cursor_y < 6;
    }
};

pub const BorderLeft = struct {
    const Self = @This();

    pub fn onCursorEnter(self: *Self, widget: *Widget, ui: *UserInterface) void {
        ui.widget_with_cursor = widget;

        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_HRESIZE_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.widget_with_cursor = null;
        ui.draw_required = true;
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        return ui.cursor_x >= 0 and ui.cursor_x < 6 and ui.cursor_y >= 6 and ui.cursor_y < ui.height - 6;
    }
};

pub const BorderRight = struct {
    const Self = @This();

    pub fn onCursorEnter(self: *Self, widget: *Widget, ui: *UserInterface) void {
        ui.widget_with_cursor = widget;

        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_HRESIZE_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.widget_with_cursor = null;
        ui.draw_required = true;
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        return ui.cursor_x >= ui.width - 6 and ui.cursor_x < ui.width and ui.cursor_y >= 6 and ui.cursor_y < ui.width - 6;
    }
};

pub const BorderBottomLeft = struct {
    const Self = @This();

    pub fn onCursorEnter(self: *Self, widget: *Widget, ui: *UserInterface) void {
        ui.widget_with_cursor = widget;

        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_RESIZE_NESW_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.widget_with_cursor = null;
        ui.draw_required = true;
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        return ui.cursor_x >= 0 and ui.cursor_x < 6 and ui.cursor_y >= ui.height - 6 and ui.cursor_y < ui.height;
    }
};

pub const BorderBottom = struct {
    const Self = @This();

    pub fn onCursorEnter(self: *Self, widget: *Widget, ui: *UserInterface) void {
        ui.widget_with_cursor = widget;

        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_RESIZE_NS_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.widget_with_cursor = null;
        ui.draw_required = true;
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        return ui.cursor_x >= 6 and ui.cursor_x < ui.width - 6 and ui.cursor_y >= ui.height - 6 and ui.cursor_y < ui.height;
    }
};

pub const BorderBottomRight = struct {
    const Self = @This();

    pub fn onCursorEnter(self: *Self, widget: *Widget, ui: *UserInterface) void {
        ui.widget_with_cursor = widget;

        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_RESIZE_NWSE_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);

        ui.widget_with_cursor = null;
        ui.draw_required = true;
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        return ui.cursor_x >= ui.width - 6 and ui.cursor_x < ui.width and ui.cursor_y >= ui.height - 6 and ui.cursor_y < ui.height;
    }
};
