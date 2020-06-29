const warn = @import("std").debug.warn;
const builtin = @import("std").builtin;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const BufferIndices = @import("../gl/buffer_indices.zig").BufferIndices;
const Quad = @import("../gl/quad.zig").Quad;
const QuadTransform = @import("../gl/quad_transform.zig").QuadTransform;
const QuadColourIndices = @import("../gl/quad_colour_indices.zig").QuadColourIndices;
const Colour = @import("../gl/colour.zig").Colour;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;
usingnamespace @import("../c.zig");

const Index = struct {
    pub const Body = struct {
        pub const MainRect = struct {
            pub const QuadId = 1;
            pub const ColourId = 1;
            pub const ColourIndicesId = 1;
        };
        pub const Shadow = struct {
            pub const QuadId = 2;
            pub const ColourId = 3;
            pub const ColourIndicesId = 2;
        };
        pub const Highlight = struct {
            pub const QuadId = 3;
            pub const ColourId = 5;
            pub const ColourIndicesId = 3;
        };
    };

    pub const FocusHighlight = struct {
        pub const Top = struct {
            pub const QuadId = 4;
            pub const ColourIndicesId = 4;
        };
        pub const Bottom = struct {
            pub const QuadId = 5;
            pub const ColourIndicesId = 5;
        };
        pub const Left = struct {
            pub const QuadId = 6;
            pub const ColourIndicesId = 6;
        };
        pub const Right = struct {
            pub const QuadId = 7;
            pub const ColourIndicesId = 7;
        };
        pub const ColourId = 7;
    };

    pub const SearchText = struct {
        pub const PlaceholderText = struct {
            pub const QuadId = 8;
            pub const ColourIndicesId = 8;
        };
        pub const UserText = struct {
            pub const QuadId = 17;
            pub const ColourIndicesId = 17;
        };
        pub const ColourId = 8;
        pub const DrawCommandId = 1;
    };

    pub const TextOverflow = struct {
        pub const Left = struct {
            pub const QuadId = 273;
            pub const ColourIndicesId = 273;
        };
        pub const Right = struct {
            pub const QuadId = 274;
            pub const ColourIndicesId = 274;
        };
        pub const ColourId = 9;
    };

    pub const TextCursor = struct {
        pub const QuadId = 275;
        pub const ColourId = 13;
        pub const ColourIndicesId = 275;
    };

    pub const SuggestionRects = struct {
        pub const QuadId = 276;
        pub const ColourId = 14;
        pub const ColourIndicesId = 276;
        pub const DrawCommandId = 2;
    };

    pub const SuggestionText = struct {
        pub const QuadId = 286;
        pub const ColourId = 16;
        pub const ColourIndicesId = 286;
        pub const DrawCommandId = 3;
    };
};

