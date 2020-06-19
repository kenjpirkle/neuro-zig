const Database = @import("database.zig").Database;
const ui = @import("user_interface.zig");
usingnamespace @import("print.zig");
usingnamespace @import("c.zig");

pub fn main() anyerror!void {
    var ft: FT_Library = undefined;
    if (FT_Init_FreeType(&ft) != 0) {
        printLine("could not initialize FreeType library");
        return error.FreeTypeLibraryFailed;
    }
    defer _ = FT_Done_FreeType(ft);

    var face: FT_Face = undefined;
    const font_face = "fonts/Lato/Lato-Light.ttf";
    if (FT_New_Face(ft, font_face, 0, &face) != 0) {
        printLine("could not load font: " ++ font_face);
        return error.FreeTypeLoadFaceFailed;
    }
    printLine("successfully loaded: " ++ font_face);
    defer _ = FT_Done_Face(face);

    var database = try Database.init("C:/Users/kenny/Desktop/neuro.db");
    defer database.deinit();

    try ui.init();
    defer ui.deinit();

    while (glfwWindowShouldClose(ui.window) == 0) {
        ui.display();
    }
}
