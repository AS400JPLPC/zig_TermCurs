/// MOUSE ON or OFF the ANSI sequence to set MOUSE mode
const std = @import("std");
const dds= @import("dds.zig");

const os = std.os;
const io = std.io;



const output =std.io.getStdOut();
var   buf_Output = std.io.bufferedWriter(output.writer());


///-------------
/// mouse
///-------------


/// onMouse
pub fn onMouse() void {
    output.writer().print("\x1b[?1000;1005;1006h", .{})  catch {return;} ;
}

/// offMouse
pub fn offMouse() void {
    output.writer().print("\x1b[?1000;1005;1006l", .{})  catch {return;} ;
}

///-------------
/// clear
///-------------


/// Clear from cursor until end of screen
pub fn cls_from_cursor_toEndScreen() void {
    output.writer().print("\x1b[0J", .{}) catch {return;} ;
}

/// Clear from cursor to beginning of screen
pub fn cls_from_cursor_toStartScreen() void {
    output.writer().print("\x1b[1J", .{}) catch {return;} ;
}

/// Clear all screen
pub fn cls() void {
    output.writer().print("\x1b[2J", .{}) catch {return;} ;
}

/// Clear from cursor to end of line
pub fn cls_from_cursor_toEndline() void {
    output.writer().print("\x1b[0K", .{}) catch {return;} ;
}

/// Clear start of line to the cursor
pub fn cls_from_cursor_toStartLine() void {
    output.writer().print("\x1b[1K", .{}) catch {return;} ;
}

/// Clear from cursor to end of line
pub fn cls_line() void {
    output.writer().print("\x1b[2K", .{}) catch {return;} ;
}

///-------------
/// cursor
///-------------

const Point = struct {
    x: usize,
    y: usize
};

pub var posCurs : Point = undefined;

/// Moves cursor to `x` column and `y` row
pub fn gotoXY( x: usize, y: usize) void {
    output.writer().print("\x1b[{d};{d}H", .{ x, y }) catch {return;} ;
}

/// Moves cursor up `y` rows
pub fn gotoUp( x: usize) void {
    output.writer().print("\x1b[{d}A", .{ x }) catch {return;} ;
}

/// Moves cursor down `y` rows
pub fn gotoDown( x: usize) void {
    output.writer().print("\x1b[{d}B", .{ x }) catch {return;} ;
}

/// Moves cursor left `y` columns
pub fn gotoLeft(y: usize) void {
    output.writer().print("\x1b[{d}D", .{ y }) catch {return;} ;
}

/// Moves cursor right `y` columns
pub fn gotoRight( y: usize) void {
    output.writer().print("\x1b[{d}C", .{y}) catch {return;} ;
}

/// Hide the cursor
pub fn hide() void {
    output.writer().print("\x1b[?25l", .{ }) catch {return;};
}

/// Show the cursor
pub fn show() void {
    output.writer().print("\x1b[?25h", .{}) catch {return;} ;
}





fn convIntCursor( x:u8) usize {
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
        else => return 0,
    }
}
pub fn getCursor() void {
    const stdin = io.getStdIn();
    // get Cursor form terminal
    var cursBuf: [13]u8 = undefined;

    posCurs.x=0;
    posCurs.y=0;

    // Don't forget to flush!
    buf_Output.flush() catch {return;} ;
    output.writer().print("\x1b[?6n", .{}) catch {return;} ;
    buf_Output.flush() catch {return;} ;


    while (true) {
        const  c =   stdin.read(&cursBuf) catch {return;} ;
        if (c != 0 ) {
            // columns
            posCurs.x= convIntCursor(cursBuf[3])   ;
            if (cursBuf[4] != 59) {
                // columns 2 caractères ex: x:24
                posCurs.x = (posCurs.x * 10) + convIntCursor(cursBuf[4]) ;

                    // rows ex y: 1..172
                    posCurs.y = convIntCursor(cursBuf[6]);
                    if (cursBuf[7] != 59)  posCurs.y = (posCurs.y * 10) + convIntCursor(cursBuf[7]) ;
                    if (cursBuf[8] != 59)  posCurs.y = (posCurs.y * 10) + convIntCursor(cursBuf[8]) ;
                }
            // rows rows ex y: 1..172
                else {
                    posCurs.y = convIntCursor(cursBuf[5]);
                    if (cursBuf[6] != 59)  posCurs.y = (posCurs.y * 10) + convIntCursor(cursBuf[6]) ;
                    if (cursBuf[7] != 59)  posCurs.y = (posCurs.y * 10) + convIntCursor(cursBuf[7]) ;
                }


                break;
            }
        }

}


