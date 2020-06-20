usingnamespace @import("c.zig");

const map_flags: GLbitfield = GL_MAP_READ_BIT | GL_MAP_WRITE_BIT | GL_MAP_PERSISTENT_BIT | GL_MAP_COHERENT_BIT;
const create_flags: GLbitfield = map_flags | GL_DYNAMIC_STORAGE_BIT;

pub fn MapBuffer(comptime T: type, comptime size: usize) type {
    return struct {
        data: []T,
        count: usize,
        fence: GLsync,

        pub fn init(self: *MapBuffer(T, size), id: GLuint, target: GLenum) !void {
            glBindBuffer(target, id);
            glNamedBufferStorage(id, @sizeOf(T) * size, null, create_flags);
            const cptr = glMapNamedBufferRange(id, 0, @sizeOf(T) * size, map_flags);

            self.data.ptr = @ptrCast([*]T, @alignCast(@alignOf([*]T), cptr));
            self.data.len = size;
            self.count = 0;
            self.fence = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);
        }

        pub fn beginModify(self: *MapBuffer(T, id)) void {
            glWaitSync(self.fence, 0, GL_TIMEOUT_IRGNORED);
        }

        pub fn endModify(self: *MapBuffer(T, id)) void {
            glDeleteSync(self.fence);
            self.fence = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);
        }
    };
}
