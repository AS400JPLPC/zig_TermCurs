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


	// ===========================================================
	// const logger = b.dependency("library", .{}).module("logger");
    const cursed = b.dependency("library", .{}).module("cursed");
    const utils  = b.dependency("library", .{}).module("utils");
	const forms  = b.dependency("library", .{}).module("forms");
    const grid   = b.dependency("library", .{}).module("grid");
	const menu   = b.dependency("library", .{}).module("menu");
	const mvzr   = b.dependency("library", .{}).module("mvzr");

		
    const mdlPanel = b.createModule(.{
		.root_source_file = b.path( "./mdlPanel.zig" ),
		.imports= &.{
			.{ .name = "cursed", .module = cursed},
			.{ .name = "utils",  .module = utils },
			.{ .name = "forms",  .module = forms },
			.{ .name = "grid",   .module = grid  },
			.{ .name = "menu",   .module = menu  },
			.{ .name = "mvzr",   .module = mvzr  },
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
			.{ .name = "mvzr",   .module = mvzr  },
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
			 .{ .name = "mvzr",   .module = mvzr  },
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
			 .{ .name = "mvzr",   .module = mvzr  },
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
			.{ .name = "mvzr",   .module = mvzr  },
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
			.{ .name = "mvzr",   .module = mvzr  },
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
			.{ .name = "mvzr",   .module = mvzr  },
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


	// Resolve the 'library' dependency.
	// const library_dep = b.dependency("library", .{});
	
	Prog.root_module.addImport("cursed", cursed);

	Prog.root_module.addImport("utils", utils);

	Prog.root_module.addImport("mvzr", mvzr);
	
	Prog.root_module.addImport("forms", forms);
	 
	Prog.root_module.addImport("grid" , grid);
	
	Prog.root_module.addImport("menu" , menu);

	
	// Prog.root_module.addImport("logger" , logger);
	
	Prog.root_module.addImport("mdlPanel" , mdlPanel);

	Prog.root_module.addImport("mdlForms" , mdlForms);

	Prog.root_module.addImport("mdlFile"  , mdlFile);

	Prog.root_module.addImport("mdlGrids" , mdlGrids);

	Prog.root_module.addImport("mdlMenus" , mdlMenus);


	b.installArtifact(Prog);





}
