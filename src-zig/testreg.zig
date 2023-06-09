const std = @import("std");
const re = @cImport({
  @cInclude("regz.h");
});

pub fn isMatch(strVal : [] const  u8, regVal : [] const  u8 ) bool {
  const allocator = std.heap.page_allocator;
  var slice  = allocator.alignedAlloc(u8, @sizeOf(usize),@sizeOf(usize)) catch unreachable;

  const regex = @ptrCast(*re.regex_t, slice);
  defer allocator.free(@ptrCast([*]u8, regex)[0..slice.len]);
  defer re.regfree(regex); // IMPORTANT!!


  const creg = allocator.alloc(u8, regVal.len ,  ) catch unreachable;
  std.mem.copy(u8, creg, regVal);

  if (re.regcomp(regex,@ptrCast([*]u8, creg),re.REG_EXTENDED | re.REG_ICASE) != 0) {
    // TODO: the pattern is invalid
    // display for test 
    std.debug.print("error patern {s}\n", .{regVal});
    return false ;
  }

  const cval = allocator.alloc(u8, strVal.len ) catch unreachable;
  std.mem.copy(u8, cval, strVal);

  return re.isMatch(regex, @ptrCast([*]u8, cval));
}


pub fn main() !void {
  std.debug.print("Macth abc {} \r\n",.{isMatch("p1","^[a-zA-Z]{1,1}[a-zA-Z0-9]{0,}$")}) ;

  std.debug.print("Macth digit {} \r\n",.{isMatch(
  "423",
  "^[1-9]{1,1}?[0-9]{0,}$")}) ;

  std.debug.print("Macth tel fr{} \r\n",.{isMatch(
  "+(33)6.12.34.56.78",
  "^[+]{1,1}[(]{0,1}[0-9]{1,3}[)]([0-9]{1,3}){1,1}([-. ]?[0-9]{2,3}){2,4}$")}) ;

  std.debug.print("Macth tel us{} \r\n",.{isMatch(
  "+(001)456.123.789",
  "^[+]{1,1}[(]([0-9]{3,3})[)]([-. ]?[0-9]{3}){2,4}$")}) ;
  
  std.debug.print("Macth date fr{} \r\n",.{isMatch(
  "12/10/1951",
  "^(0[1-9]|[12][0-9]|3[01])[\\/](0[1-9]|1[012])[\\/][0-9]{4,4}$")});


  std.debug.print("Macth date us{} \r\n",.{isMatch(
  "10/12/1951",
  "^(0[1-9]|1[012])[\\/](0[1-9]|[12][0-9]|3[01])[\\/][0-9]{4,4}$")});

  std.debug.print("Macth date iso{} \r\n",.{isMatch(
  "2003-02-25",
  "^([0-9]{4,4})[-](0[1-9]|1[012])[-](0[1-9]|[12][0-9]|3[01])$")});


  // https://stackoverflow.com/questions/201323/how-can-i-validate-an-email-address-using-a-regular-expression
  // chapitre RFC 6532 updates 5322 to allow and include full, clean UTF-8.

  std.debug.print("Macth Mail{} \r\n",.{isMatch(
  "myname.myfirstname@gmail.com",
  "^([-!#-\'*+\\/-9=?A-Z^-~]{1,64}(\\.[-!#-\'*+\\/-9=?A-Z^-~]{1,64})*|\"([]!#-[^-~ \t]|(\\[\t -~]))+\")@[0-9A-Za-z]([0-9A-Za-z-]{0,61}[0-9A-Za-z])?(\\.[0-9A-Za-z]([0-9A-Za-z-]{0,61}[0-9A-Za-z])?)+$")});

  //oreilly
  std.debug.print("Macth Mail{} \r\n",.{isMatch(
  "myname.myfirstname@gmail.com",
  "^[A-Z0-9_!#$%&'*+/=?`{|}~^.-]+@[A-Z0-9.-]+$")});



  const allocatorx = std.heap.page_allocator;
  var width :usize = 5;
  // unsigned digit
  std.debug.print("Macth digit unsigned{} \r\n",.{isMatch(
  "123",
  std.fmt.allocPrint(allocatorx,"^[0-9]{s}{d}{s}$",.{"{1,",width,"}"},) catch unreachable)});

  // unsigned digit
  std.debug.print("Macth digit {} \r\n",.{isMatch(
  "+12345",
  std.fmt.allocPrint(allocatorx,"^[+-][0-9]{s}{d}{s}$",.{"{1,",width,"}"},) catch unreachable)});

  
  // decimal unsigned  scal = 0
  std.debug.print("Macth decimal unsigned  scal = 0 {} \r\n",.{isMatch(
  "12345",
  std.fmt.allocPrint(allocatorx,"^[0-9]{s}1,{d}{s}$",.{"{",width,"}"},) catch unreachable)});

  var scal :usize = 2;
  // decimal unsigned  scal > 0
  std.debug.print("Macth decimal unsigned  scal > 0 {} \r\n",.{isMatch(
  "12345.02",
  std.fmt.allocPrint(allocatorx,
  "^[0-9]{s}1,{d}{s}[.][0-9]{s}{d}{s}$",.{"{",width,"}","{",scal,"}"}
  ) catch unreachable)});


  
  // decimal signed   scal = 0
  std.debug.print("Macth decimal signed  scal = 0 {} \r\n",.{isMatch(
  "+12345",
  std.fmt.allocPrint(allocatorx,"^[+-][0-9]{s}1,{d}{s}$",.{"{",width,"}"},) catch unreachable)});


  // decimal unsigned  scal > 0
  std.debug.print("Macth decimal signed  scal > 0 {} \r\n",.{isMatch(
  "+12345.02",
  std.fmt.allocPrint(allocatorx,
  "^[+-][0-9]{s}1,{d}{s}[.][0-9]{s}{d}{s}$",.{"{",width,"}","{",scal,"}"}
  ) catch unreachable)});

  var i: usize = 0 ;
  while(i < 5000) : ( i += 1 ) {
  _=isMatch(
  "1951-10-12",
  "^([0-9]{4,4})[-](0[1-9]|1[012])[-](0[1-9]|[12][0-9]|3[01])$");
  }

var t128:f128 = 1_234_567_890_123_456_789.123_456_789_012_34 ;

std.debug.print(" f128 {}",.{t128});

}