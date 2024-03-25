///-----------------------
/// cursed
/// connexion terminal
/// zig 0.12.0 dev
///-----------------------
const std = @import("std");
const utf = @import("std").unicode;

const io = std.io;
const os = std.os;
const fs = std.fs;

/// Define use terminal basic
var TTY: fs.File = undefined;

var original_termios: os.linux.termios = undefined;
var use_termios: os.linux.termios = undefined;

const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();
// outils

// const allocstr = std.heap.page_allocator;
var arenaTerm = std.heap.ArenaAllocator.init(std.heap.page_allocator);
pub var allocatorTerm = arenaTerm.allocator();
pub fn deinitTerm() void {
    arenaTerm.deinit();
    arenaTerm = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    allocatorTerm = arenaTerm.allocator();
}

pub const Style = enum(u8) {
    notStyle = 0, // not styled
    styleBold = 1, // bold text
    styleDim, // dim text
    styleItalic, // italic (or reverse on terminals not supporting)
    styleUnderscore, // underscored text
    styleBlink, // blinking/bold text
    styleBlinkRapid, // rapid blinking/bold text (not widely supported)
    styleReverse, // reverse
    styleHidden, // hidden text
    styleCrossed, // strikethrough
};

pub const typeCursor = enum(u8) { cDefault, cBlink, cSteady, cBlinkUnderline, cSteadyUnderline, cBlinkBar, cSteadyBar };

// def standard color fgd dull color  fg higth color
pub const ForegroundColor = enum(u8) { // terminal's foreground colors
    fgdBlack = 30, // black
    fgdRed, // red
    fgdGreen, // green
    fgdYellow, // yellow
    fgdBlue, // blue
    fgdMagenta, // magenta
    fgdCyan, // cyan
    fgdWhite, // white
    fgBlack = 90, // black
    fgRed, // red
    fgGreen, // green
    fgYellow, // yellow
    fgBlue, // blue
    fgMagenta, // magenta
    fgCyan, // cyan
    fgWhite, // white
};

pub const BackgroundColor = enum(u8) { // terminal's background colors
    bgBlack = 40, // black
    bgRed, // red
    bgGreen, // green
    bgYellow, // yellow
    bgBlue, // blue
    bgMagenta, // magenta
    bgCyan = 106, // cyan
    bgWhite = 47, // white
};

// attribut standard
pub const ZONATRB = struct { styled: [4]u32, backgr: BackgroundColor, foregr: ForegroundColor };

pub const iteratStr = struct {
    var strbuf: []const u8 = undefined;

    /// Errors that may occur when using String
    pub const ErrNbrch = error{
        InvalideAllocBuffer,
    };

    pub const StringIterator = struct {
        buf: []u8,
        index: usize,

        fn allocBuffer(size: usize) ErrNbrch![]u8 {
            const buf = allocatorTerm.alloc(u8, size) catch {
                return ErrNbrch.InvalideAllocBuffer;
            };
            return buf;
        }

        /// Deallocates the internal buffer
        pub fn deinit(self: *StringIterator) void {
            if (self.buf.len > 0) allocatorTerm.free(self.buf);
            strbuf = "";
        }

        pub fn next(it: *StringIterator) ?[]const u8 {
            const optional_buf: ?[]u8 = allocBuffer(strbuf.len) catch return null;

            it.buf = optional_buf orelse "";
            var idx: usize = 0;

            while (true) {
                if (idx >= strbuf.len) break;
                it.buf[idx] = strbuf[idx];
                idx += 1;
            }

            if (it.index >= it.buf.len) return null;
            idx = it.index;
            it.index += getUTF8Size(it.buf[idx]);
            return it.buf[idx..it.index];
        }

        pub fn preview(it: *StringIterator) ?[]const u8 {
            const optional_buf: ?[]u8 = allocBuffer(strbuf.len) catch return null;

            it.buf = optional_buf orelse "";
            var idx: usize = 0;
            while (true) {
                if (idx >= strbuf.len) break;
                it.buf[idx] = strbuf[idx];
                idx += 1;
            }

            if (it.index == 0) return null;
            idx = it.buf.len;
            it.index -= getUTF8Size(it.buf[idx]);
            return it.buf[idx..it.index];
        }
    };

    /// iterator String
    pub fn iterator(str: []const u8) StringIterator {
        strbuf = str;
        return StringIterator{
            .buf = undefined,
            .index = 0,
        };
    }

    /// Returns the UTF-8 character's size
    fn getUTF8Size(char: u8) u3 {
        return std.unicode.utf8ByteSequenceLength(char) catch unreachable;
    }
};

