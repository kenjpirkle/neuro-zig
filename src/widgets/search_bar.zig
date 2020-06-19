const Widget = @import("widget.zig").Widget;

pub const SearchBar = struct {
    parent: ?*Widget,

    pub fn onCursorEnter(self: SearchBar) void {}
    pub fn onWindowSizeChanged(self: SearchBar, width: c_int, height: c_int) void {}
};
