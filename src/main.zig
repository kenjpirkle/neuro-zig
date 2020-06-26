const Database = @import("database.zig").Database;
const UserInterface = @import("user_interface.zig").UserInterface;
usingnamespace @import("c.zig");

pub fn main() anyerror!void {
    var database = try Database.init("C:/Users/kenny/Desktop/neuro.db");
    defer database.deinit();

    var ui: UserInterface() = undefined;
    try ui.init();
    defer ui.deinit();

    while (glfwWindowShouldClose(ui.window) == 0) {
        glfwPollEvents();
        ui.display();
    }
}