/// flush terminal in-out
pub fn flushIO() void {
    _ = os.linux.tcsetattr(TTY.handle, .FLUSH, &use_termios);
}

///-------------
/// mouse
///-------------
/// onMouse
pub fn onMouse() void {
    stdout.writeAll("\x1b[?1000;1005;1006h") catch {};
}

/// offMouse
pub fn offMouse() void {
    stdout.writeAll("\x1b[?1000;1005;1006l") catch {};
}

///-------------
/// clear
///-------------
/// Clear from cursor until end of screen
pub fn cls_from_cursor_toEndScreen() void {
    stdout.writeAll("\x1b[0J") catch {};
}

/// Clear from cursor to beginning of screen
pub fn cls_from_cursor_toStartScreen() void {
    stdout.writeAll("\x1b[1J") catch {};
}

/// Clear all screen
pub fn cls() void {
    stdout.writeAll("\x1b[2J") catch {};
    stdout.writeAll("\x1b[3J") catch {};
}

/// Clear from cursor to end of line
pub fn cls_from_cursor_toEndline() void {
    stdout.writeAll("\x1b[0K") catch {};
}

/// Clear start of line to the cursor
pub fn cls_from_cursor_toStartLine() void {
    stdout.writeAll("\x1b[1K") catch {};
}

/// Clear from cursor to end of line
pub fn cls_line() void {
    stdout.writeAll("\x1b[2K") catch {};
}

///-------------
/// cursor
///-------------
const Point = struct { x: usize, y: usize };

pub var posCurs: Point = undefined;

/// Moves cursor to `x` column and `y` row
pub fn gotoXY(x: usize, y: usize) void {
    stdout.print("\x1b[{d};{d}H", .{ x, y }) catch {};
}

/// Moves cursor up `y` rows
pub fn gotoUp(x: usize) void {
    stdout.print("\x1b[{d}A", .{x}) catch {};
}

/// Moves cursor down `y` rows
pub fn gotoDown(x: usize) void {
    stdout.print("\x1b[{d}B", .{x}) catch {};
}

/// Moves cursor left `y` columns
pub fn gotoLeft(y: usize) void {
    stdout.print("\x1b[{d}D", .{y}) catch {};
}

/// Moves cursor right `y` columns
pub fn gotoRight(y: usize) void {
    stdout.print("\x1b[{d}C", .{y}) catch {};
}

/// Hide the cursor
pub fn cursHide() void {
    stdout.print("\x1b[?25l", .{}) catch {};
}

/// Show the cursor
pub fn cursShow() void {
    stdout.writeAll("\x1b[?25h") catch {};
}