pub const SearchBar = struct {
    const Self = @This();

    const placeholder_text = "search...";
    const text_offset_x: u16 = 30;
    const text_offset_y: u16 = 43;

    parent: ?*Widget = null,
    elapsed_ns: u64 = 0,
    cursor_text_origin: u16 = text_offset_x,
    cursor_position: u8 = 0,
    search_string_length: u8 = 0,
    is_focused: bool = false,
    text_navigation_mode: bool = false,
    input_handled: bool = false,

    pub fn insertIntoUi(self: *Self, ui: *UserInterface()) !void {
        ui.quad_shader.quad_data.beginModify();
        ui.quad_shader.colour_data.beginModify();
        ui.quad_shader.colour_index_data.beginModify();
        ui.quad_shader.draw_command_data.beginModify();

        ui.quad_shader.quad_data.append(&[_]Quad{
            // main body
            .{
                .transform = .{
                    .x = 20,
                    .y = 20,
                    .width = ui.width - 160,
                    .height = 34,
                },
                .layer = 2,
                .character = 0,
            },
            // main body shadow
            .{
                .transform = .{
                    .x = 20,
                    .y = 20,
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
                    .y = 52,
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
                    .y = 18,
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
                    .y = 55,
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
                    .y = 19,
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
                    .y = 19,
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
                    .y = 20,
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
                    .y = 20,
                    .width = text_offset_x,
                    .height = 34,
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
        });

        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = 1,
                .bottom_left = 2,
                .top_right = 1,
                .bottom_right = 2,
            },
            .{
                .top_left = 3,
                .bottom_left = 4,
                .top_right = 3,
                .bottom_right = 4,
            },
            .{
                .top_left = 5,
                .bottom_left = 6,
                .top_right = 5,
                .bottom_right = 6,
            },
        });
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = 7,
                .bottom_left = 7,
                .top_right = 7,
                .bottom_right = 7,
            },
        } ** 4);
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = 8,
                .bottom_left = 8,
                .top_right = 8,
                .bottom_right = 8,
            },
        } ** 265);
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = 9,
                .bottom_left = 10,
                .top_right = 11,
                .bottom_right = 12,
            },
            .{
                .top_left = 11,
                .bottom_left = 12,
                .top_right = 9,
                .bottom_right = 10,
            },
            .{
                .top_left = 13,
                .bottom_left = 13,
                .top_right = 13,
                .bottom_right = 13,
            },
        });

        ui.quad_shader.draw_command_data.append(&[_]DrawArraysIndirectCommand{
            .{
                .vertex_count = 4,
                .instance_count = 8,
                .first_vertex = 0,
                .base_instance = 0,
            },
            .{
                .vertex_count = 4,
                .instance_count = 265,
                .first_vertex = 0,
                .base_instance = 8,
            },
            .{
                .vertex_count = 4,
                .instance_count = 3,
                .first_vertex = 0,
                .base_instance = 273,
            },
        });

        self.insertPlaceholderText(ui);

        ui.quad_shader.quad_data.endModify();
        ui.quad_shader.colour_data.endModify();
        ui.quad_shader.colour_index_data.endModify();
        ui.quad_shader.draw_command_data.endModify();
    }

    fn insertPlaceholderText(self: *Self, ui: *UserInterface()) void {
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

    pub fn onCursorEnter(self: *Self, ui: *UserInterface()) void {
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

    pub fn onCursorLeave(self: *Self, ui: *UserInterface()) void {
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

    pub fn onLeftMouseDown(self: *Self, widget: *Widget, ui: *UserInterface()) void {
        if (builtin.mode == .Debug) {
            warn("left mouse button down on SearchBar\n", .{});
        }

        self.onFocus(widget, ui);
    }

    pub fn onFocus(self: *Self, widget: *Widget, ui: *UserInterface()) void {
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

    pub fn onUnfocus(self: *Self, widget: *Widget, ui: *UserInterface()) void {
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

        ui.draw_required = true;
    }

    pub fn onWindowSizeChanged(self: *Self, ui: *UserInterface()) void {
        const quads = ui.quad_shader.quad_data.data;

        quads[Index.Body.MainRect.QuadId].transform.width = ui.width - 160;
        quads[Index.Body.Shadow.QuadId].transform.width = ui.width - 160;
        quads[Index.Body.Highlight.QuadId].transform.width = ui.width - 162;

        quads[Index.FocusHighlight.Top.QuadId].transform.width = ui.width - 155;
        quads[Index.FocusHighlight.Bottom.QuadId].transform.width = ui.width - 155;
        quads[Index.FocusHighlight.Right.QuadId].transform.x = ui.width - 139;

        quads[Index.TextOverflow.Right.QuadId].transform.x = ui.width - 160;
    }

    pub fn containsPoint(self: *Self, ui: *UserInterface(), x: u16, y: u16) bool {
        const t = ui.quad_shader.quad_data.data[Index.Body.MainRect.QuadId].transform;
        return (x >= t.x) and (x <= (t.x + t.width)) and (y >= t.y) and (y <= (t.y + t.height));
    }

    pub fn animate(self: *Self, widget: *Widget, ui: *UserInterface(), time_delta: u64) void {
        self.elapsed_ns += time_delta;
        if (self.elapsed_ns >= (1000 * 1000000)) {
            self.elapsed_ns = 0;
        }

        const alpha: f32 = if (self.elapsed_ns <= (500 * 1000000)) 180.0 / 255.0 else 0.0;
        ui.quad_shader.colour_data.data[Index.TextCursor.ColourId].alpha = alpha;
        ui.animating = true;
    }
};
