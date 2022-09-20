const std = @import("std");
const io = std.io;

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
    __non_exhaustive: void,

    pub fn format(
        value: Key,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = options;
        _ = fmt;
        try writer.writeAll("Key.");

        switch (value) {
            .ctrl => |c| try std.fmt.format(writer, "ctrl({u})", .{c}),
            .alt => |c| try std.fmt.format(writer, "alt({u})", .{c}),
            .char => |c| try std.fmt.format(writer, "char({u})", .{c}),
            .fun => |d| try std.fmt.format(writer, "fun({d})", .{d}),

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

pub const MouseAction = enum {maNone, maPressed, maReleased,};

pub const MouseButton = enum {mbNone, mbLeft, mbMiddle, mbRight,} ;

pub const ScrollDirection = enum {msNone, msUp, msDown,} ;

const  Mouse = struct {
    x: i32, // x mouse position
    y: i32, // y mouse position
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
pub fn getKey(in: anytype) !Event {
    // TODO: Check buffer size
    var buf: [30]u8 = undefined;
    const c = try in.read(&buf);
    if (c == 0) {
        return .none;
    }

    const view = try std.unicode.Utf8View.init(buf[0..c]);

    var iter = view.iterator();

    var event: Event = .none;

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
        else => return Event{ .key = Key{ .char = c0 } },
    };

    return event;
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
                    else => {},
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
                    else => {},
                }
            }
            if ((buf[2]) == 50) { // f11..f14
                switch (buf[3]) {
                    'P' => return Event{ .key = Key{ .fun = 13 } },
                    'Q' => return Event{ .key = Key{ .fun = 14 } },
                    'R' => return Event{ .key = Key{ .fun = 15 } },
                    'S' => return Event{ .key = Key{ .fun = 16 } },
                    else => {},
                }
            }
            if ((buf[2]) == 60) { // f11..f14
                switch (buf[3]) {
                    'P' => return Event{ .key = Key{ .fun = 13 } },
                    'Q' => return Event{ .key = Key{ .fun = 14 } },
                    'R' => return Event{ .key = Key{ .fun = 15 } },
                    'S' => return Event{ .key = Key{ .fun = 16 } },
                    else => {},
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
                    else => {},
                }
            }

        },
        '5'...'6' => {
            if (buf[1] == 126) {
                 switch (buf[0]) {
                    '5' => return Event{ .key = .pageup },
                    '6' => return Event{ .key = .pagedown },
                    else => {},
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
                if (buf[i] != 59 and MouseInfo.x == 0 ) MouseInfo.x = convInt(buf[3]);
                if (buf[i] == 59 ) break;
                if (buf[i] != 59 and i > 3 ) MouseInfo.x = (MouseInfo.x * 10) + convInt(buf[i]);
                i += 1;
            }

            var u:usize = i + 1;
            while (true) {
                if (buf[u] != 59 and MouseInfo.y == 0 ) MouseInfo.y = convInt(buf[u]);
                if (buf[u] == 59 or  buf[u] == 77 or buf[u] == 109) break;
                if (buf[u] != 59 and u > (i+1) ) MouseInfo.y = (MouseInfo.y * 10) + convInt(buf[u]);
                u += 1;
            }

            if (buf.len == 7) {

                MouseInfo.y = convInt(buf[5]);
                if ((buf[6]) == 77 ) {
                    MouseInfo.action = MouseAction.maPressed;

                }
                if ((buf[6]) == 109 ) {
                    MouseInfo.action = MouseAction.maReleased;
                }

            }
            if (buf.len ==8) {
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
            }
            if ((buf[1]) == 54 and (buf[2]) == 53 ) {
                MouseInfo.scrollDir = ScrollDirection.msDown;
            }

            return Event{ .key = .mouse };
        },
        else => {},
    }

    return .not_supported;
}

pub const Event = union(enum) {
    key: Key,
    resize,
    not_supported,
    none,
};

test "next" {
    const term = @import("term.zig");

    const tty = (try std.fs.cwd().openFile("/dev/tty", .{})).reader();

    var raw = try term.enableRawMode(tty.context.handle, .blocking);
    defer raw.disableRawMode() catch {};

    var i: usize = 0;
    while (i < 3) : (i += 1) {
        const key = try getKey(tty);
        std.debug.print("\n\r{any}\n", .{key});
    }
}
