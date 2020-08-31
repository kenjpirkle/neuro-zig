const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const ColourReference = @import("../gl/colour_reference.zig").ColourReference;
const Rectangle = @import("../gl/rectangle.zig").Rectangle;
const Colour = @import("../gl/colour.zig").Colour;
const Colours = @import("widget_colours.zig");
const element = @import("../widget_components.zig").Window;

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

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {
        element.Background.mesh.resize(ui.width, ui.height);
    }
};
