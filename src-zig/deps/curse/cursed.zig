const std = @import("std");
const utf = @import("std").unicode;
const dds = @import("dds");
const utl = @import("utils");

const io = std.io;
const os = std.os;
const fs = std.fs;

/// Define use terminal basic
var TTY: fs.File = undefined;

var original_termios: os.linux.termios = undefined;
var use_termios: os.linux.termios = undefined;

const STDOUT_TERM = std.io.getStdOut();
var buf_Output = std.io.bufferedWriter(STDOUT_TERM.writer());
// Get the Writer interface from BufferedWriter
const wcons = buf_Output.writer();

const allocator = std.heap.page_allocator;

/// flush terminal in-out
pub fn flushIO() void {
    buf_Output.flush() catch unreachable;
    _ = os.linux.tcsetattr(TTY.handle, .FLUSH, &use_termios);
}

///-------------
/// mouse
///-------------
/// onMouse
pub fn onMouse() void {
    wcons.print("\x1b[?1000;1005;1006h", .{}) catch unreachable;
    flushIO();
}

/// offMouse
pub fn offMouse() void {
    wcons.print("\x1b[?1000;1005;1006l", .{}) catch unreachable;
    flushIO();
}

///-------------
/// clear
///-------------
/// Clear from cursor until end of screen
pub fn cls_from_cursor_toEndScreen() void {
    wcons.print("\x1b[0J", .{}) catch unreachable;
    flushIO();
}

/// Clear from cursor to beginning of screen
pub fn cls_from_cursor_toStartScreen() void {
    wcons.print("\x1b[1J", .{}) catch unreachable;
    flushIO();
}

/// Clear all screen
pub fn cls() void {
    wcons.print("\x1b[2J", .{}) catch unreachable;
    wcons.print("\x1b[3J", .{}) catch unreachable;
    flushIO();
}

/// Clear from cursor to end of line
pub fn cls_from_cursor_toEndline() void {
    wcons.print("\x1b[0K", .{}) catch unreachable;
    flushIO();
}

/// Clear start of line to the cursor
pub fn cls_from_cursor_toStartLine() void {
    wcons.print("\x1b[1K", .{}) catch unreachable;
    flushIO();
}

/// Clear from cursor to end of line
pub fn cls_line() void {
    wcons.print("\x1b[2K", .{}) catch unreachable;
    flushIO();
}

///-------------
/// cursor
///-------------
const Point = struct { x: usize, y: usize };

pub var posCurs: Point = undefined;

/// Moves cursor to `x` column and `y` row
pub fn gotoXY(x: usize, y: usize) void {
    wcons.print("\x1b[{d};{d}H", .{ x, y }) catch unreachable;
    flushIO();
}

/// Moves cursor up `y` rows
pub fn gotoUp(x: usize) void {
    wcons.print("\x1b[{d}A", .{x}) catch unreachable;
    flushIO();
}

/// Moves cursor down `y` rows
pub fn gotoDown(x: usize) void {
    wcons.print("\x1b[{d}B", .{x}) catch unreachable;
    flushIO();
}

/// Moves cursor left `y` columns
pub fn gotoLeft(y: usize) void {
    wcons.print("\x1b[{d}D", .{y}) catch unreachable;
    flushIO();
}

/// Moves cursor right `y` columns
pub fn gotoRight(y: usize) void {
    wcons.print("\x1b[{d}C", .{y}) catch unreachable;
    flushIO();
}

/// Hide the cursor
pub fn cursHide() void {
    wcons.print("\x1b[?25l", .{}) catch unreachable;
    flushIO();
}

/// Show the cursor
pub fn cursShow() void {
    wcons.print("\x1b[?25h", .{}) catch unreachable;
    flushIO();
}

