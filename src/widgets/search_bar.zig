const warn = @import("std").debug.warn;
const Widget = @import("widget.zig").Widget;
const BufferIndices = @import("../gl/buffer_indices.zig").BufferIndices;

pub const SearchBar = packed struct {
    const placeholder_text = "search...";
    const text_offset_x: u16 = 30;
    const text_offset_y: u16 = 44;

    parent: ?*Widget,
    elapsed_ms: u64 = 0,
    cursor_text_origin: u16 = text_offset_x,
    cursor_position: u8 = 0,
    search_string_length: u8 = 0,
    is_focused: bool = false,
    text_navigation_mode: bool = false,
    input_handled: bool = false,

    pub fn insertIntoUi(self: *SearchBar) void {}

    pub fn onCursorEnter(self: *SearchBar) void {
        warn("cursor entered the SearchBar\n", .{});
    }

    pub fn onCursorLeave(self: *SearchBar) void {
        warn("cursor left the SearchBar\n", .{});
    }

    pub fn onLeftMouseDown(self: *SearchBar) void {
        warn("left mouse button down on SearchBar\n", .{});
    }

    pub fn onFocus(self: *SearchBar) void {
        warn("SearchBar focus\n", .{});
    }

    pub fn onUnfocus(self: *SearchBar) void {
        warn("SearchBar unfocus\n", .{});
    }

    pub fn onWindowSizeChanged(self: *SearchBar, width: c_int, height: c_int) void {}

    pub fn containsPoint(self: *SearchBar, x: u16, y: u16) bool {
        return (x >= 20) and (x <= 940) and (y >= 20) and (y <= 20 + 34);
    }
};
