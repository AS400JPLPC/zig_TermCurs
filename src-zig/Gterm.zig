///--------------------
/// test sdl2
///--------------------
const std = @import("std");

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const os = std.os;
const fs = std.fs;

/// Define use terminal basic
var TTY: fs.File = undefined;
var original_termios: os.linux.termios = undefined;
var use_termios: os.linux.termios = undefined;

pub fn enableRawMode() void {
    TTY = fs.cwd().openFile("/dev/tty", .{ .mode = .read_write }) catch unreachable;
    //defer TTY.close();

    _ = os.linux.tcgetattr(TTY.handle, &original_termios);

    _ = os.linux.tcgetattr(TTY.handle, &use_termios);
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

    //Wait until it reads at least one byte    terminal standard
    use_termios.cc[@intFromEnum(std.os.linux.V.MIN)] = 1;

    // Wait 100 miliseconds at maximum.
    use_termios.cc[@intFromEnum(os.linux.V.TIME)] = 1;

    // apply changes
    _ = os.linux.tcsetattr(TTY.handle, .NOW, &use_termios);
}


pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0)
        return error.SDL_InitializationFailed;

    // enableRawMode();   
    var event: c.SDL_Event = undefined;
    mainLoop: while (true) {
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => break :mainLoop,
                c.SDL_KEYDOWN => {
                    if (event.key.keysym.mod == c.KMOD_CTRL){
                      // std.debug.print("key pressed CTRL: {s}\n", .{c.SDL_GetScancodeName(event.key.keysym.scancode)});
                      // std.debug.print("key pressed: {}\n", .{event.key.keysym.scancode});
                      std.debug.print("key pressed ctrl: {}\n", .{event.key.keysym.scancode});
                      }
                    else std.debug.print("key pressed: {}\n", .{event.key.keysym.scancode});
                },
                else => {},
            }
        }
        //c.SDL_Flush_Events(event);
        c.SDL_Delay(10);
    }
        // _ = os.linux.tcsetattr(TTY.handle, .FLUSH, &original_termios);
}
