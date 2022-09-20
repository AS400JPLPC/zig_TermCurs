//!  Clear screen.
//! Note: Clear doesn't move the cursor, so the cursor will stay at the same position,
//! to move cursor check `Cursor`.

const std = @import("std");
const output =std.io.getStdOut();



// Clear from cursor until end of screen
pub fn from_cursor() void {
    output.writer().print("\x1b[0J", .{}) catch {return;} ;
}

// Clear from cursor to beginning of screen
pub fn to_cursor() void {
    output.writer().print("\x1b[1J", .{}) catch {return;} ;
}


// Clear all screen
pub fn cls() void {
    output.writer().print("\x1b[2J", .{}) catch {return;} ;
}

// Clear from cursor to end of line
pub fn line_from_cursor() void {
    output.writer().print("\x1b[0K", .{}) catch {return;} ;
}

// Clear start of line to the cursor
pub fn line_to_cursor() void {
    output.writer().print("\x1b[1K", .{}) catch {return;} ;
}

// Clear from cursor to end of line
pub fn line() void {
    output.writer().print("\x1b[2K", .{}) catch {return;} ;
}