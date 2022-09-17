const std = @import("std");
const io = std.io;

const mibu = @import("mibu");

const color = mibu.color;
const cursor = mibu.cursor;
const style = mibu.style;

pub fn main() !void {
    const stdout = io.getStdOut();

    try stdout.writer().print("{s}{s}{s}Warning text{s}", .{color.print.bg(.black),color.print.fg(.red),
        style.print.bold, style.print.reset} );
    try stdout.writer().print("{s}{s}{s}*Warning JPL*{s}\n", .{color.print.bg(.black),color.print.fg(.red),
        style.print.italic, style.print.reset} );

    try color.fg256(stdout.writer(), .blue);
    try color.bg256(stdout.writer(), .white);
    try stdout.writer().print("Blue text{s}\n", .{style.print.reset});

    //try stdout.writer().print("{s}",.{style.print.reset});
    try color.fgRGB(stdout.writer(), 255, 0, 255);
    try color.bgRGB(stdout.writer(), 255, 255, 102);
    try stdout.writer().print("Purple text{s}\n", .{style.print.reset});
}
