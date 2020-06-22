const QuadTransform = @import("quad_transform.zig").QuadTransform;
usingnamespace @import("../c.zig");

pub const Quad = packed struct {
    transform: QuadTransform,
    layer: u8,
    character: u8,
};
