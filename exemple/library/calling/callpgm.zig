	///-----------------------
	/// callpgm
	/// zig 0.12.0 dev
	///-----------------------
const std = @import("std");

/// Errors that may occur when using String
pub const ErrChild = error{
	Module_Invalid,
};
var allocChild = std.heap.page_allocator;


pub fn callPgmPid( pgm: []const u8, module: []const u8, pid: ?[]const u8) !void {

	if ( ! std.mem.eql(u8, pgm, "SH") and  !std.mem.eql(u8, pgm, "APPTERM") ) return ErrChild.Module_Invalid;

	var CallModule: std.process.Child = undefined;
	
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
	
	// CallModule = std.ChildProcess.init(args[0..], allocChild);
	// Execution and suspension of the caller.
	const childTerm = std.process.Child.spawnAndWait(&CallModule)
		catch |err| {
		@panic(std.fmt.allocPrint(allocChild, "{}", .{err}) catch unreachable);
		};
		

	switch (childTerm) {
		.Exited => |code| {
			if (code != 0) return ErrChild.Module_Invalid;
		},
		else =>unreachable,

	}
}
