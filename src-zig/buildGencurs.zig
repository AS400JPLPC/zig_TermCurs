	///-----------------------
	/// build Gencurs
	/// zig 0.12.0 dev
	///-----------------------

const std = @import("std");
// zi=g 0.12.0 dev

pub fn build(b: *std.Build) void {
	// Standard release options allow the person running `zig build` to select
	// between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
	const target   = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});


	// zig-src			source projet
	// zig-src/deps		curs/ form / outils ....
	// src_c			source c/c++
	// zig-src/lib		source .h 


	// Definition of logger
	// const logger = b.createModule(.{
	//	 .root_source_file = .{ .path = "./deps/curse/logger.zig"},
	// });

	// Definition of module
	const match = b.createModule(.{
		.root_source_file = .{ .path = "./deps/curse/match.zig"},
	});
	match.addIncludePath(.{.path = "./lib/"});

	
	const cursed = b.createModule(.{
		.root_source_file = .{ .path = "./deps/curse/cursed.zig" },
	});

	const utils = b.createModule(.{
		.root_source_file = .{ .path = "./deps/curse/utils.zig" },
	});


	const forms = b.createModule(.{
		.root_source_file = .{ .path = "./deps/curse/forms.zig" },
		.imports= &.{
		.{ .name = "cursed", .module = cursed },
		.{ .name = "utils",  .module = utils },
		.{ .name = "match",  .module = match },
		},

	});


	const grid = b.createModule(.{
		.root_source_file = .{ .path = "./deps/curse/grid.zig" },
		.imports= &.{
		.{ .name = "cursed", .module = cursed },
		.{ .name = "utils",  .module = utils },
		},
	});

	
	const menu = b.createModule(.{
		.root_source_file = .{ .path = "./deps/curse/menu.zig" },
		.imports= &.{
		.{ .name = "cursed", .module = cursed },
		.{ .name = "utils",  .module = utils },
		},
	});



// ===========================================================
	
	const mdlPanel = b.createModule(.{
		.root_source_file = .{ .path = "./mdlPanel.zig" },
		.imports= &.{
			.{ .name = "cursed", .module = cursed },
			.{ .name = "utils",  .module = utils },
			.{ .name = "forms",  .module = forms },
			.{ .name = "grid",   .module = grid  },
			.{ .name = "menu",   .module = menu  },
			.{ .name = "match",  .module = match },
		},
	});

	const mdlForms = b.createModule(.{
		.root_source_file = .{ .path = "./mdlForms.zig" },
		.imports= &.{
			.{ .name = "cursed", .module = cursed },
			.{ .name = "utils",  .module = utils },
			.{ .name = "forms",  .module = forms },
			.{ .name = "grid",   .module = grid  },
			.{ .name = "menu",   .module = menu  },
			.{ .name = "match",  .module = match },
		},
	});

	 const mdlGrids = b.createModule(.{
		 .root_source_file = .{ .path = "./mdlGrids.zig" },
		 .imports= &.{
			 .{ .name = "cursed", .module = cursed },
			 .{ .name = "utils",  .module = utils },
			 .{ .name = "forms",  .module = forms },
			 .{ .name = "grid",   .module = grid  },
			 .{ .name = "menu",   .module = menu  },
			 .{ .name = "match",  .module = match },
		 },
	 });

	const mdlSjson = b.createModule(.{
		.root_source_file = .{ .path = "./mdlSjson.zig" },
		.imports= &.{
			.{ .name = "cursed", .module = cursed },
			.{ .name = "utils",  .module = utils },
			.{ .name = "forms",  .module = forms },
			.{ .name = "grid",   .module = grid  },
			.{ .name = "menu",   .module = menu  },
			.{ .name = "match",  .module = match },
		},
	});


	const mdlRjson = b.createModule(.{
		.root_source_file = .{ .path = "./mdlRjson.zig" },
		.imports= &.{
			.{ .name = "cursed", .module = cursed },
			.{ .name = "utils",  .module = utils },
			.{ .name = "forms",  .module = forms },
			.{ .name = "grid",   .module = grid  },
			.{ .name = "menu",   .module = menu  },
			.{ .name = "match",  .module = match },
		},
	});

	const mdlFile = b.createModule(.{
		.root_source_file = .{ .path = "./mdlFile.zig" },
		.imports= &.{
			.{ .name = "cursed", .module = cursed },
			.{ .name = "utils",  .module = utils },
			.{ .name = "forms",  .module = forms },
			.{ .name = "grid",   .module = grid  },
			.{ .name = "menu",   .module = menu  },
			.{ .name = "match",  .module = match },
			.{ .name = "mdlSjson",  .module = mdlSjson},
			.{ .name = "mdlRjson",  .module = mdlRjson},
		},
	});




	// Building the executable

	const Prog = b.addExecutable(.{
	.name = "Gencurs",
	.root_source_file = .{ .path = "./Gencurs.zig" },
	.target = target,
	.optimize = optimize,
	});

	Prog.linkLibC();
	Prog.addObjectFile(.{.cwd_relative = "/usr/lib/libpcre2-posix.so"});

	Prog.root_module.addImport("cursed", cursed);

	Prog.root_module.addImport("utils", utils);

	Prog.root_module.addImport("match", match);
	
	Prog.root_module.addImport("forms", forms);
	 
	Prog.root_module.addImport("grid" , grid);
	
	Prog.root_module.addImport("menu" , menu);

	// Prog.root_module.addImport("logger" , logger);
	
	Prog.root_module.addImport("mdlPanel" , mdlPanel);

	Prog.root_module.addImport("mdlForms" , mdlForms);

	Prog.root_module.addImport("mdlFile" , mdlFile);

	Prog.root_module.addImport("mdlGrids" , mdlGrids);

	const install_exe = b.addInstallArtifact(Prog, .{});
	b.getInstallStep().dependOn(&install_exe.step); 





}
