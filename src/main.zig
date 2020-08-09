const Database = @import("database.zig").Database;
const UserInterface = @import("user_interface.zig").UserInterface;
const widget = @import("widgets/widget.zig");
usingnamespace @import("c.zig");

pub fn main() anyerror!void {
    var database = try Database.init("C:/Users/kenny/Desktop/neuro.db");
    defer database.deinit();

    var ui: UserInterface = undefined;
    try ui.init(widget.app_widgets[0..], widget.root_app_widgets[0..]);
    defer ui.deinit();
    ui.start();
}
