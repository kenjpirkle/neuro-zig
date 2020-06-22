const Widget = @import("widget.zig").Widget;

pub const Rectangle = struct {
    parent: ?*Widget,

    pub fn onCursorEnter(self: Rectangle) void {}
    pub fn onCursorLeave(self: Rectangle) void {}
    pub fn onFocus(self: Rectangle) void {
        warn("Rectangle focus\n", .{});
    }
    pub fn onUnfocus(self: Rectangle) void {
        warn("Rectangle unfocus\n", .{});
    }
    pub fn onWindowSizeChanged(self: Rectangle, width: c_int, height: c_int) void {}
    pub fn containsPoint(self: Rectangle, x: u16, y: u16) bool {
        return false;
    }
};
