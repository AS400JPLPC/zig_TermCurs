const std = @import("std");
const utf = @import("std").unicode;
const builtin = @import("builtin");


var arenaZfld = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var allocZfld = arenaZfld.allocator();


/// A variable length collection of characters
pub const ZFIELD = struct {

    /// The internal character buffer
    buffer: ?[]u8,

    /// The total size of the ZFIELD
    size: usize,

    nbc : usize,

  
    pub const cmp = enum { lt, eq, gt };

    pub fn deinitZfld() void {
        arenaZfld.deinit();
        arenaZfld = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        allocZfld = arenaZfld.allocator();
    }

    /// Errors that may occur when using ZFIELD
    pub const Error = error{
        OutOfMemory,
        InvalidRange,
        Uninitialized_zone
    };

    /// Creates a ZFIELD 
    /// ### example
    /// ```zig
    /// var str = ZFIELD.init( 30 );
    /// // don't forget to deallocate
    /// defer _ = str.deinit();
    /// ```
    /// nbrchar != 0 ---> zoned ex: setZfld String  ... {normalize}

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
    fn allocate(self: *ZFIELD, bytes: usize) !void {
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
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        if (self.buffer) |buffer| return buffer.len;
        return 0;
    }

    /// Returns the size of the internal buffer
    pub fn getnbc(self: ZFIELD) usize {
        return self.nbc ;
    }

    /// Returns amount of characters in the ZFIELD
    pub fn count(self: ZFIELD) usize {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        if (self.buffer) |buffer| {
            var length: usize = 0;
            var i: usize = 0;

            while (i < self.size) {
                length += 1;
                i += ZFIELD.getUTF8Size(buffer[i]);
            }

            return length;
        } else {
            return 0;
        }
    }


    /// Clears the contents of the ZFIELD but leaves the capacity
    pub fn clear(self: *ZFIELD) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        self.buffer = null;
        self.size = 0;
    }

    /// Compares this ZFIELD with a ZFIELD literalf
    pub fn cmpeql(self: ZFIELD, src: ZFIELD) bool {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        var str1:[]const u8 = "";
        var str2:[]const u8 = "";
        if (self.buffer )| buf1 | {str1= buf1;}
        if (src.buffer)  | buf2 | {str2= buf2;}
        return std.mem.eql(u8, str1, str2);
    }
    pub fn cmpeqlStr(self: ZFIELD, src: [] const u8) bool {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        var str1:[]const u8 = "";
        if (self.buffer )| buf1 | {str1= buf1;}
        return std.mem.eql(u8, str1, src);
    }

    /// comp string
    /// lt eq gt -> enum cmp
    pub fn cmpxx(self: ZFIELD, src: ZFIELD) ZFIELD.cmp {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        var str1:[]const u8 = "";
        var str2:[]const u8 = "";
        if (self.buffer )| buf1 | {str1= buf1;}
        if (src.buffer)  | buf2 | {str2= buf2;}
        const order = std.mem.order(u8, str1, str2);
        switch (order) {
            .lt => return cmp.lt,
            .eq => return cmp.eq,
            .gt => return cmp.gt,
        }
    }
    pub fn cmpxxStr(self: ZFIELD, src: [] const u8) ZFIELD.cmp {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        var str1:[]const u8 = "";
        if (self.buffer )| buf1 | {str1= buf1;}
        const order = std.mem.order(u8, str1, src);
        switch (order) {
            .lt => return cmp.lt,
            .eq => return cmp.eq,
            .gt => return cmp.gt,
        }
    }

    /// Sets Literal the contents of the ZFIELD of normalize
    pub fn setZfld(self: *ZFIELD, literal: []const u8) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        self.clear();
        if (literal.len == 0) return;
        self.allocate(literal.len) catch unreachable;
         if (self.buffer) |buffer| {
            var  i : usize = 0;
            while (i < literal.len) : (i += 1) {
                 buffer[i] = literal[i];
            }
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



    /// Returns the Field string
    pub fn string(self: *ZFIELD) [] const u8 {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        self.normalize();
        if (self.buffer) |buffer| return buffer[0..self.size];
        return "";
    }

    // getStr buffer
    fn getStr(self: ZFIELD) [] const u8 {
        if (self.buffer) |buffer| return buffer[0..self.size];
        return "";
    }

 
    /// Copies this String into a new one
    pub fn clone(self: ZFIELD) ZFIELD {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        var newString = ZFIELD.init(self.nbc);
        newString.setZfld(self.getStr());
        return newString;
    }

    /// Copies this String into a new one
    pub fn copy(self: *ZFIELD, src: ZFIELD) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        self.clear();
        if (src.buffer) |buffer| { self.setZfld(buffer[0..src.size]); }
        self.normalize();
    }

    /// Removes the last character from the ZFIELD
    pub fn pop(self: *ZFIELD) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        if (self.size == 0) return;
        // char last
        if (self.buffer) |buffer| { 
            self.size = ZFIELD.getIndex(buffer, self.count() - 1).?;
            self.allocate(self.size) catch unreachable;
        }
    }


    /// Returns the real index of a unicode ZFIELD literal
    fn getIndex(unicode: []const u8, index: usize) ?usize {
        var s: usize = 0;
        var c: usize = 0;
        while (s <= unicode.len) : ( c += 1){
            if (c == index) return s;
            s += ZFIELD.getUTF8Size(unicode[c]);
        }
        return null;
    }

    /// returns string from a given range caracter 1.. self.nbc
    /// Start from the character- addEnd to the character
    pub fn substr(self:*ZFIELD, src : ZFIELD,  start: usize, end: usize ) void {
        if ( self.nbc == 0 or src.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc=0  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
            if (start + end > src.count() or start == src.count() or end == 0 ){
            if (builtin.mode == .Debug) {
                const s = @src();
                @panic( std.fmt.allocPrint(allocZfld,
                "\n\n\r file:{s} line:{d} column:{d} func:{s}('{s}','{s}',{d},{d})  err:{}\n\r"
                ,.{s.file, s.line, s.column,s.fn_name,self.getStr(),src.getStr(),start, end,Error.InvalidRange})
                    catch unreachable
                );
            }
            else return;
        }
        const nEnd  = start + end  ;
        if (src.buffer) |buffer| {
            if (ZFIELD.getIndex(buffer, start)) |rStart| {
                 if (ZFIELD.getIndex(buffer, nEnd )) |rEnd| {
                    self.setZfld(buffer[rStart..rEnd]);
                }
            }
        }
    }

    

    /// Removes a range of character from the String caracter 1.. self.nbc
    /// Start from the character- addEnd to the character
    pub fn remove(self: *ZFIELD, start: usize, end: usize) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
            if (start + end > self.count() or start == self.count() or end == 0 ){
            if (builtin.mode == .Debug) {
                const s = @src();
                @panic( std.fmt.allocPrint(allocZfld,
                "\n\n\r file:{s} line:{d} column:{d} func:{s}('{s}',{d},{d})  err:{}\n\r"
                ,.{s.file, s.line, s.column,s.fn_name,self.getStr(),start,end,Error.InvalidRange})
                    catch unreachable
                );

            }
            else return;
        }

        if (self.buffer) |buffer| {
            const nEnd  = start + end  ;
            const rStart = ZFIELD.getIndex(buffer, start ).?;
            var rEnd = ZFIELD.getIndex(buffer, nEnd).?;

            var buf = allocZfld.alloc(u8, self.nbc) catch  unreachable;
            defer allocZfld.free(buf);
   
            var i: usize = 0;
            while (i < rStart) : (i += 1) {
                 buf[i] = buffer[i];
            }

            // if ( nEnd < self.count() and rEnd > 0) {
                while ( rEnd < self.count()) : (rEnd += 1)  {
                    buf[i] = buffer[rEnd];
                    i +=1;
                }
            // }
                
            buf = allocZfld.realloc(buf, i) catch unreachable;
            
            self.setZfld(buf[0..buf.len]);
        }
     }

 
    /// Checks the ZFIELD is empty
    pub inline fn isEmpty(self: ZFIELD) bool {
        if ( self.size > 0) return false ;
        return  true;
    }

    /// Finds the first occurrence of the ZFIELD literal
    pub fn find(self: ZFIELD, literal: []const u8) ?usize {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        if (self.buffer) |buffer| {
            if (std.mem.indexOf(u8, buffer[0..self.size], literal)) |value| {
                return ZFIELD.getIndex(buffer, value ) orelse return null;
            }
        }
        return null;
     }

    /// Finds the last occurrence of the ZFIELD literal
    pub fn rfind(self: ZFIELD, literal: []const u8) ?usize {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        if (self.buffer) |buffer| {
            if (std.mem.lastIndexOf(u8, buffer[0..self.size], literal)) |value| {
                return ZFIELD.getIndex(buffer, value) orelse null;
            }
        }

        return null;
    }


    /// Finds the position occurrence of the string literal:
    pub fn findPos(self: ZFIELD, pos: usize , literal: []const u8) ?usize {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        if (pos <= self.size) {
            if (self.buffer) |buffer| {
                if (std.mem.indexOf(u8, buffer[pos..self.size], literal)) |value| {
                    return ZFIELD.getIndex(buffer, value + pos ) orelse null;
                }
            }
        }
        return null;
    }


    /// Appends a character onto the end of the ZFIELD
    pub fn concatStr(self: *ZFIELD, literal: []const u8) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        // Make sure buffer has enough space
        const index : usize = self.capacity(); 

        self.allocate((self.size + literal.len)) catch unreachable;

        const buffer = self.buffer.?;

        // If not, then copy contents over and insert literal.
        var i: usize = 0;
        while (i < literal.len) : (i += 1) {
            buffer[index + i] = literal[i];
        }
        self.size = buffer.len;
        self.normalize();
    }




    /// truncat 
    pub fn truncat(self: *ZFIELD, index: usize) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        if (index > self.nbc ){
            if (builtin.mode == .Debug) {
                const s = @src();
                @panic( std.fmt.allocPrint(allocZfld,
                "\n\n\r file:{s} line:{d} column:{d} func:{s}('{s}',{d})  err:{}\n\r"
                ,.{s.file, s.line, s.column,s.fn_name,self.getStr(),index,Error.InvalidRange})
                    catch unreachable
                );

            }
            else return;
        }
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
        self.normalize();
    }



    pub fn concat(self:*ZFIELD, src : ZFIELD) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        // Make sure buffer has enough space
        const index : usize = self.capacity(); 

        self.allocate((self.size + src.size)) catch unreachable;

        const buf = self.buffer.?;

        // If not, then copy contents over and insert src buffer.
        var i: usize = 0;
        if (src.buffer) |buffer| {
            while (i < src.size) : (i += 1) {
                buf[index + i] = buffer[i];
            }    
        }
        self.normalize();
    }




    /// Replaces all occurrences of a ZFIELD literal with another
    pub fn replace(self: *ZFIELD, needle: []const u8, arg: []const u8) bool {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        if (self.buffer) |buffer| {
            const InputSize = self.size;
            const size = std.mem.replacementSize(u8, buffer[0..InputSize], needle, arg);
            const buf = allocZfld.alloc(u8, size) catch unreachable;
            defer allocZfld.free(buf);
            const changes = std.mem.replace(u8, buffer, needle, arg, buf);
            self.setZfld(buf[0..buf.len]);
            if (changes > 0) return true;
        }
        return false;
    }


   /// Reverses the characters in this ZFIELD
    pub fn reverse(self: *ZFIELD) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
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





    /// Converts all (UTF8) uppercase letters to lowercase
    /// String Latin
    pub fn lowercase(self: *ZFIELD) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        if (self.buffer) |_| {
    	    var i :usize = 0;
    	    var iter = self.iterator();
            var zone : [4]   u8 = undefined;
        	var car :[]const u8 = undefined;
        	var r : u21 = 0 ;
        	while (iter.next()) |ch | {
        	    const view = std.unicode.Utf8View.init(ch) catch |err| {@panic(@errorName(err)); };
                var iter2 = view.iterator();
                const x : u21 = iter2.nextCodepoint() orelse 0  ; 
                
                r = 0 ;
        		if ( x >= 65 and x <= 90 )  r = x + 32;
                if ( x >= 192 and x <= 223 )  r = x + 32;
                if ( x == 339 )  r = x + 1;
                if ( x == 253 )  r = 255;
        		if (r > 0 ) { 
    				zone = [_]u8{0} ** 4;
    				i = utf.utf8Encode(r,&zone) catch unreachable;
    				car = zone[0..i];
    				_=self.replace(ch,car);
    			}
        	}
        }
    }



    /// upper-case String Latin
    pub fn uppercase(self: *ZFIELD) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
    	if (self.buffer) |_| {
    	    var i :usize = 0;
    	    var iter = self.iterator();
            var zone : [4]   u8 = undefined;
        	var car :[]const u8 = undefined;
        	var r : u21 = 0 ;
        	while (iter.next()) |ch | {
        	    const view = std.unicode.Utf8View.init(ch) catch |err| {@panic(@errorName(err)); };
                var iter2 = view.iterator();
                const x : u21 = iter2.nextCodepoint() orelse 0  ;  
                r = 0 ;
        		if ( x >= 97 and x <= 122 )  r = x - 32;
                if ( x >= 224 and x <= 255 )  r = x - 32;
                if ( x == 339 )  r = x - 1;
                if ( x == 255 )  r = 253;
        		if (r > 0 ) { 
    				zone = [_]u8{0} ** 4;
    				i = utf.utf8Encode(r,&zone) catch unreachable;
    				car = zone[0..i];
    				_=self.replace(ch,car);
    			}
            }
        }
    }


    /// upper-case String Latin
    pub fn capitalized(self: *ZFIELD) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
    	if (self.buffer) |_| {
    	    var i :usize = 0;
    	    var iter = self.iterator();
            var zone : [4]   u8 = undefined;
        	var car :[]const u8 = undefined;
        	var r : u21 = 0 ;
        	var is_new_word: bool = true;
        	var str : [] const u8 = "";

        	while (iter.next()) |ch| {
        	    
        	    const view = std.unicode.Utf8View.init(ch) catch |err| {@panic(@errorName(err)); };
                var iter2 = view.iterator();
                const x : u21 = iter2.nextCodepoint() orelse 0  ;
                 
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
            self.setZfld(str);
            defer allocZfld.free(str);
        }
    }


    /// Trims all whitelist characters at the start of the ZFIELD.
    pub fn trim(self: *ZFIELD, whitelist: []const u8) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        if (self.buffer) |buffer| {
            var buf = allocZfld.alloc(u8, self.size) catch unreachable;
            defer allocZfld.free(buf);
            buf = buffer[0..self.size];
            self.setZfld(std.mem.trim(u8,buf,whitelist));
            self.normalize();
        }
    }

    /// Trim-left whitelist characters at the start of the ZFIELD.
    pub fn trimLeft(self: *ZFIELD, whitelist: []const u8) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        if (self.buffer) |buffer| {
            var buf = allocZfld.alloc(u8, self.size) catch unreachable;
            defer allocZfld.free(buf);
            buf = buffer[0..self.size];
            self.setZfld(std.mem.trimLeft(u8,buf,whitelist));
            self.normalize();
        }
    }

    /// Trim-left whitelist characters at the start of the ZFIELD.
    pub fn trimRight(self: *ZFIELD, whitelist: []const u8) void {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        if (self.buffer) |buffer| {
            var buf = allocZfld.alloc(u8, self.size) catch unreachable;
            defer allocZfld.free(buf);
            buf = buffer[0..self.size];
            self.setZfld(std.mem.trimRight(u8,buf,whitelist));
            self.normalize();
        }
    }



    /// Checks if the needle ZFIELD is within the source ZFIELD
    pub fn check(self: *ZFIELD, needle: ZFIELD) bool {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
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
    pub fn checkStr(self: *ZFIELD, needle: []const u8) bool {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        if (self.size == 0 or needle.len == 0) return false;

        if (self.buffer) |buffer| {
            const found_index = std.mem.indexOf(u8, buffer[0..self.size], needle);

            if (found_index == null) return false;

            return true;
        }

        return false;
    }



    /// Returns a character at the specified index
    pub fn charAt(self: ZFIELD, index: usize) []const u8 {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        if (index > self.count()){
            if (builtin.mode == .Debug) {
                const s = @src();
                @panic( std.fmt.allocPrint(allocZfld,
                "\n\n\r file:{s} line:{d} column:{d} func:{s}({s},{d})  err:{}\n\r"
                ,.{s.file, s.line, s.column,s.fn_name,self.getStr(),index,Error.InvalidRange})
                    catch unreachable
                );
            }
            else return "NAN";
        }
        if (self.buffer) |buffer| {
            if (ZFIELD.getIndex(buffer, index)) |i| {
                const size = ZFIELD.getUTF8Size(buffer[i]);
                return buffer[i..(i + size)];
            }
        }
        return "NAN";
    }


//--------------------------------------
// ITERATOR
//--------------------------------------

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
            }
            else return null;
        }
    };



    pub fn iterator(self: *const ZFIELD) zfldIterator {
        if ( self.nbc == 0 ) {
            const s = @src();
                    @panic( std.fmt.allocPrint(allocZfld,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() not init or denit field.nbc={d}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,self.nbc,error.Uninitialized_zone})
                        catch unreachable
                    );
        }
        return zfldIterator{
            .ZFIELD = self,
            .index = 0,
        };
    }

    /// Checks if byte is part of UTF-8 character
    inline fn isUTF8Byte(byte: u8) bool {
        return ((byte & 0x80) > 0) and (((byte << 1) & 0x80) == 0);
    }


    /// Returns the UTF-8 character's size
    inline fn getUTF8Size(char: u8) u3 {
        return std.unicode.utf8ByteSequenceLength(char) catch { return 1; };
    }




    pub fn debugContext (self : ZFIELD) void {
        std.debug.print("\ndebug   buffer:>{s}<  size: {d} nbc: {d}\n",.{self.getStr(), self.size, self.nbc  });
    }
};
