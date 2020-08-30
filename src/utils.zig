pub inline fn add(a: *u32, b: i32) void {
    const result = @intCast(u32, @as(i33, a.*) + b);
    a.* = result;
}

pub inline fn addU(a: u32, b: i32) u32 {
    return @intCast(u32, @as(i33, a) + b);
}
