	///----------------------------
	/// looger / historique traçage
	/// zig 0.12.0 dev
	///----------------------------

const std = @import("std");
const builtin = @import("builtin");
const root = @import("root");

var flog :std.fs.File = undefined;



pub const EnumList = enum {
	err,
	list,
	objet,
	detail,
	
	pub fn asText(comptime self: EnumList) []const u8 {
	    return switch (self) {
	        .err => "error",
	        .list => "List",
	        .objet => "Objet",
	        .detail  => "Detail",
	    };
    }
};


pub fn customLog(
	comptime message_level: EnumList,
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


    const writer = flog.writer();
    	nosuspend {
        	writer.print("[" ++  level_txt ++ scope_name ++  "] " ++ format ++ "\n", args) catch return;
    	}
	}

pub fn scoped(comptime scope: @Type(.EnumLiteral))  type {
	return struct {
		pub fn err(comptime format: []const u8, args: anytype) void {
			@setCold(true);
			customLog(.err, scope, format, args);
		}

		pub fn list(comptime format: []const u8, args: anytype) void {
			customLog(.list, scope, format, args);
		}
		
		pub fn objet(comptime format: []const u8, args: anytype) void {
			customLog(.objet, scope, format, args);
		}
		
		pub fn detail(comptime format: []const u8, args: anytype) void {
			customLog(.detail, scope, format, args);
		}
	};
}

pub fn openFile(log:[]const u8) void {
	flog = std.fs.cwd().createFile(log, .{ .read = true }) 
		catch { @panic("impossible ouvrir file zlog.txt");};
}

pub fn deleteFile(log:[]const u8) void {
	std.fs.cwd().deleteFile(log) catch unreachable;
}

pub fn closeFile() void {
	flog.close();
}


pub fn newLine() void { 
    const writer = flog.writer();
    	nosuspend {
        	writer.print("\n",.{}) catch return;
    	}
	}


pub const default_log_scope = .default;
pub const default = scoped(default_log_scope);
pub const err = default.err;
pub const list = default.list;
pub const objet  = default.objet;
pub const detail = default.objet;