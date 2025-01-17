const Builder = @import("std").build.Builder;
const Mode = @import("builtin").Mode;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{ .abi = .gnu },
    });
    const mode = b.standardReleaseOptions();

    const exec_name = switch (mode) {
        .Debug => "neuro-zig-debug",
        .ReleaseSafe => "neuro-zig-release-safe",
        .ReleaseSmall => "neuro-zig-release-small",
        .ReleaseFast => "neuro-zig-release-fast",
    };

    const exe = b.addExecutable(exec_name, "src/main.zig");
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
    exe.addCSourceFile("deps/glad/src/glad.c", &[_][]const u8{
        "-Ideps/glad/include/",
        "-O3",
    });
    exe.addIncludeDir("deps/sqlite3/include/");
    exe.addCSourceFile("deps/sqlite3/src/sqlite3.c", &[_][]const u8{
        "-Ideps/sqlite3/include/",
        "-DSQLITE_ENABLE_FTS5",
        "-O3",
    });
    exe.addIncludeDir("deps/");
    exe.addCSourceFile("deps/stb_image.c", &[_][]const u8{
        "-Ideps/",
        "-std=c17",
        "-O3",
    });
    exe.addCSourceFile("deps/stb_image_write.c", &[_][]const u8{
        "-Ideps/",
        "-std=c17",
        "-O3",
    });
    exe.addCSourceFile("deps/stb_truetype.c", &[_][]const u8{
        "-Ideps/",
        "-std=c17",
        "-O3",
    });
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
