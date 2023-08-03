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






/// flush terminal in-out
pub fn flushIO() void {
    _ = os.linux.tcsetattr(TTY.handle, .FLUSH, &use_termios);
}

///-------------
/// mouse
///-------------
/// onMouse
pub fn onMouse() void {
  const writer = TTY.writer();
  writer.writeAll("\x1b[?1000;1005;1006h") catch unreachable;
}

/// offMouse
pub fn offMouse() void {
  const writer = TTY.writer();
  writer.writeAll("\x1b[?1000;1005;1006l") catch unreachable;
}

///-------------
/// clear
///-------------
/// Clear from cursor until end of screen
pub fn cls_from_cursor_toEndScreen() void {
  const writer = TTY.writer();
  writer.writeAll("\x1b[0J") catch unreachable;
}

/// Clear from cursor to beginning of screen
pub fn cls_from_cursor_toStartScreen() void {
  const writer = TTY.writer();
  writer.writeAll("\x1b[1J") catch unreachable;
}

/// Clear all screen
pub fn cls() void {
  const writer = TTY.writer();
  writer.writeAll("\x1b[2J") catch unreachable;
  writer.writeAll("\x1b[3J") catch unreachable;
}

/// Clear from cursor to end of line
pub fn cls_from_cursor_toEndline() void {
  const writer = TTY.writer();
  writer.writeAll("\x1b[0K") catch unreachable;
}

/// Clear start of line to the cursor
pub fn cls_from_cursor_toStartLine() void {
  const writer = TTY.writer();
  writer.writeAll("\x1b[1K") catch unreachable;
}

/// Clear from cursor to end of line
pub fn cls_line() void {
  const writer = TTY.writer();
  writer.writeAll("\x1b[2K") catch unreachable;
}

///-------------
/// cursor
///-------------
const Point = struct { x: usize, y: usize };

pub var posCurs: Point = undefined;

/// Moves cursor to `x` column and `y` row
pub fn gotoXY(x: usize, y: usize) void {
  const writer = TTY.writer();
  writer.print("\x1b[{d};{d}H", .{ x, y }) catch unreachable;
}

/// Moves cursor up `y` rows
pub fn gotoUp(x: usize) void {
  const writer = TTY.writer();
  writer.print("\x1b[{d}A", .{x}) catch unreachable;
}

/// Moves cursor down `y` rows
pub fn gotoDown(x: usize) void {
  const writer = TTY.writer();
  writer.print("\x1b[{d}B", .{x}) catch unreachable;
}

/// Moves cursor left `y` columns
pub fn gotoLeft(y: usize) void {
  const writer = TTY.writer();
  writer.print("\x1b[{d}D", .{y}) catch unreachable;
}

/// Moves cursor right `y` columns
pub fn gotoRight(y: usize) void {
  const writer = TTY.writer();
  writer.print("\x1b[{d}C", .{y}) catch unreachable;
}

/// Hide the cursor
pub fn cursHide() void {
  const writer = TTY.writer();
  writer.print("\x1b[?25l", .{}) catch unreachable;
}

/// Show the cursor
pub fn cursShow() void {
  const writer = TTY.writer();
  writer.writeAll("\x1b[?25h") catch unreachable;
}

