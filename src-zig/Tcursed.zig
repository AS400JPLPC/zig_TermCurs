const std = @import("std");
const os = std.os;
const io = std.io;

const term = @import("cursed");

pub fn main() !void {
    const stdout = io.getStdOut();


    var raw_term =  try term.enableRawMode();
    defer raw_term.disableRawMode() catch {};

    try stdout.writer().print("Press Ctrl-q to exit... crtl-c clear\n\r", .{});
    try raw_term.flushMode();

    term.onMouse();

    while (true) {
        try raw_term.flushMode();
        switch (try term.getKey()) {
            .key => |k| switch (k) {
                .fun => |c| switch (c) {
                    2 =>
                        {
                                term.onMouse();
                        },
                    3 =>
                        {
                                term.offMouse();
                        },
                    4 =>
                        {
                                try stdout.writer().print("Key fun: {d}\n\r", .{c});
                        },
                    else => continue,
                },
                .alt => |c| switch (c) {
                    'a' =>
                        {
                                try stdout.writer().print("Key alt: {u}\n\r", .{c});
                        },
                    else => continue,
                },
                // char can have more than 1 u8, because of unicode
                .char => |c| switch (c) {
                    else => try stdout.writer().print("Key char: {u}\n\r", .{c}),
                },
                .ctrl => |c| switch (c) {
                    'q' => break,
                    'c' =>
                        {
                            term.cls();
                            term.gotoXY(1,10);
                            try stdout.writer().print("Press Ctrl-q to exit... crtl-c clear\n\r", .{});
                        },
                    'w' =>
                        {
                        if (term.MouseInfo.x > 0){
                            term.gotoXY(term.MouseInfo.x,term.MouseInfo.y);
                            term.getCursor();
                            try stdout.writer().print("termor X:{d}  Y:{d}\n\r", .{term.posCurs.x, term.posCurs.y});
                            }
                        },
                    's' => term.show(),
                    'h' => term.hide(),

                    else => try stdout.writer().print("Key ctrl: {u}\n\r", .{c}),
                },
                .pageup   =>  try stdout.writer().print("Key: {s}\n\r", .{k}),
                .pagedown =>  try stdout.writer().print("Key: {s}\n\r", .{k}),
                .up =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{k});
                    // term.gotoUp(1);
                },
                .down =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{k});
                    // term.gotoDown(1);
                },
                .left =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{k});
                    // term.gotoLeft(1);
                },
                .right =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{k});
                    // term.gotoRight(1);
                },
                .mouse => {
                    try stdout.writer().print("Key: {s}\n\r", .{k});
                    try stdout.writer().print("X :{d}\n\r", .{term.MouseInfo.x});
                    try stdout.writer().print("Y :{d}\n\r", .{term.MouseInfo.y});
                    switch (term.MouseInfo.action) {
                        term.MouseAction.maPressed => try stdout.writer().print("Button-Pressed\n\r",.{}),
                        term.MouseAction.maReleased => try stdout.writer().print("Button-Released\n\r",.{}),
                        else => {},
                    }
                    switch (term.MouseInfo.button) {
                        term.MouseButton.mbLeft => try stdout.writer().print("Button-mbLeft\n\r",.{}),
                        term.MouseButton.mbMiddle => try stdout.writer().print("Button-mbMiddle\n\r",.{}),
                        term.MouseButton.mbRight => try stdout.writer().print("Button-Right\n\r",.{}),
                        else => {},
                    }
                    switch (term.MouseInfo.scrollDir) {
                        term.ScrollDirection.msUp => try stdout.writer().print("Button-Scroll up\n\r",.{}),
                        term.ScrollDirection.msDown => try stdout.writer().print("Button-Scroll Down\n\r",.{}),
                        else => {},
                    }
                },
                else => continue,
            },
            // ex. Pause Imp ...  term not supported yet
            else => {},
        }
    }

    try stdout.writer().print("Bye bye\n\r", .{});
}

