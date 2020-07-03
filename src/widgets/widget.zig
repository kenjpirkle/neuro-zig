const UserInterface = @import("../user_interface.zig").UserInterface;
const Rectangle = @import("rectangle.zig").Rectangle;
const SearchBar = @import("search_bar.zig").SearchBar;

pub const WidgetTag = enum {
    Rectangle,
    SearchBar,
};

pub const Widget = union(WidgetTag) {
    Rectangle: Rectangle,
    SearchBar: SearchBar,

    pub fn insertIntoUi(self: *Widget, ui: *UserInterface) !void {
        try switch (self.*) {
            .Rectangle => |*r| r.insertIntoUi(ui),
            .SearchBar => |*s| s.insertIntoUi(ui),
            else => unreachable,
        };
    }

    pub fn onCursorEnter(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Rectangle => |*r| r.onCursorEnter(),
            .SearchBar => |*s| s.onCursorEnter(ui),
            else => unreachable,
        }
    }

    pub fn onCursorLeave(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Rectangle => |*r| r.onCursorLeave(),
            .SearchBar => |*s| s.onCursorLeave(ui),
            else => unreachable,
        }
    }

    pub fn onKeyEvent(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Rectangle => |*r| r.onKeyEvent(self, ui),
            .SearchBar => |*s| s.onKeyEvent(self, ui),
            else => unreachable,
        }
    }

    pub fn onCharacterEvent(self: *Widget, ui: *UserInterface, codepoint: u32) void {
        switch (self.*) {
            .Rectangle => |*r| r.onCharacterEvent(self, ui, codepoint),
            .SearchBar => |*s| s.onCharacterEvent(self, ui, codepoint),
            else => unreachable,
        }
    }

    pub fn onFocus(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Rectangle => |*r| r.onFocus(),
            .SearchBar => |*s| s.onFocus(self, ui),
            else => unreachable,
        }
    }

    pub fn onUnfocus(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Rectangle => |*r| r.onUnfocus(),
            .SearchBar => |*s| s.onUnfocus(self, ui),
            else => unreachable,
        }
    }

    pub fn onLeftMouseDown(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Rectangle => |*r| r.onLeftMouseDown(),
            .SearchBar => |*s| s.onLeftMouseDown(self, ui),
            else => unreachable,
        }
    }

    pub inline fn onWindowSizeChanged(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Rectangle => |*r| r.onWindowSizeChanged(ui),
            .SearchBar => |*s| s.onWindowSizeChanged(ui),
            else => unreachable,
        }
    }

    pub inline fn containsPoint(self: *Widget, ui: *UserInterface, x: u16, y: u16) bool {
        switch (self.*) {
            .Rectangle => |*r| return r.containsPoint(x, y),
            .SearchBar => |*s| return s.containsPoint(ui, x, y),
            else => unreachable,
        }
    }

    pub inline fn animate(self: *Widget, ui: *UserInterface, time_delta: u64) void {
        switch (self.*) {
            .Rectangle => unreachable,
            .SearchBar => |*s| s.animate(self, ui, time_delta),
            else => unreachable,
        }
    }
};
