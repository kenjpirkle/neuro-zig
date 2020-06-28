const UserInterface = @import("../user_interface.zig").UserInterface;
const Rectangle = @import("rectangle.zig").Rectangle;
const SearchBar = @import("search_bar.zig").SearchBar;

const WidgetTag = packed enum {
    Rectangle,
    SearchBar,
};

pub const Widget = union(WidgetTag) {
    Rectangle: Rectangle,
    SearchBar: SearchBar,

    pub fn insertIntoUi(self: *Widget, ui: *UserInterface()) !void {
        try switch (self.*) {
            .Rectangle => |*r| r.insertIntoUi(ui),
            .SearchBar => |*s| s.insertIntoUi(ui),
            else => unreachable,
        };
    }

    pub fn onCursorEnter(self: *Widget, ui: *UserInterface()) void {
        switch (self.*) {
            .Rectangle => |*r| r.onCursorEnter(),
            .SearchBar => |*s| s.onCursorEnter(ui),
            else => unreachable,
        }
    }

    pub fn onCursorLeave(self: *Widget, ui: *UserInterface()) void {
        switch (self.*) {
            .Rectangle => |*r| r.onCursorLeave(),
            .SearchBar => |*s| s.onCursorLeave(ui),
            else => unreachable,
        }
    }

    pub fn onFocus(self: *Widget) void {
        switch (self.*) {
            .Rectangle => |*r| r.onFocus(),
            .SearchBar => |*s| s.onFocus(),
            else => unreachable,
        }
    }

    pub fn onUnfocus(self: *Widget) void {
        switch (self.*) {
            .Rectangle => |*r| r.onUnfocus(),
            .SearchBar => |*s| s.onUnfocus(),
            else => unreachable,
        }
    }

    pub fn onLeftMouseDown(self: *Widget) void {
        switch (self.*) {
            .Rectangle => |*r| r.onLeftMouseDown(),
            .SearchBar => |*s| s.onLeftMouseDown(),
            else => unreachable,
        }
    }

    pub inline fn onWindowSizeChanged(self: *Widget, ui: *UserInterface()) void {
        switch (self.*) {
            .Rectangle => |*r| r.onWindowSizeChanged(ui),
            .SearchBar => |*s| s.onWindowSizeChanged(ui),
            else => unreachable,
        }
    }

    pub inline fn containsPoint(self: *Widget, ui: *UserInterface(), x: u16, y: u16) bool {
        switch (self.*) {
            .Rectangle => |*r| return r.containsPoint(x, y),
            .SearchBar => |*s| return s.containsPoint(ui, x, y),
            else => unreachable,
        }
    }
};
