const UserInterface = @import("../user_interface.zig").UserInterface;
const Vertex = @import("vertex.zig").Vertex;
const Point = @import("point.zig").Point;
const Colour = @import("colour.zig").Colour;
const ColourReference = @import("colour_reference.zig").ColourReference;
const utils = @import("../utils.zig");

pub const Rectangle = struct {
    const Self = @This();

    pub const Transform = struct {
        position: Point,
        width: u32,
        height: u32,
        layer: u16,
    };

    vertices: []Vertex,
    layer: *u16,

    pub inline fn init(self: *Self, ui: *UserInterface) void {
        self.vertices = ui.allocVertices(6);
        self.layer = ui.allocLayer();
    }

    pub inline fn clone(self: *Self, other: Rectangle) void {
        self.vertices[0].x = other.vertices[0].x;
        self.vertices[0].y = other.vertices[0].y;
        self.vertices[0].colour_reference = other.vertices[0].colour_reference;
        self.vertices[0].material = other.vertices[0].material;
        self.vertices[1].x = other.vertices[1].x;
        self.vertices[1].y = other.vertices[1].y;
        self.vertices[1].colour_reference = other.vertices[1].colour_reference;
        self.vertices[1].material = other.vertices[1].material;
        self.vertices[2].x = other.vertices[2].x;
        self.vertices[2].y = other.vertices[2].y;
        self.vertices[2].colour_reference = other.vertices[2].colour_reference;
        self.vertices[2].material = other.vertices[2].material;
        self.vertices[3].x = other.vertices[3].x;
        self.vertices[3].y = other.vertices[3].y;
        self.vertices[3].colour_reference = other.vertices[3].colour_reference;
        self.vertices[3].material = other.vertices[3].material;
        self.vertices[4].x = other.vertices[4].x;
        self.vertices[4].y = other.vertices[4].y;
        self.vertices[4].colour_reference = other.vertices[4].colour_reference;
        self.vertices[4].material = other.vertices[4].material;
        self.vertices[5].x = other.vertices[5].x;
        self.vertices[5].y = other.vertices[5].y;
        self.vertices[5].colour_reference = other.vertices[5].colour_reference;
        self.vertices[5].material = other.vertices[5].material;
        self.layer.* = other.layer.*;
    }

    pub inline fn setTransform(self: *Self, transform: Transform) void {
        self.vertices[0].x = transform.position.x;
        self.vertices[0].y = transform.position.y;
        self.vertices[1].x = transform.position.x;
        self.vertices[1].y = transform.position.y + transform.height;
        self.vertices[2].x = transform.position.x + transform.width;
        self.vertices[2].y = transform.position.y + transform.height;
        self.vertices[3].x = transform.position.x + transform.width;
        self.vertices[3].y = transform.position.y;
        self.vertices[4].x = transform.position.x;
        self.vertices[4].y = transform.position.y;
        self.vertices[5].x = transform.position.x + transform.width;
        self.vertices[5].y = transform.position.y + transform.height;
        self.layer.* = transform.layer;
    }

    pub inline fn setLayer(self: *Self, layer: u16) void {
        self.layer.* = layer;
    }

    pub inline fn setSolidColour(self: *Self, c: ColourReference) void {
        self.vertices[0].colour_reference = c.value;
        self.vertices[1].colour_reference = c.value;
        self.vertices[2].colour_reference = c.value;
        self.vertices[3].colour_reference = c.value;
        self.vertices[4].colour_reference = c.value;
        self.vertices[5].colour_reference = c.value;
    }

    pub inline fn setVerticalGradient(
        self: *Self,
        top_c: ColourReference,
        bottom_c: ColourReference,
    ) void {
        self.vertices[0].colour_reference = top_c.value;
        self.vertices[1].colour_reference = bottom_c.value;
        self.vertices[2].colour_reference = bottom_c.value;
        self.vertices[3].colour_reference = top_c.value;
        self.vertices[4].colour_reference = top_c.value;
        self.vertices[5].colour_reference = bottom_c.value;
    }

    pub inline fn setCornerGradient(
        self: *Self,
        top_left_c: ColourReference,
        top_right_c: ColourReference,
        bottom_left_c: ColourReference,
        bottom_right_c: ColourReference,
    ) void {
        self.vertices[0].colour_reference = top_left_c.value;
        self.vertices[1].colour_reference = bottom_left_c.value;
        self.vertices[2].colour_reference = bottom_right_c.value;
        self.vertices[3].colour_reference = top_right_c.value;
        self.vertices[4].colour_reference = top_left_c.value;
        self.vertices[5].colour_reference = bottom_right_c.value;
    }

    pub inline fn setMaterial(self: *Self, material: u32) void {
        self.vertices[0].material = material;
        self.vertices[1].material = material;
        self.vertices[2].material = material;
        self.vertices[3].material = material;
        self.vertices[4].material = material;
        self.vertices[5].material = material;
    }

    pub inline fn translate(self: *Self, x: u32, y: u32) void {
        const width = self.vertices[2].x - self.vertices[0].x;
        const height = self.vertices[1].y - self.vertices[0].y;
        self.vertices[0].x = x;
        self.vertices[0].y = y;
        self.vertices[1].x = x;
        self.vertices[1].y = y + height;
        self.vertices[2].x = x + width;
        self.vertices[2].y = y + height;
        self.vertices[3].x = x + width;
        self.vertices[3].y = y;
        self.vertices[4].x = x;
        self.vertices[4].y = y;
        self.vertices[5].x = x + width;
        self.vertices[5].y = y + height;
    }

    pub inline fn translateX(self: *Self, x: u32) void {
        const offset: i32 = @intCast(i32, x) - @intCast(i32, self.vertices[0].x);
        utils.add(&self.vertices[0].x, offset);
        utils.add(&self.vertices[1].x, offset);
        utils.add(&self.vertices[2].x, offset);
        utils.add(&self.vertices[3].x, offset);
        utils.add(&self.vertices[4].x, offset);
        utils.add(&self.vertices[5].x, offset);
    }

    pub inline fn translateXBy(self: *Self, x: u32) void {
        self.vertices[0].x += x;
        self.vertices[1].x += x;
        self.vertices[2].x += x;
        self.vertices[3].x += x;
        self.vertices[4].x += x;
        self.vertices[5].x += x;
    }

    pub inline fn translateY(self: *Self, y: u32) void {
        const height = self.vertices[1].y - self.vertices[0].y;
        self.vertices[0].y = y;
        self.vertices[1].y = y + height;
        self.vertices[2].y = y + height;
        self.vertices[3].y = y;
        self.vertices[4].y = y;
        self.vertices[5].y = y + height;
    }

    pub inline fn resize(self: *Self, width: u32, height: u32) void {
        const x = self.vertices[0].x + width;
        const y = self.vertices[0].y + height;
        self.vertices[1].y = y;
        self.vertices[2].x = x;
        self.vertices[2].y = y;
        self.vertices[3].x = x;
        self.vertices[5].x = x;
        self.vertices[5].y = y;
    }

    pub inline fn setWidth(self: *Self, width: u32) void {
        const x = self.vertices[0].x + width;
        self.vertices[2].x = x;
        self.vertices[3].x = x;
        self.vertices[5].x = x;
    }

    pub inline fn setHeight(self: *Self, height: u32) void {
        const y = self.vertices[0].y + height;
        self.vertices[1].y = y;
        self.vertices[2].y = y;
        self.vertices[5].y = y;
    }

    pub inline fn originX(self: *Self) u32 {
        return self.vertices[0].x;
    }

    pub inline fn originY(self: *Self) u32 {
        return self.vertices[0].y;
    }

    pub inline fn contains(self: *Self, x: i32, y: i32) bool {
        return self.containsX(x) and self.containsY(y);
    }

    pub inline fn containsX(self: *Self, x: i32) bool {
        return x >= @intCast(i32, self.vertices[0].x) and x < @intCast(i32, self.vertices[2].x);
    }

    pub inline fn containsY(self: *Self, y: i32) bool {
        return y >= @intCast(i32, self.vertices[0].y) and y < @intCast(i32, self.vertices[1].y);
    }
};
