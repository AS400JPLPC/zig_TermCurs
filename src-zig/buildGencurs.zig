	///-----------------------
	/// build Gencurs
	/// zig 0.13.0 dev
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



	// ===========================================================
    const cursed = b.dependency("library", .{}).module("cursed");
    const utils  = b.dependency("library", .{}).module("utils");
	const forms  = b.dependency("library", .{}).module("forms");
    const grid   = b.dependency("library", .{}).module("grid");
	const menu   = b.dependency("library", .{}).module("menu");
	const match  = b.dependency("library", .{}).module("match");

	// const logger  = b.dependency("library", .{}).module("logger");
		
	    const mdlPanel = b.createModule(.{
		.root_source_file = b.path( "./mdlPanel.zig" ),
		.imports= &.{
			.{ .name = "cursed", .module = cursed},
			.{ .name = "utils",  .module = utils },
			.{ .name = "forms",  .module = forms },
			.{ .name = "grid",   .module = grid  },
			.{ .name = "menu",   .module = menu  },
			.{ .name = "match",  .module = match },
		},
	});	

		const mdlForms = b.createModule(.{
		.root_source_file = b.path( "./mdlForms.zig" ),
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
		 .root_source_file = b.path( "./mdlGrids.zig" ),
		 .imports= &.{
			 .{ .name = "cursed", .module = cursed },
			 .{ .name = "utils",  .module = utils },
			 .{ .name = "forms",  .module = forms },
			 .{ .name = "grid",   .module = grid  },
			 .{ .name = "menu",   .module = menu  },
			 .{ .name = "match",  .module = match },
		 },
	 });

	 const mdlMenus = b.createModule(.{
		 .root_source_file = b.path( "./mdlMenus.zig" ),
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
		.root_source_file = b.path("./mdlSjson.zig" ),
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
		.root_source_file = b.path( "./mdlRjson.zig" ),
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
		.root_source_file = b.path( "./mdlFile.zig" ),
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
	.root_source_file = b.path( "./Gencurs.zig" ),
	.target = target,
	.optimize = optimize,
	});

	Prog.linkLibC();
	Prog.addObjectFile(.{.cwd_relative = "/usr/lib/libpcre2-posix.so"});

	// Resolve the 'library' dependency.
	// const library_dep = b.dependency("library", .{});
	
	Prog.root_module.addImport("cursed", cursed);

	Prog.root_module.addImport("utils", utils);

	Prog.root_module.addImport("match", match);
	
	Prog.root_module.addImport("forms", forms);
	 
	Prog.root_module.addImport("grid" , grid);
	
	Prog.root_module.addImport("menu" , menu);

	
	// Prog.root_module.addImport("logger" , logger);
	
	Prog.root_module.addImport("mdlPanel" , mdlPanel);

	Prog.root_module.addImport("mdlForms" , mdlForms);

	Prog.root_module.addImport("mdlFile"  , mdlFile);

	Prog.root_module.addImport("mdlGrids" , mdlGrids);

	Prog.root_module.addImport("mdlMenus" , mdlMenus);




	// const install_exe = b.addInstallArtifact(Prog, .{});
	// b.getInstallStep().dependOn(&install_exe.step); 
	b.installArtifact(Prog);





}
