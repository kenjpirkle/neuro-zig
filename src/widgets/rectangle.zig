const Widget = @import("widget.zig").Widget;

pub const Rectangle = struct {
    parent: ?*Widget,

    pub fn onCursorEnter(self: Rectangle) void {}
    pub fn onWindowSizeChanged(self: Rectangle, width: c_int, height: c_int) void {}
};