pub fn defCursor(e_curs: typeCursor) void {
    // define type	Cursor form terminal
    switch (e_curs) {
        .cDefault => {
            stdout.writeAll("\x1b[0 q") catch {}; //	0 → default terminal
        },
        .cBlink => {
            stdout.writeAll("\x1b[1 q") catch {}; //	1 → blinking block
        },
        .cSteady => {
            stdout.writeAll("\x1b[2 q") catch {}; //	2 → steady block
        },
        .cBlinkUnderline => {
            stdout.writeAll("\x1b[3 q") catch {}; //	3 → blinking underlines
        },
        .cSteadyUnderline => {
            stdout.writeAll("\x1b[4 q") catch {}; //	4 → steady underlines
        },
        .cBlinkBar => {
            stdout.writeAll("\x1b[5 q") catch {}; //	5 → blinking bar
        },
        .cSteadyBar => {
            stdout.writeAll("\x1b[6 q") catch {}; //	6 → steady bar
        },
    }
    stdout.writeAll("\x1b[?25h") catch {};
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

    posCurs.x = 0;
    posCurs.y = 0;

    flushIO();

    // Don't forget to flush!
    stdout.writeAll("\x1b[?6n") catch {};

    var c: usize = 0;
    while (c == 0) {
        c = stdin.read(&cursBuf) catch unreachable;
    }
    flushIO();

    // columns = 1 digit
    if (cursBuf[4] == 59) {
        posCurs.x = convIntCursor(cursBuf[3]);

        if (cursBuf[6] == 59) posCurs.y = convIntCursor(cursBuf[5]);

        if (cursBuf[7] == 59) {
            posCurs.y = convIntCursor(cursBuf[5]);
            posCurs.y = (posCurs.y * 10) + convIntCursor(cursBuf[6]);
        }

        if (cursBuf[8] == 59) {
            posCurs.y = convIntCursor(cursBuf[5]);
            posCurs.y = (posCurs.y * 10) + convIntCursor(cursBuf[6]);
            posCurs.y = (posCurs.y * 10) + convIntCursor(cursBuf[7]);
        }
    }

    // columns = 2 digits
    if (cursBuf[5] == 59) {
        posCurs.x = convIntCursor(cursBuf[3]);
        posCurs.x = (posCurs.x * 10) + convIntCursor(cursBuf[4]);

        if (cursBuf[7] == 59) posCurs.y = convIntCursor(cursBuf[6]);

        if (cursBuf[8] == 59) {
            posCurs.y = convIntCursor(cursBuf[6]);
            posCurs.y = (posCurs.y * 10) + convIntCursor(cursBuf[7]);
        }

        if (cursBuf[9] == 59) {
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
    stdout.writeAll("\x1b[0m") catch {};
}

/// Sets the terminal style.
fn setStyle(style: [4]u32) void {
    for (style) |v| {
        if (v != 0) {
            stdout.print("\x1b[{d}m", .{v}) catch {};
        }
    }
}

/// Sets the terminal's foreground color.
fn setForegroundColor(color: BackgroundColor) void {
    stdout.print("\x1b[{d}m", .{@intFromEnum(color)}) catch {};
}

/// Sets the terminal's Background color.
fn setBackgroundColor(color: ForegroundColor) void {
    stdout.print("\x1b[{d}m", .{@intFromEnum(color)}) catch {};
}

/// write text and attribut
pub fn writeStyled(text: []const u8, attribut: ZONATRB) void {
    setForegroundColor(attribut.backgr);
    setBackgroundColor(attribut.foregr);
    setStyle(attribut.styled);
    stdout.print("{s}\x1b[0m", .{text}) catch {};
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
    // https://man7.org/linux/man-pages/man3/ttermios.3.html

    // https://manpages.ubuntu.com/manpages/trusty/fr/man3/termios.3.html

    // https://zig.news/lhp/want-to-create-a-tui-application-the-basics-of-uncooked-terminal-io-17gm

    //---------------------------------------------------------------
    // v 0.11.0
    //---------------------------------------------------------------
    // use_termios.iflag &= ~(os.linux.IGNBRK | os.linux.BRKINT | os.linux.PARMRK | os.linux.INPCK | os.linux.ISTRIP |
    // 		os.linux.INLCR | os.linux.IGNCR | os.linux.ICRNL | os.linux.IXON);
    // use_termios.oflag &= ~(os.linux.OPOST);
    // use_termios.cflag &= ~(os.linux.CSIZE | os.linux.PARENB);
    // use_termios.cflag |= (os.linux.CS8);
    // use_termios.lflag &= ~(os.linux.ECHO | os.linux.ECHONL | os.linux.ICANON | os.linux.IEXTEN | os.linux.ISIG);

    // Wait until it reads at least one byte	terminal standard
    // use_termios.cc[os.linux.V.MIN] = 1;

    // Wait 100 miliseconds at maximum.
    // use_termios.cc[os.linux.V.TIME] = 0;
    //---------------------------------------------------------------

    // iflag;	  /* input modes			*/
    // oflag;	  /* output modes			*/
    // cflag;	  /* control modes			*/
    // lflag;	  /* local modes			*/
    // cc[NCCS];   /* special characters	*/

    // V 0.12 0 >
    var iflags = use_termios.iflag;
    iflags.IGNBRK = false;
    iflags.BRKINT = false;
    iflags.PARMRK = false;
    iflags.INPCK = false;
    iflags.ISTRIP = false;
    iflags.INLCR = false;
    iflags.IGNCR = false;
    iflags.ICRNL = false;
    iflags.IXON = false;

    use_termios.iflag = iflags;

    var oflags = use_termios.oflag;
    oflags.OPOST = false;
    use_termios.oflag = oflags;

    var cflags = use_termios.cflag;
    cflags.CSIZE = std.c.CSIZE.CS8;
    cflags.PARENB = false;
    use_termios.cflag = cflags;

    var lflags = use_termios.lflag;
    lflags.ECHO = false;
    lflags.ECHONL = false;
    lflags.ICANON = false;
    lflags.IEXTEN = false;
    lflags.ISIG = false;
    use_termios.lflag = lflags;

    //Wait until it reads at least one byte	terminal standard
    use_termios.cc[@intFromEnum(std.os.linux.V.MIN)] = 1;

    // Wait 100 miliseconds at maximum.
    use_termios.cc[@intFromEnum(os.linux.V.TIME)] = 1;

    // apply changes
    _ = os.linux.tcsetattr(TTY.handle, .NOW, &use_termios);

    // cursor HIDE par défault
    cursHide();
    offMouse();
}

/// Clear gross terminal
fn reset() void {
    stdout.writeAll("\x1bc") catch {};

    stdout.writeAll("\x1b[H") catch {};
}

/// Returns to the previous terminal state
pub fn disableRawMode() void {
    defCursor(typeCursor.cSteady);
    offMouse();
    cursShow();
    _ = os.linux.tcsetattr(TTY.handle, .FLUSH, &original_termios);
    reset();
}

/// get size terminal
const TermSize = struct { width: usize, height: usize };

pub fn getSize() TermSize {
    var win_size: std.os.linux.winsize = undefined;

    const err = os.linux.ioctl(TTY.handle, os.linux.T.IOCGWINSZ, @intFromPtr(&win_size));
    if (std.posix.errno(err) != .SUCCESS) {
        @panic(" Cursed getSize error ioctl TTY");
        //return os.unexpectedErrno(os.errno(err));
    }
    return TermSize{
        .height = win_size.ws_row,
        .width = win_size.ws_col,
    };
}

/// Update title terminal
pub fn titleTerm(title: []const u8) void {
    if (title.len > 0) {
        stdout.print("\x1b]0;{s}\x07", .{title}) catch {};
    }
}

// if use resize	ok : vte application terminal ex TermVte
// change XTERM
// sudo thunar /etc/X11/app-defaults/XTerm
// *allowWindowOps: true	*eightBitInput: false

pub fn resizeTerm(line: usize, cols: usize) void {
    if (line > 0 and cols > 0) {
        stdout.print("\x1b[8;{d};{d};t", .{ line, cols }) catch {};
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
    call,

    pub fn enumToStr(self: kbd) []const u8 {
        return @as([]const u8, @tagName(self));
    }

    pub fn toEnum(name: []const u8) kbd {
        var vlen: usize = 0;
        var iter = iteratStr.iterator(name);
        defer iter.deinit();
        var result: usize = 0;
        while (iter.next()) |_| {
            vlen += 1;
        }

        //return @intToEnum(kbd, @as(u8, name[1]));
        if (name[0] == 'F') {

            //f1..f9
            if (vlen == 2) {
                result = @as(u8, name[1]) - 48;
                return @as(kbd, @enumFromInt(result));
            }

            // f10..f19
            if (vlen == 3 and name[1] == '1') {
                result = @as(u8, name[2]) - 48;
                return @as(kbd, @enumFromInt(10 + result));
            }

            // f20..f24
            if (vlen == 3 and name[1] == '2') {
                result = @as(u8, name[2]) - 48;
                return @as(kbd, @enumFromInt(20 + result));
            }
        }

        if (name[0] == 'a' and name[1] == 'l' and name[2] == 't') {
            if (vlen != 4) return .none;
            result = @as(u8, name[3]) - 41;
            if (result < 25 or result > 50) return .none else return @as(kbd, @enumFromInt(result));
        }

        if (name[0] == 'c' and name[1] == 't' and name[2] == 'r' and name[3] == 'l') {
            if (vlen != 5) return .none;
            result = @as(u8, name[4]) - 14;
            if (result < 51 or result > 76) return .none else return @as(kbd, @enumFromInt(result));
        }

        //std.debug.print("{s}\r\n",.{name});

        if (std.mem.eql(u8, name, "pageUp")) return kbd.pageUp;

        if (std.mem.eql(u8, name, "pageDown")) return kbd.pageDown;

        if (std.mem.eql(u8, name, "home")) return kbd.home;

        if (std.mem.eql(u8, name, "end")) return kbd.end;

        if (std.mem.eql(u8, name, "esc")) return kbd.esc;

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

        // TODO: Check buffer size
        var keybuf: [13]u8 = undefined;
        flushIO();

        var c: usize = 0;
        while (c == 0) {
            c = stdin.read(&keybuf) catch {
                Event.Key = kbd.none;
                return Event;
            };
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
                            1 => {
                                Event.Key = kbd.F1;
                                return Event;
                            },
                            2 => {
                                Event.Key = kbd.F2;
                                return Event;
                            },
                            3 => {
                                Event.Key = kbd.F3;
                                return Event;
                            },
                            4 => {
                                Event.Key = kbd.F4;
                                return Event;
                            },
                            else => {
                                Event.Key = kbd.none;
                                return Event;
                            },
                        }
                    },

                    // csi
                    '[' => {
                        return parse_csiFunc(keybuf[2..c]);
                    },

                    // alt key
                    else => {
                        switch (c1) {
                            'a' => {
                                Event.Key = kbd.altA;
                                return Event;
                            },
                            'b' => {
                                Event.Key = kbd.altB;
                                return Event;
                            },
                            'c' => {
                                Event.Key = kbd.altC;
                                return Event;
                            },
                            'd' => {
                                Event.Key = kbd.altD;
                                return Event;
                            },
                            'e' => {
                                Event.Key = kbd.altE;
                                return Event;
                            },
                            'f' => {
                                Event.Key = kbd.altF;
                                return Event;
                            },
                            'g' => {
                                Event.Key = kbd.altG;
                                return Event;
                            },
                            'h' => {
                                Event.Key = kbd.altH;
                                return Event;
                            },
                            'i' => {
                                Event.Key = kbd.altI;
                                return Event;
                            },
                            'j' => {
                                Event.Key = kbd.altJ;
                                return Event;
                            },
                            'k' => {
                                Event.Key = kbd.altK;
                                return Event;
                            },
                            'l' => {
                                Event.Key = kbd.altL;
                                return Event;
                            },
                            'm' => {
                                Event.Key = kbd.altM;
                                return Event;
                            },
                            'n' => {
                                Event.Key = kbd.altN;
                                return Event;
                            },
                            'o' => {
                                Event.Key = kbd.altO;
                                return Event;
                            },
                            'p' => {
                                Event.Key = kbd.altP;
                                return Event;
                            },
                            'q' => {
                                Event.Key = kbd.altQ;
                                return Event;
                            },
                            'r' => {
                                Event.Key = kbd.altR;
                                return Event;
                            },
                            's' => {
                                Event.Key = kbd.altS;
                                return Event;
                            },
                            't' => {
                                Event.Key = kbd.altT;
                                return Event;
                            },
                            'u' => {
                                Event.Key = kbd.altU;
                                return Event;
                            },
                            'v' => {
                                Event.Key = kbd.altV;
                                return Event;
                            },
                            'w' => {
                                Event.Key = kbd.altW;
                                return Event;
                            },
                            'x' => {
                                Event.Key = kbd.altX;
                                return Event;
                            },
                            'y' => {
                                Event.Key = kbd.altY;
                                return Event;
                            },
                            'z' => {
                                Event.Key = kbd.altZ;
                                return Event;
                            },
                            else => {
                                Event.Key = kbd.none;
                                return Event;
                            },
                        }
                    },
                } else {
                    Event.Key = kbd.esc;
                    return Event;
                }
            },

            // ctrl keys ( crtl-i (x09)	 ctrl-m (x0d) )
            '\x01'...'\x08', '\x0A'...'\x0C', '\x0E'...'\x1A' => {
                switch (c0 + '\x60') {
                    'a' => {
                        Event.Key = kbd.ctrlA;
                        return Event;
                    },
                    'b' => {
                        Event.Key = kbd.ctrlB;
                        return Event;
                    },
                    'c' => {
                        Event.Key = kbd.ctrlC;
                        return Event;
                    },
                    'd' => {
                        Event.Key = kbd.ctrlD;
                        return Event;
                    },
                    'e' => {
                        Event.Key = kbd.ctrlE;
                        return Event;
                    },
                    'f' => {
                        Event.Key = kbd.ctrlF;
                        return Event;
                    },
                    'g' => {
                        Event.Key = kbd.ctrlG;
                        return Event;
                    },
                    'h' => {
                        Event.Key = kbd.ctrlH;
                        return Event;
                    },
                    // 'i' => { Event.Key = kbd.ctrlI; return Event; },
                    'j' => {
                        Event.Key = kbd.ctrlJ;
                        return Event;
                    },
                    'k' => {
                        Event.Key = kbd.ctrlK;
                        return Event;
                    },
                    'l' => {
                        Event.Key = kbd.ctrlL;
                        return Event;
                    },
                    // 'm' => { Event.Key = kbd.ctrlM; return Event; },
                    'n' => {
                        Event.Key = kbd.ctrlN;
                        return Event;
                    },
                    'o' => {
                        Event.Key = kbd.ctrlO;
                        return Event;
                    },
                    'p' => {
                        Event.Key = kbd.ctrlP;
                        return Event;
                    },
                    'q' => {
                        Event.Key = kbd.ctrlQ;
                        return Event;
                    },
                    'r' => {
                        Event.Key = kbd.ctrlR;
                        return Event;
                    },
                    's' => {
                        Event.Key = kbd.ctrlS;
                        return Event;
                    },
                    't' => {
                        Event.Key = kbd.ctrlT;
                        return Event;
                    },
                    'u' => {
                        Event.Key = kbd.ctrlU;
                        return Event;
                    },
                    'v' => {
                        Event.Key = kbd.ctrlV;
                        return Event;
                    },
                    'w' => {
                        Event.Key = kbd.ctrlW;
                        return Event;
                    },
                    'x' => {
                        Event.Key = kbd.ctrlX;
                        return Event;
                    },
                    'y' => {
                        Event.Key = kbd.ctrlY;
                        return Event;
                    },
                    'z' => {
                        Event.Key = kbd.ctrlZ;
                        return Event;
                    },
                    else => {
                        Event.Key = kbd.none;
                        return Event;
                    },
                }
            },

            // tab
            '\x09' => {
                Event.Key = kbd.tab;
                return Event;
            },

            // backspace
            '\x7f' => {
                Event.Key = kbd.backspace;
                return Event;
            },

            // Enter
            '\x0d' => {
                Event.Key = kbd.enter;
                return Event;
            },

            else => {
                // return Character UTF8
                var vUnicode: []u8 = undefined;
                vUnicode = allocatorTerm.alloc(u8, 4) catch unreachable;
                const i = utf.utf8Encode(c0, vUnicode) catch {
                    Event.Key = kbd.none;
                    return Event;
                };
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
            'A' => {
                Event.Key = kbd.up;
                return Event;
            },
            'B' => {
                Event.Key = kbd.down;
                return Event;
            },
            'C' => {
                Event.Key = kbd.right;
                return Event;
            },
            'D' => {
                Event.Key = kbd.left;
                return Event;
            },
            'H' => {
                Event.Key = kbd.home;
                return Event;
            },
            'F' => {
                Event.Key = kbd.end;
                return Event;
            },
            '3' => {
                Event.Key = kbd.delete;
                return Event;
            },
            'Z' => {
                Event.Key = kbd.stab;
                return Event;
            },

            '1'...'2' => {
                if (csibuf[1] == 126) {
                    switch (csibuf[0]) { // insert
                        '2' => {
                            Event.Key = kbd.ins;
                            return Event;
                        },
                        else => {
                            Event.Key = kbd.none;
                            return Event;
                        },
                    }
                }

                if (csibuf[2] == 126) {
                    switch (csibuf[1]) { // f5..f12
                        '5' => {
                            Event.Key = kbd.F5;
                            return Event;
                        },
                        '7' => {
                            Event.Key = kbd.F6;
                            return Event;
                        },
                        '8' => {
                            Event.Key = kbd.F7;
                            return Event;
                        },
                        '9' => {
                            Event.Key = kbd.F8;
                            return Event;
                        },
                        '0' => {
                            Event.Key = kbd.F9;
                            return Event;
                        },
                        '1' => {
                            Event.Key = kbd.F10;
                            return Event;
                        },
                        '3' => {
                            Event.Key = kbd.F11;
                            return Event;
                        },
                        '4' => {
                            Event.Key = kbd.F12;
                            return Event;
                        },
                        else => {
                            Event.Key = kbd.none;
                            return Event;
                        },
                    }
                }

                if (csibuf[2] == 50) { // f11..f14 and // shift
                    switch (csibuf[3]) {
                        'P' => {
                            Event.Key = kbd.F13;
                            return Event;
                        },
                        'Q' => {
                            Event.Key = kbd.F14;
                            return Event;
                        },
                        'R' => {
                            Event.Key = kbd.F15;
                            return Event;
                        },
                        'S' => {
                            Event.Key = kbd.F16;
                            return Event;
                        },
                        'A' => {
                            Event.Key = kbd.up;
                            return Event;
                        },
                        'B' => {
                            Event.Key = kbd.down;
                            return Event;
                        },
                        'C' => {
                            Event.Key = kbd.right;
                            return Event;
                        },
                        'D' => {
                            Event.Key = kbd.left;
                            return Event;
                        },
                        'H' => {
                            Event.Key = kbd.home;
                            return Event;
                        },
                        'F' => {
                            Event.Key = kbd.end;
                            return Event;
                        },
                        '3' => {
                            Event.Key = kbd.delete;
                            return Event;
                        },
                        '5' => {
                            Event.Key = kbd.pageUp;
                            return Event;
                        },
                        '6' => {
                            Event.Key = kbd.pageDown;
                            return Event;
                        },
                        else => {
                            Event.Key = kbd.none;
                            return Event;
                        },
                    }
                }

                if (csibuf[2] == 53) { //	sihft ctrl
                    switch (csibuf[3]) {
                        'A' => {
                            Event.Key = kbd.up;
                            return Event;
                        },
                        'B' => {
                            Event.Key = kbd.down;
                            return Event;
                        },
                        'C' => {
                            Event.Key = kbd.right;
                            return Event;
                        },
                        'D' => {
                            Event.Key = kbd.left;
                            return Event;
                        },
                        'H' => {
                            Event.Key = kbd.home;
                            return Event;
                        },
                        '5' => {
                            Event.Key = kbd.pageUp;
                            return Event;
                        },
                        '6' => {
                            Event.Key = kbd.pageDown;
                            return Event;
                        },
                        else => {
                            Event.Key = kbd.none;
                            return Event;
                        },
                    }
                }

                if (csibuf[2] == 54) { //	sihft / controle
                    switch (csibuf[3]) {
                        'A' => {
                            Event.Key = kbd.up;
                            return Event;
                        },
                        'B' => {
                            Event.Key = kbd.down;
                            return Event;
                        },
                        'C' => {
                            Event.Key = kbd.right;
                            return Event;
                        },
                        'D' => {
                            Event.Key = kbd.left;
                            return Event;
                        },
                        'H' => {
                            Event.Key = kbd.home;
                            return Event;
                        },
                        '5' => {
                            Event.Key = kbd.pageUp;
                            return Event;
                        },
                        '6' => {
                            Event.Key = kbd.pageDown;
                            return Event;
                        },
                        else => {
                            Event.Key = kbd.none;
                            return Event;
                        },
                    }
                }

                if (csibuf[2] == 60) { // f11..f14
                    switch (csibuf[3]) {
                        'P' => {
                            Event.Key = kbd.F13;
                            return Event;
                        },
                        'Q' => {
                            Event.Key = kbd.F14;
                            return Event;
                        },
                        'R' => {
                            Event.Key = kbd.F15;
                            return Event;
                        },
                        'S' => {
                            Event.Key = kbd.F16;
                            return Event;
                        },
                        else => {
                            Event.Key = kbd.none;
                            return Event;
                        },
                    }
                }

                if (csibuf[4] == 126) { // f15..f24
                    switch (csibuf[1]) {
                        '5' => {
                            Event.Key = kbd.F17;
                            return Event;
                        },
                        '7' => {
                            Event.Key = kbd.F18;
                            return Event;
                        },
                        '8' => {
                            Event.Key = kbd.F19;
                            return Event;
                        },
                        '9' => {
                            Event.Key = kbd.F20;
                            return Event;
                        },
                        '0' => {
                            Event.Key = kbd.F21;
                            return Event;
                        },
                        '1' => {
                            Event.Key = kbd.F22;
                            return Event;
                        },
                        '3' => {
                            Event.Key = kbd.F23;
                            return Event;
                        },
                        '4' => {
                            Event.Key = kbd.F24;
                            return Event;
                        },
                        else => {
                            Event.Key = kbd.none;
                            return Event;
                        },
                    }
                }
            },

            '5'...'6' => {
                if (csibuf[1] == 126) {
                    switch (csibuf[0]) {
                        '5' => {
                            Event.Key = kbd.pageUp;
                            return Event;
                        },
                        '6' => {
                            Event.Key = kbd.pageDown;
                            return Event;
                        },
                        else => {
                            Event.Key = kbd.none;
                            return Event;
                        },
                    }
                }

                if (csibuf[3] == 126) {
                    switch (csibuf[2]) {
                        '5' => {
                            Event.Key = kbd.pageUp;
                            return Event;
                        },
                        '6' => {
                            Event.Key = kbd.pageDown;
                            return Event;
                        },
                        else => {
                            Event.Key = kbd.none;
                            return Event;
                        },
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
                    if (csibuf[6] == 77) MouseInfo.action = MouseAction.maPressed;
                    if (csibuf[6] == 109) MouseInfo.action = MouseAction.maReleased;
                }

                if (csibuf.len == 8) {
                    if (csibuf[7] == 77) MouseInfo.action = MouseAction.maPressed;
                    if (csibuf[7] == 109) MouseInfo.action = MouseAction.maReleased;
                }

                if (csibuf.len == 9) {
                    if (csibuf[8] == 77) MouseInfo.action = MouseAction.maPressed;
                    if (csibuf[8] == 109) MouseInfo.action = MouseAction.maReleased;
                }

                if (csibuf.len == 10) {
                    if (csibuf[9] == 77) MouseInfo.action = MouseAction.maPressed;
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
