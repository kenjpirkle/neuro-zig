const UserInterface = @import("../user_interface.zig").UserInterface;
const WidgetIndex = @import("widget_index.zig");
usingnamespace @import("window.zig");
const TitleBar = @import("title_bar.zig").TitleBar;
const MinimizeButton = @import("minimize_button.zig").MinimizeButton;
const MaximizeRestoreButton = @import("maximize_restore_button.zig").MaximizeRestoreButton;
const CloseButton = @import("close_button.zig").CloseButton;
const SearchBar = @import("search_bar.zig").SearchBar;

pub var app_widgets = [_]Widget{
    .{ .Window = .{} },
    .{ .BorderTopLeft = .{} },
    .{ .BorderTop = .{} },
    .{ .BorderTopRight = .{} },
    .{ .BorderLeft = .{} },
    .{ .BorderRight = .{} },
    .{ .BorderBottomLeft = .{} },
    .{ .BorderBottom = .{} },
    .{ .BorderBottomRight = .{} },
    .{ .TitleBar = .{} },
    .{ .MinimizeButton = .{} },
    .{ .MaximizeRestoreButton = .{} },
    .{ .CloseButton = .{} },
    .{ .SearchBar = .{} },
};

pub var root_app_widgets = [_]*Widget{
    &app_widgets[WidgetIndex.Window],
    &app_widgets[WidgetIndex.TitleBar],
    &app_widgets[WidgetIndex.SearchBar],
};

pub const Widget = union(enum) {
    Window: Window,
    BorderTopLeft: BorderTopLeft,
    BorderTop: BorderTop,
    BorderTopRight: BorderTopRight,
    BorderLeft: BorderLeft,
    BorderRight: BorderRight,
    BorderBottomLeft: BorderBottomLeft,
    BorderBottom: BorderBottom,
    BorderBottomRight: BorderBottomRight,
    TitleBar: TitleBar,
    MinimizeButton: MinimizeButton,
    MaximizeRestoreButton: MaximizeRestoreButton,
    CloseButton: CloseButton,
    SearchBar: SearchBar,

    pub inline fn fromChild(widget_type: anytype) *Widget {
        return @ptrCast(*Widget, @alignCast(@alignOf(*Widget), widget_type));
    }

    pub fn init(self: *Widget, ui: *UserInterface) !void {
        try switch (self.*) {
            .Window => |*b| b.init(ui),
            .TitleBar => |*t| t.init(ui),
            .MinimizeButton => |*m| m.init(ui),
            .MaximizeRestoreButton => |*m| m.init(ui),
            .CloseButton => |*c| c.init(ui),
            .SearchBar => |*s| s.init(ui),
            else => {},
        };
    }

    pub fn onCursorPositionChanged(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .Window => |*w| w.onCursorPositionChanged(ui),
            .TitleBar => |*t| t.onCursorPositionChanged(ui),
            .SearchBar => |*s| s.onCursorPositionChanged(ui),
            else => {},
        }
    }

    pub fn onCursorEnter(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .BorderTopLeft => |*b| b.onCursorEnter(self, ui),
            .BorderTop => |*b| b.onCursorEnter(self, ui),
            .BorderTopRight => |*b| b.onCursorEnter(self, ui),
            .BorderLeft => |*b| b.onCursorEnter(self, ui),
            .BorderRight => |*b| b.onCursorEnter(self, ui),
            .BorderBottomLeft => |*b| b.onCursorEnter(self, ui),
            .BorderBottom => |*b| b.onCursorEnter(self, ui),
            .BorderBottomRight => |*b| b.onCursorEnter(self, ui),
            .MinimizeButton => |*m| m.onCursorEnter(ui),
            .MaximizeRestoreButton => |*m| m.onCursorEnter(ui),
            .CloseButton => |*c| c.onCursorEnter(ui),
            .SearchBar => |*s| s.onCursorEnter(ui),
            else => {},
        }
    }

    pub fn onCursorLeave(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            .BorderTopLeft => |*b| b.onCursorLeave(ui),
            .BorderTop => |*b| b.onCursorLeave(ui),
            .BorderTopRight => |*b| b.onCursorLeave(ui),
            .BorderLeft => |*b| b.onCursorLeave(ui),
            .BorderRight => |*b| b.onCursorLeave(ui),
            .BorderBottomLeft => |*b| b.onCursorLeave(ui),
            .BorderBottom => |*b| b.onCursorLeave(ui),
            .BorderBottomRight => |*b| b.onCursorLeave(ui),
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
            .SearchBar => |*s| s.onFocus(ui),
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
            // .Window => |*w| w.onLeftMouseDown(ui),
            .TitleBar => |*t| t.onLeftMouseDown(ui),
            .MinimizeButton => |*m| m.onLeftMouseDown(ui),
            .MaximizeRestoreButton => |*m| m.onLeftMouseDown(ui),
            .CloseButton => |*c| c.onLeftMouseDown(ui),
            .SearchBar => |*s| s.onLeftMouseDown(ui),
            else => {},
        }
    }

    pub fn onLeftMouseUp(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            // .Window => |*w| w.onLeftMouseUp(ui),
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
            .Window => |*b| b.onWindowSizeChanged(ui),
            .TitleBar => |*t| t.onWindowSizeChanged(ui),
            .MinimizeButton => |*m| m.onWindowSizeChanged(ui),
            .MaximizeRestoreButton => |*m| m.onWindowSizeChanged(ui),
            .CloseButton => |*c| c.onWindowSizeChanged(ui),
            .SearchBar => |*s| s.onWindowSizeChanged(ui),
            else => {},
        }
    }

    pub inline fn onMaximized(self: *Widget, ui: *UserInterface) void {
        switch (self.*) {
            else => {},
        }
    }

    pub inline fn containsPoint(self: *Widget, ui: *UserInterface) bool {
        switch (self.*) {
            .BorderTopLeft => |*b| return b.containsPoint(ui),
            .BorderTop => |*b| return b.containsPoint(ui),
            .BorderTopRight => |*b| return b.containsPoint(ui),
            .BorderLeft => |*b| return b.containsPoint(ui),
            .BorderRight => |*b| return b.containsPoint(ui),
            .BorderBottomLeft => |*b| return b.containsPoint(ui),
            .BorderBottom => |*b| return b.containsPoint(ui),
            .BorderBottomRight => |*b| return b.containsPoint(ui),
            .TitleBar => |*t| return t.containsPoint(ui),
            .MinimizeButton => |*m| return m.containsPoint(ui),
            .MaximizeRestoreButton => |*m| return m.containsPoint(ui),
            .CloseButton => |*c| return c.containsPoint(ui),
            .SearchBar => |*s| return s.containsPoint(ui),
            else => return false,
        }
    }

    pub inline fn animate(self: *Widget, ui: *UserInterface, time_delta: u64) void {
        switch (self.*) {
            .SearchBar => |*s| s.animate(self, ui, time_delta),
            else => {},
        }
    }
};
