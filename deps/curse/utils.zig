const std = @import("std");
const utf = @import("std").unicode;

/// Tools for internal variables

// Iterator support iteration string
pub const iteratS = struct {
    var strbuf:[] const u8 = undefined;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    //defer arena.deinit();
    const allocator = arena.allocator();
    /// Errors that may occur when using String
    pub const ErrNbrch = error{
        InvalideAllocBuffer,
    };
    fn allocBuffer ( size :usize) ErrNbrch![]u8 {
        var buf = allocator.alloc(u8, size) catch {
                return ErrNbrch.InvalideAllocBuffer;
            };
        return buf;
    }

    pub const StringIterator = struct {
        buf: []u8 ,
        index: usize ,

        pub fn next(it: *StringIterator) ?[]const u8 {
            var optional_buf: ?[]u8  = allocBuffer(strbuf.len) catch return null;
            it.buf= optional_buf orelse "";
            var n : usize = 0;
            while (true) {
                if (n >= strbuf.len) break;
                it.buf[n] = strbuf[n];
                n += 1;
            }

            if (it.index == it.buf.len) return null;
            var i = it.index;
            it.index += getUTF8Size(it.buf[i]);
            return it.buf[i..it.index];

        }
    };

    pub fn iterator(str:[] const u8) StringIterator {
        strbuf = str;
        return StringIterator{
            .buf = undefined,
            .index = 0,
        };
    }

    /// Returns the UTF-8 character's size
    fn getUTF8Size(char: u8) u3 {
        return std.unicode.utf8ByteSequenceLength(char) catch {
            return 1;
        };
    }
};