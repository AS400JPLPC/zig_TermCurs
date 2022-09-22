const std = @import("std");
const io = std.io;

const events = @import("events");
const term   = @import("term");
const mouse  = @import("mouse");
const clear  = @import("clear");
const cursor = @import("cursor");


pub fn main() !void {
    const stdin = io.getStdIn();
    const stdout = io.getStdOut();

    // Enable terminal raw mode, its very recommended when listening for events
    var raw_term = try term.enableRawMode(stdin.handle, .blocking);
    defer raw_term.disableRawMode() catch {};


    mouse.fmouse(mouse.on_mouse);

    try stdout.writer().print("Press Ctrl-q to exit... crtl-c clear\n\r", .{});

    while (true) {
        try raw_term.flushMode();
        switch (try events.getKey()) {
            .key => |k| switch (k) {
                // char can have more than 1 u8, because of unicode
                .char => |c| switch (c) {
                    else => try stdout.writer().print("Key char: {u}\n\r", .{c}),
                },
                .ctrl => |c| switch (c) {
                    'q' => break,
                    'c' =>
                        {
                            clear.cls();
                            cursor.gotoXY(1,10);
                            try stdout.writer().print("Press Ctrl-q to exit... crtl-c clear\n\r", .{});
                        },
                    'w' =>
                        {
                        if (events.MouseInfo.x >0){
                            cursor.gotoXY(events.MouseInfo.x,events.MouseInfo.y);
                            cursor.getCursor();
                            try stdout.writer().print("cursor X:{d}  Y:{d}\n\r", .{cursor.posCurs.x, cursor.posCurs.y});
                            }
                        },
                    's' => cursor.show(),
                    'h' => cursor.hide(),
                    else => try stdout.writer().print("Key: {s}\n\r", .{k}),
                },
                .pageup   =>  try stdout.writer().print("Key: {s}\n\r", .{k}),
                .pagedown =>  try stdout.writer().print("Key: {s}\n\r", .{k}),
                .up =>  {
                    cursor.gotoUp(1);
                },
                .down =>  {
                    cursor.gotoDown(1);
                },
                .left =>  {
                    cursor.gotoLeft(1);
                },
                .right =>  {
                    cursor.gotoRight(1);
                },
                .mouse => {
                    try stdout.writer().print("Key: {s}\n\r", .{k});
                    try stdout.writer().print("X :{d}\n\r", .{events.MouseInfo.x});
                    try stdout.writer().print("Y :{d}\n\r", .{events.MouseInfo.y});
                    switch (events.MouseInfo.action) {
                        events.MouseAction.maPressed => try stdout.writer().print("Button-Pressed\n\r",.{}),
                        events.MouseAction.maReleased => try stdout.writer().print("Button-Released\n\r",.{}),
                        else => {},
                    }
                    switch (events.MouseInfo.button) {
                        events.MouseButton.mbLeft => try stdout.writer().print("Button-mbLeft\n\r",.{}),
                        events.MouseButton.mbMiddle => try stdout.writer().print("Button-mbMiddle\n\r",.{}),
                        events.MouseButton.mbRight => try stdout.writer().print("Button-Right\n\r",.{}),
                        else => {},
                    }
                    switch (events.MouseInfo.scrollDir) {
                        events.ScrollDirection.msUp => try stdout.writer().print("Button-Scroll up\n\r",.{}),
                        events.ScrollDirection.msDown => try stdout.writer().print("Button-Scroll Down\n\r",.{}),
                        else => {},
                    }
                },
                else => try stdout.writer().print("Key: {s}\n\r", .{k}),
            },
            // ex. Pause Imp ...  events not supported yet
            else => {},
        }
    }

    try stdout.writer().print("Bye bye\n\r", .{});
}
