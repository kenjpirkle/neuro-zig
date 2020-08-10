const QuadTransform = @import("quad_transform.zig").QuadTransform;
usingnamespace @import("../c.zig");

pub const QuadData = struct {
    x: u16,
    y: u16,
    width: u16,
    height: u16,
    layer: u8,
    character: u8,
};

pub const Quad = packed struct {
    const Self = @This();

    transform: QuadTransform,
    layer: u8,
    character: u8,

    pub inline fn make(data: QuadData) Quad {
        return .{
            .transform = .{
                .x = data.x,
                .y = data.y,
                .width = data.width,
                .height = data.height,
            },
            .layer = data.layer,
            .character = data.character,
        };
    }

    pub inline fn contains(self: *Self, x: i32, y: i32) bool {
        return self.containsX(x) and self.containsY(y);
    }

    pub inline fn containsX(self: *Self, x: i32) bool {
        return (x >= @as(i32, self.transform.x)) and (x < @as(i32, self.transform.x + self.transform.width));
    }

    pub inline fn containsY(self: *Self, y: i32) bool {
        return (y >= @as(i32, self.transform.y)) and (y < @as(i32, self.transform.y + self.transform.height));
    }
};
