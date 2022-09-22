const std = @import("std");
const io = std.io;

const output =std.io.getStdOut();
var   buf_Output = std.io.bufferedWriter(output.writer());

const Point = struct {
    x: i32,
    y: i32
};

pub var posCurs : Point = undefined;

/// Moves cursor to `x` column and `y` row
pub fn gotoXY( x: anytype, y: anytype) void {
    output.writer().print("\x1b[{d};{d}H", .{ x, y }) catch {return;} ;
}

/// Moves cursor up `y` rows
pub fn gotoUp( x: anytype) void {
    output.writer().print("\x1b[{d}A", .{ x }) catch {return;} ;
}

/// Moves cursor down `y` rows
pub fn gotoDown( x: anytype) void {
    output.writer().print("\x1b[{d}B", .{ x }) catch {return;} ;
}

/// Moves cursor left `y` columns
pub fn gotoLeft(y: anytype) void {
    output.writer().print("\x1b[{d}D", .{ y }) catch {return;} ;
}

/// Moves cursor right `y` columns
pub fn gotoRight( y: anytype) void {
    output.writer().print("\x1b[{d}C", .{y}) catch {return;} ;
}

/// Hide the cursor
pub fn hide() void {
    output.writer().print("\x1b[?25l", .{ }) catch {return;} catch {return;} ;
}

/// Show the cursor
pub fn show() void {
    output.writer().print("\x1b[?25h", .{}) catch {return;} ;
}

/// Save cursor position
pub fn save() void {
    output.writer().print("\x1b[u", .{ }) catch {return;} ;
}

/// Restore cursor position
pub fn restore() void {
    output.writer().print("\x1b[s", .{ }) catch {return;} ;
}




fn convInt( x:u8) i32 {
    switch(x){
        '0' =>  return 0,
        '1' =>  return 1,
        '2' =>  return 2,
        '3' =>  return 3,
        '4' =>  return 4,
        '5' =>  return 5,
        '6' =>  return 6,
        '7' =>  return 7,
        '8' =>  return 8,
        '9' =>  return 9,
        else => return -1,
    }
}
pub fn getCursor() void {
    const stdin = io.getStdIn();
    // get Cursor form terminal
    var cursBuf: [13]u8 = undefined;

    posCurs.x=0;
    posCurs.y=0;

    // Don't forget to flush!
    buf_Output.flush()catch {return;} ;
    output.writer().print("\x1b[?6n", .{}) catch {return;} ;
    buf_Output.flush()catch {return;} ;


    while (true) {
        const  c =   stdin.read(&cursBuf) catch {return;} ;
        if (c != 0 ) {
            posCurs.x=  convInt(cursBuf[3]) ;

            if (cursBuf[4] != 59) {
                posCurs.x = (posCurs.x * 10) + convInt(cursBuf[4]) ;

                posCurs.y = convInt(cursBuf[6]);
                if (cursBuf[7] != 59)  posCurs.y = (posCurs.y * 10) + convInt(cursBuf[7]) ;
                if (cursBuf[8] != 59)  posCurs.y = (posCurs.y * 10) + convInt(cursBuf[8]) ;
            }
            else {
                posCurs.y = convInt(cursBuf[5]);
                if (cursBuf[6] != 59)  posCurs.y = (posCurs.y * 10) + convInt(cursBuf[6]) ;
                if (cursBuf[7] != 59)  posCurs.y = (posCurs.y * 10) + convInt(cursBuf[7]) ;
            }


            break;
        }
    }

}