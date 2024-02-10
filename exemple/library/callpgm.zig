const std = @import("std");


/// Errors that may occur when using String
pub const ErrChild = error{
	Module_Invalid,
};

	/// callPgm( pgm, module)  ex: APPTERM (libVte)   module ex: Exemple
	pub fn callPgm(pgm : [] const  u8, module : [] const u8) ErrChild ! void {

		const allocChild = std.heap.page_allocator;

		const prog  = std.fmt.allocPrint(allocChild,"./{s}",.{pgm}) catch unreachable;
		defer allocChild.free(prog);

		const cmd  = std.fmt.allocPrint(allocChild,"./{s}",.{module}) catch unreachable;
		defer allocChild.free(cmd);

		// Retrieval of the working library.
		var buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
		const cwd = std.os.getcwd(&buf) catch unreachable;

		// Initialization of the process (calling a program, and parameter).
		const args : [2][]const u8= .{prog,cmd };
		var CallModule : std.ChildProcess = std.ChildProcess.init(args[0..], allocChild) ;

		//The set of modules is located in the manager's library, for example: (APPTERM).
		CallModule.cwd = cwd;

		// Execution and suspension of the caller.
		const childTerm = std.ChildProcess.spawnAndWait(&CallModule) catch unreachable;

		// Error handling is provided to the calling procedure.
		switch (childTerm) {
		.Exited => |code| { if (code != 0) return ErrChild.Module_Invalid ; },
		else => unreachable,
		}

	}