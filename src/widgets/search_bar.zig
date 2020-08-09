const std = @import("std");
const math = std.math;
const warn = std.debug.warn;
const builtin = std.builtin;
const mem = std.mem;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const Quad = @import("../gl/quad.zig").Quad;
const QuadTransform = @import("../gl/quad_transform.zig").QuadTransform;
const QuadColourIndices = @import("../gl/quad_colour_indices.zig").QuadColourIndices;
const Colour = @import("../gl/colour.zig").Colour;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
const Index = @import("../buffer_indices.zig").SearchBar;
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
    is_focused: bool = false,
    text_navigation_mode: bool = false,
    input_handled: bool = false,

    pub fn insertIntoUi(self: *Self, ui: *UserInterface) !void {
        var id = ui.quad_shader.quad_data.data.len;
        Index.Body.MainRect.Quad = id;
        Index.Body.Shadow.Quad = id + 1;
        Index.Body.Highlight.Quad = id + 2;
        Index.FocusHighlight.Top.Quad = id + 3;
        Index.FocusHighlight.Bottom.Quad = id + 4;
        Index.FocusHighlight.Left.Quad = id + 5;
        Index.FocusHighlight.Right.Quad = id + 6;
        ui.quad_shader.quad_data.append(&[_]Quad{
            // main body
            Quad.make(.{
                .x = 20,
                .y = 20 + offset_y,
                .width = ui.width - 160,
                .height = 34,
                .layer = 2,
                .character = 1,
            }),
            // main body shadow
            Quad.make(.{
                .x = 20,
                .y = 20 + offset_y,
                .width = ui.width - 160,
                .height = 4,
                .layer = 5,
                .character = 0,
            }),
            // main body highlight
            Quad.make(.{
                .x = 21,
                .y = 52 + offset_y,
                .width = ui.width - 162,
                .height = 2,
                .layer = 5,
                .character = 0,
            }),
            // focus highlight top
            Quad.make(.{
                .x = 17,
                .y = 18 + offset_y,
                .width = ui.width - 155,
                .height = 1,
                .layer = 6,
                .character = 0,
            }),
            // focus highlight bottom
            Quad.make(.{
                .x = 17,
                .y = 55 + offset_y,
                .width = ui.width - 155,
                .height = 1,
                .layer = 6,
                .character = 0,
            }),
            // focus highlight left
            Quad.make(.{
                .x = 17,
                .y = 19 + offset_y,
                .width = 1,
                .height = 36,
                .layer = 6,
                .character = 0,
            }),
            // focus highlight right
            Quad.make(.{
                .x = ui.width - 139,
                .y = 19 + offset_y,
                .width = 1,
                .height = 36,
                .layer = 6,
                .character = 0,
            }),
        });

        Index.SearchText.PlaceholderText.Quad = ui.quad_shader.quad_data.data.len;
        Index.SearchText.UserText.Quad = Index.SearchText.PlaceholderText.Quad + placeholder_text.len;
        ui.quad_shader.quad_data.append(&[_]Quad{
            // search text
            Quad.make(.{
                .x = 0,
                .y = 0,
                .width = 0,
                .height = 0,
                .layer = 3,
                .character = 0,
            }),
        } ** 265);

        id = ui.quad_shader.quad_data.data.len;
        Index.TextOverflow.Left.Quad = id;
        Index.TextOverflow.Right.Quad = id + 1;
        Index.SelectionRect.Quad = id + 2;
        Index.TextCursor.Quad = id + 3;
        ui.quad_shader.quad_data.append(&[_]Quad{
            // left text overflow
            Quad.make(.{
                .x = 20,
                .y = 20 + offset_y,
                .width = text_offset_x,
                .height = 34,
                .layer = 4,
                .character = 0,
            }),
            // right text overflow
            Quad.make(.{
                .x = ui.width - 170,
                .y = 20 + offset_y,
                .width = text_offset_x,
                .height = 34,
                .layer = 4,
                .character = 0,
            }),
            // selection rect
            Quad.make(.{
                .x = text_offset_x,
                .y = text_offset_y - @intCast(u16, ui.quad_shader.font.max_ascender),
                .width = 0,
                .height = @intCast(u16, ui.quad_shader.font.max_glyph_height),
                .layer = 4,
                .character = 0,
            }),
            // text cursor
            Quad.make(.{
                .x = text_offset_x - 1,
                .y = text_offset_y - @intCast(u16, ui.quad_shader.font.max_ascender),
                .width = 2,
                .height = @intCast(u16, ui.quad_shader.font.max_glyph_height),
                .layer = 5,
                .character = 0,
            }),
        });

        const cid = @intCast(u8, ui.quad_shader.colour_data.data.len);
        Index.Body.MainRect.Colours[0] = cid;
        Index.Body.MainRect.Colours[1] = cid + 1;
        Index.Body.Shadow.Colours[0] = cid + 2;
        Index.Body.Shadow.Colours[1] = cid + 3;
        Index.Body.Highlight.Colours[0] = cid + 4;
        Index.Body.Highlight.Colours[1] = cid + 5;
        Index.FocusHighlight.Colour = cid + 6;
        Index.SearchText.PlaceholderText.Colour = cid + 7;
        Index.SearchText.UserText.Colour = cid + 8;
        Index.TextOverflow.Colours[0] = cid + 9;
        Index.TextOverflow.Colours[1] = cid + 10;
        Index.TextOverflow.Colours[2] = cid + 11;
        Index.TextOverflow.Colours[3] = cid + 12;
        Index.TextCursor.Colour = cid + 13;
        Index.SelectionRect.Colour = cid + 14;
        ui.quad_shader.colour_data.append(&[_]Colour{
            // main body top
            Colour.fromRgbaInt(47, 48, 59, 255),
            // main body bottom
            Colour.fromRgbaInt(52, 53, 64, 255),
            // main body shadow top
            Colour.fromRgbaInt(25, 25, 25, 250),
            // main body shadow bottom
            Colour.fromRgbaInt(25, 25, 25, 0),
            // main body highlight top
            Colour.fromRgbaInt(255, 255, 255, 0),
            // main body highlight bottom
            Colour.fromRgbaInt(255, 255, 255, 51),
            // focus highlight
            Colour.fromRgbaInt(50, 25, 255, 0),
            // placeholder search text
            Colour.fromRgbaInt(217, 217, 255, 120),
            // user search text
            Colour.fromRgbaInt(255, 255, 255, 80),
            // left text overflow top
            Colour.fromRgbaInt(47, 48, 59, 0),
            // left text overflow bottom
            Colour.fromRgbaInt(52, 53, 64, 0),
            // right text overflow top
            Colour.fromRgbaInt(47, 48, 59, 0),
            // right text overflow bottom
            Colour.fromRgbaInt(52, 53, 64, 0),
            // text cursor
            Colour.fromRgbaInt(50, 25, 255, 0),
            // selection rect
            Colour.fromRgbaInt(50, 50, 255, 0),
        });

        id = ui.quad_shader.colour_index_data.data.len;
        Index.Body.MainRect.ColourIndices = id;
        Index.Body.Shadow.ColourIndices = id + 1;
        Index.Body.Highlight.ColourIndices = id + 2;
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = Index.Body.MainRect.Colours[0],
                .bottom_left = Index.Body.MainRect.Colours[1],
                .top_right = Index.Body.MainRect.Colours[0],
                .bottom_right = Index.Body.MainRect.Colours[1],
            },
            .{
                .top_left = Index.Body.Shadow.Colours[0],
                .bottom_left = Index.Body.Shadow.Colours[1],
                .top_right = Index.Body.Shadow.Colours[0],
                .bottom_right = Index.Body.Shadow.Colours[1],
            },
            .{
                .top_left = Index.Body.Highlight.Colours[0],
                .bottom_left = Index.Body.Highlight.Colours[1],
                .top_right = Index.Body.Highlight.Colours[0],
                .bottom_right = Index.Body.Highlight.Colours[1],
            },
        });

        id = ui.quad_shader.colour_index_data.data.len;
        Index.FocusHighlight.Top.ColourIndices = id;
        Index.FocusHighlight.Bottom.ColourIndices = id + 1;
        Index.FocusHighlight.Left.ColourIndices = id + 2;
        Index.FocusHighlight.Right.ColourIndices = id + 3;
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = Index.FocusHighlight.Colour,
                .bottom_left = Index.FocusHighlight.Colour,
                .top_right = Index.FocusHighlight.Colour,
                .bottom_right = Index.FocusHighlight.Colour,
            },
            .{
                .top_left = Index.FocusHighlight.Colour,
                .bottom_left = Index.FocusHighlight.Colour,
                .top_right = Index.FocusHighlight.Colour,
                .bottom_right = Index.FocusHighlight.Colour,
            },
            .{
                .top_left = Index.FocusHighlight.Colour,
                .bottom_left = Index.FocusHighlight.Colour,
                .top_right = Index.FocusHighlight.Colour,
                .bottom_right = Index.FocusHighlight.Colour,
            },
            .{
                .top_left = Index.FocusHighlight.Colour,
                .bottom_left = Index.FocusHighlight.Colour,
                .top_right = Index.FocusHighlight.Colour,
                .bottom_right = Index.FocusHighlight.Colour,
            },
        });

        Index.SearchText.PlaceholderText.ColourIndices = ui.quad_shader.colour_index_data.data.len;
        var index: usize = 0;
        while (index < placeholder_text.len) : (index += 1) {
            ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
                .{
                    .top_left = Index.SearchText.PlaceholderText.Colour,
                    .bottom_left = Index.SearchText.PlaceholderText.Colour,
                    .top_right = Index.SearchText.PlaceholderText.Colour,
                    .bottom_right = Index.SearchText.PlaceholderText.Colour,
                },
            });
        }

        Index.SearchText.UserText.ColourIndices = ui.quad_shader.colour_index_data.data.len;
        index = 0;
        while (index < 256) : (index += 1) {
            ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
                .{
                    .top_left = Index.SearchText.UserText.Colour,
                    .bottom_left = Index.SearchText.UserText.Colour,
                    .top_right = Index.SearchText.UserText.Colour,
                    .bottom_right = Index.SearchText.UserText.Colour,
                },
            });
        }

        id = ui.quad_shader.colour_index_data.data.len;
        Index.TextOverflow.Left.ColourIndices = id;
        Index.TextOverflow.Right.ColourIndices = id + 1;
        Index.SelectionRect.ColourIndices = id + 2;
        Index.TextCursor.ColourIndices = id + 3;
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = Index.TextOverflow.Colours[0],
                .bottom_left = Index.TextOverflow.Colours[1],
                .top_right = Index.TextOverflow.Colours[2],
                .bottom_right = Index.TextOverflow.Colours[3],
            },
            .{
                .top_left = Index.TextOverflow.Colours[2],
                .bottom_left = Index.TextOverflow.Colours[3],
                .top_right = Index.TextOverflow.Colours[0],
                .bottom_right = Index.TextOverflow.Colours[1],
            },
            .{
                .top_left = Index.SelectionRect.Colour,
                .bottom_left = Index.SelectionRect.Colour,
                .top_right = Index.SelectionRect.Colour,
                .bottom_right = Index.SelectionRect.Colour,
            },
            .{
                .top_left = Index.TextCursor.Colour,
                .bottom_left = Index.TextCursor.Colour,
                .top_right = Index.TextCursor.Colour,
                .bottom_right = Index.TextCursor.Colour,
            },
        });

        Index.FocusHighlight.DrawCommand = ui.quad_shader.draw_command_data.data.len;
        Index.SearchText.DrawCommand = Index.FocusHighlight.DrawCommand + 1;
        Index.TextOverflow.DrawCommand = Index.SearchText.DrawCommand + 1;
        ui.quad_shader.draw_command_data.append(&[_]DrawArraysIndirectCommand{
            .{
                .vertex_count = 4,
                .instance_count = @intCast(c_uint, Index.SearchText.PlaceholderText.Quad),
                .first_vertex = 0,
                .base_instance = 0,
            },
            .{
                .vertex_count = 4,
                .instance_count = @intCast(c_uint, Index.TextOverflow.Left.Quad - Index.SearchText.PlaceholderText.Quad),
                .first_vertex = 0,
                .base_instance = @intCast(c_uint, Index.SearchText.PlaceholderText.Quad),
            },
            .{
                .vertex_count = 4,
                .instance_count = @intCast(c_uint, Index.TextCursor.Quad - Index.TextOverflow.Left.Quad + 1),
                .first_vertex = 0,
                .base_instance = @intCast(c_uint, Index.TextOverflow.Left.Quad),
            },
        });

        self.insertPlaceholderText(ui);
    }

    fn insertPlaceholderText(self: *Self, ui: *UserInterface) void {
        var origin = text_offset_x;
        for (placeholder_text) |c, i| {
            const glyph = &ui.quad_shader.font.glyphs[c];
            const glyph_width = glyph.x1 - glyph.x0;
            const glyph_height = glyph.y1 - glyph.y0;
            const bearing_x = glyph.x_off;
            const bearing_y = glyph.y_off;
            const glyph_quad = ui.quadAt(Index.SearchText.PlaceholderText.Quad + i);

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

    pub fn onCursorPositionChanged(self: *Self, ui: *UserInterface) void {
        if (self.containsPoint(ui, ui.cursor_x, ui.cursor_y)) {
            self.onCursorEnter(ui);
        }
    }

    pub fn onCursorEnter(self: *Self, ui: *UserInterface) void {
        if (self.is_focused == false) {
            ui.colourAt(Index.Body.MainRect.Colours[0]).setRgbaInt(53, 54, 65, 255);
            ui.colourAt(Index.Body.MainRect.Colours[1]).setRgbaInt(58, 59, 70, 255);

            ui.colourAt(Index.TextOverflow.Colours[0]).setRgbInt(53, 54, 65);
            ui.colourAt(Index.TextOverflow.Colours[1]).setRgbInt(58, 59, 70);
            ui.colourAt(Index.TextOverflow.Colours[2]).setRgbInt(53, 54, 65);
            ui.colourAt(Index.TextOverflow.Colours[3]).setRgbInt(58, 59, 70);
        }

        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_IBEAM_CURSOR);
        glfwSetCursor(ui.window, ui.cursor);
        ui.widget_with_cursor = Widget.fromChild(self);
        ui.draw_required = true;
        ui.input_handled = true;
    }

    pub fn onCursorLeave(self: *Self, ui: *UserInterface) void {
        if (self.is_focused == false) {
            ui.colourAt(Index.Body.MainRect.Colours[0]).setRgbaInt(47, 48, 59, 255);
            ui.colourAt(Index.Body.MainRect.Colours[1]).setRgbaInt(52, 53, 64, 255);

            ui.colourAt(Index.TextOverflow.Colours[0]).setRgbInt(47, 48, 59);
            ui.colourAt(Index.TextOverflow.Colours[1]).setRgbInt(52, 53, 64);
            ui.colourAt(Index.TextOverflow.Colours[2]).setRgbInt(47, 48, 59);
            ui.colourAt(Index.TextOverflow.Colours[3]).setRgbInt(52, 53, 64);
        }

        glfwDestroyCursor(ui.cursor);
        ui.cursor = glfwCreateStandardCursor(GLFW_CURSOR_NORMAL);
        glfwSetCursor(ui.window, ui.cursor);
        ui.draw_required = true;
    }

    pub fn onLeftMouseDown(self: *Self, widget: *Widget, ui: *UserInterface, x: u16, y: u16) void {
        if (!self.is_focused) {
            self.onFocus(widget, ui);
        }

        self.elapsed_ns = 0;
    }

    pub fn onFocus(self: *Self, widget: *Widget, ui: *UserInterface) void {
        self.is_focused = true;

        ui.colourAt(Index.FocusHighlight.Colour).alpha = Colour.intVal(185);
        ui.colourAt(Index.TextCursor.Colour).alpha = Colour.intVal(220);

        if (self.search_string_length == 0) {
            ui.drawCommandAt(Index.SearchText.DrawCommand).instance_count = 0;
        }

        var i: usize = 0;
        while (i < ui.animating_widgets.len) : (i += 1) {
            var w = ui.animating_widgets.uncheckedAt(i);
            if (w.* == null) {
                // it is possible to retrieve the Widget union from the Widget type
                // w.* = @ptrCast(*Widget, @alignCast(@alignOf(*Widget), self));
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

        ui.colourAt(Index.Body.MainRect.Colours[0]).setRgbaInt(47, 48, 59, 255);
        ui.colourAt(Index.Body.MainRect.Colours[1]).setRgbaInt(52, 53, 64, 255);
        ui.colourAt(Index.FocusHighlight.Colour).alpha = Colour.intVal(0);
        ui.colourAt(Index.TextCursor.Colour).alpha = Colour.intVal(0);

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
                const new_char_index: u32 = @intCast(u32, math.min(self.search_string_length, self.cursor_position) + Index.SearchText.UserText.Quad);
                self.insertChar(ui, codepoint, new_char_index);
            }

            self.elapsed_ns = 0;
        }
    }

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface) void {
        ui.quadAt(Index.Body.MainRect.Quad).transform.width = ui.width - 160;
        ui.quadAt(Index.Body.Shadow.Quad).transform.width = ui.width - 160;
        ui.quadAt(Index.Body.Highlight.Quad).transform.width = ui.width - 162;

        ui.quadAt(Index.FocusHighlight.Top.Quad).transform.width = ui.width - 155;
        ui.quadAt(Index.FocusHighlight.Bottom.Quad).transform.width = ui.width - 155;
        ui.quadAt(Index.FocusHighlight.Right.Quad).transform.x = ui.width - 139;

        ui.quadAt(Index.TextOverflow.Right.Quad).transform.x = ui.width - 160;
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface, x: u16, y: u16) bool {
        return ui.quadAt(Index.Body.MainRect.Quad).contains(x, y);
    }

    pub fn animate(self: *Self, widget: *Widget, ui: *UserInterface, time_delta: u64) void {
        self.elapsed_ns += time_delta;
        if (self.elapsed_ns >= (1000 * 1000000)) {
            self.elapsed_ns = 0;
        }

        const alpha: u8 = if (self.elapsed_ns <= (500 * 1000000)) 180 else 0;
        ui.colourAt(Index.TextCursor.Colour).alpha = Colour.intVal(alpha);
        ui.animating = true;
    }

    inline fn moveCursor(self: *Self, ui: *UserInterface, advance: i32) void {
        const x = &ui.quadAt(Index.TextCursor.Quad).transform.x;
        x.* = @intCast(u16, @as(i17, x.*) + advance);
    }

    inline fn resetText(self: *Self, ui: *UserInterface) void {
        const d = ui.drawCommandAt(Index.SearchText.DrawCommand);
        d.instance_count = placeholder_text.len;
        d.base_instance = @intCast(c_uint, Index.SearchText.PlaceholderText.Quad);
    }

    inline fn updateText(self: *Self, ui: *UserInterface, text_length: u8) void {
        const d = ui.drawCommandAt(Index.SearchText.DrawCommand);
        d.instance_count = text_length;
        d.base_instance = @intCast(c_uint, Index.SearchText.UserText.Quad);
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
            const previous_character_quad_id = Index.SearchText.UserText.Quad + self.cursor_position - 1;
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

            self.moveCursor(ui, @bitCast(i32, -%character_advance));
            self.updateText(ui, self.search_string_length);
        }
    }

    inline fn onDelete(self: *Self, ui: *UserInterface) void {
        var q = &ui.quad_shader.quad_data;

        if (self.search_string_length > 0 and self.cursor_position < self.search_string_length) {
            const next_character_quad_id = Index.SearchText.UserText.Quad + self.cursor_position;
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
            const previous_character_quad_id = Index.SearchText.UserText.Quad + self.cursor_position - 1;
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
            const next_character_quad_id = Index.SearchText.UserText.Quad + self.cursor_position;
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
        const end_quad_id: usize = Index.SearchText.UserText.Quad + 255;
        var cursor_char_quad_id = Index.SearchText.UserText.Quad + self.cursor_position;
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
        cursor_char_quad_id = Index.SearchText.UserText.Quad + self.cursor_position;
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

        const q = &ui.quad_shader.quad_data.data[Index.SearchText.UserText.Quad + self.search_string_length - 1];

        ui.quad_shader.quad_data.data[Index.SelectionRect.Quad].transform.width = q.transform.x + q.transform.width - text_offset_x;
        ui.quad_shader.colour_data.data[Index.SelectionRect.Colour].alpha = 100.0 / 255.0;
    }

    inline fn calculateBackwardJump(self: *Self, ui: *UserInterface, index: u8, advance: *u16, num_chars: *u8) void {
        var q = &ui.quad_shader.quad_data;
        var i: u8 = index;
        if (q.data[i + 1].character == ' ') {
            while (i >= Index.SearchText.UserText.Quad and q.data[i].character == ' ') {
                advance.* += @intCast(u16, ui.quad_shader.font.glyphs[q.data[i].character].advance);
                i -= 1;
            }
        } else {
            while (i >= Index.SearchText.UserText.Quad and q.data[i].character != ' ') {
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
