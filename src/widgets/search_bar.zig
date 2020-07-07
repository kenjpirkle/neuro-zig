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
const Index = @import("../buffer_indices.zig").SearchBarIndices;

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
    is_focused: bool = false,
    text_navigation_mode: bool = false,
    input_handled: bool = false,

    pub fn insertIntoUi(self: *Self, ui: *UserInterface) !void {
        ui.quad_shader.quad_data.beginModify();
        ui.quad_shader.colour_data.beginModify();
        ui.quad_shader.colour_index_data.beginModify();
        ui.quad_shader.draw_command_data.beginModify();

        ui.quad_shader.quad_data.append(&[_]Quad{
            // main body
            .{
                .transform = .{
                    .x = 20,
                    .y = 20 + offset_y,
                    .width = ui.width - 160,
                    .height = 34,
                },
                .layer = 2,
                .character = 1,
            },
            // main body shadow
            .{
                .transform = .{
                    .x = 20,
                    .y = 20 + offset_y,
                    .width = ui.width - 160,
                    .height = 4,
                },
                .layer = 5,
                .character = 0,
            },
            // main body highlight
            .{
                .transform = .{
                    .x = 21,
                    .y = 52 + offset_y,
                    .width = ui.width - 162,
                    .height = 2,
                },
                .layer = 5,
                .character = 0,
            },
            // focus highlight top
            .{
                .transform = .{
                    .x = 17,
                    .y = 18 + offset_y,
                    .width = ui.width - 155,
                    .height = 1,
                },
                .layer = 6,
                .character = 0,
            },
            // focus highlight bottom
            .{
                .transform = .{
                    .x = 17,
                    .y = 55 + offset_y,
                    .width = ui.width - 155,
                    .height = 1,
                },
                .layer = 6,
                .character = 0,
            },
            // focus highlight left
            .{
                .transform = .{
                    .x = 17,
                    .y = 19 + offset_y,
                    .width = 1,
                    .height = 36,
                },
                .layer = 6,
                .character = 0,
            },
            // focus highlight right
            .{
                .transform = .{
                    .x = ui.width - 139,
                    .y = 19 + offset_y,
                    .width = 1,
                    .height = 36,
                },
                .layer = 6,
                .character = 0,
            },
        });
        ui.quad_shader.quad_data.append(&[_]Quad{
            // search text
            .{
                .transform = .{
                    .x = 0,
                    .y = 0,
                    .width = 0,
                    .height = 0,
                },
                .layer = 3,
                .character = 0,
            },
        } ** 265);
        ui.quad_shader.quad_data.append(&[_]Quad{
            // left text overflow
            .{
                .transform = .{
                    .x = 20,
                    .y = 20 + offset_y,
                    .width = text_offset_x,
                    .height = 34,
                },
                .layer = 4,
                .character = 0,
            },
            // right text overflow
            .{
                .transform = .{
                    .x = ui.width - 170,
                    .y = 20 + offset_y,
                    .width = text_offset_x,
                    .height = 34,
                },
                .layer = 4,
                .character = 0,
            },
            // selection rect
            .{
                .transform = .{
                    .x = text_offset_x,
                    .y = text_offset_y - @intCast(u16, ui.quad_shader.font.max_ascender),
                    .width = 0,
                    .height = @intCast(u16, ui.quad_shader.font.max_glyph_height),
                },
                .layer = 4,
                .character = 0,
            },
            // text cursor
            .{
                .transform = .{
                    .x = text_offset_x - 1,
                    .y = text_offset_y - @intCast(u16, ui.quad_shader.font.max_ascender),
                    .width = 2,
                    .height = @intCast(u16, ui.quad_shader.font.max_glyph_height),
                },
                .layer = 5,
                .character = 0,
            },
        });

        ui.quad_shader.colour_data.append(&[_]Colour{
            // main body top
            .{
                .red = 47.0 / 255.0,
                .green = 48.0 / 255.0,
                .blue = 59.0 / 255.0,
                .alpha = 1.0,
            },
            // main body bottom
            .{
                .red = 52.0 / 255.0,
                .green = 53.0 / 255.0,
                .blue = 64.0 / 255.0,
                .alpha = 1.0,
            },
            // main body shadow top
            .{
                .red = 25.0 / 255.0,
                .green = 25.0 / 255.0,
                .blue = 25.0 / 255.0,
                .alpha = 250.0 / 255.0,
            },
            // main body shadow bottom
            .{
                .red = 25.0 / 255.0,
                .green = 25.0 / 255.0,
                .blue = 25.0 / 255.0,
                .alpha = 0.0,
            },
            // main body highlight top
            .{
                .red = 1.0,
                .green = 1.0,
                .blue = 1.0,
                .alpha = 0.0,
            },
            // main body highlight bottom
            .{
                .red = 1.0,
                .green = 1.0,
                .blue = 1.0,
                .alpha = 51.0 / 255.0,
            },
            // focus highlight
            .{
                .red = 50.0 / 255.0,
                .green = 25.0 / 255.0,
                .blue = 1.0,
                .alpha = 0.0,
            },
            // placeholder search text
            .{
                .red = 0.7,
                .green = 0.7,
                .blue = 1.0,
                .alpha = 120.0 / 255.0,
            },
            // search text
            .{
                .red = 1.0,
                .green = 1.0,
                .blue = 1.0,
                .alpha = 80.0 / 255.0,
            },
            // left text overflow top
            .{
                .red = 47.0 / 255.0,
                .green = 48.0 / 255.0,
                .blue = 59.0 / 255.0,
                .alpha = 0.0,
            },
            // left text overflow bottom
            .{
                .red = 52.0 / 255.0,
                .green = 53.0 / 255.0,
                .blue = 64.0 / 255.0,
                .alpha = 0.0,
            },
            // right text overflow top
            .{
                .red = 47.0 / 255.0,
                .green = 48.0 / 255.0,
                .blue = 59.0 / 255.0,
                .alpha = 0.0,
            },
            // right text overflow bottom
            .{
                .red = 52.0 / 255.0,
                .green = 53.0 / 255.0,
                .blue = 64.0 / 255.0,
                .alpha = 0.0,
            },
            // text cursor
            .{
                .red = 50.0 / 255.0,
                .green = 25.0 / 255.0,
                .blue = 1.0,
                .alpha = 0.0,
            },
            // selection rect
            .{
                .red = 50.0 / 255.0,
                .green = 50.0 / 255.0,
                .blue = 1.0,
                .alpha = 0.0,
            },
        });

        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = Index.Body.MainRect.ColourId,
                .bottom_left = Index.Body.MainRect.ColourId + 1,
                .top_right = Index.Body.MainRect.ColourId,
                .bottom_right = Index.Body.MainRect.ColourId + 1,
            },
            .{
                .top_left = Index.Body.Shadow.ColourId,
                .bottom_left = Index.Body.Shadow.ColourId + 1,
                .top_right = Index.Body.Shadow.ColourId,
                .bottom_right = Index.Body.Shadow.ColourId + 1,
            },
            .{
                .top_left = Index.Body.Highlight.ColourId,
                .bottom_left = Index.Body.Highlight.ColourId + 1,
                .top_right = Index.Body.Highlight.ColourId,
                .bottom_right = Index.Body.Highlight.ColourId + 1,
            },
        });
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = Index.FocusHighlight.ColourId,
                .bottom_left = Index.FocusHighlight.ColourId,
                .top_right = Index.FocusHighlight.ColourId,
                .bottom_right = Index.FocusHighlight.ColourId,
            },
        } ** 4);
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = Index.SearchText.PlaceholderText.ColourId,
                .bottom_left = Index.SearchText.PlaceholderText.ColourId,
                .top_right = Index.SearchText.PlaceholderText.ColourId,
                .bottom_right = Index.SearchText.PlaceholderText.ColourId,
            },
        } ** placeholder_text.len);
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = Index.SearchText.UserText.ColourId,
                .bottom_left = Index.SearchText.UserText.ColourId,
                .top_right = Index.SearchText.UserText.ColourId,
                .bottom_right = Index.SearchText.UserText.ColourId,
            },
        } ** 256);
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = Index.TextOverflow.ColourId,
                .bottom_left = Index.TextOverflow.ColourId + 1,
                .top_right = Index.TextOverflow.ColourId + 2,
                .bottom_right = Index.TextOverflow.ColourId + 3,
            },
            .{
                .top_left = Index.TextOverflow.ColourId + 2,
                .bottom_left = Index.TextOverflow.ColourId + 3,
                .top_right = Index.TextOverflow.ColourId,
                .bottom_right = Index.TextOverflow.ColourId + 1,
            },
            .{
                .top_left = Index.SelectionRect.ColourId,
                .bottom_left = Index.SelectionRect.ColourId,
                .top_right = Index.SelectionRect.ColourId,
                .bottom_right = Index.SelectionRect.ColourId,
            },
            .{
                .top_left = Index.TextCursor.ColourId,
                .bottom_left = Index.TextCursor.ColourId,
                .top_right = Index.TextCursor.ColourId,
                .bottom_right = Index.TextCursor.ColourId,
            },
        });

        ui.quad_shader.draw_command_data.append(&[_]DrawArraysIndirectCommand{
            .{
                .vertex_count = 4,
                .instance_count = 13,
                .first_vertex = 0,
                .base_instance = 0,
            },
            .{
                .vertex_count = 4,
                .instance_count = 265,
                .first_vertex = 0,
                .base_instance = 13,
            },
            .{
                .vertex_count = 4,
                .instance_count = 4,
                .first_vertex = 0,
                .base_instance = 278,
            },
        });

        self.insertPlaceholderText(ui);

        ui.quad_shader.quad_data.endModify();
        ui.quad_shader.colour_data.endModify();
        ui.quad_shader.colour_index_data.endModify();
        ui.quad_shader.draw_command_data.endModify();
    }

    fn insertPlaceholderText(self: *Self, ui: *UserInterface) void {
        var origin = text_offset_x;
        for (placeholder_text) |c, i| {
            const glyph = &ui.quad_shader.font.glyphs[c];
            const glyph_width = glyph.x1 - glyph.x0;
            const glyph_height = glyph.y1 - glyph.y0;
            const bearing_x = glyph.x_off;
            const bearing_y = glyph.y_off;
            const glyph_quad = &ui.quad_shader.quad_data.data[Index.SearchText.PlaceholderText.QuadId + i];

            glyph_quad.transform = .{
                .x = origin + @intCast(u16, bearing_x),
                .y = text_offset_y - @intCast(u16, bearing_y),
                .width = @intCast(u16, glyph_width),
                .height = @intCast(u16, glyph_height),
            };
            glyph_quad.character = @intCast(u8, c);

            origin += @intCast(u16, glyph.advance);
        }
    }

    pub fn onCursorEnter(self: *Self, ui: *UserInterface) void {
        if (builtin.mode == .Debug) {
            warn("cursor entered the SearchBar\n", .{});
        }

        if (self.is_focused == false) {
            ui.quad_shader.colour_data.data[Index.Body.MainRect.ColourId] = .{
                .red = 53.0 / 255.0,
                .green = 54.0 / 255.0,
                .blue = 65.0 / 255.0,
                .alpha = 1.0,
            };
            ui.quad_shader.colour_data.data[Index.Body.MainRect.ColourId + 1] = .{
                .red = 58.0 / 255.0,
                .green = 59.0 / 255.0,
                .blue = 70.0 / 255.0,
                .alpha = 1.0,
            };

            const toc = &ui.quad_shader.colour_data;
            toc.data[Index.TextOverflow.ColourId].setRGB(53.0 / 255.0, 54.0 / 255.0, 65.0 / 255.0);
            toc.data[Index.TextOverflow.ColourId + 1].setRGB(58.0 / 255.0, 59.0 / 255.0, 70.0 / 255.0);
            toc.data[Index.TextOverflow.ColourId + 2].setRGB(53.0 / 255.0, 54.0 / 255.0, 65.0 / 255.0);
            toc.data[Index.TextOverflow.ColourId + 3].setRGB(58.0 / 255.0, 59.0 / 255.0, 70.0 / 255.0);
        }

        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_IBEAM_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);
        ui.draw_required = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        if (builtin.mode == .Debug) {
            warn("cursor left the SearchBar\n", .{});
        }

        if (self.is_focused == false) {
            ui.quad_shader.colour_data.data[Index.Body.MainRect.ColourId] = .{
                .red = 47.0 / 255.0,
                .green = 48.0 / 255.0,
                .blue = 59.0 / 255.0,
                .alpha = 1.0,
            };
            ui.quad_shader.colour_data.data[Index.Body.MainRect.ColourId + 1] = .{
                .red = 52.0 / 255.0,
                .green = 53.0 / 255.0,
                .blue = 64.0 / 255.0,
                .alpha = 1.0,
            };

            const toc = &ui.quad_shader.colour_data;
            toc.data[Index.TextOverflow.ColourId].setRGB(47.0 / 255.0, 48.0 / 255.0, 59.0 / 255.0);
            toc.data[Index.TextOverflow.ColourId + 1].setRGB(52.0 / 255.0, 53.0 / 255.0, 64.0 / 255.0);
            toc.data[Index.TextOverflow.ColourId].setRGB(47.0 / 255.0, 48.0 / 255.0, 59.0 / 255.0);
            toc.data[Index.TextOverflow.ColourId + 1].setRGB(52.0 / 255.0, 53.0 / 255.0, 64.0 / 255.0);
        }

        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_CURSOR_NORMAL);
        glfwSetCursor(ui.window, ui.cursor);
        ui.draw_required = true;
    }

    pub fn onLeftMouseDown(self: *Self, widget: *Widget, ui: *UserInterface, x: u16, y: u16) void {
        if (builtin.mode == .Debug) {
            warn("left mouse button down on SearchBar\n", .{});
        }

        if (!self.is_focused) {
            self.onFocus(widget, ui);
        }

        self.elapsed_ns = 0;
    }

    pub fn onFocus(self: *Self, widget: *Widget, ui: *UserInterface) void {
        if (builtin.mode == .Debug) {
            warn("SearchBar focus\n", .{});
        }

        self.is_focused = true;

        const cd = &ui.quad_shader.colour_data;

        cd.data[Index.FocusHighlight.ColourId].alpha = 185.0 / 255.0;
        cd.data[Index.TextCursor.ColourId].alpha = 220.0 / 255.0;

        if (self.search_string_length == 0) {
            ui.quad_shader.draw_command_data.data[Index.SearchText.DrawCommandId].instance_count = 0;
        }

        var i: usize = 0;
        while (i < ui.animating_widgets.len) : (i += 1) {
            var w = ui.animating_widgets.uncheckedAt(i);
            if (w.* == null) {
                w.* = widget;
                break;
            }
        } else {
            var w = ui.animating_widgets.addOne() catch unreachable;
            w.* = widget;
        }

        ui.animating = true;
        self.elapsed_ns = 0;
    }

    pub fn onUnfocus(self: *Self, widget: *Widget, ui: *UserInterface) void {
        if (builtin.mode == .Debug) {
            warn("SearchBar unfocus\n", .{});
        }

        self.is_focused = false;

        const cd = &ui.quad_shader.colour_data;
        cd.data[Index.Body.MainRect.ColourId] = .{
            .red = 47.0 / 255.0,
            .green = 48.0 / 255.0,
            .blue = 59.0 / 255.0,
            .alpha = 1.0,
        };
        cd.data[Index.Body.MainRect.ColourId + 1] = .{
            .red = 52.0 / 255.0,
            .green = 53.0 / 255.0,
            .blue = 64.0 / 255.0,
            .alpha = 1.0,
        };
        cd.data[Index.FocusHighlight.ColourId].alpha = 0.0;
        cd.data[Index.TextCursor.ColourId].alpha = 0.0;

        var i: usize = 0;
        while (i < ui.animating_widgets.len) : (i += 1) {
            var w = ui.animating_widgets.uncheckedAt(i);
            if (w.* == widget) {
                w.* = null;
                break;
            }
        }

        if (self.search_string_length == 0) {
            self.resetText(ui);
        }

        ui.draw_required = true;
    }

    pub fn onKeyEvent(self: *Self, widget: *Widget, ui: *UserInterface) void {
        self.input_handled = false;

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
        if (!self.text_navigation_mode and !self.input_handled) {
            if (self.search_string_length < search_text_limit) {
                const new_char_index: u32 = math.min(self.search_string_length, self.cursor_position) + Index.SearchText.UserText.QuadId;
                self.insertChar(ui, codepoint, new_char_index);
            }

            self.elapsed_ns = 0;
        }
    }

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {
        const quads = ui.quad_shader.quad_data.data;

        quads[Index.Body.MainRect.QuadId].transform.width = ui.width - 160;
        quads[Index.Body.Shadow.QuadId].transform.width = ui.width - 160;
        quads[Index.Body.Highlight.QuadId].transform.width = ui.width - 162;

        quads[Index.FocusHighlight.Top.QuadId].transform.width = ui.width - 155;
        quads[Index.FocusHighlight.Bottom.QuadId].transform.width = ui.width - 155;
        quads[Index.FocusHighlight.Right.QuadId].transform.x = ui.width - 139;

        quads[Index.TextOverflow.Right.QuadId].transform.x = ui.width - 160;
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface, x: u16, y: u16) bool {
        const t = &ui.quad_shader.quad_data.data[Index.Body.MainRect.QuadId];
        return t.contains(x, y);
    }

    pub fn animate(self: *Self, widget: *Widget, ui: *UserInterface, time_delta: u64) void {
        self.elapsed_ns += time_delta;
        if (self.elapsed_ns >= (1000 * 1000000)) {
            self.elapsed_ns = 0;
        }

        const alpha: f32 = if (self.elapsed_ns <= (500 * 1000000)) 180.0 / 255.0 else 0.0;
        ui.quad_shader.colour_data.data[Index.TextCursor.ColourId].alpha = alpha;
        ui.animating = true;
    }

    inline fn moveCursor(self: *Self, ui: *UserInterface, advance: i32) void {
        const x = &ui.quad_shader.quad_data.data[Index.TextCursor.QuadId].transform.x;
        x.* = @intCast(u16, @as(i17, x.*) + advance);
    }

    inline fn resetText(self: *Self, ui: *UserInterface) void {
        var d = &ui.quad_shader.draw_command_data.data[Index.SearchText.DrawCommandId];
        d.instance_count = placeholder_text.len;
        d.base_instance = Index.SearchText.PlaceholderText.QuadId;
    }

    inline fn updateText(self: *Self, ui: *UserInterface, text_length: u8) void {
        var command = &ui.quad_shader.draw_command_data.data[Index.SearchText.DrawCommandId];
        command.instance_count = text_length;
        command.base_instance = Index.SearchText.UserText.QuadId;
    }

    inline fn insertChar(self: *Self, ui: *UserInterface, codepoint: u32, index: usize) void {
        const c = @intCast(u8, codepoint);
        const q = &ui.quad_shader.quad_data;
        const glyph = ui.quad_shader.font.glyphs[c];
        const glyph_width = @intCast(u16, glyph.x1 - glyph.x0);
        const glyph_height = @intCast(u16, glyph.y1 - glyph.y0);
        const bearing_x = glyph.x_off;
        const bearing_y = glyph.y_off;

        const to_copy = self.search_string_length - self.cursor_position;
        var i: usize = index + to_copy;
        while (i > index) : (i -= 1) {
            q.data[i] = q.data[i - 1];
            q.data[i].transform.x += @intCast(u16, glyph.advance);
        }

        q.data[index].transform = .{
            .x = @intCast(u16, @as(i33, self.cursor_text_origin) + bearing_x),
            .y = @intCast(u16, @as(i33, text_offset_y) - bearing_y),
            .width = glyph_width,
            .height = glyph_height,
        };
        q.data[index].character = c;

        self.cursor_text_origin += @intCast(u16, glyph.advance);
        self.cursor_position += 1;
        self.search_string_length += 1;

        self.moveCursor(ui, @intCast(i32, glyph.advance));
        self.updateText(ui, self.search_string_length);
    }

    inline fn onBackspace(self: *Self, ui: *UserInterface) void {
        var q = &ui.quad_shader.quad_data;

        if (self.search_string_length > 0 and self.cursor_position > 0) {
            const previous_character_quad_id = Index.SearchText.UserText.QuadId + self.cursor_position - 1;
            const previous_character = q.data[previous_character_quad_id].character;
            const character_advance = ui.quad_shader.font.glyphs[previous_character].advance;
            var num_to_delete: u8 = 1;

            // if (ui.keyboard_state.modifiers == GLFW_MOD_CONTROL) {
            //     self.calculateBackwardJump(ui, c_ind - 1, &cursor_advance, &num_to_delete);
            // }

            const to_copy = self.search_string_length - self.cursor_position;
            const end_index = previous_character_quad_id + to_copy;
            var i: usize = previous_character_quad_id;
            while (i < end_index) : (i += 1) {
                q.data[i] = q.data[i + 1];
                q.data[i].transform.x -= @intCast(u16, character_advance);
            }

            self.cursor_text_origin -= @intCast(u16, character_advance);
            self.cursor_position -= 1;
            self.search_string_length -= 1;

            self.moveCursor(ui, @intCast(i32, -%character_advance));
            self.updateText(ui, self.search_string_length);
        }
    }

    inline fn onDelete(self: *Self, ui: *UserInterface) void {
        var q = &ui.quad_shader.quad_data;

        if (self.search_string_length > 0 and self.cursor_position < self.search_string_length) {
            const next_character_quad_id = Index.SearchText.UserText.QuadId + self.cursor_position;
            const next_character = q.data[next_character_quad_id].character;
            const character_advance = ui.quad_shader.font.glyphs[next_character].advance;
            var num_to_delete: u8 = 1;

            // if (ui.keyboard_state.modifiers == GLFW_MOD_CONTROL) {
            //     self.calculateBackwardJump(ui, c_ind - 1, &cursor_advance, &num_to_delete);
            // }

            const to_copy = self.search_string_length - self.cursor_position - 1;
            const end_index = next_character_quad_id + to_copy;
            var i: usize = next_character_quad_id;
            while (i < end_index) : (i += 1) {
                q.data[i] = q.data[i + 1];
                q.data[i].transform.x -= @intCast(u16, character_advance);
            }

            self.search_string_length -= 1;
            self.updateText(ui, self.search_string_length);
        }
    }

    inline fn onLeft(self: *Self, ui: *UserInterface) void {
        if (self.search_string_length > 0 and self.cursor_position > 0) {
            const previous_character_quad_id = Index.SearchText.UserText.QuadId + self.cursor_position - 1;
            const previous_character = ui.quad_shader.quad_data.data[previous_character_quad_id].character;
            const character_advance = ui.quad_shader.font.glyphs[previous_character].advance;

            const negative_advance = @intCast(i32, -%character_advance);
            self.moveCursor(ui, negative_advance);
            self.cursor_position -= 1;
            self.cursor_text_origin -= @intCast(u16, character_advance);
        }
    }

    inline fn onRight(self: *Self, ui: *UserInterface) void {
        if (self.search_string_length > 0 and self.cursor_position < self.search_string_length) {
            const next_character_quad_id = Index.SearchText.UserText.QuadId + self.cursor_position;
            const next_character = ui.quad_shader.quad_data.data[next_character_quad_id].character;
            const character_advance = ui.quad_shader.font.glyphs[next_character].advance;

            self.moveCursor(ui, @intCast(i32, character_advance));
            self.cursor_position += 1;
            self.cursor_text_origin += @intCast(u16, character_advance);
        }
    }

    inline fn onPaste(self: *Self, ui: *UserInterface) void {
        const q = &ui.quad_shader.quad_data;
        const clipboard = glfwGetClipboardString(ui.window);
        if (clipboard[0] == 0) {
            return;
        }

        // copy all characters from cursor position to end
        const end_quad_id: usize = Index.SearchText.UserText.QuadId + 255;
        var cursor_char_quad_id = Index.SearchText.UserText.QuadId + self.cursor_position;
        const to_copy = self.search_string_length - self.cursor_position;
        var i: usize = 0;
        while (i < to_copy) : (i += 1) {
            q.data[end_quad_id - i] = q.data[cursor_char_quad_id + to_copy - 1 - i];
        }

        const old_cursor_text_origin = self.cursor_text_origin;
        // insert pasted characters
        const available_space = search_text_limit - self.search_string_length;
        var cursor_advance: i32 = 0;
        i = 0;
        while (clipboard[i] != 0 and i < available_space) : (i += 1) {
            const c = @intCast(u8, clipboard[i]);
            const glyph = ui.quad_shader.font.glyphs[c];
            const glyph_width = @intCast(u16, glyph.x1 - glyph.x0);
            const glyph_height = @intCast(u16, glyph.y1 - glyph.y0);
            const bearing_x = glyph.x_off;
            const bearing_y = glyph.y_off;

            q.data[cursor_char_quad_id + i].transform = .{
                .x = @intCast(u16, @as(i33, self.cursor_text_origin) + bearing_x),
                .y = @intCast(u16, @as(i33, text_offset_y) - bearing_y),
                .width = glyph_width,
                .height = glyph_height,
            };
            q.data[cursor_char_quad_id + i].character = c;

            self.cursor_text_origin += @intCast(u16, glyph.advance);
            cursor_advance += @intCast(i32, glyph.advance);
        }

        self.cursor_position += @intCast(u8, i);
        self.search_string_length += @intCast(u8, i);

        // copy old characters back from end if required
        const new_offset = self.cursor_text_origin - old_cursor_text_origin;
        cursor_char_quad_id = Index.SearchText.UserText.QuadId + self.cursor_position;
        i = 0;
        while (i < to_copy) : (i += 1) {
            const index = cursor_char_quad_id + i;
            q.data[index] = q.data[end_quad_id - to_copy + 1 + i];
            q.data[index].transform.x += new_offset;
        }

        self.moveCursor(ui, cursor_advance);
        self.updateText(ui, self.search_string_length);
    }

    inline fn selectAll(self: *Self, ui: *UserInterface) void {
        if (self.search_string_length < 1) {
            return;
        }

        const q = &ui.quad_shader.quad_data.data[Index.SearchText.UserText.QuadId + self.search_string_length - 1];

        ui.quad_shader.quad_data.data[Index.SelectionRect.QuadId].transform.width = q.transform.x + q.transform.width - text_offset_x;
        ui.quad_shader.colour_data.data[Index.SelectionRect.ColourId].alpha = 100.0 / 255.0;
    }

    inline fn calculateBackwardJump(self: *Self, ui: *UserInterface, index: u8, advance: *u16, num_chars: *u8) void {
        var q = &ui.quad_shader.quad_data;
        var i: u8 = index;
        if (q.data[i + 1].character == ' ') {
            while (i >= Index.SearchText.UserText.QuadId and q.data[i].character == ' ') {
                advance.* += @intCast(u16, ui.quad_shader.font.glyphs[q.data[i].character].advance);
                i -= 1;
            }
        } else {
            while (i >= Index.SearchText.UserText.QuadId and q.data[i].character != ' ') {
                advance.* += @intCast(u16, ui.quad_shader.font.glyphs[q.data[i].character].advance);
                i -= 1;
            }
        }

        num_chars.* += index - i;
    }

    inline fn calculateForwardJump(self: *Self, ui: *UserInterface, index: u8, advance: *u16, num_chars: *u8) void {
        var q = &ui.quad_shader.quad_data;
        var i: usize = index;
        if (q.data[i].character == ' ') {
            while (i < Index.SearchText.UserText.QuadId + self.search_string_length and q.data[i].character == ' ') {
                advance.* += ui.quad_shader.font.glyphs[q.data[i].character].advance;
                i += 1;
            }
        } else {
            while (i < Index.SearchText.UserText.QuadId + self.search_string_length and q.data[i].character != ' ') {
                advance.* += ui.quad_shader.font.glyphs[q.data[i].character].advance;
                i += 1;
            }
        }

        num_chars.* += i - index;
    }
};
