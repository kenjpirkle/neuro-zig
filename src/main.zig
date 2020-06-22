const Database = @import("database.zig").Database;
const ui = @import("user_interface.zig");
usingnamespace @import("c.zig");

pub fn main() anyerror!void {
    var database = try Database.init("C:/Users/kenny/Desktop/neuro.db");
    defer database.deinit();

    try ui.init();
    defer ui.deinit();

    while (glfwWindowShouldClose(ui.window) == 0) {
        ui.display();
    }
}