pub fn defCursor(e_curs: dds.typeCursor) void {
    // define type  Cursor form terminal
    switch (e_curs) {
        .cDefault => {
            wcons.print("\x1b[0 q", .{}) catch unreachable; // 0 → default terminal
        },
        .cBlink => {
            wcons.print("\x1b[1 q", .{}) catch unreachable; // 1 → blinking block
        },
        .cSteady => {
            wcons.print("\x1b[2 q", .{}) catch unreachable; //  2 → steady block
        },
        .cBlinkUnderline => {
            wcons.print("\x1b[3 q", .{}) catch unreachable; //  3 → blinking underlines
        },
        .cSteadyUnderline => {
            wcons.print("\x1b[4 q", .{}) catch unreachable; //  4 → steady underlines
        },
        .cBlinkBar => {
            wcons.print("\x1b[5 q", .{}) catch unreachable; //  5 → blinking bar
        },
        .cSteadyBar => {
            wcons.print("\x1b[6 q", .{}) catch unreachable; //  6 → steady bar
        },
    }
    wcons.print("\x1b[?25h", .{}) catch unreachable;
    flushIO();
}

fn convIntCursor(x: u8) usize {
    switch (x) {
        '0' => return 0,
        '1' => return 1,
        '2' => return 2,
        '3' => return 3,
        '4' => return 4,
        '5' => return 5,
        '6' => return 6,
        '7' => return 7,
        '8' => return 8,
        '9' => return 9,
        else => return 0,
    }
}

pub fn getCursor() void {
    // get Cursor form terminal
    var cursBuf: [13]u8 = undefined;
    const wtty = TTY.writer();

    posCurs.x = 0;
    posCurs.y = 0;

    flushIO();

    // Don't forget to flush!
    wtty.writeAll("\x1b[?6n") catch unreachable;

    var c: usize = 0;
    while (c == 0) {
        c = TTY.read(&cursBuf) catch unreachable;
    }
    flushIO();

    // columns = 1 digit
    if (cursBuf[4] == 59) {
      posCurs.x = convIntCursor(cursBuf[3]);

      if (cursBuf[6] == 59)  posCurs.y = convIntCursor(cursBuf[5]);

      if (cursBuf[7] == 59) {
          posCurs.y = convIntCursor(cursBuf[5]);
          posCurs.y = (posCurs.y * 10) + convIntCursor(cursBuf[6]);
      }

      if ( cursBuf[8] == 59 ) {
          posCurs.y = convIntCursor(cursBuf[5]);
          posCurs.y = (posCurs.y * 10) + convIntCursor(cursBuf[6]);
          posCurs.y = (posCurs.y * 10) + convIntCursor(cursBuf[7]);
      }
    }
    // columns = 2 digits
    if (cursBuf[5] == 59) {
      posCurs.x = convIntCursor(cursBuf[3]);
      posCurs.x = (posCurs.x * 10) + convIntCursor(cursBuf[4]);
      
      if (cursBuf[7] == 59)  posCurs.y = convIntCursor(cursBuf[6]);

      if ( cursBuf[8] == 59) {
          posCurs.y = convIntCursor(cursBuf[6]);
          posCurs.y = (posCurs.y * 10) + convIntCursor(cursBuf[7]);
      }

      if ( cursBuf[9] == 59 ) {
          posCurs.y = convIntCursor(cursBuf[6]);
          posCurs.y = (posCurs.y * 10) + convIntCursor(cursBuf[7]);
          posCurs.y = (posCurs.y * 10) + convIntCursor(cursBuf[8]);
      }


    }
    flushIO();
}

///-------------------------
/// style color writestyled
///-------------------------
/// Reset the terminal style.
pub fn resetStyle() void {
    wcons.print("\x1b[0m", .{}) catch unreachable;
}

/// Sets the terminal style.
fn setStyle(style: [4]u32) void {
    for (style) |v| {
        if (v != 0) {
            wcons.print("\x1b[{d}m", .{v}) catch unreachable;
        }
    }
}

