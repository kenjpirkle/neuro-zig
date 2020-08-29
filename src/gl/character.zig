const UserInterface = @import("../user_interface.zig").UserInterface;
const Vertex = @import("vertex.zig").Vertex;

pub const Character = struct {
    const Self = @This();

    pub const Transform = struct {
        x: u32,
        y: u32,
        width: u32,
        height: u32,
    };

    vertices: []Vertex,

    pub inline fn init(self: *Self, ui: *UserInterface) void {
        self.vertices = ui.allocVertices(6);
    }

    pub inline fn clone(self: *Self, other: Rectangle) void {
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
    }

    pub inline fn initFromRectSolid(self: *Self, rect: RectSolid) void {
        self.vertices[0].x = rect.x;
        self.vertices[0].y = rect.y;
        self.vertices[0].colour_index = rect.colour_index;
        self.vertices[0].material = rect.material;
        self.vertices[1].x = rect.x;
        self.vertices[1].y = rect.y + rect.height;
        self.vertices[1].colour_index = rect.colour_index;
        self.vertices[1].material = rect.material;
        self.vertices[2].x = rect.x + rect.width;
        self.vertices[2].y = rect.y + rect.height;
        self.vertices[2].colour_index = rect.colour_index;
        self.vertices[2].material = rect.material;
        self.vertices[3].x = rect.x + rect.width;
        self.vertices[3].y = rect.y;
        self.vertices[3].colour_index = rect.colour_index;
        self.vertices[3].material = rect.material;
        self.vertices[4].x = rect.x;
        self.vertices[4].y = rect.y;
        self.vertices[4].colour_index = rect.colour_index;
        self.vertices[4].material = rect.material;
        self.vertices[5].x = rect.x + rect.width;
        self.vertices[5].y = rect.y + rect.height;
        self.vertices[5].colour_index = rect.colour_index;
        self.vertices[5].material = rect.material;
    }

    pub inline fn initFromQuadSolid(self: *Self, quad: QuadSolid) void {
        self.vertices[0].x = quad.top_left[0];
        self.vertices[0].y = quad.top_left[1];
        self.vertices[0].colour_index = quad.colour_index;
        self.vertices[0].material = quad.material;
        self.vertices[1].x = quad.bottom_left[0];
        self.vertices[1].y = quad.bottom_left[1];
        self.vertices[1].colour_index = quad.colour_index;
        self.vertices[1].material = quad.material;
        self.vertices[2].x = quad.bottom_right[0];
        self.vertices[2].y = quad.bottom_right[1];
        self.vertices[2].colour_index = quad.colour_index;
        self.vertices[2].material = quad.material;
        self.vertices[3].x = quad.top_right[0];
        self.vertices[3].y = quad.top_right[1];
        self.vertices[3].colour_index = quad.colour_index;
        self.vertices[3].material = quad.material;
        self.vertices[4].x = quad.top_left[0];
        self.vertices[4].y = quad.top_left[1];
        self.vertices[4].colour_index = quad.colour_index;
        self.vertices[4].material = quad.material;
        self.vertices[5].x = quad.bottom_right[0];
        self.vertices[5].y = quad.bottom_right[1];
        self.vertices[5].colour_index = quad.colour_index;
        self.vertices[5].material = quad.material;
    }

    pub inline fn initFromRectVerticalGradient(self: *Self, rect: RectVerticalGradient) void {
        self.vertices[0].x = rect.x;
        self.vertices[0].y = rect.y;
        self.vertices[0].colour_index = rect.top_colour_index;
        self.vertices[0].material = rect.material;
        self.vertices[1].x = rect.x;
        self.vertices[1].y = rect.y + rect.height;
        self.vertices[1].colour_index = rect.bottom_colour_index;
        self.vertices[1].material = rect.material;
        self.vertices[2].x = rect.x + rect.width;
        self.vertices[2].y = rect.y + rect.height;
        self.vertices[2].colour_index = rect.bottom_colour_index;
        self.vertices[2].material = rect.material;
        self.vertices[3].x = rect.x + rect.width;
        self.vertices[3].y = rect.y;
        self.vertices[3].colour_index = rect.top_colour_index;
        self.vertices[3].material = rect.material;
        self.vertices[4].x = rect.x;
        self.vertices[4].y = rect.y;
        self.vertices[4].colour_index = rect.top_colour_index;
        self.vertices[4].material = rect.material;
        self.vertices[5].x = rect.x + rect.width;
        self.vertices[5].y = rect.y + rect.height;
        self.vertices[5].colour_index = rect.bottom_colour_index;
        self.vertices[5].material = rect.material;
    }

    pub inline fn initFromRectCornerGradient(self: *Self, rect: RectCornerGradient) void {
        self.vertices[0].x = rect.x;
        self.vertices[0].y = rect.y;
        self.vertices[0].colour_index = rect.top_left_colour_index;
        self.vertices[0].material = rect.material;
        self.vertices[1].x = rect.x;
        self.vertices[1].y = rect.y + rect.height;
        self.vertices[1].colour_index = rect.bottom_left_colour_index;
        self.vertices[1].material = rect.material;
        self.vertices[2].x = rect.x + rect.width;
        self.vertices[2].y = rect.y + rect.height;
        self.vertices[2].colour_index = rect.bottom_right_colour_index;
        self.vertices[2].material = rect.material;
        self.vertices[3].x = rect.x + rect.width;
        self.vertices[3].y = rect.y;
        self.vertices[3].colour_index = rect.top_right_colour_index;
        self.vertices[3].material = rect.material;
        self.vertices[4].x = rect.x;
        self.vertices[4].y = rect.y;
        self.vertices[4].colour_index = rect.top_left_colour_index;
        self.vertices[4].material = rect.material;
        self.vertices[5].x = rect.x + rect.width;
        self.vertices[5].y = rect.y + rect.height;
        self.vertices[5].colour_index = rect.bottom_right_colour_index;
        self.vertices[5].material = rect.material;
    }

    pub inline fn setTransform(self: *Self, transform: Transform) void {
        self.vertices[0].x = transform.x;
        self.vertices[0].y = transform.y;
        self.vertices[1].x = transform.x;
        self.vertices[1].y = transform.y + transform.height;
        self.vertices[2].x = transform.x + transform.width;
        self.vertices[2].y = transform.y + transform.height;
        self.vertices[3].x = transform.x + transform.width;
        self.vertices[3].y = transform.y;
        self.vertices[4].x = transform.x;
        self.vertices[4].y = transform.y;
        self.vertices[5].x = transform.x + transform.width;
        self.vertices[5].y = transform.y + transform.height;

        return self;
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
        const width = self.vertices[2].x - self.vertices[0].x;
        self.vertices[0].x = x;
        self.vertices[1].x = x;
        self.vertices[2].x = x + width;
        self.vertices[3].x = x + width;
        self.vertices[4].x = x;
        self.vertices[5].x = x + width;
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

    pub inline fn setMaterial(self: *Self, material: u32) void {
        self.vertices[0].material = material;
        self.vertices[1].material = material;
        self.vertices[2].material = material;
        self.vertices[3].material = material;
        self.vertices[4].material = material;
        self.vertices[5].material = material;
    }
};
