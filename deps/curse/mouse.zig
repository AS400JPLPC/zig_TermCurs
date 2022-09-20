/// MOUSE ON or OFF the ANSI sequence to set MOUSE mode
const std = @import("std");
const output =std.io.getStdOut();


pub const on_mouse = "?1000;1005;1006h";
pub const off_mouse = "?1000;1005;1006l";

pub fn fmouse(comptime fmt: []const u8) void {
  output.writer().print("\x1b[{s}", .{fmt})  catch {return;} ;
}
