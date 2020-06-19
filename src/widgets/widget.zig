const rect = @import("rectangle.zig");
const sb = @import("search_bar.zig");

const WidgetTag = packed enum {
    Rectangle,
    SearchBar,
};

pub const Widget = union(WidgetTag) {
    Rectangle: rect.Rectangle,
    SearchBar: sb.SearchBar,

    pub fn onCursorEnter(self: Widget) void {
        switch (self) {
            WidgetTag.Rectangle => |*r| r.onCursorEnter(),
            WidgetTag.SearchBar => |*s| s.onCursorEnter(),
            else => unreachable,
        }
    }

    pub inline fn onWindowSizeChanged(self: Widget, width: c_int, height: c_int) void {
        switch (self) {
            WidgetTag.Rectangle => |*r| r.onWindowSizeChanged(width, height),
            WidgetTag.SearchBar => |*s| s.onWindowSizeChanged(width, height),
            else => unreachable,
        }
    }
};