///-------------------------
/// style color writestyled
///-------------------------

/// Reset the terminal style.
pub fn resetStyle() void {
    output.writer().print("\x1b[0m", .{}) catch {return;} ;

}

/// Sets the terminal style.
pub fn setStyle(style:[4]u32 ) void {
    for (style) |v| {
        if (v != 0) {
        output.writer().print("\x1b[{d}m", .{v}) catch {return;} ;
        }
    }
}

/// Sets the terminal's foreground color.
pub fn  setForegroundColor(attribut : dds.ZONATRB) void {
    output.writer().print("\x1b[{d}m", .{@enumToInt(attribut.foregr)}) catch {return;} ;
}

/// Sets the terminal's Background color.
pub fn  setBackgroundColor(attribut : dds.ZONATRB) void {
    output.writer().print("\x1b[{d}m", .{@enumToInt(attribut.backgr)})  catch {return;} ;
}

/// write text and attribut
pub fn writeStyled(text: []const u8 , attribut : dds.ZONATRB ) void {
    setForegroundColor(attribut);
    setBackgroundColor(attribut);
    setStyle(attribut.styled);
    output.writer().print("{s}", .{text}) catch {return;} ;
    resetStyle();
}




///-------------------------
/// Terminal
///-------------------------
/// A raw terminal representation, you can enter terminal raw mode
/// using this struct. Raw mode is essential to create a TUI.

pub const RawTerm = struct {
    orig_termios: os.termios,
    cur_termios: os.termios,
    /// The OS-specific file descriptor or file handle.
    handle: os.system.fd_t,

    const Self = @This();

    /// Returns to the previous terminal state
    pub fn disableRawMode(self: *Self) !void {
        try os.tcsetattr(self.handle, .FLUSH, self.orig_termios);
    }
    pub fn flushMode(self: *Self) !void {
        try os.tcsetattr(self.handle,.FLUSH, self.cur_termios);
    }
};




/// open terminal and config
pub fn enableRawMode() !RawTerm {
    // var original_termios = try os.tcgetattr(handle);
    const stdin = io.getStdIn();
    var original_termios = try os.tcgetattr(stdin.handle );

    var termios = original_termios;

    // https://viewsourcecode.org/snaptoken/kilo/02.enteringRawMode.html
    // https://codeberg.org/josias/zigcurses/src/branch/master/src/main.zig
    // https://man7.org/linux/man-pages/man3/termios.3.html

    // https://manpages.ubuntu.com/manpages/trusty/fr/man3/termios.3.html

    termios.iflag &= ~(
                        os.system.IGNBRK | os.system.BRKINT | os.system.PARMRK | os.system.INPCK | os.system.ISTRIP |
                        os.system.INLCR | os.system.IGNCR | os.system.ICRNL | os.system.IXON
                    );


    termios.oflag &= ~(os.system.OPOST);
    termios.cflag &= ~(os.system.CSIZE | os.system.PARENB);
    termios.cflag |= (os.system.CS8 );
    termios.lflag &= ~(os.system.ECHO | os.system.ECHONL | os.system.ICANON | os.system.IEXTEN | os.system.ISIG);


    // Wait until it reads at least one byte  terminal standard
    termios.cc[os.system.V.MIN] = 1;


    // Wait 100 miliseconds at maximum.
    termios.cc[os.system.V.TIME] = 1;

    // apply changes
    try os.tcsetattr(stdin.handle, .FLUSH, termios);

    return RawTerm{
        .orig_termios = original_termios,
        .cur_termios = termios,
        .handle = stdin.handle ,
    };
}



/// get size terminal
const TermSize = struct { width: usize, height: usize };

fn getSize() !TermSize {
    var win_size: std.os.system.winsize = undefined;
    const stdin = io.getStdIn();
    const err = os.system.ioctl(stdin.handle, os.system.T.IOCGWINSZ, @ptrToInt(&win_size));
    if (os.errno(err) != .SUCCESS) {
        return os.unexpectedErrno(@intToEnum(os.system.E, err));
    }
    return TermSize{
        .height = win_size.ws_row,
        .width = win_size.ws_col,
    };
}




///--------------------------------------------
/// Event keyboard and mouse
///--------------------------------------------

