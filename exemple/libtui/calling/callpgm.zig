///-----------------------
/// callpgm
///-----------------------
const std = @import("std");

fn Perror(err : ErrCallpgm) void{
var out = std.fs.File.stdout().writerStreaming(&.{});
    out.interface.print("\r\nCallpgm err: {}\n",.{err}) catch unreachable;
var stdin = std.fs.File.stdin();
    var buf: [16]u8 =  [_]u8{0} ** 16;
    var c  : usize = 0;
    while (c == 0) {
        c = stdin.read(&buf) catch unreachable;
    }

}

/// Errors that may occur when using String
pub const ErrCallpgm = error{
    Module_Interface_Invalid,
    Module_error_internal_Occurs,
    Module_Error,
};
var allocChild = std.heap.page_allocator;

var CallModule: std.process.Child = undefined;

pub fn getProcess() *std.process.Child{ return &CallModule;}


pub fn callPgmPid( pgm: []const u8, module: []const u8, pid: ?[]const u8 , wait : bool) !void {


    if ( ! std.mem.eql(u8, pgm, "SH") and  !std.mem.eql(u8, pgm, "APPTERM") ) {
        Perror(ErrCallpgm.Module_Interface_Invalid);
        return ErrCallpgm.Module_Error;
    }
    
    // Retrieval of the working library.
    var buf: [std.fs.max_path_bytes]u8 = undefined;
    const cwd = std.posix.getcwd(&buf) catch unreachable;
    //The set of modules is located in the manager's library, for example: (APPTERM).
    CallModule.cwd = cwd;


    var arg2: [2][]const u8 = undefined;
    var arg3: [3][]const u8 = undefined;
    var prog: [] const u8 = undefined;

    var cmd : [] const u8 = undefined;
    
    var parm: [] const u8 = undefined;

    
    if (pid) |value| {
        if (std.mem.eql(u8, pgm, "SH")) {
            cmd = std.fmt.allocPrint(allocChild, "./{s}  {s}", .{ module, value}) catch unreachable;
            arg3 = .{ "/bin/sh", "-c", cmd };
            CallModule = std.process.Child.init(arg3[0..], allocChild);
        } 
        if (std.mem.eql(u8, pgm, "APPTERM")) {
            prog = std.fmt.allocPrint(allocChild,"./{s}", .{pgm}) catch unreachable;
            cmd  = std.fmt.allocPrint(allocChild,"./{s}", .{module}) catch unreachable;
            parm = std.fmt.allocPrint(allocChild,"{s}", .{ value }) catch unreachable;
            arg3 = .{prog,cmd, parm};
            CallModule = std.process.Child.init(arg3[0..], allocChild);
        }
    } else {
        if (std.mem.eql(u8, pgm, "SH")) {
            cmd  = std.fmt.allocPrint(allocChild, "./{s}", .{ module}) catch unreachable;
            arg3 = .{ "/bin/sh", "-c", cmd };
            CallModule = std.process.Child.init(arg3[0..], allocChild);
        } 
        if (std.mem.eql(u8, pgm, "APPTERM")) {
            prog = std.fmt.allocPrint(allocChild,"./{s}", .{pgm}) catch unreachable;
            cmd  = std.fmt.allocPrint(allocChild,"./{s}", .{module}) catch unreachable;
            arg2 = .{ prog, cmd };
            CallModule = std.process.Child.init(arg2[0..], allocChild);
        }
    }

    if ( wait ) {
        // CallModule = std.ChildProcess.init(args[0..], allocChild);
        // Execution and suspension of the caller.
        const childTerm = std.process.Child.spawnAndWait(&CallModule) catch unreachable;
        switch (childTerm) {
            .Exited => |code| {
                if (code != 0) {
                    // permet l'affichage de l'erreur renvoyé par zmmap
                    Perror(ErrCallpgm.Module_error_internal_Occurs);
                    return ErrCallpgm.Module_Error;
                }
            },
            else =>unreachable,

        }
    } else {
         std.process.Child.spawn(&CallModule) catch unreachable;
    }
}
