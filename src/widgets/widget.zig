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

    pub fn onCursorEnter(self: *Widget, ui: *UserInterface, x: u16, y: u16) void {
        switch (self.*) {
            .TitleBar => |*t| t.onCursorEnter(ui, x, y),
            .MinimizeButton => |*m| m.onCursorEnter(ui),
            .MaximizeRestoreButton => |*m| m.onCursorEnter(ui),
            .CloseButton => |*c| {},
            .SearchBar => |*s| s.onCursorEnter(ui),
            else => {},
        }
    }

    pub fn onCursorLeave(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .MinimizeButton => |*m| m.onCursorLeave(ui),
            .MaximizeRestoreButton => |*m| m.onCursorLeave(ui),
            .CloseButton => |*c| {},
            .SearchBar => |*s| s.onCursorLeave(ui),
            else => {},
        }
    }

    pub fn onKeyEvent(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .TitleBar => |*t| t.onKeyEvent(self, ui),
            .MinimizeButton => |*minb| {},
            .MaximizeRestoreButton => |*maxb| {},
            .CloseButton => |*c| {},
            .SearchBar => |*s| s.onKeyEvent(self, ui),
            else => {},
        }
    }

    pub fn onCharacterEvent(self: *Widget, ui: *UserInterface, codepoint: u32) void {
        switch (self.*) {
            .TitleBar => |*t| t.onCharacterEvent(self, ui, codepoint),
            .MinimizeButton => |*minb| {},
            .MaximizeRestoreButton => |*maxb| {},
            .CloseButton => |*c| {},
            .SearchBar => |*s| s.onCharacterEvent(self, ui, codepoint),
            else => {},
        }
    }

    pub fn onFocus(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .TitleBar => |*t| t.onFocus(self, ui),
            .MinimizeButton => |*minb| {},
            .MaximizeRestoreButton => |*maxb| {},
            .CloseButton => |*c| {},
            .SearchBar => |*s| s.onFocus(self, ui),
            else => {},
        }
    }

    pub fn onUnfocus(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .TitleBar => |*t| t.onUnfocus(self, ui),
            .MinimizeButton => |*minb| {},
            .MaximizeRestoreButton => |*maxb| {},
            .CloseButton => |*c| {},
            .SearchBar => |*s| s.onUnfocus(self, ui),
            else => {},
        }
    }

    pub fn onLeftMouseDown(self: *Widget, ui: *UserInterface, x: u16, y: u16) void {
        switch (self.*) {
            .TitleBar => |*t| t.onLeftMouseDown(self, ui, x, y),
            .MinimizeButton => |*minb| {},
            .MaximizeRestoreButton => |*maxb| {},
            .CloseButton => |*c| {},
            .SearchBar => |*s| s.onLeftMouseDown(self, ui, x, y),
            else => {},
        }
    }

    pub fn onLeftMouseUp(self: *Widget, ui: *UserInterface, x: u16, y: u16) void {
        switch (self.*) {
            .TitleBar => |*t| t.onLeftMouseUp(self, ui, x, y),
            .MinimizeButton => |*minb| {},
            .MaximizeRestoreButton => |*maxb| {},
            .CloseButton => |*c| {},
            else => {},
        }
    }

    pub fn onDrag(self: *Widget, ui: *UserInterface, x: u16, y: u16) void {
        switch (self.*) {
            .TitleBar => |*t| t.onDrag(ui, x, y),
            .MinimizeButton => |*minb| {},
            .MaximizeRestoreButton => |*maxb| {},
            .CloseButton => |*c| {},
            else => {},
        }
    }

    pub inline fn onWindowSizeChanged(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Background => |*b| b.onWindowSizeChanged(ui),
            .TitleBar => |*t| t.onWindowSizeChanged(ui),
            .MinimizeButton => |*minb| {},
            .MaximizeRestoreButton => |*maxb| {},
            .CloseButton => |*c| {},
            .SearchBar => |*s| s.onWindowSizeChanged(ui),
        }
    }

    pub inline fn containsPoint(self: *Widget, ui: *UserInterface, x: u16, y: u16) bool {
        switch (self.*) {
            .TitleBar => |*t| return t.containsPoint(ui, x, y),
            .MinimizeButton => |*minb| return false,
            .MaximizeRestoreButton => |*maxb| return false,
            .CloseButton => |*c| return false,
            .SearchBar => |*s| return s.containsPoint(ui, x, y),
            else => unreachable,
        }
    }

    pub inline fn animate(self: *Widget, ui: *UserInterface, time_delta: u64) void {
        switch (self.*) {
            .TitleBar => |*t| t.animate(self, ui, time_delta),
            .MinimizeButton => |*minb| {},
            .MaximizeRestoreButton => |*maxb| {},
            .CloseButton => |*c| {},
            .SearchBar => |*s| s.animate(self, ui, time_delta),
            else => {},
        }
    }
};