/// Sets the terminal's foreground color.
fn setForegroundColor(color: dds.BackgroundColor) void {
    wcons.print("\x1b[{d}m", .{@enumToInt(color)}) catch unreachable;
}

/// Sets the terminal's Background color.
fn setBackgroundColor(color: dds.ForegroundColor) void {
    wcons.print("\x1b[{d}m", .{@enumToInt(color)}) catch unreachable;
}

/// write text and attribut
pub fn writeStyled(text: []const u8, attribut: dds.ZONATRB) void {
    setForegroundColor(attribut.backgr);
    setBackgroundColor(attribut.foregr);
    setStyle(attribut.styled);
    wcons.print("{s}\x1b[0m", .{text}) catch unreachable;
    //flushIO();
}

///-------------------------
/// Terminal
///-------------------------
/// A raw terminal representation, you can enter terminal raw mode
/// using this struct. Raw mode is essential to create a TUI.
/// open terminal and config
pub fn enableRawMode() void {
    TTY = fs.cwd().openFile("/dev/tty", .{ .mode = .read_write }) catch unreachable;
    //defer TTY.close();

    _ = os.linux.tcgetattr(TTY.handle, &original_termios);

    _ = os.linux.tcgetattr(TTY.handle, &use_termios);

    // https://viewsourcecode.org/snaptoken/kilo/02.enteringRawMode.html
    // https://codeberg.org/josias/zigcurses/src/branch/master/src/main.zig
    // https://man7.org/linux/man-pages/man3/termios.3.html

    // https://manpages.ubuntu.com/manpages/trusty/fr/man3/termios.3.html

    // https://zig.news/lhp/want-to-create-a-tui-application-the-basics-of-uncooked-terminal-io-17gm

    use_termios.iflag &= ~(os.linux.IGNBRK | os.linux.BRKINT | os.linux.PARMRK | os.linux.INPCK | os.linux.ISTRIP |
        os.linux.INLCR | os.linux.IGNCR | os.linux.ICRNL | os.linux.IXON);

    use_termios.oflag &= ~(os.linux.OPOST);
    use_termios.cflag &= ~(os.linux.CSIZE | os.linux.PARENB);
    use_termios.cflag |= (os.linux.CS8);
    use_termios.lflag &= ~(os.linux.ECHO | os.linux.ECHONL | os.linux.ICANON | os.linux.IEXTEN | os.linux.ISIG);

    // Wait until it reads at least one byte  terminal standard
    use_termios.cc[os.linux.V.MIN] = 1;

    // Wait 100 miliseconds at maximum.
    use_termios.cc[os.linux.V.TIME] = 0;

    // apply changes
    _ = os.linux.tcsetattr(TTY.handle, .NOW, &use_termios);

    // cursor HIDE par défault
    cursHide();
    offMouse();
}

/// Clear gross terminal
fn reset() void {
    var name = "/bin/echo";
    var args = [_:null]?[*:0]const u8{ "echo", "\x1b[H\x1b[3J" };
    var env = [_:null]?[*:0]u8{};

    std.os.execveZ(name, args[0..args.len], env[0..env.len]) catch unreachable;
}

/// Returns to the previous terminal state
pub fn disableRawMode() void {
    defCursor(dds.typeCursor.cSteady);
    offMouse();
    cursShow();
    cls();
    wcons.print("\x1b[H", .{}) catch unreachable; // init pos_coursor

    _ = os.linux.tcsetattr(TTY.handle, .FLUSH, &original_termios);
    reset();
}

/// get size terminal
const TermSize = struct { width: usize, height: usize };

pub fn getSize() !TermSize {
    var win_size: std.os.linux.winsize = undefined;

    const err = os.linux.ioctl(TTY.handle, os.linux.T.IOCGWINSZ, @ptrToInt(&win_size));
    if (os.errno(err) != .SUCCESS) {
        return os.unexpectedErrno(@intToEnum(os.linux.E, err));
    }
    return TermSize{
        .height = win_size.ws_row,
        .width = win_size.ws_col,
    };
}

