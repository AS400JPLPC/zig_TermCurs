const std = @import("std");

const re = @cImport({
  @cInclude("regz.h");
});



// function macth regex.h  standard libc 
// display patern only test 
pub fn isMatch(strVal : [] const  u8, regVal : [] const  u8 ) bool {
  const allocator = std.heap.page_allocator;
  
  var slice  = allocator.alignedAlloc(u8, @sizeOf(usize),@sizeOf(usize)) catch unreachable;
  defer allocator.free(slice);

  const regex = @ptrCast(*re.regex_t, slice);

  defer re.regfree(regex); // IMPORTANT!!


  const creg = allocator.alloc(u8, regVal.len ,  ) catch unreachable;
  defer allocator.free(creg);

  std.mem.copy(u8, creg, regVal);

  if (re.regcomp(regex,@ptrCast([*]u8, creg),re.REG_EXTENDED | re.REG_ICASE) != 0) {
    // TODO: the pattern is invalid
    // display for test 
    // std.debug.print("error patern {s}\n", .{regVal});
    return false ;
  }

  const cval = allocator.alloc(u8, strVal.len ) catch unreachable;
  defer allocator.free(cval);

  std.mem.copy(u8, cval, strVal);

  var vBool = re.isMatch(regex, @ptrCast([*]u8, cval));

  return vBool;
}