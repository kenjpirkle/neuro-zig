const UserInterface = @import("../user_interface.zig").UserInterface;
const Colour = @import("colour.zig").Colour;

pub const ColourReference = packed struct {
    const Self = @This();

    value: u32,
    reference: *Colour,

    pub inline fn init(self: *Self, ui: *UserInterface, colour: Colour) void {
        self.* = ui.allocColour();
        self.reference.* = colour;
    }

    pub inline fn set(self: *Self, colour: Colour) void {
        self.reference.* = colour;
    }

    pub inline fn setRgbInt(self: *Self, comptime red: u8, comptime green: u8, comptime blue: u8) void {
        self.reference.red = @intToFloat(f32, red) / 255.0;
        self.reference.green = @intToFloat(f32, green) / 255.0;
        self.reference.blue = @intToFloat(f32, blue) / 255.0;
    }

    pub inline fn setRgbaInt(self: *Self, comptime red: u8, comptime green: u8, comptime blue: u8, comptime alpha: u8) void {
        self.reference.red = @intToFloat(f32, red) / 255.0;
        self.reference.green = @intToFloat(f32, green) / 255.0;
        self.reference.blue = @intToFloat(f32, blue) / 255.0;
        self.reference.alpha = @intToFloat(f32, alpha) / 255.0;
    }
};
