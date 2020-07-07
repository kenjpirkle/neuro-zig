const UserInterface = @import("../user_interface.zig").UserInterface;
const Rectangle = @import("rectangle.zig").Rectangle;
const TitleBar = @import("title_bar.zig").TitleBar;
const SearchBar = @import("search_bar.zig").SearchBar;

pub const WidgetTag = enum {
    Rectangle,
    TitleBar,
    SearchBar,
};

pub const Widget = union(WidgetTag) {
    Rectangle: Rectangle,
    TitleBar: TitleBar,
    SearchBar: SearchBar,

    pub fn insertIntoUi(self: *Widget, ui: *UserInterface) !void {
        try switch (self.*) {
            .Rectangle => |*r| r.insertIntoUi(ui),
            .TitleBar => |*t| t.insertIntoUi(ui),
            .SearchBar => |*s| s.insertIntoUi(ui),
            else => unreachable,
        };
    }

    pub fn onCursorEnter(self: *Widget, ui: *UserInterface, x: u16, y: u16) void {
        switch (self.*) {
            .Rectangle => |*r| r.onCursorEnter(),
            .TitleBar => |*t| t.onCursorEnter(ui, x, y),
            .SearchBar => |*s| s.onCursorEnter(ui),
            else => unreachable,
        }
    }

    pub fn onCursorLeave(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Rectangle => |*r| r.onCursorLeave(),
            .TitleBar => |*t| t.onCursorLeave(ui),
            .SearchBar => |*s| s.onCursorLeave(ui),
            else => unreachable,
        }
    }

    pub fn onKeyEvent(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Rectangle => |*r| r.onKeyEvent(self, ui),
            .TitleBar => |*t| t.onKeyEvent(self, ui),
            .SearchBar => |*s| s.onKeyEvent(self, ui),
            else => unreachable,
        }
    }

    pub fn onCharacterEvent(self: *Widget, ui: *UserInterface, codepoint: u32) void {
        switch (self.*) {
            .Rectangle => |*r| r.onCharacterEvent(self, ui, codepoint),
            .TitleBar => |*t| t.onCharacterEvent(self, ui, codepoint),
            .SearchBar => |*s| s.onCharacterEvent(self, ui, codepoint),
            else => unreachable,
        }
    }

    pub fn onFocus(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Rectangle => |*r| r.onFocus(),
            .TitleBar => |*t| t.onFocus(self, ui),
            .SearchBar => |*s| s.onFocus(self, ui),
            else => unreachable,
        }
    }

    pub fn onUnfocus(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Rectangle => |*r| r.onUnfocus(),
            .TitleBar => |*t| t.onUnfocus(self, ui),
            .SearchBar => |*s| s.onUnfocus(self, ui),
            else => unreachable,
        }
    }

    pub fn onLeftMouseDown(self: *Widget, ui: *UserInterface, x: u16, y: u16) void {
        switch (self.*) {
            .Rectangle => |*r| r.onLeftMouseDown(),
            .TitleBar => |*t| t.onLeftMouseDown(self, ui, x, y),
            .SearchBar => |*s| s.onLeftMouseDown(self, ui, x, y),
            else => unreachable,
        }
    }

    pub fn onLeftMouseUp(self: *Widget, ui: *UserInterface, x: u16, y: u16) void {
        switch (self.*) {
            .Rectangle => |*r| return,
            .TitleBar => |*t| t.onLeftMouseUp(self, ui, x, y),
            .SearchBar => |*s| return,
            else => unreachable,
        }
    }

    pub fn onDrag(self: *Widget, ui: *UserInterface, x: u16, y: u16) void {
        switch (self.*) {
            .Rectangle => |*r| return,
            .TitleBar => |*t| t.onDrag(ui, x, y),
            .SearchBar => |*s| return,
            else => unreachable,
        }
    }

    pub inline fn onWindowSizeChanged(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Rectangle => |*r| r.onWindowSizeChanged(ui),
            .TitleBar => |*t| t.onWindowSizeChanged(ui),
            .SearchBar => |*s| s.onWindowSizeChanged(ui),
            else => unreachable,
        }
    }

    pub inline fn containsPoint(self: *Widget, ui: *UserInterface, x: u16, y: u16) bool {
        switch (self.*) {
            .Rectangle => |*r| return r.containsPoint(x, y),
            .TitleBar => |*t| return t.containsPoint(ui, x, y),
            .SearchBar => |*s| return s.containsPoint(ui, x, y),
            else => unreachable,
        }
    }

    pub inline fn animate(self: *Widget, ui: *UserInterface, time_delta: u64) void {
        switch (self.*) {
            .Rectangle => unreachable,
            .TitleBar => |*t| t.animate(self, ui, time_delta),
            .SearchBar => |*s| s.animate(self, ui, time_delta),
            else => unreachable,
        }
    }
};
