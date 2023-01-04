
const std = @import("std");
const utf = @import("std").unicode;
const dds = @import("dds.zig");

/// Tools for internal variables

// Iterator support iteration string
pub const iteratStr = struct {
  var strbuf:[] const u8 = undefined;

  var arenastr = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  //defer arena.deinit();
  const allocator = arenastr.allocator();
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
    pub fn preview(it: *StringIterator) ?[]const u8 {
        var optional_buf: ?[]u8  = allocBuffer(strbuf.len) catch return null;
        it.buf= optional_buf orelse "";
        var n : usize = 0;
        while (true) {
            if (n >= strbuf.len) break;
            it.buf[n] = strbuf[n];
            n += 1;
        }

        if (it.index == 0) return null;
        var i = it.buf.len;
        it.index -= getUTF8Size(it.buf[i]);
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

// number characters String
pub fn nbrCharStr(str:[] const u8) usize {
  var wl : usize =0;
  var iter = iteratStr.iterator(str);
  while (iter.next()) |_| { wl +=1; }
  return wl;
}

pub fn trimStr(str:[] const u8) [] const u8{
  var val =std.mem.trim(u8, str ," ");
  return val;
}

// testing isDigit off Index
pub fn isDigitStr(str:[] const u8, idx: usize) bool {
  var wl : usize =0;
  var iter = iteratStr.iterator(str);
  while (iter.next()) |ch| {
    wl +=1;
    const t:u8 = ch[0];
    if ( wl == idx) {
      switch (t) {
        '0'...'9' => return true,
        else => return false,
      }
    }
  }
  return false;
}


pub fn concatStr( a: []const u8, b: []const u8) ![]const u8 {
  const allocator = std.heap.page_allocator;
  const result = try allocator.alloc(u8, a.len + b.len);
  std.mem.copy(u8, result, a);
  std.mem.copy(u8, result[a.len..], b);
  return result;
}


/// Compares this String with a string strbuf
pub fn cmpStr(self: []const u8, strbuf: []const u8) bool {

  if (nbrCharStr(self) != nbrCharStr(strbuf)) return false;
  const allocator = std.heap.page_allocator;
  var buf: []u8  = allocator.alloc(u8,self.len) catch return false;


  var n : usize = 0;
  while (true) {
      if (n >= self.len) break;
      buf[n] = self[n];
      n += 1;
  }

  if ( std.mem.eql(u8, buf[0..], strbuf) ) return true;

  return false;
}

pub fn alignStr(text: []const u8,aligns :dds.ALIGNS, wlen : usize ) []const u8 {

  var wl : usize =0;
  var iter = iteratStr.iterator(text);
  var string: [] const u8 = "" ;

  while (iter.next()) |ch|  {
    wl += 1 ;
    if (wl > wlen) break;
    if ( wl == 1 ) string = ch
    else {
      string =  concatStr(string,ch) catch unreachable;
    }
  }

  if (aligns == dds.ALIGNS.left) {
    while (wl < wlen)  : (wl +=1) {
      string =  concatStr(string," ") catch unreachable;
    }
  }

  if (aligns == dds.ALIGNS.rigth) {
    while (wl < wlen)  : (wl +=1) {
      string =  concatStr(" ",string) catch unreachable;
    }
  }

  return string;
}




pub fn removeListStr(self: std.ArrayList([]const u8), i: usize) !std.ArrayList([]const u8){

            const allocator = std.heap.page_allocator;
            var LIST = std.ArrayList([] const u8).init(allocator);

            for (self.items) | val , idx | {
              if ( idx != i-1 ) LIST.append(val) catch unreachable;
            }
            self.deinit();
            return LIST;

        }



//------- bool--------------

fn boolToStr(v: bool) []const u8 {
    return if (v) "1"  else "0";
}

fn strToBool(v: []const u8) bool {
    return if (cmpStr(v, "1")) true  else  false;
}

fn strToSBool(v: []const u8) []const u8 {
    return if (cmpStr(v, "1")) dds.CTRUE  else dds.CFALSE;
}
fn boolToSbool(v: usize) []const u8 {
    return if  (v == 1 ) dds.CTRUE  else dds.CFALSE;
}

fn sboolToBool(v: []const u8) bool {
    return if ( std.mem.eql(u8,v, dds.CTRUE) ) true  else  false;
}

fn sboolToStr(v: []const u8) []const u8 {
    return if ( std.mem.eql(u8,v, dds.CTRUE) ) "1"  else  "0";
}