const Key = union(enum) {
    // unicode character
    char: u21,
    ctrl: u21,
    alt: u21,
    fun: u8,

    // arrow keys
    up: void,
    down: void,
    left: void,
    right: void,
    pageup: void,
    pagedown: void,
    home: void,
    end: void,
    esc: void,
    delete: void,
    enter: void,
    del: void,
    ins: void,
    tab: void,
    backspace: void,
    mouse: void,

    pub fn format(
        value: Key,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = options;
        _ = fmt;
        writer.writeAll("Key.") catch {return;} ;

        switch (value) {
            .ctrl => |c| try std.fmt.format(writer, "ctrl({u})", .{c}),
            .alt => |c| try std.fmt.format(writer, "alt({u})", .{c}),
            .char => |c| try std.fmt.format(writer, "char({u})", .{c}),
            .fun => |c| try std.fmt.format(writer, "fun({d})", .{c}),

            // arrow keys
            .up => try std.fmt.format(writer, "up", .{}),
            .down => try std.fmt.format(writer, "down", .{}),
            .left => try std.fmt.format(writer, "left", .{}),
            .right => try std.fmt.format(writer, "right", .{}),
            .pageup => try std.fmt.format(writer, "Pageup", .{}),
            .pagedown => try std.fmt.format(writer, "Pagedown", .{}),
            .home => try std.fmt.format(writer, "Home", .{}),
            .end => try std.fmt.format(writer, "End", .{}),
            .delete => try std.fmt.format(writer, "delete", .{}),
            .ins => try std.fmt.format(writer, "ins", .{}),
            .tab => try std.fmt.format(writer, "tab", .{}),
            .backspace => try std.fmt.format(writer, "backspace", .{}),
            // special keys
            .esc => try std.fmt.format(writer, "esc", .{}),
            .enter => try std.fmt.format(writer, "enter", .{}),
            .mouse => try std.fmt.format(writer, "mouse", .{}),
            else => try std.fmt.format(writer, "Not available yet", .{}),
        }
    }
};


const Event = union(enum) {
    key: Key,
    none,
};




/// mouse struct
pub const MouseAction = enum {maNone, maPressed, maReleased,};

pub const MouseButton = enum {mbNone, mbLeft, mbMiddle, mbRight,} ;

pub const ScrollDirection = enum {msNone, msUp, msDown,} ;


const  Mouse = struct {
        x: usize, // x mouse position
        y: usize, // y mouse position
        button: MouseButton, // which button was pressed
        action: MouseAction, // if button was released or pressed
        ctrl: bool, // was ctrl was down on event
        shift: bool, // was shift was down on event
        scroll: bool, // if this is a mouse scroll
        scrollDir: ScrollDirection,
        move: bool, // if this a mouse move
    };


pub var MouseInfo : Mouse = undefined;





/// Returns the next event received.
/// If raw term is `.blocking` or term is canonical it will block until read at least one event.
/// otherwise it will return `.none` if it didnt read any event
///
/// `in`: needs to be reader
pub fn getKey() !Event {
    // TODO: Check buffer size

    var buf: [30]u8 = undefined;
    const stdin = io.getStdIn();
    //var event :Event = .none;

    const c = try stdin.read(&buf);
    if (c == 0) {
        return .none;
    }

    const view = try std.unicode.Utf8View.init(buf[0..c]);

    var iter = view.iterator();

    //std.debug.print("\n\rview:{any}\n", .{buf});

    // TODO: Find a better way to iterate buffer
    if (iter.nextCodepoint()) |c0| switch (c0) {
        '\x1b' => {
            if (iter.nextCodepoint()) |c1| switch (c1) {
                // fn (1 - 4)
                // O - 0x6f - 111
                '\x4f' => {
                    return Event{ .key = Key{ .fun = (1 + buf[2] - '\x50') } };
                },

                // csi
                '[' => {
                    return try parse_csi(buf[2..c]);

                },

                // alt key
                else => {
                    return Event{ .key = Key{ .alt = c1 } };
                },
            } else {
                return Event{ .key = .esc };
            }
        },
        // ctrl keys (avoids  crtl-i (x09)   ctrl-m (x0D) )
        '\x01'...'\x08','\x0A'...'\x0C','\x0E'...'\x1A' => return Event{ .key = Key{ .ctrl = c0 + '\x60' } },
        // tab
        '\x09' => return Event{ .key = .tab },
        // backspace
        '\x7f' => return Event{ .key = .backspace },
        // special chars
        '\x0D' => return Event{ .key = .enter },

        // chars and shift + chars
        else => {
            return Event{ .key = Key{ .char = c0 } };
        },
    };

     return .none ;
}



