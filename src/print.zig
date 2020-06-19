const warn = @import("std").debug.warn;

pub fn print(item: var) void {
    warn("{}", .{item});
}

pub fn printLine(item: var) void {
    warn("{}\n", .{item});
}