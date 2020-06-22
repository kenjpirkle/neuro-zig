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

    pub fn onCursorLeave(self: Widget) void {
        switch (self) {
            WidgetTag.Rectangle => |*r| r.onCursorLeave(),
            WidgetTag.SearchBar => |*s| s.onCursorLeave(),
            else => unreachable,
        }
    }

    pub fn onFocus(self: Widget) void {
        switch (self) {
            WidgetTag.Rectangle => |*r| r.onFocus(),
            WidgetTag.Rectangle => |*r| r.onFocus(),
            else => unreachable,
        }
    }

    pub fn onUnfocus(self: Widget) void {
        switch (self) {
            WidgetTag.Rectangle => |*r| r.onUnfocus(),
            WidgetTag.Rectangle => |*r| r.onUnfocus(),
            else => unreachable,
        }
    }

    pub fn onLeftMouseDown(self: Widget) void {
        switch (self) {
            WidgetTag.Rectangle => |*r| r.onLeftMouseDown(),
            WidgetTag.SearchBar => |*s| s.onLeftMouseDown(),
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

    pub inline fn containsPoint(self: Widget, x: u16, y: u16) bool {
        switch (self) {
            WidgetTag.Rectangle => |*r| return r.containsPoint(x, y),
            WidgetTag.SearchBar => |*s| return s.containsPoint(x, y),
            else => unreachable,
        }
    }
};
