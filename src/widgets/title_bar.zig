const std = @import("std");
const math = std.math;
const warn = std.debug.warn;
const builtin = std.builtin;
const mem = std.mem;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const BufferIndices = @import("../gl/buffer_indices.zig").BufferIndices;
const Quad = @import("../gl/quad.zig").Quad;
const QuadTransform = @import("../gl/quad_transform.zig").QuadTransform;
const QuadColourIndices = @import("../gl/quad_colour_indices.zig").QuadColourIndices;
const Colour = @import("../gl/colour.zig").Colour;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
usingnamespace @import("../c.zig");
const Index = @import("../buffer_indices.zig").TitleBarIndices;

pub const TitleBar = packed struct {
    const Self = @This();

    const titlebar_height: u16 = 24;
    const button_width: u16 = 30;

    elapsed_ns: u64 = 0,
    cursor_x: u16 = 0,
    cursor_y: u16 = 0,

    pub fn insertIntoUi(self: *Self, ui: *UserInterface) !void {
        ui.quad_shader.quad_data.beginModify();
        ui.quad_shader.colour_data.beginModify();
        ui.quad_shader.colour_index_data.beginModify();

        ui.quad_shader.quad_data.append(&[_]Quad{
            // main bar
            .{
                .transform = .{
                    .x = 0,
                    .y = 0,
                    .width = ui.width - (button_width * 3),
                    .height = titlebar_height,
                },
                .layer = 2,
                .character = 1,
            },
            // minimize background
            .{
                .transform = .{
                    .x = ui.width - (button_width * 3),
                    .y = 0,
                    .width = button_width,
                    .height = titlebar_height,
                },
                .layer = 3,
                .character = 1,
            },
            // minimize icon
            .{
                .transform = .{
                    .x = ui.width - (button_width * 3) + 10,
                    .y = 11,
                    .width = 10,
                    .height = 2,
                },
                .layer = 4,
                .character = 1,
            },
            // maximize/restore
            .{
                .transform = .{
                    .x = ui.width - (button_width * 2),
                    .y = 0,
                    .width = button_width,
                    .height = titlebar_height,
                },
                .layer = 3,
                .character = 1,
            },
            // close
            .{
                .transform = .{
                    .x = ui.width - button_width,
                    .y = 0,
                    .width = button_width,
                    .height = titlebar_height,
                },
                .layer = 3,
                .character = 1,
            },
        });

        ui.quad_shader.colour_data.append(&[_]Colour{
            // titlebar
            .{
                .red = 1.0,
                .green = 1.0,
                .blue = 1.0,
                .alpha = 0.0,
            },
            // minimize background
            .{
                .red = 0.35,
                .green = 0.35,
                .blue = 0.35,
                .alpha = 0.0,
            },
            // minimize icon
            .{
                .red = 1.0,
                .green = 1.0,
                .blue = 1.0,
                .alpha = 0.5,
            },
            // maximize/restore
            .{
                .red = 0.0,
                .green = 1.0,
                .blue = 0.0,
                .alpha = 1.0,
            },
            // close
            .{
                .red = 1.0,
                .green = 0.0,
                .blue = 0.0,
                .alpha = 1.0,
            },
        });

        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = Index.MainRect.ColourId,
                .bottom_left = Index.MainRect.ColourId,
                .top_right = Index.MainRect.ColourId,
                .bottom_right = Index.MainRect.ColourId,
            },
            .{
                .top_left = Index.Minimize.ColourId,
                .bottom_left = Index.Minimize.ColourId,
                .top_right = Index.Minimize.ColourId,
                .bottom_right = Index.Minimize.ColourId,
            },
            .{
                .top_left = Index.MinimizeIcon.ColourId,
                .bottom_left = Index.MinimizeIcon.ColourId,
                .top_right = Index.MinimizeIcon.ColourId,
                .bottom_right = Index.MinimizeIcon.ColourId,
            },
            .{
                .top_left = Index.MaximizeRestore.ColourId,
                .bottom_left = Index.MaximizeRestore.ColourId,
                .top_right = Index.MaximizeRestore.ColourId,
                .bottom_right = Index.MaximizeRestore.ColourId,
            },
            .{
                .top_left = Index.Close.ColourId,
                .bottom_left = Index.Close.ColourId,
                .top_right = Index.Close.ColourId,
                .bottom_right = Index.Close.ColourId,
            },
        });

        ui.quad_shader.quad_data.endModify();
        ui.quad_shader.colour_data.endModify();
        ui.quad_shader.colour_index_data.endModify();
    }

    pub fn onCursorEnter(self: *Self, ui: *UserInterface, x: u16, y: u16) void {
        if (builtin.mode == .Debug) {
            warn("cursor entered the TitleBar\n", .{});
        }

        const minimize_quad = &ui.quad_shader.quad_data.data[Index.Minimize.QuadId];
        const maximize_quad = &ui.quad_shader.quad_data.data[Index.MaximizeRestore.QuadId];
        const close_quad = &ui.quad_shader.quad_data.data[Index.Close.QuadId];

        if (minimize_quad.containsX(x)) {
            ui.quad_shader.colour_data.data[Index.Minimize.ColourId].alpha = 1.0;
        } else {
            ui.quad_shader.colour_data.data[Index.Minimize.ColourId].alpha = 0.0;
        }
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        if (builtin.mode == .Debug) {
            warn("cursor left the TitleBar\n", .{});
        }
    }

    pub fn onDrag(self: *Self, ui: *UserInterface, x: u16, y: u16) void {
        const cursor_delta_x: i32 = @intCast(i32, x) - @intCast(i32, self.cursor_x);
        const cursor_delta_y: i32 = @intCast(i32, y) - @intCast(i32, self.cursor_y);
        glfwSetWindowPos(ui.window, ui.x + cursor_delta_x, ui.y + cursor_delta_y);
    }

    pub fn onLeftMouseDown(self: *Self, widget: *Widget, ui: *UserInterface, x: u16, y: u16) void {
        if (builtin.mode == .Debug) {
            warn("left mouse button down on TitleBar\n", .{});
        }

        const minimize_quad = &ui.quad_shader.quad_data.data[Index.Minimize.QuadId];
        const maximize_quad = &ui.quad_shader.quad_data.data[Index.MaximizeRestore.QuadId];
        const close_quad = &ui.quad_shader.quad_data.data[Index.Close.QuadId];

        if (minimize_quad.containsX(x)) {
            glfwIconifyWindow(ui.window);
        } else if (maximize_quad.containsX(x)) {
            const is_maximized = glfwGetWindowAttrib(ui.window, GLFW_MAXIMIZED);
            if (is_maximized == 0) {
                glfwMaximizeWindow(ui.window);
            } else {
                glfwRestoreWindow(ui.window);
            }
        } else if (close_quad.containsX(x)) {
            glfwSetWindowShouldClose(ui.window, GLFW_TRUE);
        } else {
            ui.widget_with_mouse = widget;
            var xpos: f64 = undefined;
            var ypos: f64 = undefined;
            glfwGetCursorPos(ui.window, &xpos, &ypos);
            self.cursor_x = @floatToInt(u16, xpos);
            self.cursor_y = @floatToInt(u16, ypos);
        }
    }

    pub fn onLeftMouseUp(self: *Self, widget: *Widget, ui: *UserInterface, x: u16, y: u16) void {
        ui.widget_with_mouse = null;
    }

    pub fn onFocus(self: *Self, widget: *Widget, ui: *UserInterface) void {
        if (builtin.mode == .Debug) {
            warn("TitleBar focus\n", .{});
        }
    }

    pub fn onUnfocus(self: *Self, widget: *Widget, ui: *UserInterface) void {
        if (builtin.mode == .Debug) {
            warn("TitleBar unfocus\n", .{});
        }
    }

    pub fn onKeyEvent(self: *Self, widget: *Widget, ui: *UserInterface) void {}

    pub fn onCharacterEvent(self: *Self, widget: *Widget, ui: *UserInterface, codepoint: u32) void {}

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {
        const quads = ui.quad_shader.quad_data.data;

        // main bar
        quads[Index.MainRect.QuadId].transform.width = ui.width - (button_width * 3);
        // minimize
        quads[Index.Minimize.QuadId].transform.x = ui.width - (button_width * 3);
        // maximize/restore
        quads[Index.MaximizeRestore.QuadId].transform.x = ui.width - (button_width * 2);
        // close
        quads[Index.Close.QuadId].transform.x = ui.width - button_width;
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface, x: u16, y: u16) bool {
        return (y >= 0) and (y <= titlebar_height);
    }

    pub fn animate(self: *Self, widget: *Widget, ui: *UserInterface, time_delta: u64) void {}
};
