pub usingnamespace @cImport({
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("stdio.h");
    @cInclude("sqlite3.h");
    @cInclude("glad.h");
    @cInclude("glfw3.h");
    @cInclude("freetype.h");
});

pub const math = @cImport({
    @cInclude("math.h");
});
