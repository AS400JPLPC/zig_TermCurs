    ///----------------------------
    /// looger / historique traçage
    ///----------------------------

const std = @import("std");
const builtin = @import("builtin");
const root = @import("root");

var flog :std.fs.File = undefined;
const allocator = std.heap.page_allocator;


pub const EnumList = enum {
    err,
    objet,
    ligne,
    
    pub fn asText(comptime self: EnumList) []const u8 {
        return switch (self) {
            .err => "error",
            .objet => "Objet",
            .ligne => "ligne",
        };
    }
};


fn customLog(
    comptime message_level: EnumList,
    comptime scope: @Type(.@"enum_literal"),
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


    const out_buffer: []u8 =  allocator.alloc(u8, 4096) catch unreachable;
    defer allocator.free(out_buffer);
    var writer =std.Io.Writer.fixed(out_buffer);
        nosuspend {
            writer.print("[" ++  level_txt ++ scope_name ++  "] " ++ format ++ "\n", args) catch return;
            flog.writeAll(writer.buffered()) catch unreachable;
        }
}


fn editLog(
    comptime format: []const u8,
    args: anytype,

) void {
    if (builtin.os.tag == .freestanding)
        @compileError(
            \\freestanding targets do not have I/O configured;
            \\please provide at least an empty `log` function declaration
        );
            
    const out_buffer: []u8 =  allocator.alloc(u8, 4096) catch unreachable;
    defer allocator.free(out_buffer);
    var writer =std.Io.Writer.fixed(out_buffer);
        nosuspend {
            writer.print("" ++ format ++ "\n", args) catch return;
            flog.writeAll(writer.buffered()) catch unreachable;
        }
}



pub fn scoped(comptime scope: @Type(.@"enum_literal"))  type {
    return struct {
        pub fn err(comptime format: []const u8, args: anytype) void {
            // @setCold(true);
            customLog(.err, scope, format, args);
        }

        pub fn objet(comptime format: []const u8, args: anytype) void {
            customLog(.objet, scope, format, args);
        }
        
        pub fn ligne(comptime format: []const u8, args: anytype) void {
            editLog(format, args);
        }

    };
}


pub fn openFile(log:[]const u8) void {
    flog = std.fs.cwd().createFile(log, .{ .read = true }) 
        catch { @panic("impossible ouvrir file zlog.txt");};
}

pub fn deleteFile(log:[]const u8) void {

        _ = std.fs.cwd().createFile(log, .{ .read = true }) catch |e|
        switch (e) {
            error.PathAlreadyExists => std.fs.cwd().deleteFile(log) catch unreachable,

            else =>{} ,
        };
    return;    
}

pub fn closeFile() void {
    flog.close();
}


pub fn newLine() void { 
    const out_buffer: []u8 = allocator.alloc(u8, 4096) catch unreachable;
    defer allocator.free(out_buffer);
    var writer =std.Io.Writer.fixed(out_buffer);
        nosuspend {
            writer.print("\n",.{}) catch return;
            flog.writeAll(writer.buffered()) catch unreachable;
        }
    }


pub const default_log_scope = .default;
pub const default = scoped(default_log_scope);
pub const err = default.err;
pub const objet  = default.objet;
pub const ligne  = default.objet;
