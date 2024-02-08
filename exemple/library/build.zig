const std = @import("std");
// zi=g 0.12.0 dev

pub fn build(b: *std.Build) void {


	const cursed_mod = b.addModule("cursed", .{
		.root_source_file = .{ .path = "cursed.zig" },
	});

	const utils_mod = b.addModule("utils", .{
		.root_source_file = .{ .path = "utils.zig" },
	});

	const match_mod = b.addModule("match", .{
		.root_source_file = .{ .path = "match.zig" },
	});

	const callpgm_mod = b.addModule("callpgm", .{
		.root_source_file = .{ .path = "callpgm.zig" },
	});

 	const forms_mod = b.addModule("forms", .{
		.root_source_file = .{ .path = "forms.zig" },
		.imports= &.{
		.{ .name = "cursed", .module = cursed_mod },
		.{ .name = "utils",  .module = utils_mod},
		.{ .name = "match",  .module = match_mod },
		},
	});

	const grid_mod = b.addModule("grid", .{
		.root_source_file = .{ .path = "grid.zig" },
		.imports = &.{
		.{ .name = "cursed", .module = cursed_mod},
		.{ .name = "utils",  .module = utils_mod},
		},
	});

	const menu_mod= b.addModule("menu", .{
		.root_source_file = .{ .path = "menu.zig" },
		.imports= &.{
		.{ .name = "cursed", .module = cursed_mod},
		.{ .name = "utils",  .module = utils_mod},
		},
	});

	
	const library_mod = b.addModule("library", .{
		.root_source_file = .{ .path = "library.zig" },
		.imports = &.{
		.{ .name = "cursed",	.module = cursed_mod },
		.{ .name = "utils",		.module = utils_mod },
		.{ .name = "match",		.module = match_mod },
		.{ .name = "cllpgm",	.module = callpgm_mod },
		.{ .name = "forms",		.module = forms_mod },
		.{ .name = "grid",		.module = grid_mod },
		.{ .name = "menu",		.module = menu_mod },

			
		},
	});

	match_mod.addIncludePath(.{.path = "./lib/"});
	match_mod.link_libc = true;
	match_mod.addObjectFile(.{.cwd_relative = "/usr/lib/libpcre2-posix.so"});
	
	_ = library_mod;


}
