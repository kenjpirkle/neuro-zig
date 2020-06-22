const warn = @import("std").debug.warn;
const Widget = @import("widget.zig").Widget;

pub const SearchBar = struct {
    parent: ?*Widget,

    pub fn onCursorEnter(self: SearchBar) void {
        warn("cursor entered the SearchBar\n", .{});
    }
    pub fn onCursorLeave(self: SearchBar) void {
        warn("cursor left the SearchBar\n", .{});
    }
    pub fn onFocus(self: SearchBar) void {
        warn("SearchBar focus\n", .{});
    }
    pub fn onUnfocus(self: SearchBar) void {
        warn("SearchBar unfocus\n", .{});
    }
    pub fn onWindowSizeChanged(self: SearchBar, width: c_int, height: c_int) void {}
    pub fn containsPoint(self: SearchBar, x: u16, y: u16) bool {
        return (x >= 20) and (x <= 940) and (y >= 20) and (y <= 20 + 34);
    }
};
