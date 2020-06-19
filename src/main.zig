const std = @import("std");
const warn = std.debug.warn;
const Database = @import("database.zig").Database;
const ui = @import("user_interface.zig");
usingnamespace @import("c.zig");

pub fn main() anyerror!void {
    var ft: FT_Library = undefined;
    if (FT_Init_FreeType(&ft) != 0) {
        warn("could not initialize FreeType library\n", .{});
        return error.FreeTypeLibraryFailed;
    }
    defer _ = FT_Done_FreeType(ft);

    var face: FT_Face = undefined;
    const font_face = "fonts/Lato/Lato-Light.ttf";
    if (FT_New_Face(ft, font_face, 0, &face) != 0) {
        warn("could not load font {}\n", .{font_face});
        return error.FreeTypeLoadFaceFailed;
    }
    warn("successfully loaded {}\n", .{font_face});
    defer _ = FT_Done_Face(face);

    var database = try Database.init("C:/Users/kenny/Desktop/neuro.db");
    defer database.deinit();

    try ui.init();
    defer ui.deinit();

    while (glfwWindowShouldClose(ui.window) == 0) {
        ui.display();
    }
}
