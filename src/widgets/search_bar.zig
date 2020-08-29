const std = @import("std");
const math = std.math;
const warn = std.debug.warn;
const mem = std.mem;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const Rectangle = @import("../gl/rectangle.zig").Rectangle;
const Colour = @import("../gl/colour.zig").Colour;
const Colours = @import("widget_colours.zig").SearchBar;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const element = @import("../widget_components.zig").SearchBar;
usingnamespace @import("../c.zig");

pub const SearchBar = packed struct {
    const Self = @This();

    const placeholder_text = "search...";
    const search_text_limit = 255;
    const text_offset_x: u16 = 30;
    const offset_y: u16 = 24;
    const text_offset_y: u16 = 43 + offset_y;

    parent: ?*Widget = null,
    elapsed_ns: u64 = 0,
    cursor_text_origin: u16 = text_offset_x,
    cursor_position: u8 = 0,
    first_visible_char: u8 = 0,
    last_visible_char: u8 = 0,
    search_string_length: u8 = 0,
    text_navigation_mode: bool = false,
    input_handled: bool = false,

    pub fn init(self: *Self, ui: *UserInterface) !void {
        element.Body.MainRect.colour_references[0].init(ui, Colours.MainRect.Top.Default);
        element.Body.MainRect.colour_references[1].init(ui, Colours.MainRect.Bottom.Default);
        element.Body.MainRect.mesh.init(ui);
        element.Body.MainRect.mesh.setTransform(.{
            .position = .{
                .x = 20,
                .y = 20 + offset_y,
            },
            .width = ui.width - 160,
            .height = 34,
            .layer = 2,
        });
        element.Body.MainRect.mesh.setVerticalGradient(
            element.Body.MainRect.colour_references[0],
            element.Body.MainRect.colour_references[1],
        );
        element.Body.MainRect.mesh.setMaterial(0);

        element.Body.Shadow.colour_references[0].init(ui, Colours.Shadow.Top.Default);
        element.Body.Shadow.colour_references[1].init(ui, Colours.Shadow.Bottom.Default);
        element.Body.Shadow.mesh.init(ui);
        element.Body.Shadow.mesh.setTransform(.{
            .position = .{
                .x = 20,
                .y = 20 + offset_y,
            },
            .width = ui.width - 160,
            .height = 3,
            .layer = 5,
        });
        element.Body.Shadow.mesh.setVerticalGradient(
            element.Body.Shadow.colour_references[0],
            element.Body.Shadow.colour_references[1],
        );
        element.Body.Shadow.mesh.setMaterial(0);

        element.Body.Highlight.colour_references[0].init(ui, Colours.Highlight.Top.Default);
        element.Body.Highlight.colour_references[1].init(ui, Colours.Highlight.Bottom.Default);
        element.Body.Highlight.mesh.init(ui);
        element.Body.Highlight.mesh.setTransform(.{
            .position = .{
                .x = 21,
                .y = 52 + offset_y,
            },
            .width = ui.width - 162,
            .height = 2,
            .layer = 5,
        });
        element.Body.Highlight.mesh.setVerticalGradient(
            element.Body.Highlight.colour_references[0],
            element.Body.Highlight.colour_references[1],
        );
        element.Body.Highlight.mesh.setMaterial(0);

        element.FocusHighlight.colour_reference.init(ui, Colours.FocusHighlight.Default);
        element.FocusHighlight.Top.mesh.init(ui);
        element.FocusHighlight.Top.mesh.setTransform(.{
            .position = .{
                .x = 17,
                .y = 18 + offset_y,
            },
            .width = ui.width - 155,
            .height = 1,
            .layer = 6,
        });
        element.FocusHighlight.Top.mesh.setSolidColour(element.FocusHighlight.colour_reference);
        element.FocusHighlight.Top.mesh.setMaterial(0);

        element.FocusHighlight.Left.mesh.init(ui);
        element.FocusHighlight.Left.mesh.setTransform(.{
            .position = .{
                .x = 17,
                .y = 19 + offset_y,
            },
            .width = 1,
            .height = 36,
            .layer = 6,
        });
        element.FocusHighlight.Left.mesh.setSolidColour(element.FocusHighlight.colour_reference);
        element.FocusHighlight.Left.mesh.setMaterial(0);

        element.FocusHighlight.Right.mesh.init(ui);
        element.FocusHighlight.Right.mesh.setTransform(.{
            .position = .{
                .x = ui.width - 139,
                .y = 19 + offset_y,
            },
            .width = 1,
            .height = 36,
            .layer = 6,
        });
        element.FocusHighlight.Right.mesh.setSolidColour(element.FocusHighlight.colour_reference);
        element.FocusHighlight.Right.mesh.setMaterial(0);

        element.FocusHighlight.Bottom.mesh.init(ui);
        element.FocusHighlight.Bottom.mesh.setTransform(.{
            .position = .{
                .x = 17,
                .y = 55 + offset_y,
            },
            .width = ui.width - 155,
            .height = 1,
            .layer = 6,
        });
        element.FocusHighlight.Bottom.mesh.setSolidColour(element.FocusHighlight.colour_reference);
        element.FocusHighlight.Bottom.mesh.setMaterial(0);

        element.SearchText.PlaceholderText.colour_reference.init(ui, Colours.PlaceholderText.Default);
        {
            var i: usize = 0;
            while (i < placeholder_text.len) : (i += 1) {
                element.SearchText.PlaceholderText.meshes[i].init(ui);
                element.SearchText.PlaceholderText.meshes[i].setLayer(3);
            }
        }

        element.SearchText.UserText.colour_reference.init(ui, Colours.UserText.Default);
        {
            var i: usize = 0;
            while (i < 256) : (i += 1) {
                element.SearchText.UserText.meshes[i].init(ui);
                element.SearchText.UserText.meshes[i].setLayer(3);
            }
        }

        element.TextOverflow.colour_references[0].init(ui, Colours.TextOverflow.Left.Top);
        element.TextOverflow.colour_references[1].init(ui, Colours.TextOverflow.Left.Bottom);
        element.TextOverflow.colour_references[2].init(ui, Colours.TextOverflow.Right.Top);
        element.TextOverflow.colour_references[3].init(ui, Colours.TextOverflow.Right.Bottom);

        element.TextOverflow.Left.mesh.init(ui);
        element.TextOverflow.Left.mesh.setTransform(.{
            .position = .{
                .x = 20,
                .y = 20 + offset_y,
            },
            .width = text_offset_x,
            .height = 34,
            .layer = 4,
        });
        element.TextOverflow.Left.mesh.setCornerGradient(
            element.TextOverflow.colour_references[0],
            element.TextOverflow.colour_references[1],
            element.TextOverflow.colour_references[2],
            element.TextOverflow.colour_references[3],
        );
        element.TextOverflow.Left.mesh.setMaterial(0);

        element.TextOverflow.Right.mesh.init(ui);
        element.TextOverflow.Right.mesh.setTransform(.{
            .position = .{
                .x = ui.width - 170,
                .y = 20 + offset_y,
            },
            .width = text_offset_x,
            .height = 34,
            .layer = 4,
        });
        element.TextOverflow.Right.mesh.setCornerGradient(
            element.TextOverflow.colour_references[2],
            element.TextOverflow.colour_references[3],
            element.TextOverflow.colour_references[0],
            element.TextOverflow.colour_references[1],
        );
        element.TextOverflow.Right.mesh.setMaterial(0);

        element.SelectionRect.colour_reference.init(ui, Colours.SelectionRect.Default);
        element.SelectionRect.mesh.init(ui);
        element.SelectionRect.mesh.setTransform(.{
            .position = .{
                .x = text_offset_x,
                .y = text_offset_y - @intCast(u16, ui.default_shader.font.max_ascender),
            },
            .width = 0,
            .height = @intCast(u16, ui.default_shader.font.max_glyph_height),
            .layer = 4,
        });
        element.SelectionRect.mesh.setSolidColour(element.SelectionRect.colour_reference);
        element.SelectionRect.mesh.setMaterial(0);

        element.TextCursor.colour_reference.init(ui, Colours.TextCursor.Default);
        element.TextCursor.mesh.init(ui);
        element.TextCursor.mesh.setTransform(.{
            .position = .{
                .x = text_offset_x - 1,
                .y = text_offset_y - @intCast(u16, ui.default_shader.font.max_ascender),
            },
            .width = 2,
            .height = @intCast(u16, ui.default_shader.font.max_glyph_height),
            .layer = 5,
        });
        element.TextCursor.mesh.setSolidColour(element.TextCursor.colour_reference);
        element.TextCursor.mesh.setMaterial(0);

        element.FocusHighlight.draw_command = ui.allocDrawCommand();
        element.FocusHighlight.draw_command.* = .{
            .vertex_count = 6,
            .instance_count = 19,
            .first_vertex = 0,
            .base_instance = 0,
        };
        element.SearchText.draw_command = ui.allocDrawCommand();
        element.SearchText.draw_command.* = .{
            .vertex_count = 6,
            .instance_count = 265,
            .first_vertex = 19 * 6,
            .base_instance = 19,
        };
        element.TextOverflow.draw_command = ui.allocDrawCommand();
        element.TextOverflow.draw_command.* = .{
            .vertex_count = 6,
            .instance_count = 4,
            .first_vertex = (265 + 19) * 6,
            .base_instance = 265,
        };

        self.insertPlaceholderText(ui);
    }

    fn insertPlaceholderText(self: *Self, ui: *UserInterface) void {
        var origin = text_offset_x;
        for (placeholder_text) |c, i| {
            const glyph = &ui.default_shader.font.glyphs[c];
            const glyph_width = glyph.x1 - glyph.x0;
            const glyph_height = glyph.y1 - glyph.y0;
            const bearing_x = glyph.x_off;
            const bearing_y = glyph.y_off;

            const x = blk: {
                if (bearing_x < 0) {
                    break :blk origin - @intCast(u16, (math.absInt(bearing_x) catch unreachable));
                } else {
                    break :blk origin + @intCast(u16, bearing_x);
                }
            };
            const y = text_offset_y - @intCast(u16, bearing_y);
            const char = @intCast(u8, c);

            element.SearchText.PlaceholderText.meshes[i].setTransform(.{
                .position = .{
                    .x = x,
                    .y = y,
                },
                .width = @intCast(u16, glyph_width),
                .height = @intCast(u16, glyph_height),
                .layer = 3,
            });
            element.SearchText.PlaceholderText.meshes[i].setSolidColour(element.SearchText.PlaceholderText.colour_reference);
            element.SearchText.PlaceholderText.meshes[i].setMaterial(char);

            origin += @intCast(u16, glyph.advance);
        }
    }

    pub fn onCursorPositionChanged(self: *Self, ui: *UserInterface) void {
        if (self.containsPoint(ui)) {
            self.onCursorEnter(ui);
        }
    }

    pub fn onCursorEnter(self: *Self, ui: *UserInterface) void {
        if (ui.widget_with_focus == Widget.fromChild(self)) {
            element.Body.MainRect.colour_references[0].set(Colours.MainRect.Top.FocusedHover);
            element.Body.MainRect.colour_references[1].setRgbaInt(58, 59, 70, 255);

            element.TextOverflow.colour_references[0].setRgbInt(53, 54, 65);
            element.TextOverflow.colour_references[1].setRgbInt(58, 59, 70);
            element.TextOverflow.colour_references[2].setRgbInt(53, 54, 65);
            element.TextOverflow.colour_references[3].setRgbInt(58, 59, 70);
        } else {
            element.Body.MainRect.colour_references[0].set(Colours.MainRect.Top.Hover);
            element.Body.MainRect.colour_references[1].setRgbaInt(58, 59, 70, 255);

            element.TextOverflow.colour_references[0].setRgbInt(53, 54, 65);
            element.TextOverflow.colour_references[1].setRgbInt(58, 59, 70);
            element.TextOverflow.colour_references[2].setRgbInt(53, 54, 65);
            element.TextOverflow.colour_references[3].setRgbInt(58, 59, 70);
        }

        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_IBEAM_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);
        ui.widget_with_cursor = Widget.fromChild(self);
        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        if (ui.widget_with_focus == Widget.fromChild(self)) {
            element.Body.MainRect.colour_references[0].setRgbaInt(47, 48, 59, 255);
            element.Body.MainRect.colour_references[1].setRgbaInt(52, 53, 64, 255);

            element.TextOverflow.colour_references[0].setRgbInt(47, 48, 59);
            element.TextOverflow.colour_references[1].setRgbInt(52, 53, 64);
            element.TextOverflow.colour_references[2].setRgbInt(47, 48, 59);
            element.TextOverflow.colour_references[3].setRgbInt(52, 53, 64);
        } else {
            element.Body.MainRect.colour_references[0].set(Colours.MainRect.Top.Default);
            element.Body.MainRect.colour_references[1].set(Colours.MainRect.Bottom.Default);

            element.TextOverflow.colour_references[0].set(Colours.TextOverflow.Left.Top);
            element.TextOverflow.colour_references[1].set(Colours.TextOverflow.Left.Bottom);
            element.TextOverflow.colour_references[2].set(Colours.TextOverflow.Right.Top);
            element.TextOverflow.colour_references[3].set(Colours.TextOverflow.Right.Bottom);
        }

        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_CURSOR_NORMAL);
        glfwSetCursor(ui.window, ui.cursor);
        ui.widget_with_cursor = null;
        ui.draw_required = true;
    }

    pub fn onLeftMouseDown(self: *Self, widget: *Widget, ui: *UserInterface) void {
        if (!(ui.widget_with_focus == Widget.fromChild(self))) {
            self.onFocus(widget, ui);
        }

        self.elapsed_ns = 0;
    }

    pub fn onFocus(self: *Self, widget: *Widget, ui: *UserInterface) void {
        ui.widget_with_focus = Widget.fromChild(self);

        element.FocusHighlight.colour_reference.reference.alpha = Colour.intVal(185);
        element.TextCursor.colour_reference.reference.alpha = Colour.intVal(220);

        if (self.search_string_length == 0) {
            element.SearchText.draw_command.instance_count = 0;
        }

        ui.addAnimatingWidget(widget);

        ui.animating = true;
        self.elapsed_ns = 0;
    }

    pub fn onUnfocus(self: *Self, widget: *Widget, ui: *UserInterface) void {
        ui.widget_with_focus = null;

        element.Body.MainRect.colour_references[0].setRgbaInt(47, 48, 59, 255);
        element.Body.MainRect.colour_references[1].setRgbaInt(52, 53, 64, 255);
        element.FocusHighlight.colour_reference.reference.alpha = Colour.intVal(0);
        element.TextCursor.colour_reference.reference.alpha = Colour.intVal(0);

        ui.removeAnimatingWidget(widget);

        if (self.search_string_length == 0) {
            self.resetText(ui);
        }

        ui.draw_required = true;
    }

    pub fn onKeyEvent(self: *Self, widget: *Widget, ui: *UserInterface) void {
        const keys = &ui.keyboard_state;
        if (keys.action != GLFW_RELEASE) {
            if (keys.modifiers == GLFW_MOD_CONTROL) {
                switch (keys.key) {
                    GLFW_KEY_A => self.selectAll(ui),
                    GLFW_KEY_X => {},
                    GLFW_KEY_Z => {},
                    GLFW_KEY_Y => {},
                    GLFW_KEY_C => {},
                    GLFW_KEY_V => self.onPaste(ui),
                    else => {},
                }
            } else {
                switch (keys.key) {
                    GLFW_KEY_BACKSPACE => self.onBackspace(ui),
                    GLFW_KEY_DELETE => self.onDelete(ui),
                    GLFW_KEY_LEFT => self.onLeft(ui),
                    GLFW_KEY_RIGHT => self.onRight(ui),
                    GLFW_KEY_ENTER => {},
                    else => {},
                }
            }

            self.elapsed_ns = 0;
        }
    }

    pub fn onCharacterEvent(self: *Self, widget: *Widget, ui: *UserInterface, codepoint: u32) void {
        if (!self.text_navigation_mode and !ui.input_handled) {
            if (self.search_string_length < search_text_limit) {
                const new_char_index: usize = math.min(self.search_string_length, self.cursor_position);
                self.insertChar(ui, codepoint, new_char_index);
            }

            self.elapsed_ns = 0;
        }
    }

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {
        element.Body.MainRect.mesh.setWidth(ui.width - 160);
        element.Body.Shadow.mesh.setWidth(ui.width - 160);
        element.Body.Highlight.mesh.setWidth(ui.width - 162);
        element.FocusHighlight.Top.mesh.setWidth(ui.width - 155);
        element.FocusHighlight.Bottom.mesh.setWidth(ui.width - 155);
        element.FocusHighlight.Right.mesh.translateX(ui.width - 139);
        element.TextOverflow.Right.mesh.translateX(ui.width - 160);
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface) bool {
        return element.Body.MainRect.mesh.contains(ui.cursor_x, ui.cursor_y);
    }

    pub fn animate(self: *Self, widget: *Widget, ui: *UserInterface, time_delta: u64) void {
        self.elapsed_ns += time_delta;
        if (self.elapsed_ns >= (1000 * 1000000)) {
            self.elapsed_ns = 0;
        }

        const alpha: u8 = if (self.elapsed_ns <= (500 * 1000000)) 180 else 0;
        element.TextCursor.colour_reference.reference.alpha = Colour.intVal(alpha);
        ui.animating = true;
    }

    inline fn moveCursor(self: *Self, ui: *UserInterface, advance: i32) void {
        const x = @intCast(u32, @as(i33, element.TextCursor.mesh.originX()) + advance);
        element.TextCursor.mesh.translateX(x);
    }

    inline fn resetText(self: *Self, ui: *UserInterface) void {
        const d = element.SearchText.draw_command;
        d.instance_count = placeholder_text.len;
        d.first_vertex = 19 * 6;
        d.base_instance = 19;
    }

    inline fn updateText(self: *Self, ui: *UserInterface, text_length: u8) void {
        const d = element.SearchText.draw_command;
        d.instance_count = text_length;
        d.first_vertex = 28 * 6;
        d.base_instance = 28;
    }

    inline fn insertChar(self: *Self, ui: *UserInterface, codepoint: u32, index: usize) void {
        const c = @intCast(u8, codepoint);
        const glyph = ui.default_shader.font.glyphs[c];
        const glyph_width = @intCast(u16, glyph.x1 - glyph.x0);
        const glyph_height = @intCast(u16, glyph.y1 - glyph.y0);
        const bearing_x = glyph.x_off;
        const bearing_y = glyph.y_off;

        const to_copy = self.search_string_length - self.cursor_position;
        var i: usize = index + to_copy;
        while (i > index) : (i -= 1) {
            element.SearchText.UserText.meshes[i].clone(element.SearchText.UserText.meshes[i - 1]);
            element.SearchText.UserText.meshes[i].translateXBy(@intCast(u16, glyph.advance));
        }

        const x = blk: {
            if (bearing_x < 0) {
                break :blk self.cursor_text_origin - @intCast(u16, (math.absInt(bearing_x) catch unreachable));
            } else {
                break :blk self.cursor_text_origin + @intCast(u16, bearing_x);
            }
        };
        const y = @intCast(u16, @as(i33, text_offset_y) - bearing_y);
        element.SearchText.UserText.meshes[index].setTransform(.{
            .position = .{
                .x = x,
                .y = y,
            },
            .width = glyph_width,
            .height = glyph_height,
            .layer = 3,
        });
        element.SearchText.UserText.meshes[index].setSolidColour(element.SearchText.UserText.colour_reference);
        element.SearchText.UserText.meshes[index].setMaterial(c);

        self.cursor_text_origin += @intCast(u16, glyph.advance);
        self.cursor_position += 1;
        self.search_string_length += 1;

        self.moveCursor(ui, @intCast(i32, glyph.advance));
        self.updateText(ui, self.search_string_length);
    }

    inline fn onBackspace(self: *Self, ui: *UserInterface) void {
        if (self.search_string_length > 0 and self.cursor_position > 0) {
            const prev_quad = element.SearchText.UserText.meshes[self.cursor_position - 1];
            const prev_char = @intCast(u8, prev_quad.vertices[0].material);
            const char_advance = ui.default_shader.font.glyphs[prev_char].advance;
            var num_to_delete: u8 = 1;

            // if (ui.keyboard_state.modifiers == GLFW_MOD_CONTROL) {
            //     self.calculateBackwardJump(ui, c_ind - 1, &cursor_advance, &num_to_delete);
            // }

            const to_copy = self.search_string_length - self.cursor_position;
            var i: usize = 0;
            while (i < to_copy) : (i += 1) {
                var quad = element.SearchText.UserText.meshes[self.cursor_position + i - 1];
                const next_quad = element.SearchText.UserText.meshes[self.cursor_position + i];
                quad.clone(next_quad);
                quad.translateX(quad.originX() - @intCast(u16, char_advance));
            }

            self.cursor_text_origin -= @intCast(u16, char_advance);
            self.cursor_position -= 1;
            self.search_string_length -= 1;

            self.moveCursor(ui, @bitCast(i32, -%char_advance));
            self.updateText(ui, self.search_string_length);
        }
    }

    inline fn onDelete(self: *Self, ui: *UserInterface) void {
        if (self.search_string_length > 0 and self.cursor_position < self.search_string_length) {
            var next_quad = element.SearchText.UserText.meshes[self.cursor_position];
            const next_char = @intCast(u8, next_quad.vertices[0].material);
            const char_advance = ui.default_shader.font.glyphs[next_char].advance;
            var num_to_delete: u8 = 1;

            // if (ui.keyboard_state.modifiers == GLFW_MOD_CONTROL) {
            //     self.calculateBackwardJump(ui, c_ind - 1, &cursor_advance, &num_to_delete);
            // }

            const to_copy = self.search_string_length - self.cursor_position - 1;
            var i: usize = 0;
            while (i < to_copy) : (i += 1) {
                var quad = element.SearchText.UserText.meshes[self.cursor_position + i];
                next_quad = element.SearchText.UserText.meshes[self.cursor_position + i + 1];
                quad.clone(next_quad);
                quad.translateX(quad.originX() - @intCast(u16, char_advance));
            }

            self.search_string_length -= 1;
            self.updateText(ui, self.search_string_length);
        }
    }

    inline fn onLeft(self: *Self, ui: *UserInterface) void {
        if (self.search_string_length > 0 and self.cursor_position > 0) {
            const prev_char = element.SearchText.UserText.meshes[self.cursor_position - 1].vertices[0].material;
            const char_advance = ui.default_shader.font.glyphs[prev_char].advance;

            const negative_advance = @intCast(i32, -%char_advance);
            self.moveCursor(ui, negative_advance);
            self.cursor_position -= 1;
            self.cursor_text_origin -= @intCast(u16, char_advance);
        }
    }

    inline fn onRight(self: *Self, ui: *UserInterface) void {
        if (self.search_string_length > 0 and self.cursor_position < self.search_string_length) {
            const next_char = element.SearchText.UserText.meshes[self.cursor_position].vertices[0].material;
            const char_advance = ui.default_shader.font.glyphs[next_char].advance;

            self.moveCursor(ui, @intCast(i32, char_advance));
            self.cursor_position += 1;
            self.cursor_text_origin += @intCast(u16, char_advance);
        }
    }

    inline fn onPaste(self: *Self, ui: *UserInterface) void {
        const clipboard = glfwGetClipboardString(ui.window);
        if (clipboard[0] == 0) {
            return;
        }

        // copy all characters from cursor position to end
        const to_copy = self.search_string_length - self.cursor_position;
        var i: usize = 0;
        while (i < to_copy) : (i += 1) {
            element.SearchText.UserText.meshes[255 - i].clone(element.SearchText.UserText.meshes[self.cursor_position + to_copy - i - 1]);
        }

        const old_cursor_text_origin = self.cursor_text_origin;
        // insert pasted characters
        const available_space = search_text_limit - self.search_string_length;
        var cursor_advance: i32 = 0;
        i = 0;
        while (clipboard[i] != 0 and i < available_space) : (i += 1) {
            const c = @intCast(u8, clipboard[i]);
            const glyph = ui.default_shader.font.glyphs[c];
            const glyph_width = @intCast(u16, glyph.x1 - glyph.x0);
            const glyph_height = @intCast(u16, glyph.y1 - glyph.y0);
            const bearing_x = glyph.x_off;
            const bearing_y = glyph.y_off;

            element.SearchText.UserText.meshes[self.cursor_position + i].setTransform(.{
                .position = .{
                    .x = @intCast(u16, @as(i33, self.cursor_text_origin) + bearing_x),
                    .y = @intCast(u16, @as(i33, text_offset_y) - bearing_y),
                },
                .width = glyph_width,
                .height = glyph_height,
                .layer = 3,
            });
            element.SearchText.UserText.meshes[self.cursor_position + i].setSolidColour(element.SearchText.UserText.colour_reference);
            element.SearchText.UserText.meshes[self.cursor_position + i].setMaterial(c);

            self.cursor_text_origin += @intCast(u16, glyph.advance);
            cursor_advance += @intCast(i32, glyph.advance);
        }

        self.cursor_position += @intCast(u8, i);
        self.search_string_length += @intCast(u8, i);

        // copy old characters back from end if required
        const new_offset = self.cursor_text_origin - old_cursor_text_origin;
        i = 0;
        while (i < to_copy) : (i += 1) {
            element.SearchText.UserText.meshes[self.cursor_position + i].clone(element.SearchText.UserText.meshes[255 - to_copy + 1 - i]);
            element.SearchText.UserText.meshes[self.cursor_position + i].translateXBy(new_offset);
        }

        self.moveCursor(ui, cursor_advance);
        self.updateText(ui, self.search_string_length);
    }

    inline fn selectAll(self: *Self, ui: *UserInterface) void {
        if (self.search_string_length < 1) {
            return;
        }

        const x = element.SearchText.UserText.meshes[self.search_string_length - 1].vertices[2].x;
        element.SelectionRect.mesh.setWidth(x);
        element.SelectionRect.colour_reference.reference.alpha = Colour.intVal(100);
    }

    inline fn calculateBackwardJump(self: *Self, ui: *UserInterface, index: u8, advance: *u16, num_chars: *u8) void {
        var i: u8 = index;
        if (element.SearchText.UserText.meshes[i + 1].vertices[0].material == ' ') {
            while (i >= 0 and element.SearchText.UserText.meshes[i].vertices[0].material == ' ') : (i -= 1) {
                const char = element.SearchText.UserText.meshes[i].vertices[0].material;
                const char_advance = ui.default_shader.font.glyphs[char].advance;
                advance.* += @intCast(u16, char_advance);
            }
        } else {
            while (i >= 0 and element.SearchText.UserText.meshes[i].vertices[0].material == ' ') : (i -= 1) {
                const char = element.SearchText.UserText.meshes[i].vertices[0].material;
                const char_advance = ui.default_shader.font.glyphs[char].advance;
                advance.* += @intCast(u16, char_advance);
            }
        }

        num_chars.* += index - i;
    }

    inline fn calculateForwardJump(self: *Self, ui: *UserInterface, index: u8, advance: *u16, num_chars: *u8) void {
        var i: usize = index;
        if (element.SearchText.UserText.meshes[i].vertices[0].material == ' ') {
            while (i < self.search_string_length and element.SearchText.UserText.meshes[i].vertices[0].material == ' ') : (i += 1) {
                const char = element.SearchText.UserText.meshes[i].vertices[0].material;
                const char_advance = ui.default_shader.font.glyphs[char].advance;
                advance.* += @intCast(u16, char_advance);
            }
        } else {
            while (i < self.search_string_length and element.SearchText.UserText.meshes[i].vertices[0].material == ' ') : (i += 1) {
                const char = element.SearchText.UserText.meshes[i].vertices[0].material;
                const char_advance = ui.default_shader.font.glyphs[char].advance;
                advance.* += @intCast(u16, char_advance);
            }
        }

        num_chars.* += i - index;
    }
};
