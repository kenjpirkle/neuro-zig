usingnamespace @import("../c.zig");

pub const Colour = packed struct {
    const Self = @This();

    red: f32,
    green: f32,
    blue: f32,
    alpha: f32,

    pub inline fn intVal(value: u8) f32 {
        return @intToFloat(f32, value) / 255.0;
    }

    pub inline fn fromRgbaInt(comptime red: u8, comptime green: u8, comptime blue: u8, comptime alpha: u8) Colour {
        return .{
            .red = @intToFloat(f32, red) / 255.0,
            .green = @intToFloat(f32, green) / 255.0,
            .blue = @intToFloat(f32, blue) / 255.0,
            .alpha = @intToFloat(f32, alpha) / 255.0,
        };
    }

    pub inline fn setRgbInt(self: *Self, comptime red: u8, comptime green: u8, comptime blue: u8) void {
        self.red = @intToFloat(f32, red) / 255.0;
        self.green = @intToFloat(f32, green) / 255.0;
        self.blue = @intToFloat(f32, blue) / 255.0;
    }

    pub inline fn setRgbaInt(self: *Self, comptime red: u8, comptime green: u8, comptime blue: u8, comptime alpha: u8) void {
        self.red = @intToFloat(f32, red) / 255.0;
        self.green = @intToFloat(f32, green) / 255.0;
        self.blue = @intToFloat(f32, blue) / 255.0;
        self.alpha = @intToFloat(f32, alpha) / 255.0;
    }

    pub fn setRgb(self: *Self, comptime red: f32, comptime green: f32, comptime blue: f32) void {
        self.red = comptime {
            red / 255.0;
        };
        self.green = comptime {
            green / 255.0;
        };
        self.blue = comptime {
            blue / 255.0;
        };
    }
};
