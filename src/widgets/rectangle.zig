const warn = @import("std").debug.warn;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const BufferIndices = @import("../gl/buffer_indices.zig").BufferIndices;

pub const Rectangle = struct {
    parent: ?*Widget = null,

    pub fn insertIntoUi(self: *Rectangle, ui: *UserInterface()) !void {}

    pub fn onCursorEnter(self: *Rectangle) void {}

    pub fn onCursorLeave(self: *Rectangle) void {}

    pub fn onLeftMouseDown(self: *Rectangle) void {
        warn("left mouse button down on Rectangle\n", .{});
    }

    pub fn onFocus(self: *Rectangle) void {
        warn("Rectangle focus\n", .{});
    }

    pub fn onUnfocus(self: *Rectangle) void {
        warn("Rectangle unfocus\n", .{});
    }

    pub fn onWindowSizeChanged(self: *Rectangle, width: c_int, height: c_int) void {}

    pub fn containsPoint(self: *Rectangle, x: u16, y: u16) bool {
        return false;
    }
};
