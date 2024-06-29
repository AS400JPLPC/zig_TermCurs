	///-----------------------
	/// build (library)
	/// zig 0.12.0 dev
	///-----------------------

const std = @import("std");


pub fn build(b: *std.Build) void {

	const logger_mod = b.addModule("logger", .{
		.root_source_file =  b.path( "./curse/logger.zig" ),
	});


	const cursed_mod = b.addModule("cursed", .{
		.root_source_file = b.path( "./curse/cursed.zig" ),
	});

	const utils_mod = b.addModule("utils", .{
		.root_source_file = b.path( "./curse/utils.zig" ),
	});

	const match_mod = b.addModule("match", .{
		.root_source_file = b.path( "./curse/match.zig" ),
	});

 	const forms_mod = b.addModule("forms", .{
		.root_source_file = b.path( "./curse/forms.zig" ),
		.imports= &.{
		.{ .name = "cursed", .module = cursed_mod },
		.{ .name = "utils",  .module = utils_mod},
		.{ .name = "match",  .module = match_mod },
		},
	});

	const grid_mod = b.addModule("grid", .{
		.root_source_file = b.path( "./curse/grid.zig" ),
		.imports = &.{
		.{ .name = "cursed", .module = cursed_mod},
		.{ .name = "utils",  .module = utils_mod},
		},
	});

	const menu_mod= b.addModule("menu", .{
		.root_source_file = b.path( "./curse/menu.zig" ),
		.imports= &.{
		.{ .name = "cursed", .module = cursed_mod},
		.{ .name = "utils",  .module = utils_mod},
		},
	});



	const callpgm_mod = b.addModule("callpgm", .{
		.root_source_file = b.path( "./calling/callpgm.zig" ),
	});



	const crypto_mod= b.addModule("crypto", .{
		.root_source_file = b.path( "./crypt/crypto.zig" ),
	});



	const zmmap_mod= b.addModule("zmmap", .{
		.root_source_file = b.path( "./mmap/zmmap.zig" ),
		.imports= &.{
		.{ .name = "crypto", .module = crypto_mod},
		.{ .name = "logger", .module = logger_mod},
		},
	});


	const decimal_mod = b.addModule("decimal", .{
		.root_source_file = b.path( "./decimal/decimal.zig" ),
	});







	match_mod.addIncludePath( b.path( "./lib/"));
	match_mod.link_libc = true;
	match_mod.addObjectFile(.{.cwd_relative = "/usr/lib/libpcre2-posix.so"});

	decimal_mod.addIncludePath( b.path( "./lib/"));
	decimal_mod.link_libc = true;
	decimal_mod.addObjectFile(.{.cwd_relative = "/usr/lib/libmpdec.so"});


	
	const library_mod = b.addModule("library", .{
		.root_source_file = b.path( "library.zig" ),
		.imports = &.{
		.{ .name = "cursed",	.module = cursed_mod },
		.{ .name = "utils",		.module = utils_mod },
		.{ .name = "match",		.module = match_mod },
		.{ .name = "forms",		.module = forms_mod },
		.{ .name = "grid",		.module = grid_mod },
		.{ .name = "menu",		.module = menu_mod },
		.{ .name = "decimal",	.module = decimal_mod },
		
		.{ .name = "callpgm",	.module = callpgm_mod },
		.{ .name = "zmmap",		.module = zmmap_mod },
		.{ .name = "crypto",	.module = crypto_mod },
		
		.{ .name = "logger",	.module = logger_mod },
			
		},
	});






	
	_ = library_mod;


}
