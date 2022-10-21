/// Define use terminal basic
const std = @import("std");
const utf = @import("std").unicode;
const dds = @import("dds.zig");
const utl = @import("utils");



const os = std.os;
const io = std.io;



const output =std.io.getStdOut();
var buf_Output = std.io.bufferedWriter(output.writer());
const allocator = std.heap.page_allocator;


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
pub fn cursHide() void {
    output.writer().print("\x1b[?25l", .{ }) catch {return;};
}

/// Show the cursor
pub fn cursShow() void {
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
    output.writer().print("\x1b[?6n", .{}) catch {return;} ;

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
    flushIO();

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
pub fn  setForegroundColor(color : dds.BackgroundColor) void {
    output.writer().print("\x1b[{d}m", .{@enumToInt(color)}) catch {return;} ;
}

/// Sets the terminal's Background color.
pub fn  setBackgroundColor(color : dds.ForegroundColor) void {
    output.writer().print("\x1b[{d}m", .{@enumToInt(color)})  catch {return;} ;
}

/// write text and attribut
pub fn writeStyled(text: []const u8 , attribut : dds.ZONATRB ) void {
    setForegroundColor(attribut.backgr);
    setBackgroundColor(attribut.foregr);
    setStyle(attribut.styled);
    output.writer().print("{s}", .{text}) catch {return;} ;
    resetStyle();
    //flushIO();
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
        offMouse();
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

    // cursor HIDE par défault
    cursHide();
    offMouse();

    return RawTerm{
        .orig_termios = original_termios,
        .cur_termios = termios,
        .handle = stdin.handle ,
    };
}

/// flush terminal in-out
pub fn flushIO() void {
    buf_Output.flush() catch unreachable;
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

/// Update title terminal
pub fn  titleTerm( title : [] const u8) void {
    if (title.len > 0 ) {
        output.writer().print("\x1b]0;{s}\x07", .{title}) catch {return;};
        flushIO();
    }
}



// if use resize  ok : vte application terminal ex TermVte
// change XTERM
// sudo thunar /etc/X11/app-defaults/XTerm
// *allowWindowOps: true  *eightBitInput: false

pub fn resizeTerm(line : usize ,cols : usize) void {
    if (line > 0  and cols > 0) {
        output.writer().print("\x1b[8;{d};{d};t",.{line,cols}) catch {return;};
        flushIO();
    }
}



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


pub const Keyboard = struct {
     Key: kbd,
     Char : []const u8
};


/// Decrypt the keyboard

pub const kbd = enum {
    none,
    F1 ,
    F2 ,
    F3 ,
    F4 ,
    F5 ,
    F6 ,
    F7 ,
    F8 ,
    F9 ,
    F10 ,
    F11 ,
    F12 ,
    F13 ,
    F14 ,
    F15 ,
    F16 ,
    F17 ,
    F18 ,
    F19 ,
    F20 ,
    F21 ,
    F22 ,
    F23 ,
    F24 ,
    altA,
    altB,
    altC,
    altD,
    altE,
    altF,
    altG,
    altH,
    altI,
    altJ,
    altK,
    altL,
    altM,
    altN,
    altO,
    altP,
    altQ,
    altR,
    altS,
    altT,
    altU,
    altV,
    altW,
    altX,
    altY,
    altZ,
    ctrlA,
    ctrlB,
    ctrlC,
    ctrlD,
    ctrlE,
    ctrlF,
    ctrlG,
    ctrlH,
    ctrlI,
    ctrlJ,
    ctrlK,
    ctrlL,
    ctrlM,
    ctrlN,
    ctrlO,
    ctrlP,
    ctrlQ,
    ctrlR,
    ctrlS,
    ctrlT,
    ctrlU,
    ctrlV,
    ctrlW,
    ctrlX,
    ctrlY,
    ctrlZ,
    // specific for grid
    pageUp,
    pageDown,
    home,
    end,
    esc,
    // Specific for typing
    mouse,
    char,

    up ,
    down,
    left,
    right,
    delete,
    enter,
    ins,
    tab,
    backspace,



    pub const NameTable= [@typeInfo(kbd).Enum.fields.len][:0]const u8{
        "none",
        "F1",
        "F2",
        "F3",
        "F4",
        "F5",
        "F6",
        "F7",
        "F8",
        "F9",
        "F10",
        "F11",
        "F12",
        "F13",
        "F14",
        "F15",
        "F16",
        "F17",
        "F18",
        "F19",
        "F20",
        "F21",
        "F22",
        "F23",
        "F24",
        "Alt.a",
        "Alt.b",
        "Alt.c",
        "Alt.d",
        "Alt.e",
        "Alt.f",
        "Alt.g",
        "Alt.h",
        "Alt.i",
        "Alt.j",
        "Alt.k",
        "Alt.l",
        "Alt.m",
        "Alt.n",
        "Alt.o",
        "Alt.p",
        "Alt.q",
        "Alt.r",
        "Alt.s",
        "Alt.t",
        "Alt.u",
        "Alt.v",
        "Alt.w",
        "Alt.x",
        "Alt.y",
        "Alt.z",
        "Ctrl.a",
        "Ctrl.b",
        "Ctrl.c",
        "Ctrl.d",
        "Ctrl.e",
        "Ctrl.f",
        "Ctrl.g",
        "Ctrl.h",
        "Ctrl.i",
        "Ctrl.j",
        "Ctrl.k",
        "Ctrl.l",
        "Ctrl.m",
        "Ctrl.n",
        "Ctrl.o",
        "Ctrl.p",
        "Ctrl.q",
        "Ctrl.r",
        "Ctrl.s",
        "Ctrl.t",
        "Ctrl.u",
        "Ctrl.v",
        "Ctrl.w",
        "Ctrl.x",
        "Ctrl.y",
        "Ctrl.z",
        // specific for grid
        "PageUp",
        "PageDown",
        "Home",
        "End",
        "Esc",
        // Specific for typing
        "mouse",
        "char",

        "up" ,
        "down",
        "left",
        "right",
        "delete",
        "enter",
        "ins",
        "tab",
        "backspace",


    };

    pub fn str(self: kbd) [:0]const u8 {
        return NameTable[@enumToInt(self)];
    }

    pub fn toEnum( name:[]const u8) kbd {
        var vlen: usize = 0;
        var vn  : u8 = 0 ;
        var iter = utl.iteratS.iterator(name);
        while (iter.next()) |_| { vlen += 1; }


        if (name[0] == 'F') {
            //f1..f9
            if (vlen == 2) return @intToEnum(kbd, @as(u8,name[1]));
            // f10..f19
            if (vlen == 3 and name[1] == '1') return @intToEnum(kbd, 10 + @as(u8,name[2]));
            // f20..f24
            if (vlen == 3 and name[2] == '2') return @intToEnum(kbd, 20 + @as(u8,name[2]));
        }


        if (name[0] == 'A' and name[1] == 'l' and  name[2] == 't' and name[3] == '.') {

            if (vlen != 5) return .none;
            vn = @as(u8, name[4]) - 72 ;
            if (vn < 25 or vn > 50 ) return .none
            else return @intToEnum(kbd, vn);
        }

        if (name[0] == 'C' and name[1] == 't' and  name[2] == 'r'  and  name[3] == 'l' and name[4] == '.') {

            if (vlen != 6) return .none;
            vn = @as(u8, name[4]) - 46 ;
            if (vn < 51 or vn > 76 ) return .none
            else return @intToEnum(kbd, vn);

        }

        if (std.eql(u8,name,"PageUp") == true)      return .pageUp;

        if (std.eql(u8,name,"PageDown") == true)    return .pageDown;

        if (std.eql(u8,name,"Home") == true)        return .home;

        if (std.eql(u8,name,"End") == true)         return .end;

        if (std.eql(u8,name,"Esc") == true)         return .esc;

        return .none;
    }



    /// converted keyboard variable

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

    // get All keyboard keys allowed in terminal
    pub fn getKEY()  Keyboard {

        // init Event
        var Event : Keyboard = Keyboard{.Key = kbd.none ,.Char =""};

        // variable --> Event.Char
        var vUnicode: []u8 = undefined;
        vUnicode = allocator. alloc(u8, 4) catch unreachable;

        // TODO: Check buffer size
        var buf: [12]u8 = undefined;
        const stdin = io.getStdIn();

        const c =  stdin.read(&buf) catch {Event.Key = kbd.none; return Event;};
        if (c == 0) {
            Event.Key = kbd.none; return Event;
        }

        const view = std.unicode.Utf8View.init(buf[0..c]) catch { Event.Key = kbd.none; return Event;};

        var iter = view.iterator();



        //std.debug.print("\n\rview:{any}\n", .{buf});

        // TODO: Find a better way to iterate buffer

        if (iter.nextCodepoint()) |c0| switch (c0) {
            '\x1b' => {
                if (iter.nextCodepoint()) |c1| switch (c1) {
                    // fn (1 - 4)
                    // O - 0x6f - 111
                    '\x4f' => {
                            switch ((1 + buf[2] - '\x50') ) {
                                1 => { Event.Key = kbd.F1; return Event;},
                                2 => { Event.Key = kbd.F2; return Event;},
                                3 => { Event.Key = kbd.F3; return Event;},
                                4 => { Event.Key = kbd.F4; return Event;},
                                else => { Event.Key = kbd.none; return Event;}
                            }
                    },

                    // csi
                    '[' => {
                        return  parse_csiFunc(buf[2..c]);

                    },

                    // alt key
                    else => {
                        switch (c1) {
                                'a' =>  { Event.Key = kbd.altA; return Event;},
                                'b' =>  { Event.Key = kbd.altB; return Event;},
                                'c' =>  { Event.Key = kbd.altC; return Event;},
                                'd' =>  { Event.Key = kbd.altD; return Event;},
                                'e' =>  { Event.Key = kbd.altE; return Event;},
                                'f' =>  { Event.Key = kbd.altF; return Event;},
                                'g' =>  { Event.Key = kbd.altG; return Event;},
                                'h' =>  { Event.Key = kbd.altH; return Event;},
                                'i' =>  { Event.Key = kbd.altI; return Event;},
                                'j' =>  { Event.Key = kbd.altJ; return Event;},
                                'k' =>  { Event.Key = kbd.altK; return Event;},
                                'l' =>  { Event.Key = kbd.altL; return Event;},
                                'm' =>  { Event.Key = kbd.altM; return Event;},
                                'n' =>  { Event.Key = kbd.altN; return Event;},
                                'o' =>  { Event.Key = kbd.altO; return Event;},
                                'p' =>  { Event.Key = kbd.altP; return Event;},
                                'q' =>  { Event.Key = kbd.altQ; return Event;},
                                'r' =>  { Event.Key = kbd.altR; return Event;},
                                's' =>  { Event.Key = kbd.altS; return Event;},
                                't' =>  { Event.Key = kbd.altT; return Event;},
                                'u' =>  { Event.Key = kbd.altU; return Event;},
                                'v' =>  { Event.Key = kbd.altV; return Event;},
                                'w' =>  { Event.Key = kbd.altW; return Event;},
                                'x' =>  { Event.Key = kbd.altX; return Event;},
                                'y' =>  { Event.Key = kbd.altY; return Event;},
                                'z' =>  { Event.Key = kbd.altZ; return Event;},
                                else => { Event.Key = kbd.none; return Event;},
                            }
                    },
                } else {
                        Event.Key = kbd.esc;
                        return Event;
                }
            },
            // ctrl keys (avoids  crtl-i (x09)   ctrl-m (x0D) )
            '\x01'...'\x08','\x0A'...'\x0C','\x0E'...'\x1A' => {
                    switch ( c0 + '\x60') {
                        'a' =>  { Event.Key = kbd.ctrlA; return Event;},
                        'b' =>  { Event.Key = kbd.ctrlB; return Event;},
                        'c' =>  { Event.Key = kbd.ctrlC; return Event;},
                        'd' =>  { Event.Key = kbd.ctrlD; return Event;},
                        'e' =>  { Event.Key = kbd.ctrlE; return Event;},
                        'f' =>  { Event.Key = kbd.ctrlF; return Event;},
                        'g' =>  { Event.Key = kbd.ctrlG; return Event;},
                        'h' =>  { Event.Key = kbd.ctrlH; return Event;},
                        'i' =>  { Event.Key = kbd.ctrlI; return Event;},
                        'j' =>  { Event.Key = kbd.ctrlJ; return Event;},
                        'k' =>  { Event.Key = kbd.ctrlK; return Event;},
                        'l' =>  { Event.Key = kbd.ctrlL; return Event;},
                        'm' =>  { Event.Key = kbd.ctrlM; return Event;},
                        'n' =>  { Event.Key = kbd.ctrlN; return Event;},
                        'o' =>  { Event.Key = kbd.ctrlO; return Event;},
                        'p' =>  { Event.Key = kbd.ctrlP; return Event;},
                        'q' =>  { Event.Key = kbd.ctrlQ; return Event;},
                        'r' =>  { Event.Key = kbd.ctrlR; return Event;},
                        's' =>  { Event.Key = kbd.ctrlS; return Event;},
                        't' =>  { Event.Key = kbd.ctrlT; return Event;},
                        'u' =>  { Event.Key = kbd.ctrlU; return Event;},
                        'v' =>  { Event.Key = kbd.ctrlV; return Event;},
                        'w' =>  { Event.Key = kbd.ctrlW; return Event;},
                        'x' =>  { Event.Key = kbd.ctrlX; return Event;},
                        'y' =>  { Event.Key = kbd.ctrlY; return Event;},
                        'z' =>  { Event.Key = kbd.ctrlZ; return Event;},
                        else => { Event.Key = kbd.none; return Event;},
                        }

            },
            // tab
            '\x09' =>   { Event.Key = kbd.tab; return Event;},
            // backspace
            '\x7f' =>   { Event.Key = kbd.backspace; return Event;},
            // Enter
            '\x0D' =>   { Event.Key = kbd.enter; return Event;},

            else => {
                // var vUnicode : [4]u8 = undefined; // if en Global then initaliser avec 0
                // vUnicode = [_]u8{0} ** 4; //

                var i = utf.utf8Encode(c0,vUnicode) catch unreachable;

                Event.Char  = vUnicode[0..i];

                Event.Key = kbd.char;

                //std.debug.print(" var CHAR {s} {any} \n\r",.{Event.Char,vUnicode });

                return Event;
                }
        };

        Event.Key = kbd.none;
        return Event;

    }

    fn parse_csiFunc(buf: []const u8) Keyboard {
        //std.debug.print("\n\rview:{any}\n", .{buf});
        // init
        var Event : Keyboard = Keyboard{.Key = kbd.none , .Char =""};

        switch (buf[0]) {
            // keys
            'A' => { Event.Key = kbd.up; return Event;},
            'B' => { Event.Key = kbd.down; return Event;},
            'C' => { Event.Key = kbd.right; return Event;},
            'D' => { Event.Key = kbd.left; return Event;},
            'H' => { Event.Key = kbd.home; return Event;},
            'F' => { Event.Key = kbd.end; return Event;},
            '3' => { Event.Key = kbd.delete; return Event;},


            '1'...'2' => {

                if (buf[1] == 126) {
                    switch (buf[0]) { // insert
                        '2' => { Event.Key = kbd.ins; return Event;},
                        else => { Event.Key = kbd.none; return Event;},
                    }
                }
                if (buf[2] == 126) {
                    switch (buf[1]) { // f5..f12
                        '5' => { Event.Key = kbd.F5; return Event;},
                        '7' => { Event.Key = kbd.F6; return Event;},
                        '8' => { Event.Key = kbd.F7; return Event;},
                        '9' => { Event.Key = kbd.F8; return Event;},
                        '0' => { Event.Key = kbd.F9; return Event;},
                        '1' => { Event.Key = kbd.F10; return Event;},
                        '3' => { Event.Key = kbd.F11; return Event;},
                        '4' => { Event.Key = kbd.F12; return Event;},
                        else =>  { Event.Key = kbd.none; return Event;},
                    }
                }
                if (buf[2] == 50) { // f11..f14 and // shift
                    switch (buf[3]) {
                        'P' => { Event.Key = kbd.F13; return Event;},
                        'Q' => { Event.Key = kbd.F14; return Event;},
                        'R' => { Event.Key = kbd.F15; return Event;},
                        'S' => { Event.Key = kbd.F16; return Event;},
                        'A' => { Event.Key = kbd.up; return Event;},
                        'B' => { Event.Key = kbd.down; return Event;},
                        'C' => { Event.Key = kbd.right; return Event;},
                        'D' => { Event.Key = kbd.left; return Event;},
                        'H' => { Event.Key = kbd.home; return Event;},
                        'F' => { Event.Key = kbd.end; return Event;},
                        '3' => { Event.Key = kbd.delete; return Event;},
                        '5' => { Event.Key = kbd.pageUp; return Event;},
                        '6' => { Event.Key = kbd.pageDown; return Event;},
                        else =>  { Event.Key = kbd.none ; return Event;},
                    }
                }
                if (buf[2] == 53) { //  sihft ctrl
                    switch (buf[3]) {
                    'A' => { Event.Key = kbd.up; return Event;},
                    'B' => { Event.Key = kbd.down; return Event;},
                    'C' => { Event.Key = kbd.right; return Event;},
                    'D' => { Event.Key = kbd.left; return Event;},
                    'H' => { Event.Key = kbd.home; return Event;},
                    '5' => { Event.Key = kbd.pageUp; return Event;},
                    '6' => { Event.Key = kbd.pageDown; return Event;},
                    else =>  { Event.Key = kbd.none; return Event;},
                    }
                }

                if (buf[2] == 54) { //  sihft / controle
                    switch (buf[3]) {
                    'A' => { Event.Key = kbd.up; return Event;},
                    'B' => { Event.Key = kbd.down; return Event;},
                    'C' => { Event.Key = kbd.right; return Event;},
                    'D' => { Event.Key = kbd.left; return Event;},
                    'H' => { Event.Key = kbd.home; return Event;},
                    '5' => { Event.Key = kbd.pageUp; return Event;},
                    '6' => { Event.Key = kbd.pageDown; return Event;},
                    else =>  { Event.Key = kbd.none; return Event;},
                    }
                }

                if (buf[2] == 60) { // f11..f14
                    switch (buf[3]) {
                        'P' => { Event.Key = kbd.F13; return Event;},
                        'Q' => { Event.Key = kbd.F14; return Event;},
                        'R' => { Event.Key = kbd.F15; return Event;},
                        'S' => { Event.Key = kbd.F16; return Event;},
                        else =>  { Event.Key = kbd.none; return Event;},
                    }
                }
                if (buf[4] == 126) { // f15..f24
                    switch (buf[1]) {
                        '5' => { Event.Key = kbd.F17; return Event;},
                        '7' => { Event.Key = kbd.F18; return Event;},
                        '8' => { Event.Key = kbd.F19; return Event;},
                        '9' => { Event.Key = kbd.F20; return Event;},
                        '0' => { Event.Key = kbd.F21; return Event;},
                        '1' => { Event.Key = kbd.F22; return Event;},
                        '3' => { Event.Key = kbd.F23; return Event;},
                        '4' => { Event.Key = kbd.F24; return Event;},
                        else =>  { Event.Key = kbd.none; return Event;},
                    }
                }

            },

            '5'...'6' => {
                if (buf[1] == 126) {
                    switch (buf[0]) {
                        '5' => { Event.Key = kbd.pageUp; return Event;},
                        '6' => { Event.Key = kbd.pageDown; return Event;},
                        else =>  { Event.Key = kbd.none ; return Event;},
                    }
                }
                if (buf[3] == 126) {
                    switch (buf[2]) {
                        '5' => { Event.Key = kbd.pageUp; return Event;},
                        '6' => { Event.Key = kbd.pageDown; return Event;},
                        else =>  { Event.Key = kbd.none ; return Event;},
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
                    if ((buf[6]) == 77 )    MouseInfo.action = MouseAction.maPressed;

                    if ((buf[6]) == 109 )   MouseInfo.action = MouseAction.maReleased;
                }

                if (buf.len == 8) {
                    if ((buf[7]) == 77 )    MouseInfo.action = MouseAction.maPressed;

                    if ((buf[7]) == 109 )   MouseInfo.action = MouseAction.maReleased;
                }

                if (buf.len == 9) {
                    if ((buf[8]) == 77 )    MouseInfo.action = MouseAction.maPressed;

                    if ((buf[8]) == 109 )   MouseInfo.action = MouseAction.maReleased;
                }

                if (buf.len == 10) {
                    if ((buf[9]) == 77 )    MouseInfo.action = MouseAction.maPressed;

                    if ((buf[9]) == 109 )   MouseInfo.action = MouseAction.maReleased;
                }

                if ((buf[1]) == 48 )    MouseInfo.button = MouseButton.mbLeft;

                if ((buf[1]) == 49 )    MouseInfo.button = MouseButton.mbMiddle;

                if ((buf[1]) == 50 )    MouseInfo.button = MouseButton.mbRight;

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

                return { Event.Key = kbd.mouse; return Event;};
            },
            else => { Event.Key = kbd.none; return Event;}
        }

        Event.Key = kbd.none;
        return Event;
    }

};




test "tested" {
//pub fn main() !void {
    const defAtrLabel : dds.ZONATRB = .{
    .styled=[_]u32{@enumToInt(dds.Style.styleBright),
                   @enumToInt(dds.Style.styleItalic),
                   @enumToInt(dds.Style.notStyle),
                   @enumToInt(dds.Style.notStyle)},
    .backgr = dds.BackgroundColor.bgBlack,
    .foregr = dds.ForegroundColor.fgGreen,
    };
    var raw_term = try enableRawMode();
    defer raw_term.disableRawMode() catch {};

    writeStyled("bonjour \n\r",defAtrLabel );

    getCursor();
    std.debug.print("\n\rcursor X:{d}  Y:{d}\n\r", .{posCurs.x, posCurs.y}) ;
    gotoXY(10,100);  // use terminal
    getCursor();
    std.debug.print("gotoXY X:{d}  Y:{d}\n\r", .{posCurs.x, posCurs.y});

    var size: TermSize = try getSize();
    std.debug.print("screen width:{d} height:{d}\n\r",.{size.width , size.height });
    offMouse();
    flushIO();


    const Tkey = kbd.getKEY();
    std.debug.print("F.. {any}\n\r",.{Tkey});
    switch (Tkey.Key) {
                .F16    => std.debug.print("F.. {} \n\r",.{Tkey.Key}),
                .altB   => std.debug.print("Alt. {} \n\r",.{Tkey.Key}),
                .ctrlG  => std.debug.print("Ctrl. {} \n\r",.{Tkey.Key}),
                .mouse  => std.debug.print("Ctrl. {} \n\r",.{Tkey.Key}),
                .char  =>  {
                    std.debug.print("Char. {s}\n\r",.{Tkey.Char });
                },
                else    => std.debug.print("F.. {} \n\r",.{Tkey.Key}),
            }

}