fn convIntMouse( x:u8) usize {
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
        else => return 1,
    }
}

fn parse_csi(buf: []const u8) !Event {
    //std.debug.print("\n\rview:{any}\n", .{buf});
    switch (buf[0]) {
        // keys
        'A' => return Event{ .key = .up },
        'B' => return Event{ .key = .down },
        'C' => return Event{ .key = .right },
        'D' => return Event{ .key = .left },
        'H' => return Event{ .key = .home },
        'F' => return Event{ .key = .end },
        '3' => return Event{ .key = .delete },

        '1'...'2' => {
            if (buf[1] == 126) {
                switch (buf[0]) { // insert
                    '2' => return Event{ .key = .ins },
                    else => return .none ,
                }
            }
            if (buf[2] == 126) {
                switch (buf[1]) { // f5..f12
                    '5' => return Event{ .key = Key{ .fun = 5 } },
                    '7' => return Event{ .key = Key{ .fun = 6 } },
                    '8' => return Event{ .key = Key{ .fun = 7 } },
                    '9' => return Event{ .key = Key{ .fun = 8 } },
                    '0' => return Event{ .key = Key{ .fun = 9 } },
                    '1' => return Event{ .key = Key{ .fun = 10 } },
                    '3' => return Event{ .key = Key{ .fun = 11 } },
                    '4' => return Event{ .key = Key{ .fun = 12 } },
                    else =>  return .none ,
                }
            }
            if ((buf[2]) == 50) { // f11..f14 and // shift
                switch (buf[3]) {
                    'P' => return Event{ .key = Key{ .fun = 13 } },
                    'Q' => return Event{ .key = Key{ .fun = 14 } },
                    'R' => return Event{ .key = Key{ .fun = 15 } },
                    'S' => return Event{ .key = Key{ .fun = 16 } },
                    'A' => return Event{ .key = .up },
                    'B' => return Event{ .key = .down },
                    'C' => return Event{ .key = .right },
                    'D' => return Event{ .key = .left },
                    'F' => return Event{ .key = .end },
                    '3' => return Event{ .key = .delete },
                    '5' => return Event{ .key = .pageup },
                    '6' => return Event{ .key = .pagedown },
                    else =>  return .none ,
                }
            }
            if ((buf[2]) == 53) { //  sihft ctrl
                    switch (buf[3]) {
                    'A' => return Event{ .key = .up },
                    'B' => return Event{ .key = .down },
                    'C' => return Event{ .key = .right },
                    'D' => return Event{ .key = .left },
                    'F' => return Event{ .key = .end },
                    'H' => return Event{ .key = .home },
                    '5' => return Event{ .key = .pageup },
                    '6' => return Event{ .key = .pagedown },
                    else =>  return .none ,
                }
            }

            if ((buf[2]) == 54) { //  sihft / controle
                    switch (buf[3]) {
                    'A' => return Event{ .key = .up },
                    'B' => return Event{ .key = .down },
                    'C' => return Event{ .key = .right },
                    'D' => return Event{ .key = .left },
                    'F' => return Event{ .key = .end },
                    'H' => return Event{ .key = .home },
                    '5' => return Event{ .key = .pageup },
                    '6' => return Event{ .key = .pagedown },
                    else =>  return .none ,
                }
            }
            if ((buf[2]) == 60) { // f11..f14
                switch (buf[3]) {
                    'P' => return Event{ .key = Key{ .fun = 13 } },
                    'Q' => return Event{ .key = Key{ .fun = 14 } },
                    'R' => return Event{ .key = Key{ .fun = 15 } },
                    'S' => return Event{ .key = Key{ .fun = 16 } },
                    else =>  return .none ,
                }
            }
            if ((buf[4]) == 126) { // f15..f24
                switch (buf[1]) {
                    '5' => return Event{ .key = Key{ .fun = 17 } },
                    '7' => return Event{ .key = Key{ .fun = 18 } },
                    '8' => return Event{ .key = Key{ .fun = 19 } },
                    '9' => return Event{ .key = Key{ .fun = 20 } },
                    '0' => return Event{ .key = Key{ .fun = 21 } },
                    '1' => return Event{ .key = Key{ .fun = 22 } },
                    '3' => return Event{ .key = Key{ .fun = 23 } },
                    '4' => return Event{ .key = Key{ .fun = 24 } },
                    else =>  return .none ,
                }
            }

        },
        '5'...'6' => {
            if (buf[1] == 126) {
                 switch (buf[0]) {
                    '5' => return Event{ .key = .pageup },
                    '6' => return Event{ .key = .pagedown },
                    else =>  return .none ,
                }
            }
            if (buf[3] == 126) {
                 switch (buf[2]) {
                    '5' => return Event{ .key = .pageup },
                    '6' => return Event{ .key = .pagedown },
                    else =>  return .none ,
                }
            }
        },
        '<' => {// mouse
            MouseInfo.action = MouseAction.maNone;
            MouseInfo.button = MouseButton.mbNone;
            MouseInfo.scrollDir = ScrollDirection.msNone;
            MouseInfo.x = 0;
            MouseInfo.y = 0;

            var i:usize = 3;
            while (true) {
                if (buf[i] != 59 and MouseInfo.y == 0 ) MouseInfo.y = convIntMouse(buf[3]);
                if (buf[i] == 59 ) break;
                if (buf[i] != 59 and i > 3 ) MouseInfo.y = (MouseInfo.y * 10) + convIntMouse(buf[i]);
                i += 1;
            }

            var u:usize = i + 1;
            while (true) {
                if (buf[u] != 59 and MouseInfo.x == 0 ) MouseInfo.x = convIntMouse(buf[u]);
                if (buf[u] == 59 or  buf[u] == 77 or buf[u] == 109) break;
                if (buf[u] != 59 and u > (i+1) ) MouseInfo.x = (MouseInfo.x * 10) + convIntMouse(buf[u]);
                u += 1;
            }

            if (buf.len == 7) {
                if ((buf[6]) == 77 ) {
                    MouseInfo.action = MouseAction.maPressed;

                }
                if ((buf[6]) == 109 ) {
                    MouseInfo.action = MouseAction.maReleased;
                }

            }
            if (buf.len == 8) {
                if ((buf[7]) == 77 ) {
                    MouseInfo.action = MouseAction.maPressed;
                }
                if ((buf[7]) == 109 ) {
                    MouseInfo.action = MouseAction.maReleased;
                }

            }
            if (buf.len == 9) {
                if ((buf[8]) == 77 ) {
                    MouseInfo.action = MouseAction.maPressed;
                }
                if ((buf[8]) == 109 ) {
                    MouseInfo.action = MouseAction.maReleased;
                }
            }

            if (buf.len == 10) {
                if ((buf[9]) == 77 ) {
                    MouseInfo.action = MouseAction.maPressed;
                }
                if ((buf[9]) == 109 ) {
                    MouseInfo.action = MouseAction.maReleased;
                }
            }
            if ((buf[1]) == 48 ) {
                MouseInfo.button = MouseButton.mbLeft;
            }
            if ((buf[1]) == 49 ) {
                MouseInfo.button = MouseButton.mbMiddle;
            }
            if ((buf[1]) == 50 ) {
                MouseInfo.button = MouseButton.mbRight;
            }
            if ((buf[1]) == 54 and (buf[2]) == 52 ) {
                MouseInfo.scrollDir = ScrollDirection.msUp;
                MouseInfo.x = 0;
                MouseInfo.y = 0;
            }
            if ((buf[1]) == 54 and (buf[2]) == 53 ) {
                MouseInfo.scrollDir = ScrollDirection.msDown;
                MouseInfo.x = 0;
                MouseInfo.y = 0;
            }

            return Event{ .key = .mouse };
        },
        else =>  return .none ,
    }
    return .none ;
}














test "tested" {
//pub fn main() !void {
    const defAtrLabel : dds.ZONATRB = .{
    .styled=[_]u32{@enumToInt(dds.Style.styleBright),
                   @enumToInt(dds.Style.styleItalic),
                   @enumToInt(dds.Style.notStyle),
                   @enumToInt(dds.Style.notStyle)},
    .backgr = dds.BackgroundColor.bgBlack,
    .backBright = false,
    .foregr = dds.ForegroundColor.fgGreen,
    .foreBright = true
    };
    //const stdin = io.getStdIn();
    // Enable terminal raw mode, its very recommended when listening for events  stdin.handle

    var raw_term = try enableRawMode();
    defer raw_term.disableRawMode() catch {};

    writeStyled("bonjour \n",defAtrLabel );
    getCursor();
    std.debug.print("cursor X:{d}  Y:{d}\n\r", .{posCurs.x, posCurs.y});
    var size: TermSize = try getSize();
    std.debug.print("screen width:{d} height:{d}\n\r",.{size.width , size.height });

}

