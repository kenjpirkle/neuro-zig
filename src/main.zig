const std = @import("std");
const warn = std.debug.warn;
usingnamespace @import("database.zig");
usingnamespace @import("user_interface.zig");
usingnamespace @import("c.zig");

pub fn main() anyerror!void {
    var database = try Database.init("C:/Users/kenny/Desktop/neuro.db");
    defer database.deinit();

    var ui = try UserInterface.init();
    defer ui.deinit();

    while (glfwWindowShouldClose(ui.window) == 0) {
        ui.display();
    }
}