/// Update title terminal
pub fn titleTerm(title: []const u8) void {
    if (title.len > 0) {
        wcons.print("\x1b]0;{s}\x07", .{title}) catch unreachable;
        flushIO();
    }
}

// if use resize  ok : vte application terminal ex TermVte
// change XTERM
// sudo thunar /etc/X11/app-defaults/XTerm
// *allowWindowOps: true  *eightBitInput: false

pub fn resizeTerm(line: usize, cols: usize) void {
    if (line > 0 and cols > 0) {
        wcons.print("\x1b[8;{d};{d};t", .{ line, cols }) catch unreachable;
        flushIO();
    }
}

/// mouse struct
pub const MouseAction = enum {
    maNone,
    maPressed,
    maReleased,
};

pub const MouseButton = enum {
    mbNone,
    mbLeft,
    mbMiddle,
    mbRight,
};

pub const ScrollDirection = enum {
    msNone,
    msUp,
    msDown,
};

const Mouse = struct {
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

pub var MouseInfo: Mouse = undefined;

pub const Keyboard = struct { Key: kbd, Char: []const u8 };

/// Decrypt the keyboard
pub const kbd = enum {
    none,
    F1,
    F2,
    F3,
    F4,
    F5,
    F6,
    F7,
    F8,
    F9,
    F10,
    F11,
    F12,
    F13,
    F14,
    F15,
    F16,
    F17,
    F18,
    F19,
    F20,
    F21,
    F22,
    F23,
    F24,
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

    up,
    down,
    left,
    right,
    delete,
    enter,
    ins,
    tab,
    stab,
    backspace,
    func,
    task,

    pub const NameTable = [@typeInfo(kbd).Enum.fields.len][:0]const u8{
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

        "up",
        "down",
        "left",
        "right",
        "delete",
        "enter",
        "ins",
        "tab",
        "stab",
        "backspace",
        "func", // Triggered by ioField function
        "task", // Triggered by ioField task
    };

    pub fn str(self: kbd) [:0]const u8 {
        return NameTable[@enumToInt(self)];
    }

    pub fn toEnum(name: []const u8) kbd {
        var vlen: usize = 0;
        var vn: u8 = 0;
        var iter = utl.iteratStr.iterator(name);
        while (iter.next()) |_| {
            vlen += 1;
        }

        if (name[0] == 'F') {
            //f1..f9
            if (vlen == 2) return @intToEnum(kbd, @as(u8, name[1]));
            // f10..f19
            if (vlen == 3 and name[1] == '1') return @intToEnum(kbd, 10 + @as(u8, name[2]));
            // f20..f24
            if (vlen == 3 and name[2] == '2') return @intToEnum(kbd, 20 + @as(u8, name[2]));
        }

        if (name[0] == 'A' and name[1] == 'l' and name[2] == 't' and name[3] == '.') {
            if (vlen != 5) return .none;
            vn = @as(u8, name[4]) - 72;
            if (vn < 25 or vn > 50) return .none else return @intToEnum(kbd, vn);
        }

        if (name[0] == 'C' and name[1] == 't' and name[2] == 'r' and name[3] == 'l' and name[4] == '.') {
            if (vlen != 6) return .none;
            vn = @as(u8, name[4]) - 46;
            if (vn < 51 or vn > 76) return .none else return @intToEnum(kbd, vn);
        }

        if (std.eql(u8, name, "PageUp") == true) return .pageUp;

        if (std.eql(u8, name, "PageDown") == true) return .pageDown;

        if (std.eql(u8, name, "Home") == true) return .home;

        if (std.eql(u8, name, "End") == true) return .end;

        if (std.eql(u8, name, "Esc") == true) return .esc;

        return .none;
    }

    /// converted keyboard variable
    fn convIntMouse(x: u8) usize {
        switch (x) {
            '0' => return 0,
            '1' => return 1,
            '2' => return 2,
            '3' => return 3,
            '4' => return 4,
            '5' => return 5,
            '6' => return 6,
            '7' => return 7,
            '8' => return 8,
            '9' => return 9,
            else => return 1,
        }
    }

    // get All keyboard keys allowed in terminal
    pub fn getKEY() Keyboard {

        // init Event
        var Event: Keyboard = Keyboard{ .Key = kbd.none, .Char = "" };

        // variable --> Event.Char
        var vUnicode: []u8 = undefined;
        vUnicode = allocator.alloc(u8, 4) catch unreachable;
        var x: usize = 0;
        while (x < 4) : (x += 1) vUnicode[x] = 0;

        // TODO: Check buffer size
        var keybuf: [13]u8 = undefined;

        flushIO();

        var c: usize = 0;
        while (c == 0) {
            c = TTY.read(&keybuf) catch continue;
        }

        const view = std.unicode.Utf8View.init(keybuf[0..c]) catch {
            Event.Key = kbd.none;
            return Event;
        };

        var iter = view.iterator();

        // TODO: Find a better way to iterate buffer

        if (iter.nextCodepoint()) |c0| switch (c0) {
            '\x1b' => {
                if (iter.nextCodepoint()) |c1| switch (c1) {
                    // fn (1 - 4)
                    // O - 0x6f - 111
                    '\x4f' => {
                        switch ((1 + keybuf[2] - '\x50')) {
                            1 => { Event.Key = kbd.F1; return Event; },
                            2 => { Event.Key = kbd.F2; return Event; },
                            3 => { Event.Key = kbd.F3; return Event; },
                            4 => { Event.Key = kbd.F4; return Event; },
                            else => { Event.Key = kbd.none; return Event; },
                        }
                    },

                    // csi
                    '[' => {
                        return parse_csiFunc(keybuf[2..c]);
                    },

                    // alt key
                    else => {
                        switch (c1) {
                            'a' => { Event.Key = kbd.altA; return Event; },
                            'b' => { Event.Key = kbd.altB; return Event; },
                            'c' => { Event.Key = kbd.altC; return Event; },
                            'd' => { Event.Key = kbd.altD; return Event; },
                            'e' => { Event.Key = kbd.altE; return Event; },
                            'f' => { Event.Key = kbd.altF; return Event; },
                            'g' => { Event.Key = kbd.altG; return Event; },
                            'h' => { Event.Key = kbd.altH; return Event; },
                            'i' => { Event.Key = kbd.altI; return Event; },
                            'j' => { Event.Key = kbd.altJ; return Event; },
                            'k' => { Event.Key = kbd.altK; return Event; },
                            'l' => { Event.Key = kbd.altL; return Event; },
                            'm' => { Event.Key = kbd.altM; return Event; },
                            'n' => { Event.Key = kbd.altN; return Event; },
                            'o' => { Event.Key = kbd.altO; return Event; },
                            'p' => { Event.Key = kbd.altP; return Event; },
                            'q' => { Event.Key = kbd.altQ; return Event; },
                            'r' => { Event.Key = kbd.altR; return Event; },
                            's' => { Event.Key = kbd.altS; return Event; },
                            't' => { Event.Key = kbd.altT; return Event; },
                            'u' => { Event.Key = kbd.altU; return Event; },
                            'v' => { Event.Key = kbd.altV; return Event; },
                            'w' => { Event.Key = kbd.altW; return Event; },
                            'x' => { Event.Key = kbd.altX; return Event; },
                            'y' => { Event.Key = kbd.altY; return Event; },
                            'z' => { Event.Key = kbd.altZ; return Event; },
                            else => { Event.Key = kbd.none; return Event; },
                        }
                    },
                } else { Event.Key = kbd.esc; return Event; }
            },

            // ctrl keys ( crtl-i (x09)   ctrl-m (x0D) )
            '\x01'...'\x08', '\x0A'...'\x0C', '\x0E'...'\x1A' => {
                switch (c0 + '\x60') {
                    'a' => { Event.Key = kbd.ctrlA; return Event; },
                    'b' => { Event.Key = kbd.ctrlB; return Event; },
                    'c' => { Event.Key = kbd.ctrlC; return Event; },
                    'd' => { Event.Key = kbd.ctrlD; return Event; },
                    'e' => { Event.Key = kbd.ctrlE; return Event; },
                    'f' => { Event.Key = kbd.ctrlF; return Event; },
                    'g' => { Event.Key = kbd.ctrlG; return Event; },
                    'h' => { Event.Key = kbd.ctrlH; return Event; },
                    'i' => { Event.Key = kbd.ctrlI; return Event; },
                    'j' => { Event.Key = kbd.ctrlJ; return Event; },
                    'k' => { Event.Key = kbd.ctrlK; return Event; },
                    'l' => { Event.Key = kbd.ctrlL; return Event; },
                    'm' => { Event.Key = kbd.ctrlM; return Event; },
                    'n' => { Event.Key = kbd.ctrlN; return Event; },
                    'o' => { Event.Key = kbd.ctrlO; return Event; },
                    'p' => { Event.Key = kbd.ctrlP; return Event; },
                    'q' => { Event.Key = kbd.ctrlQ; return Event; },
                    'r' => { Event.Key = kbd.ctrlR; return Event; },
                    's' => { Event.Key = kbd.ctrlS; return Event; },
                    't' => { Event.Key = kbd.ctrlT; return Event; },
                    'u' => { Event.Key = kbd.ctrlU; return Event; },
                    'v' => { Event.Key = kbd.ctrlV; return Event; },
                    'w' => { Event.Key = kbd.ctrlW; return Event; },
                    'x' => { Event.Key = kbd.ctrlX; return Event; },
                    'y' => { Event.Key = kbd.ctrlY; return Event; },
                    'z' => { Event.Key = kbd.ctrlZ; return Event; },
                    else => { Event.Key = kbd.none; return Event; },
                }
            },

            // tab
            '\x09' => { Event.Key = kbd.tab;       return Event; },
            // backspace
            '\x7f' => { Event.Key = kbd.backspace; return Event; },
            // Enter
            '\x0D' => { Event.Key = kbd.enter;     return Event; },

            else => {
                var i = utf.utf8Encode(c0, vUnicode) catch unreachable;

                Event.Char = vUnicode[0..i];

                Event.Key = kbd.char;

                return Event;
            },
        };

        Event.Key = kbd.none;
        return Event;
    }

    fn parse_csiFunc(csibuf: []const u8) Keyboard {
        // init
        var Event: Keyboard = Keyboard{ .Key = kbd.none, .Char = "" };

        switch (csibuf[0]) {
            // keys
            'A' => { Event.Key = kbd.up;     return Event; },
            'B' => { Event.Key = kbd.down;   return Event; },
            'C' => { Event.Key = kbd.right;  return Event; },
            'D' => { Event.Key = kbd.left;   return Event; },
            'H' => { Event.Key = kbd.home;   return Event; },
            'F' => { Event.Key = kbd.end;    return Event; },
            '3' => { Event.Key = kbd.delete; return Event; },
            'Z' => { Event.Key = kbd.stab;   return Event; },

            '1'...'2' => {
                if (csibuf[1] == 126) {
                    switch (csibuf[0]) { // insert
                        '2' =>  { Event.Key = kbd.ins;  return Event; },
                        else => { Event.Key = kbd.none; return Event; },
                    }
                }
                if (csibuf[2] == 126) {
                    switch (csibuf[1]) { // f5..f12
                        '5' => { Event.Key = kbd.F5;  return Event; },
                        '7' => { Event.Key = kbd.F6;  return Event; },
                        '8' => { Event.Key = kbd.F7;  return Event; },
                        '9' => { Event.Key = kbd.F8;  return Event; },
                        '0' => { Event.Key = kbd.F9;  return Event; },
                        '1' => { Event.Key = kbd.F10; return Event; },
                        '3' => { Event.Key = kbd.F11; return Event; },
                        '4' => { Event.Key = kbd.F12; return Event; },
                        else => {Event.Key = kbd.none;return Event; },
                    }
                }
                if (csibuf[2] == 50) { // f11..f14 and // shift
                    switch (csibuf[3]) {
                        'P' => { Event.Key = kbd.F13;     return Event; },
                        'Q' => { Event.Key = kbd.F14;     return Event; },
                        'R' => { Event.Key = kbd.F15;     return Event; },
                        'S' => { Event.Key = kbd.F16;     return Event; },
                        'A' => { Event.Key = kbd.up;      return Event; },
                        'B' => { Event.Key = kbd.down;    return Event; },
                        'C' => { Event.Key = kbd.right;   return Event; },
                        'D' => { Event.Key = kbd.left;    return Event; },
                        'H' => { Event.Key = kbd.home;    return Event; },
                        'F' => { Event.Key = kbd.end;     return Event; },
                        '3' => { Event.Key = kbd.delete;   return Event; },
                        '5' => { Event.Key = kbd.pageUp;   return Event; },
                        '6' => { Event.Key = kbd.pageDown; return Event; },
                        else => { Event.Key = kbd.none;    return Event; },
                    }
                }
                if (csibuf[2] == 53) { //  sihft ctrl
                    switch (csibuf[3]) {
                        'A' => { Event.Key = kbd.up;       return Event; },
                        'B' => { Event.Key = kbd.down;     return Event; },
                        'C' => { Event.Key = kbd.right;    return Event; },
                        'D' => { Event.Key = kbd.left;     return Event; },
                        'H' => { Event.Key = kbd.home;     return Event; },
                        '5' => { Event.Key = kbd.pageUp;   return Event; },
                        '6' => { Event.Key = kbd.pageDown; return Event; },
                        else => { Event.Key = kbd.none;    return Event; },
                    }
                }

                if (csibuf[2] == 54) { //  sihft / controle
                    switch (csibuf[3]) {
                        'A' => {Event.Key = kbd.up;        return Event; },
                        'B' => {Event.Key = kbd.down;      return Event; },
                        'C' => {Event.Key = kbd.right;     return Event; },
                        'D' => {Event.Key = kbd.left;      return Event; },
                        'H' => {Event.Key = kbd.home;      return Event; },
                        '5' => {Event.Key = kbd.pageUp;    return Event; },
                        '6' => {Event.Key = kbd.pageDown;  return Event; },
                        else => {Event.Key = kbd.none;     return Event; },
                    }
                }

                if (csibuf[2] == 60) { // f11..f14
                    switch (csibuf[3]) {
                        'P' => { Event.Key = kbd.F13;   return Event; },
                        'Q' => { Event.Key = kbd.F14;   return Event; },
                        'R' => { Event.Key = kbd.F15;   return Event; },
                        'S' => { Event.Key = kbd.F16;   return Event; },
                        else => { Event.Key = kbd.none; return Event; },
                    }
                }
                if (csibuf[4] == 126) { // f15..f24
                    switch (csibuf[1]) {
                        '5' => { Event.Key = kbd.F17;   return Event; },
                        '7' => { Event.Key = kbd.F18;   return Event; },
                        '8' => { Event.Key = kbd.F19;   return Event; },
                        '9' => { Event.Key = kbd.F20;   return Event; },
                        '0' => { Event.Key = kbd.F21;   return Event; },
                        '1' => { Event.Key = kbd.F22;   return Event; },
                        '3' => { Event.Key = kbd.F23;   return Event; },
                        '4' => { Event.Key = kbd.F24;   return Event; },
                        else => { Event.Key = kbd.none; return Event; },
                    }
                }
            },

            '5'...'6' => {
                if (csibuf[1] == 126) {
                    switch (csibuf[0]) {
                        '5' => { Event.Key = kbd.pageUp;   return Event; },
                        '6' => { Event.Key = kbd.pageDown; return Event; },
                        else => { Event.Key = kbd.none;    return Event; },
                    }
                }
                if (csibuf[3] == 126) {
                    switch (csibuf[2]) {
                        '5' => { Event.Key = kbd.pageUp;   return Event; },
                        '6' => { Event.Key = kbd.pageDown; return Event; },
                        else => { Event.Key = kbd.none;    return Event; },
                    }
                }
            },

            '<' => { // mouse
                MouseInfo.action = MouseAction.maNone;
                MouseInfo.button = MouseButton.mbNone;
                MouseInfo.scrollDir = ScrollDirection.msNone;
                MouseInfo.scroll = false;
                MouseInfo.x = 0;
                MouseInfo.y = 0;
                Event.Key = kbd.mouse;
                Event.Char = "";

                var i: usize = 3;
                while (true) {
                    if (csibuf[i] != 59 and MouseInfo.y == 0) MouseInfo.y = convIntMouse(csibuf[3]);
                    if (csibuf[i] == 59) break;
                    if (csibuf[i] != 59 and i > 3) MouseInfo.y = (MouseInfo.y * 10) + convIntMouse(csibuf[i]);
                    i += 1;
                }

                var u: usize = i + 1;
                while (true) {
                    if (csibuf[u] != 59 and MouseInfo.x == 0) MouseInfo.x = convIntMouse(csibuf[u]);
                    if (csibuf[u] == 59 or csibuf[u] == 77 or csibuf[u] == 109) break;
                    if (csibuf[u] != 59 and u > (i + 1)) MouseInfo.x = (MouseInfo.x * 10) + convIntMouse(csibuf[u]);
                    u += 1;
                }

                if (csibuf.len == 7) {
                    if (csibuf[6] == 77)  MouseInfo.action = MouseAction.maPressed;

                    if (csibuf[6] == 109) MouseInfo.action = MouseAction.maReleased;
                }

                if (csibuf.len == 8) {
                    if (csibuf[7] == 77)  MouseInfo.action = MouseAction.maPressed;

                    if (csibuf[7] == 109) MouseInfo.action = MouseAction.maReleased;
                }

                if (csibuf.len == 9) {
                    if (csibuf[8] == 77)  MouseInfo.action = MouseAction.maPressed;

                    if (csibuf[8] == 109) MouseInfo.action = MouseAction.maReleased;
                }

                if (csibuf.len == 10) {
                    if (csibuf[9] == 77)  MouseInfo.action = MouseAction.maPressed;

                    if (csibuf[9] == 109) MouseInfo.action = MouseAction.maReleased;
                }

                if (csibuf[1] == 48) MouseInfo.button = MouseButton.mbLeft;

                if (csibuf[1] == 49) MouseInfo.button = MouseButton.mbMiddle;

                if (csibuf[1] == 50) MouseInfo.button = MouseButton.mbRight;

                if (csibuf[1] == 54 and csibuf[2] == 52) {
                    MouseInfo.scroll = true;
                    MouseInfo.scrollDir = ScrollDirection.msUp;
                    MouseInfo.x = 0;
                    MouseInfo.y = 0;
                }

                if (csibuf[1] == 54 and csibuf[2] == 53) {
                    MouseInfo.scroll = true;
                    MouseInfo.scrollDir = ScrollDirection.msDown;
                    MouseInfo.x = 0;
                    MouseInfo.y = 0;
                }

              return Event;

            },
            else => {
                Event.Key = kbd.none;
                return Event;
            },
        }

        Event.Key = kbd.none;
        return Event;
    }
};
