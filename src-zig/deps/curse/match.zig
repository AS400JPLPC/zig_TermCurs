const std = @import("std");

const re = @cImport({
  @cDefine("PCRE2_CODE_UNIT_WIDTH", "8");
  @cInclude("regPcre2.h");
});


// function macth regex.h  standard libc 
// display patern only test 
// linux aligne i64 = usize 
pub fn isMatch(strVal : [] const  u8, regVal : [] const  u8 ) bool {
  const allocator = std.heap.page_allocator;
  var slice  = allocator.alignedAlloc(u8, @sizeOf(usize),@sizeOf(usize)) catch unreachable;
  defer allocator.free(slice);
  
  const regex: *re.regex_t = @ptrCast(slice );

  

  defer re.pcre2_regfree(regex); // IMPORTANT!!


  const creg: []u8 = allocator.alloc(u8, regVal.len ,  ) catch unreachable;
  defer allocator.free(creg);
  std.mem.copy(u8, creg, regVal);

  if (re.pcre2_regcomp(regex,@ptrCast(creg),re.REG_EXTENDED | re.REG_ICASE) != 0) {
    // TODO: the pattern is invalid
    // display for test 
    // std.debug.print("error patern {s}\n", .{regVal});
    return false ;
  }

  const cval: []u8 = allocator.alloc(u8, strVal.len ) catch unreachable;
  defer allocator.free(cval);
  std.mem.copy(u8, cval, strVal);


  var vBool = re.isMatch(regex, @ptrCast(cval));


  return vBool;
}