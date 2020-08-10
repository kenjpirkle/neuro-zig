const UserInterface = @import("../user_interface.zig").UserInterface;
const WidgetIndex = @import("widget_index.zig");
const Background = @import("background.zig").Background;
const TitleBar = @import("title_bar.zig").TitleBar;
const MinimizeButton = @import("minimize_button.zig").MinimizeButton;
const MaximizeRestoreButton = @import("maximize_restore_button.zig").MaximizeRestoreButton;
const CloseButton = @import("close_button.zig").CloseButton;
const SearchBar = @import("search_bar.zig").SearchBar;

pub var app_widgets = [_]Widget{
    .{ .Background = .{} },
    .{ .TitleBar = .{} },
    .{ .MinimizeButton = .{} },
    .{ .MaximizeRestoreButton = .{} },
    .{ .CloseButton = .{} },
    .{ .SearchBar = .{} },
};

pub var root_app_widgets = [_]*Widget{
    &app_widgets[WidgetIndex.TitleBar],
    &app_widgets[WidgetIndex.SearchBar],
};

pub const Widget = union(enum) {
    Background: Background,
    TitleBar: TitleBar,
    MinimizeButton: MinimizeButton,
    MaximizeRestoreButton: MaximizeRestoreButton,
    CloseButton: CloseButton,
    SearchBar: SearchBar,

    pub inline fn fromChild(widget_type: anytype) *Widget {
        return @ptrCast(*Widget, @alignCast(@alignOf(*Widget), widget_type));
    }

    pub fn insertIntoUi(self: *Widget, ui: *UserInterface) !void {
        try switch (self.*) {
            .Background => |*b| b.insertIntoUi(ui),
            .TitleBar => |*t| t.insertIntoUi(ui),
            .MinimizeButton => |*m| m.insertIntoUi(ui),
            .MaximizeRestoreButton => |*m| m.insertIntoUi(ui),
            .CloseButton => |*c| c.insertIntoUi(ui),
            .SearchBar => |*s| s.insertIntoUi(ui),
        };
    }

    pub fn onCursorPositionChanged(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .TitleBar => |*t| t.onCursorPositionChanged(ui),
            .SearchBar => |*s| s.onCursorPositionChanged(ui),
            else => {},
        }
    }

    pub fn onCursorEnter(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .TitleBar => |*t| t.onCursorEnter(ui),
            .MinimizeButton => |*m| m.onCursorEnter(ui),
            .MaximizeRestoreButton => |*m| m.onCursorEnter(ui),
            .CloseButton => |*c| c.onCursorEnter(ui),
            .SearchBar => |*s| s.onCursorEnter(ui),
            else => {},
        }
    }

    pub fn onCursorLeave(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .MinimizeButton => |*m| m.onCursorLeave(ui),
            .MaximizeRestoreButton => |*m| m.onCursorLeave(ui),
            .CloseButton => |*c| c.onCursorLeave(ui),
            .SearchBar => |*s| s.onCursorLeave(ui),
            else => {},
        }
    }

    pub fn onKeyEvent(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .SearchBar => |*s| s.onKeyEvent(self, ui),
            else => {},
        }
    }

    pub fn onCharacterEvent(self: *Widget, ui: *UserInterface, codepoint: u32) void {
        switch (self.*) {
            .SearchBar => |*s| s.onCharacterEvent(self, ui, codepoint),
            else => {},
        }
    }

    pub fn onFocus(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .SearchBar => |*s| s.onFocus(self, ui),
            else => {},
        }
    }

    pub fn onUnfocus(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .SearchBar => |*s| s.onUnfocus(self, ui),
            else => {},
        }
    }

    pub fn onLeftMouseDown(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .TitleBar => |*t| t.onLeftMouseDown(self, ui),
            .MinimizeButton => |*m| m.onLeftMouseDown(ui),
            .MaximizeRestoreButton => |*m| m.onLeftMouseDown(ui),
            .CloseButton => |*c| c.onLeftMouseDown(ui),
            .SearchBar => |*s| s.onLeftMouseDown(self, ui),
            else => {},
        }
    }

    pub fn onLeftMouseUp(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .TitleBar => |*t| t.onLeftMouseUp(ui),
            .MinimizeButton => |*m| m.onLeftMouseUp(ui),
            .MaximizeRestoreButton => |*m| m.onLeftMouseUp(ui),
            .CloseButton => |*c| c.onLeftMouseUp(ui),
            else => {},
        }
    }

    pub fn onDrag(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .TitleBar => |*t| t.onDrag(ui),
            else => {},
        }
    }

    pub inline fn onWindowSizeChanged(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Background => |*b| b.onWindowSizeChanged(ui),
            .MinimizeButton => |*m| m.onWindowSizeChanged(ui),
            .MaximizeRestoreButton => |*m| m.onWindowSizeChanged(ui),
            .CloseButton => |*c| c.onWindowSizeChanged(ui),
            .SearchBar => |*s| s.onWindowSizeChanged(ui),
            else => {},
        }
    }

    pub inline fn containsPoint(self: *Widget, ui: *UserInterface) bool {
        switch (self.*) {
            .TitleBar => |*t| return t.containsPoint(ui),
            .MinimizeButton => |*m| return m.containsPoint(ui),
            .MaximizeRestoreButton => |*m| return m.containsPoint(ui),
            .CloseButton => |*c| return c.containsPoint(ui),
            .SearchBar => |*s| return s.containsPoint(ui),
            else => unreachable,
        }
    }

    pub inline fn animate(self: *Widget, ui: *UserInterface, time_delta: u64) void {
        switch (self.*) {
            .SearchBar => |*s| s.animate(self, ui, time_delta),
            else => {},
        }
    }
};
