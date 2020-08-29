const UserInterface = @import("../user_interface.zig").UserInterface;
const Vertex = @import("vertex.zig").Vertex;
const ColourReference = @import("colour_reference.zig").ColourReference;
const Point = @import("point.zig").Point;
const warn = @import("std").debug.warn;
const utils = @import("../utils.zig");

pub const Quad = struct {
    const Self = @This();

    pub const Transform = struct {
        top_left: Point,
        top_right: Point,
        bottom_left: Point,
        bottom_right: Point,
        layer: u16,
    };

    vertices: []Vertex,
    layer: *u16,

    pub inline fn init(self: *Self, ui: *UserInterface) void {
        self.vertices = ui.allocVertices(6);
        self.layer = ui.allocLayer();
    }

    pub inline fn clone(self: *Self, other: Quad) void {
        self.vertices[0].x = other.vertices[0].x;
        self.vertices[0].y = other.vertices[0].y;
        self.vertices[0].colour_index = other.vertices[0].colour_index;
        self.vertices[0].material = other.vertices[0].material;
        self.vertices[1].x = other.vertices[1].x;
        self.vertices[1].y = other.vertices[1].y;
        self.vertices[1].colour_index = other.vertices[1].colour_index;
        self.vertices[1].material = other.vertices[1].material;
        self.vertices[2].x = other.vertices[2].x;
        self.vertices[2].y = other.vertices[2].y;
        self.vertices[2].colour_index = other.vertices[2].colour_index;
        self.vertices[2].material = other.vertices[2].material;
        self.vertices[3].x = other.vertices[3].x;
        self.vertices[3].y = other.vertices[3].y;
        self.vertices[3].colour_index = other.vertices[3].colour_index;
        self.vertices[3].material = other.vertices[3].material;
        self.vertices[4].x = other.vertices[4].x;
        self.vertices[4].y = other.vertices[4].y;
        self.vertices[4].colour_index = other.vertices[4].colour_index;
        self.vertices[4].material = other.vertices[4].material;
        self.vertices[5].x = other.vertices[5].x;
        self.vertices[5].y = other.vertices[5].y;
        self.vertices[5].colour_index = other.vertices[5].colour_index;
        self.vertices[5].material = other.vertices[5].material;
        self.layer.* = other.layer.*;
    }

    pub inline fn setTransform(self: *Self, transform: Transform) void {
        self.vertices[0].x = transform.top_left.x;
        self.vertices[0].y = transform.top_left.y;
        self.vertices[1].x = transform.bottom_left.x;
        self.vertices[1].y = transform.bottom_left.y;
        self.vertices[2].x = transform.bottom_right.x;
        self.vertices[2].y = transform.bottom_right.y;
        self.vertices[3].x = transform.top_right.x;
        self.vertices[3].y = transform.top_right.y;
        self.vertices[4].x = transform.top_left.x;
        self.vertices[4].y = transform.top_left.y;
        self.vertices[5].x = transform.bottom_right.x;
        self.vertices[5].y = transform.bottom_right.y;
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

    pub inline fn setMaterial(self: *Self, material: u32) void {
        self.vertices[0].material = material;
        self.vertices[1].material = material;
        self.vertices[2].material = material;
        self.vertices[3].material = material;
        self.vertices[4].material = material;
        self.vertices[5].material = material;
    }

    pub inline fn translate(self: *Self, x: u32, y: u32) void {
        const x_offset: i32 = @intCast(i32, x) - @intCast(i32, self.vertices[0].x);
        const y_offset: i32 = @intCast(i32, y) - @intCast(i32, self.vertices[0].y);
        utils.add(&self.vertices[0].x, x_offset);
        utils.add(&self.vertices[0].y, y_offset);
        utils.add(&self.vertices[1].x, x_offset);
        utils.add(&self.vertices[1].y, y_offset);
        utils.add(&self.vertices[2].x, x_offset);
        utils.add(&self.vertices[2].y, y_offset);
        utils.add(&self.vertices[3].x, x_offset);
        utils.add(&self.vertices[3].y, y_offset);
        utils.add(&self.vertices[4].x, x_offset);
        utils.add(&self.vertices[4].y, y_offset);
        utils.add(&self.vertices[5].x, x_offset);
        utils.add(&self.vertices[5].y, y_offset);
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
        const offset: i32 = @intCast(i32, y) - @intCast(i32, self.vertices[0].y);
        utils.add(&self.vertices[0].y, offset);
        utils.add(&self.vertices[1].y, offset);
        utils.add(&self.vertices[2].y, offset);
        utils.add(&self.vertices[3].y, offset);
        utils.add(&self.vertices[4].y, offset);
        utils.add(&self.vertices[5].y, offset);
    }

    pub inline fn resize(self: *Self, x: u32, y: u32) void {
        self.vertices[1].y = y;
        self.vertices[2].x = x;
        self.vertices[2].y = y;
        self.vertices[3].x = x;
        self.vertices[5].x = x;
        self.vertices[5].y = y;
    }

    pub inline fn resizeX(self: *Self, x: u32) void {
        self.vertices[2].x = x;
        self.vertices[3].x = x;
        self.vertices[5].x = x;
    }

    pub inline fn resizeY(self: *Self, y: u32) void {
        self.vertices[1].y = y;
        self.vertices[2].y = y;
        self.vertices[5].y = y;
    }
};
