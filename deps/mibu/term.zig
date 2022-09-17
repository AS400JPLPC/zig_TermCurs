const std = @import("std");
const os = std.os;
const io = std.io;

/// ReadMode defines the read behaivour when using raw mode
pub const ReadMode = enum {
    blocking,
    nonblocking,
};

pub fn enableRawMode(handle: os.system.fd_t, blocking: ReadMode) !RawTerm {
    // var original_termios = try os.tcgetattr(handle);
    var original_termios = try os.tcgetattr(handle);

    var termios = original_termios;

    // https://viewsourcecode.org/snaptoken/kilo/02.enteringRawMode.html
    // All of this are bitflags, so we do NOT and then AND to disable

    // https://man7.org/linux/man-pages/man3/termios.3.html

    termios.iflag &= ~(os.system.IGNBRK | os.system.BRKINT | os.system.PARMRK | os.system.INPCK |os.system.ISTRIP |
                       os.system.INLCR | os.system.IGNCR| os.system.ICRNL | os.system.IXON);
    termios.oflag &= ~(os.system.OPOST);
    termios.cflag &= ~(os.system.CSIZE | os.system.PARENB);
    termios.cflag |= (os.system.CS8);
    termios.lflag &= ~(os.system.ECHO | os.system.ECHONL | os.system.ICANON | os.system.IEXTEN | os.system.ISIG);

    switch (blocking) {
        // Wait until it reads at least one byte
        .blocking => termios.cc[os.system.V.MIN] = 1,

        // Don't wait
        .nonblocking => termios.cc[os.system.V.MIN] = 0,
    }

    // Wait 100 miliseconds at maximum.
    termios.cc[os.system.V.TIME] = 1;

    // apply changes
    try os.tcsetattr(handle, .FLUSH, termios);

    return RawTerm{
        .orig_termios = original_termios,
        .cur_termios = termios,
        .handle = handle,
    };
}

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
        try os.tcsetattr(os.STDIN_FILENO,.FLUSH, self.cur_termios);
}
};

/// Returned by `getSize()`
pub const TermSize = struct {
    width: u16,
    height: u16,
};

/// Get the terminal size, use `fd` equals to 0 use stdin
pub fn getSize(fd: std.os.fd_t) !TermSize {
    var ws: std.os.system.winsize = undefined;

    // https://github.com/ziglang/zig/blob/master/lib/std/os/linux/errno/generic.zig
    const err = std.c.ioctl(fd, os.system.T.IOCGWINSZ, @ptrToInt(&ws));
    if (std.os.errno(err) != .SUCCESS) {
        return error.IoctlError;
    }

    return TermSize{
        .width = ws.ws_col,
        .height = ws.ws_row,
    };
}



test "entering stdin raw mode" {
    const tty = (try std.fs.cwd().openFile("/dev/tty", .{})).reader();

    var term = try enableRawMode(tty.context.handle, .blocking); // stdin.handle is the same as os.STDIN_FILENO
    defer term.disableRawMode() catch {};
}