pub fn defCursor(e_curs: dds.typeCursor) void {
  const writer = TTY.writer();
    // define type  Cursor form terminal
    switch (e_curs) {
        .cDefault => {
            writer.writeAll("\x1b[0 q") catch unreachable; // 0 → default terminal
        },
        .cBlink => {
            writer.writeAll("\x1b[1 q") catch unreachable; // 1 → blinking block
        },
        .cSteady => {
            writer.writeAll("\x1b[2 q") catch unreachable; //  2 → steady block
        },
        .cBlinkUnderline => {
            writer.writeAll("\x1b[3 q") catch unreachable; //  3 → blinking underlines
        },
        .cSteadyUnderline => {
            writer.writeAll("\x1b[4 q") catch unreachable; //  4 → steady underlines
        },
        .cBlinkBar => {
            writer.writeAll("\x1b[5 q") catch unreachable; //  5 → blinking bar
        },
        .cSteadyBar => {
            writer.writeAll("\x1b[6 q") catch unreachable; //  6 → steady bar
        },
    }
    writer.writeAll("\x1b[?25h") catch unreachable;
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

      if (cursBuf[8] == 59) {
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
  const writer = TTY.writer();
  writer.writeAll("\x1b[0m") catch unreachable;
}

/// Sets the terminal style.
fn setStyle(style: [4]u32) void {
  const writer = TTY.writer();
  for (style) |v| {
      if (v != 0) {
          writer.print("\x1b[{d}m", .{v}) catch unreachable;
      }
  }
}

/// Sets the terminal's foreground color.
fn setForegroundColor(color: dds.BackgroundColor) void {
  const writer = TTY.writer();
  writer.print("\x1b[{d}m", .{@intFromEnum(color)}) catch unreachable;
}

/// Sets the terminal's Background color.
fn setBackgroundColor(color: dds.ForegroundColor) void {
  const writer = TTY.writer();
  writer.print("\x1b[{d}m", .{@intFromEnum(color)}) catch unreachable;
}

/// write text and attribut
pub fn writeStyled(text: []const u8, attribut: dds.ZONATRB) void {
  const writer = TTY.writer();
  setForegroundColor(attribut.backgr);
  setBackgroundColor(attribut.foregr);
  setStyle(attribut.styled);
  writer.print("{s}\x1b[0m", .{text}) catch unreachable;
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
  const writer = TTY.writer();
  writer.print("\x1b[H", .{}) catch unreachable; // init pos_coursor

  _ = os.linux.tcsetattr(TTY.handle, .FLUSH, &original_termios);
  reset();
}

/// get size terminal
const TermSize = struct { width: usize, height: usize };

pub fn getSize() !TermSize {
  var win_size: std.os.linux.winsize = undefined;

  const err = os.linux.ioctl(TTY.handle, os.linux.T.IOCGWINSZ, @intFromPtr(&win_size));
  if (os.errno(err) != .SUCCESS) {
      return os.unexpectedErrno(os.errno(err));
  }
  return TermSize{
      .height = win_size.ws_row,
      .width = win_size.ws_col,
  };
}

/// Update title terminal
pub fn titleTerm(title: []const u8) void {
  if (title.len > 0) {
    const writer = TTY.writer();
    writer.print("\x1b]0;{s}\x07", .{title}) catch unreachable;
  }
}

// if use resize  ok : vte application terminal ex TermVte
// change XTERM
// sudo thunar /etc/X11/app-defaults/XTerm
// *allowWindowOps: true  *eightBitInput: false

pub fn resizeTerm(line: usize, cols: usize) void {
  if (line > 0 and cols > 0) {
    const writer = TTY.writer();
    writer.print("\x1b[8;{d};{d};t", .{ line, cols }) catch unreachable;
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



    pub fn enumToStr(self: kbd) []const u8 {
        return @as( [] const u8 ,@tagName(self));
    }

    pub fn toEnum(name: []const u8) kbd {
        var vlen: usize = 0;
        var iter = utl.iteratStr.iterator(name);
        var result: usize = 0;
        while (iter.next()) |_| {
            vlen += 1;
        }

        //return @intToEnum(kbd, @as(u8, name[1])); 
        if (name[0] == 'F') {
            //f1..f9

            if (vlen == 2) {
              result = @as(u8, name[1]) - 48;
              return @as(kbd,@enumFromInt(result)) ;
            }
            // f10..f19
            if (vlen == 3 and name[1] == '1') {
              result = @as(u8, name[2]) - 48;
              return @as(kbd,@enumFromInt(10 + result)) ;
            }
            // f20..f24
            if (vlen == 3 and name[1] == '2') {
              result = @as(u8, name[2]) - 48;
              return @as(kbd,@enumFromInt(20 + result)) ;
            }
        }

        if (name[0] == 'a' and name[1] == 'l' and name[2] == 't') {
            if (vlen != 4) return .none;
            result = @as(u8, name[3]) - 41;
            if (result < 25 or result > 50) return .none else return @as(kbd,@enumFromInt(result)) ;
        }

        if (name[0] == 'c' and name[1] == 't' and name[2] == 'r' and name[3] == 'l') {
            if (vlen != 5) return .none;
            result = @as(u8, name[4]) - 14;
            if (result < 51 or result > 76) return .none else return @as(kbd,@enumFromInt(result)) ;
        }

        std.debug.print("{s}\r\n",.{name});
        if (std.mem.eql(u8, name, "pageUp")) return kbd.pageUp;

        if (std.mem.eql(u8, name, "pageDown")) return kbd.pageDown;

        if (std.mem.eql(u8, name, "pome")) return kbd.home;

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

        // variable --> Event.Char
        var vUnicode: []u8 = undefined;
        vUnicode = dds.allocatorPnl.alloc(u8, 4) catch unreachable;



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
                var i = utf.utf8Encode(c0, vUnicode[0..4]) catch unreachable;

                Event.Char = vUnicode[0..i];

                Event.Key  = kbd.char;

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
