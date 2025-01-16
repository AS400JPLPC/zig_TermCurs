const std = @import("std");
const utf = @import("std").unicode;

    var arenaZfld = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocZfld = arenaZfld.allocator();
	pub fn deinitZfld() void {
	    arenaZfld.deinit();
	    arenaZfld = std.heap.ArenaAllocator.init(std.heap.page_allocator);
	    allocZfld = arenaZfld.allocator();
	}
/// A variable length collection of characters
pub const ZFIELD = struct {

    /// The internal character buffer
    buffer: ?[]u8,

    /// The total size of the ZFIELD
    size: usize,

    nbc : usize,

  
    pub const CMP = enum { LT, EQ, GT };

    pub const err : usize = 999999999;

    /// Errors that may occur when using ZFIELD
    pub const Error = error{
        OutOfMemory,
        InvalidRange,
    };

    /// Creates a ZFIELD 
    /// ### example
    /// ```zig
    /// var str = ZFIELD.init( 30 );
    /// // don't forget to deallocate
    /// defer _ = str.deinit();
    /// ```
    /// nbrchar != 0 ---> zoned ex: setZoned getZoned  ... {normalize}

     pub fn init(nbrchar : usize) ZFIELD {
      	return  .{
            .buffer = null,
            .size = 0,
            .nbc = nbrchar,
        };

    }



    /// User is responsible for managing allocator ex: ArenaAllocator
    pub fn deinit(self: *ZFIELD) void {
        if (self.buffer) |buffer| allocZfld.free(buffer);
        self.buffer = null;
        self.size = 0;
        self.nbc = 0;
      
    }

    /// Allocates space for the internal buffer
    fn allocate(self: *ZFIELD, bytes: usize) Error!void {
        if (self.buffer) |buffer| {
            if (self.size > 0) self.size = bytes; // Clamp size to capacity
            self.buffer = allocZfld.realloc(buffer, bytes) catch {
                return Error.OutOfMemory;
            };
        } else {
            self.buffer = allocZfld.alloc(u8, bytes) catch {
                return Error.OutOfMemory;
            };
        }
    }

    /// Returns the size of the internal buffer
    pub fn capacity(self: ZFIELD) usize {
        if (self.buffer) |buffer| return buffer.len;
        return 0;
    }

    /// Returns the size of the internal buffer
    pub fn getnbc(self: ZFIELD) usize {
        return self.nbc ;
    }

    /// Returns amount of characters in the ZFIELD
    pub fn len(self: ZFIELD) usize {
        if (self.buffer) |buffer| {
            var length: usize = 0;
            var i: usize = 0;

            while (i < self.size) {
                i += ZFIELD.getUTF8Size(buffer[i]);
                length += 1;
            }

            return length;
        } else {
            return 0;
        }
    }

    





     /// Clears the contents of the ZFIELD but leaves the capacity
    pub fn clear(self: *ZFIELD) void {
       self.buffer = null;
       self.size = 0;
    }

    /// Compares this ZFIELD with a ZFIELD literal
    pub fn cmpeql(self: ZFIELD, literal: []const u8) bool {
        if (self.buffer) |buffer| {
            return std.mem.eql(u8, buffer[0..self.size], literal);
        }
        return false;
    }

    /// comp string
    /// LT EQ GT -> enum CMP
    pub fn cmpxx(self: ZFIELD, literal: []const u8) ZFIELD.CMP {
        const str1 = self.getStr();
        const order = std.mem.order(u8, str1, literal);
        switch (order) {
            .lt => return CMP.LT,
            .eq => return CMP.EQ,
            .gt => return CMP.GT,
        }
    }

    /// check normalise for sql or screen or buffering 
    pub fn check( self: *ZFIELD) bool {
        if ( self.len() > self.nbc) return false ;
        return true ; 
    }



    /// get string  for sql or buffering  screen
    pub fn string(self: *ZFIELD) [] const u8 {
        self.normalize();
        if (self.buffer) |buffer| return buffer[0..self.size];
        return "";
    }


    /// getStr buffer
    fn getStr(self: ZFIELD) [] const u8 {
          if (self.buffer) |buffer| return buffer[0..self.size];
        return "";
    }

    /// Sets Literal
    /// Be careful not to exceed, but can be useful in certain cases
    pub fn setFull(self: *ZFIELD, literal: []const u8) Error!void {
        self.clear();
        try self.allocate(literal.len);
         if (self.buffer) |buffer| {
            var  i : usize = 0;
            while (i < literal.len) : (i += 1) {
                 buffer[i] = literal[i];
            }
            self.size = literal.len;
         }
    }

    /// Sets Literal the contents of the ZFIELD of normalize
    pub fn setZfld(self: *ZFIELD, literal: []const u8) Error!void {
        self.clear();
        try self.allocate(literal.len);
         if (self.buffer) |buffer| {
            var  i : usize = 0;
            while (i < literal.len) : (i += 1) {
                 buffer[i] = literal[i];
            }
            self.size = literal.len;
            self.normalize();
        }
    }

    /// normalize for sql or buffering  screen
    fn normalize(self: *ZFIELD) void{
         if (self.buffer) |buffer| {
            var length: usize = 0;
            var i: usize = 0;

            while (i < self.size) {
                i += ZFIELD.getUTF8Size(buffer[i]);
                length += 1;
                if ( length == self.nbc) {
                    self.allocate(i) catch unreachable;
                    break;
                }
            }
         }
        self.size = self.capacity(); 
    }

    /// returns string from a given range
    pub fn getSubstr(self: ZFIELD, start: usize, end: usize ) ! []const u8 {
        if (self.buffer) |buffer| {
            if (ZFIELD.getIndex(buffer, start, true)) |rStart| {
                if (ZFIELD.getIndex(buffer, end, true)) |rEnd| {
                    if (rEnd < rStart or rEnd > self.size) return Error.InvalidRange;
                    return(buffer[rStart..rEnd]);
                }
            }
        }
        return "";
     }


    /// Copies this String into a new one
    /// User is responsible for managing the new String
    pub fn clone(self: ZFIELD) Error!ZFIELD {
        var newString = ZFIELD.init(self.nbc);
        try newString.setZfld(self.getStr());
        return newString;
    }

    /// Removes the last character from the ZFIELD
    pub fn pop(self: *ZFIELD) ?[]const u8 {
        if (self.size == 0) return null;

        if (self.buffer) |buffer| {
            var i: usize = 0;
            while (i < self.size) {
                const size = ZFIELD.getUTF8Size(buffer[i]);
                if (i + size >= self.size) break;
                i += size;
            }

            const ret = buffer[i..self.size];
            self.size -= (self.size - i);
            return ret;
        }

        return null ;
    }

    /// Removes a character at the specified index
    pub fn remove(self: *ZFIELD, index: usize) !bool {
        if (index > self.size) return false;
        if (index < self.size ) try self.removeRange(index, index + 1)
        else {
            // char last
            if (self.buffer) |buffer| { 
                const rEnd = ZFIELD.getIndex(buffer, index - 1, true).?;
                self.size = rEnd;
                try self.allocate(self.size);
            }
        }
        return true;
    }

    /// Removes a range of character from the String
    /// Start (inclusive) - End (Exclusive)
    fn removeRange(self: *ZFIELD, start: usize, end: usize) Error!void {
        const length = self.len();
        if (end < start or end > length) return Error.InvalidRange;

        if (self.buffer) |buffer| {
            const rStart = ZFIELD.getIndex(buffer, start, true).?;
            const rEnd = ZFIELD.getIndex(buffer, end, true).?;
            const difference = rEnd - rStart;

            var i: usize = rEnd;
            while (i < self.size) : (i += 1) {
                buffer[i - difference] = buffer[i];
            }
            self.size -= difference;
            try self.allocate(self.size);
        }
    }







    /// Returns an owned slice of this ZFIELD
    pub fn toOwned(self: ZFIELD) Error!?[]u8 {
        if (self.buffer != null) {
            const txt = self.str();
            if (allocZfld.alloc(u8, ZFIELD.len)) |newStr| {
                std.mem.copyForwards(u8, newStr, txt);
                return newStr;
            } else |_| {
                return Error.OutOfMemory;
            }
        }
        return ;
     }

    /// Returns a character at the specified index
    pub fn charAt(self: ZFIELD, index: usize) ?[]const u8 {
        if (self.buffer) |buffer| {
            if (ZFIELD.getIndex(buffer, index, true)) |i| {
                const size = ZFIELD.getUTF8Size(buffer[i]);
                return buffer[i..(i + size)];
            }
        }
        return ;
    }






    /// Checks the ZFIELD is empty
    pub inline fn isEmpty(self: ZFIELD) bool {
        if ( self.size > 0) return false ;
        return  true;
    }

    /// Finds the first occurrence of the ZFIELD literal
    pub fn find(self: ZFIELD, literal: []const u8) usize {
        if (self.buffer) |buffer| {
            const index = std.mem.indexOf(u8, buffer[0..self.size], literal);
            if (index) |i| {
                return ZFIELD.getIndex(buffer, i, false) orelse err;
            }
        }
        return err ;
    }

    /// Finds the last occurrence of the ZFIELD literal
    pub fn rfind(self: ZFIELD, literal: []const u8) usize {
        if (self.buffer) |buffer| {
            const index = std.mem.lastIndexOf(u8, buffer[0..self.size], literal);
            if (index) |i| {
                return ZFIELD.getIndex(buffer, i, false) orelse err;
            }
        }

        return err ;
    }

    /// Finds the position occurrence of the string literal
    pub fn findPos(self: ZFIELD, pos: usize , literal: []const u8) ?usize {
        if (pos <= self.size) {
            if (self.buffer) |buffer| {
                const index = std.mem.indexOf(u8, buffer[pos..self.size], literal);
                if (index) |i| {
                    return ZFIELD.getIndex(buffer, i + pos, false);
                }
            }
        }
        return null;
    }






    // Iterator support
    pub const zfldIterator = struct {
        ZFIELD: *const ZFIELD,
        index: usize,

        pub fn next(it: *zfldIterator) ?[]const u8 {
            if (it.ZFIELD.buffer) |buffer| {
                if (it.index == it.ZFIELD.size) return null;
                const i = it.index;
                it.index += ZFIELD.getUTF8Size(buffer[i]);
                 return buffer[i..it.index];
            } else {
                return null;
            }
        }
        pub fn preview(it: *zfldIterator) ?[]const u8 {
            if (it.index == 0 ) return null;
            if (it.ZFIELD.buffer) |buffer| {
                const i = it.index;
                it.index -= ZFIELD.getUTF8Size(buffer[i]);
                return buffer[i..it.index];
            } else {
                return null;
            }
        }
    };



    pub fn iterator(self: *const ZFIELD) zfldIterator {
        return zfldIterator{
            .ZFIELD = self,
            .index = 0,
        };
    }

    /// Checks if byte is part of UTF-8 character
    inline fn isUTF8Byte(byte: u8) bool {
        return ((byte & 0x80) > 0) and (((byte << 1) & 0x80) == 0);
    }

    /// Returns the real index of a unicode ZFIELD literal
    fn getIndex(unicode: []const u8, index: usize, real: bool) ?usize {
        var i: usize = 0;
        var j: usize = 0;
        while (i < unicode.len) {
            if (real) {
                if (j == index) return i;
            } else {
                if (i == index) return j;
            }
            i += ZFIELD.getUTF8Size(unicode[i]);
            j += 1;
        }
        return null;
    }

    /// Returns the UTF-8 character's size
    inline fn getUTF8Size(char: u8) u3 {
        return std.unicode.utf8ByteSequenceLength(char) catch {
            return 1;
        };
    }







    /// Appends a character onto the end of the ZFIELD
    /// Be careful not to exceed, but can be useful in certain cases
    pub fn concat(self: *ZFIELD, literal: []const u8) Error!void {
        // Make sure buffer has enough space
        const index : usize = self.capacity(); 
        if (self.buffer) |buffer| {
            if (self.size + literal.len > buffer.len) {
                try self.allocate((self.size + literal.len));
            }
        } else {
            try self.allocate(literal.len);
        }        const buffer = self.buffer.?;

        // If not, then copy contents over and insert literal.
        var i: usize = 0;
        while (i < literal.len) : (i += 1) {
            buffer[index + i] = literal[i];
        }
        self.size = buffer.len;
    }

    /// Replaces all occurrences of a ZFIELD literal with another
    /// Be careful not to exceed, but can be useful in certain cases
    pub fn replace(self: *ZFIELD, needle: []const u8, replacement: []const u8) !bool {
        if (self.buffer) |buffer| {
            const InputSize = self.size;
            const size = std.mem.replacementSize(u8, buffer[0..InputSize], needle, replacement);
            defer allocZfld.free(buffer);
            self.buffer = allocZfld.alloc(u8, size) catch {
                return Error.OutOfMemory;
            };
            self.size = size;
            const changes = std.mem.replace(u8, buffer[0..InputSize], needle, replacement, self.buffer.?);
            if (changes > 0) {
                return true;
            }
        }
        return false;
    }


   /// Reverses the characters in this ZFIELD
    pub fn reverse(self: *ZFIELD) void {
        if (self.buffer) |buffer| {
            var i: usize = 0;
            while (i < self.size) {
                const size = ZFIELD.getUTF8Size(buffer[i]);
                if (size > 1) std.mem.reverse(u8, buffer[i..(i + size)]);
                i += size;
            }

            std.mem.reverse(u8, buffer[0..self.size]);
        }
    }


    /// truncat 
    fn truncat(self: *ZFIELD, index: usize) ! void{
        if (self.nbc < index) return Error.InvalidRange;
        if (self.buffer) |buffer| {
            var length: usize = 0;
            var i: usize = 0;

            while (i < self.size) {
                i += ZFIELD.getUTF8Size(buffer[i]);
                length += 1;
                if ( length == index) {
                    self.allocate(i) catch unreachable;
                    break;
                }
            }
         }
        self.size = self.capacity(); 
    }







    /// Converts all (UTF8) uppercase letters to lowercase
    /// String Latin
    pub fn lowercase(self: *ZFIELD) void {
        if (self.buffer) |_| {
    	    var i :usize = 0;
    	    var iter = self.iterator();
            var zone : [4]   u8 = undefined;
        	var car :[]const u8 = undefined;
        	var r : u21 = 0 ;
        	while (iter.next()) |ch | {
        	    const x = utf.utf8Decode(ch) catch unreachable;
         		r = 0 ;
        		if ( x >= 65 and x <= 90 )  r = x + 32;
                if ( x >= 192 and x <= 223 )  r = x + 32;
                if ( x == 339 )  r = x + 1;
                if ( x == 253 )  r = 255;
        		if (r > 0 ) { 
    				zone = [_]u8{0} ** 4;
    				i = utf.utf8Encode(r,&zone) catch unreachable;
    				car = zone[0..i];
    				_= self.replace(ch,car) catch unreachable;
    			}
         	}
        }	
    }


    /// upper-case String Latin
    pub fn uppercase(self: *ZFIELD) void {
    	if (self.buffer) |_| {
    	    var i :usize = 0;
    	    var iter = self.iterator();
            var zone : [4]   u8 = undefined;
        	var car :[]const u8 = undefined;
        	var r : u21 = 0 ;
        	while (iter.next()) |ch | {
        	    const x = utf.utf8Decode(ch) catch unreachable;
         		r = 0 ;
        		if ( x >= 97 and x <= 122 )  r = x - 32;
                if ( x >= 224 and x <= 255 )  r = x - 32;
                if ( x == 339 )  r = x - 1;
                if ( x == 255 )  r = 253;
        		if (r > 0 ) { 
    				zone = [_]u8{0} ** 4;
    				i = utf.utf8Encode(r,&zone) catch unreachable;
    				car = zone[0..i];
    				_= self.replace(ch,car) catch unreachable;
    			}
         	}
        }	
    }

    /// upper-case String Latin
    pub fn capitalized(self: *ZFIELD) void {
    	if (self.buffer) |_| {
    	    var i :usize = 0;
    	    var iter = self.iterator();
            var zone : [4]   u8 = undefined;
        	var car :[]const u8 = undefined;
        	var r : u21 = 0 ;
        	var is_new_word: bool = true;
        	var str : [] const u8 = "";

        	while (iter.next()) |ch| {
        	    
        	    const x = utf.utf8Decode(ch) catch unreachable;
        	    if (x == 32) {
                    is_new_word = true;
                    str = std.fmt.allocPrint(allocZfld, "{s}{s}", .{str ," "}) catch unreachable;
                    continue;
                }
                if (is_new_word) {
             		r = 0 ;
            		if ( x >= 97 and x <= 122 )  r = x - 32;
                    if ( x >= 224 and x <= 255 )  r = x - 32;
                    if ( x == 339 )  r = x - 1;
                    if ( x == 255 )  r = 253;
            		if (r > 0 ) { 
        				zone = [_]u8{0} ** 4;
        				i = utf.utf8Encode(r,&zone) catch unreachable;
        				car = "";
        				car = zone[0..i];
        				str = std.fmt.allocPrint(allocZfld, "{s}{s}", .{str ,car}) catch unreachable;
        				is_new_word = false;
                        continue;
        			}
        		}else {
        		    zone = [_]u8{0} ** 4;
    				i = utf.utf8Encode(x,&zone) catch unreachable;
    				car = "";
    				car = zone[0..i];
    				str = std.fmt.allocPrint(allocZfld, "{s}{s}", .{str ,car}) catch unreachable;
        		}	
             }
            self.setZfld(str) catch unreachable;
            defer allocZfld.free(str);         }	
    }






   /// Checks whether or not a character is whitelisted
    fn inWhitelist(char: u8, whitelist: []const u8) bool {
        var i: usize = 0;
        while (i < whitelist.len) : (i += 1) {
            if (whitelist[i] == char) return true;
        }
        return false;
    }


    /// Trims all whitelist characters at the start of the ZFIELD.
    pub fn trimStart(self: *ZFIELD, whitelist: []const u8) void {
        if (self.buffer) |buffer| {
            var i: usize = 0;
            while (i < self.size) : (i += 1) {
                const size = ZFIELD.getUTF8Size(buffer[i]);
                if (size > 1 or !inWhitelist(buffer[i], whitelist)) break;
            }

            if (ZFIELD.getIndex(buffer, i, false)) |k| {
                self.removeRange(0, k) catch {};
            }
        }
    }

    /// Trims all whitelist characters at the end of the ZFIELD.
    pub fn trimEnd(self: *ZFIELD, whitelist: []const u8) void {
        self.reverse();
        self.trimStart(whitelist);
        self.reverse();
    }

    /// Trims all whitelist characters from both ends of the ZFIELD
    pub fn trim(self: *ZFIELD, whitelist: []const u8) void {
        self.trimStart(whitelist);
        self.trimEnd(whitelist);
    }






    /// Checks the start of the ZFIELD against a literal
    pub fn inStartsWith(self: *ZFIELD, literal: []const u8) bool {
        if (self.buffer) |buffer| {
            const index = std.mem.indexOf(u8, buffer[0..self.size], literal);
            return index == 0;
        }
        return false;
    }

    /// Checks the end of the ZFIELD against a literal
    pub fn inEndsWith(self: *ZFIELD, literal: []const u8) bool {
        if (self.buffer) |buffer| {
            const index = std.mem.lastIndexOf(u8, buffer[0..self.size], literal);
            const i: usize = self.size - literal.len;
            return index == i;
        }
        return false;
    }

    /// Checks if the needle ZFIELD is within the source ZFIELD
    pub fn includesZFIELD(self: *ZFIELD, needle: ZFIELD) bool {

        if (self.size == 0 or needle.size == 0) return false;

        if (self.buffer) |buffer| {
            if (needle.buffer) |needle_buffer| {
                const found_index = std.mem.indexOf(u8, buffer[0..self.size], needle_buffer[0..needle.size]);

                if (found_index == null) return false;

                return true;
            }
        }

        return false;
    }

    /// Checks if the needle literal is within the source ZFIELD
    pub fn includesStr(self: *ZFIELD, needle: []const u8) bool {

        if (self.size == 0 or needle.len == 0) return false;

        if (self.buffer) |buffer| {
            const found_index = std.mem.indexOf(u8, buffer[0..self.size], needle);

            if (found_index == null) return false;

            return true;
        }

        return false;
    }

    pub fn debugContext (self : ZFIELD) void {
        const str = self.getStr();
        std.debug.print("\ndebug   buffer:>{s}<  size: {d} nbc: {d}\n",.{str , self.size, self.nbc  });
    }
};
