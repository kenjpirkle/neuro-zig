const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{
        .default_target = .{ .abi = .gnu },
    });

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("neuro-zig", "src/main.zig");
    exe.addLibPath("C:/mingw64/bin");
    exe.addLibPath("deps/freetype/lib");
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("glfw3");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("pthread");
    exe.linkSystemLibrary("freetype");
    exe.addIncludeDir("deps/freetype/include");
    exe.addIncludeDir("deps/freetype/include/freetype");
    exe.addIncludeDir("deps/GLFW/include");
    exe.addIncludeDir("deps/glad/include/glad");
    exe.addCSourceFile("deps/glad/src/glad.c", &[_][]const u8{ "-Ideps/glad/include/", "-O3" });
    exe.addIncludeDir("deps/sqlite3/include/");
    exe.addCSourceFile("deps/sqlite3/src/sqlite3.c", &[_][]const u8{
        "-Ideps/sqlite3/include/",
        "-DSQLITE_ENABLE_FTS5",
        "-O3",
        "-fno-sanitize=undefined",
    });
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
