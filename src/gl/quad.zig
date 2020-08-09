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

    pub inline fn contains(self: *Self, x: u16, y: u16) bool {
        return (x >= self.transform.x) and (x <= self.transform.x + self.transform.width) and (y >= self.transform.y) and (y <= self.transform.y + self.transform.height);
    }

    pub inline fn containsX(self: *Self, x: u16) bool {
        return (x >= self.transform.x) and (x <= self.transform.x + self.transform.width);
    }

    pub inline fn containsY(self: *Self, y: u16) bool {
        return (y >= self.transform.y) and (y <= self.transform.y + self.transform.height);
    }
};
