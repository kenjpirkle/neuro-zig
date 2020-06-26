const warn = @import("std").debug.warn;
const UserInterface = @import("../user_interface.zig").UserInterface;
const Widget = @import("widget.zig").Widget;
const BufferIndices = @import("../gl/buffer_indices.zig").BufferIndices;
const Quad = @import("../gl/quad.zig").Quad;
const QuadTransform = @import("../gl/quad_transform.zig").QuadTransform;
const QuadColourIndices = @import("../gl/quad_colour_indices.zig").QuadColourIndices;
const Colour = @import("../gl/colour.zig").Colour;
const DrawArraysIndirectCommand = @import("../gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;

pub const SearchBar = packed struct {
    const placeholder_text = "search...";
    const text_offset_x: u16 = 30;
    const text_offset_y: u16 = 44;

    parent: ?*Widget = null,
    elapsed_ms: u64 = 0,
    cursor_text_origin: u16 = text_offset_x,
    cursor_position: u8 = 0,
    search_string_length: u8 = 0,
    is_focused: bool = false,
    text_navigation_mode: bool = false,
    input_handled: bool = false,

    pub fn insertIntoUi(self: *SearchBar, ui: *UserInterface()) !void {
        ui.quad_shader.quad_data.beginModify();
        ui.quad_shader.colour_data.beginModify();
        ui.quad_shader.colour_index_data.beginModify();
        ui.quad_shader.draw_command_data.beginModify();

        ui.quad_shader.quad_data.append(&[_]Quad{
            .{
                .transform = .{
                    .x = 20,
                    .y = 20,
                    .width = ui.width - 160,
                    .height = 34,
                },
                .layer = 1,
                .character = 0,
            },
        });
        ui.quad_shader.colour_data.append(&[_]Colour{
            .{
                .red = 47.0 / 255.0,
                .green = 48.0 / 255.0,
                .blue = 59.0 / 255.0,
                .alpha = 1.0,
            },
            .{
                .red = (47.0 + 5.0) / 255.0,
                .green = (48.0 + 5.0) / 255.0,
                .blue = (59.0 + 5.0) / 255.0,
                .alpha = 1.0,
            },
        });
        ui.quad_shader.colour_index_data.append(&[_]QuadColourIndices{
            .{
                .top_left = 0,
                .bottom_left = 1,
                .top_right = 0,
                .bottom_right = 1,
            },
        });
        ui.quad_shader.draw_command_data.append(&[_]DrawArraysIndirectCommand{
            .{
                .vertex_count = 4,
                .instance_count = 1,
                .first_vertex = 0,
                .base_instance = 0,
            },
        });

        ui.quad_shader.quad_data.endModify();
        ui.quad_shader.colour_data.endModify();
        ui.quad_shader.colour_index_data.endModify();
        ui.quad_shader.draw_command_data.endModify();
    }

    pub fn onCursorEnter(self: *SearchBar) void {
        warn("cursor entered the SearchBar\n", .{});
    }

    pub fn onCursorLeave(self: *SearchBar) void {
        warn("cursor left the SearchBar\n", .{});
    }

    pub fn onLeftMouseDown(self: *SearchBar) void {
        warn("left mouse button down on SearchBar\n", .{});
    }

    pub fn onFocus(self: *SearchBar) void {
        warn("SearchBar focus\n", .{});
    }

    pub fn onUnfocus(self: *SearchBar) void {
        warn("SearchBar unfocus\n", .{});
    }

    pub fn onWindowSizeChanged(self: *SearchBar, width: c_int, height: c_int) void {}

    pub fn containsPoint(self: *SearchBar, x: u16, y: u16) bool {
        return (x >= 20) and (x <= 940) and (y >= 20) and (y <= 20 + 34);
    }
};
