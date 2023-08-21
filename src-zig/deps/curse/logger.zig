const std = @import("std");
const builtin = @import("builtin");
const root = @import("root");

var flog :std.fs.File = undefined;

pub fn customLog(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,

) void {
    if (builtin.os.tag == .freestanding)
        @compileError(
            \\freestanding targets do not have I/O configured;
            \\please provide at least an empty `log` function declaration
        );

    const level_txt = comptime message_level.asText();
    const scope_name = "(" ++ @tagName(scope) ++ ")";

    std.debug.getStderrMutex().lock();
    defer std.debug.getStderrMutex().unlock();
    const w  = flog.writer();
    nosuspend w.print("[" ++ level_txt ++ scope_name ++ "] " ++ format ++ "\n", args) 
              catch { @panic("file write error zlog;txt");};
}

pub fn scoped(comptime scope: @Type(.EnumLiteral)) type {
    return struct {
        pub fn err(comptime format: []const u8, args: anytype) void {
            @setCold(true);
            customLog(.err, scope, format, args);
        }

        pub fn warn(comptime format: []const u8, args: anytype) void {
            customLog(.warn, scope, format, args);
        }

        pub fn info(comptime format: []const u8, args: anytype) void {
            customLog(.info, scope, format, args);
        }

        pub fn debug(comptime format: []const u8, args: anytype) void {
            customLog(.debug, scope, format, args);
        }
    };
}

pub fn openFile(log:[]const u8) void {
  flog = std.fs.cwd().createFile(log, .{ .read = true }) 
          catch { @panic("impossible ouvrir file zlog;txt");};
}

pub fn closeFile() void {
  flog.close();
}

pub const default = scoped(.LOG);
pub const err = default.err;
pub const warn = default.warn;
pub const info = default.info;
pub const debug = default.debug;
