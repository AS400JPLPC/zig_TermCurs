const std = @import("std");


pub fn build(b: *std.build) void {
	// Standard release options allow the person running `zig build` to select
	// between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
	const target   = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});


	// zig-src			source projet
	// zig-src/deps	   curs/ form / outils ....
	// src_c			  source c/c++
	// zig-src/lib		source .h 


	// Definition of logger
	const logger = b.createModule(.{
		.source_file = .{ .path = "./deps/curse/logger.zig"},
	});

	// Definition of module
	const match = b.createModule(.{
		.source_file = .{ .path = "./deps/curse/match.zig"},
	});
	// data commune
	const dds = b.createModule(.{
		.source_file = .{ .path = "./deps/curse/dds.zig" },
	});
	
	const cursed = b.createModule(.{
		.source_file = .{ .path = "./deps/curse/cursed.zig" },
		.dependencies= &.{
			.{ .name = "dds", .module = dds },
		},
	});

	const utils = b.createModule(.{
		.source_file = .{ .path = "./deps/curse/utils.zig" },
			.dependencies= &.{
			.{ .name = "dds", .module = dds },
			.{ .name = "cursed", .module = cursed },
		}
	});

	const forms = b.createModule(.{
		.source_file = .{ .path = "./deps/curse/forms.zig" },
		.dependencies= &.{
			.{ .name = "dds",	.module = dds },
			.{ .name = "cursed", .module = cursed },
			.{ .name = "utils",  .module = utils },
			.{ .name = "match",  .module = match },
		},
	});


	const grid = b.createModule(.{
		.source_file = .{ .path = "./deps/curse/grid.zig" },
		.dependencies= &.{
			.{ .name = "dds",	.module = dds },
			.{ .name = "cursed", .module = cursed },
			.{ .name = "utils",  .module = utils },
			.{ .name = "forms",  .module = forms },
		},
	});
	

	const mdlPanel = b.createModule(.{
		.source_file = .{ .path = "./mdlPanel.zig" },
		.dependencies= &.{
			.{ .name = "dds",	.module = dds },
			.{ .name = "cursed", .module = cursed },
			.{ .name = "utils",  .module = utils },
			.{ .name = "forms",  .module = forms },
			.{ .name = "grid",   .module = grid  },
			.{ .name = "match",  .module = match },
		},
	});

	const mdlObjet = b.createModule(.{
		.source_file = .{ .path = "./mdlObjet.zig" },
		.dependencies= &.{
			.{ .name = "dds",	.module = dds },
			.{ .name = "cursed", .module = cursed },
			.{ .name = "utils",  .module = utils },
			.{ .name = "forms",  .module = forms },
			.{ .name = "grid",   .module = grid  },
			.{ .name = "match",  .module = match },
		},
	});

	const mdlSjson = b.createModule(.{
		.source_file = .{ .path = "./mdlSjson.zig" },
		.dependencies= &.{
			.{ .name = "dds",	.module = dds },
			.{ .name = "cursed", .module = cursed },
			.{ .name = "utils",  .module = utils },
			.{ .name = "forms",  .module = forms },
			.{ .name = "grid",   .module = grid  },
			.{ .name = "match",  .module = match },
			.{ .name = "logger", .module = logger },
		},
	});


	const mdlRjson = b.createModule(.{
		.source_file = .{ .path = "./mdlRjson.zig" },
		.dependencies= &.{
			.{ .name = "dds",	.module = dds },
			.{ .name = "cursed", .module = cursed },
			.{ .name = "utils",  .module = utils },
			.{ .name = "forms",  .module = forms },
			.{ .name = "grid",   .module = grid  },
			.{ .name = "match",  .module = match },
			.{ .name = "logger", .module = logger },
		},
	});

	const mdlFile = b.createModule(.{
		.source_file = .{ .path = "./mdlFile.zig" },
		.dependencies= &.{
			.{ .name = "dds",	.module = dds },
			.{ .name = "cursed", .module = cursed },
			.{ .name = "utils",  .module = utils },
			.{ .name = "forms",  .module = forms },
			.{ .name = "grid",   .module = grid  },
			.{ .name = "match",  .module = match },
			.{ .name = "mdlSjson",  .module = mdlSjson},
			.{ .name = "mdlRjson",  .module = mdlRjson},
			.{ .name = "logger", .module = logger },
		},
	});




	// Building the executable

	const Prog = b.addExecutable(.{
	.name = "Gencurs",
	.root_source_file = .{ .path = "./Gencurs.zig" },
	.target = target,
	.optimize = optimize,
	});

	Prog.addIncludePath(.{.path = "./lib/"});
	Prog.linkLibC();
	Prog.addObjectFile(.{.cwd_relative = "/usr/lib/libpcre2-posix.so"});
	Prog.addModule("dds"   , dds);
	Prog.addModule("cursed", cursed); 
	Prog.addModule("utils" , utils);
	Prog.addModule("forms" , forms);
	Prog.addModule("grid"  , grid);
	Prog.addModule("match" , match);
	Prog.addModule("mdlPanel" , mdlPanel);
	Prog.addModule("mdlObjet" , mdlObjet);
	Prog.addModule("mdlFile" , mdlFile);

	Prog.addModule("logger" , logger);

	const install_exe = b.addInstallArtifact(Prog, .{});
	b.getInstallStep().dependOn(&install_exe.step); 





	//Build step to generate docs:  

	const docs = b.addTest(.{
	.name = "Gencurs",
	.root_source_file = .{ .path = "./Gencurs.zig" },
	//.target = target,
	//.optimize = optimize,
	});

	docs.addIncludePath(.{.path = "./lib/"});
	docs.linkLibC();
	docs.addObjectFile(.{.cwd_relative = "/usr/lib/libpcre2-posix.so"});

	docs.addModule("dds"   , dds);
	docs.addModule("cursed", cursed);
	docs.addModule("utils" , utils);
	docs.addModule("forms" , forms);
	docs.addModule("grid"  , grid);
	docs.addModule("match" , match);
	docs.addModule("mdlPanel" , mdlPanel);
	docs.addModule("mdlObjet" , mdlObjet);
	Prog.addModule("mdlFile" , mdlFile);

	//docs.emit_docs = .emit;


	const install_docs = b.addInstallDirectory(.{
		.source_dir = docs.getEmittedDocs(),
		.install_dir = .prefix,
		.install_subdir = "Docs_Gencurs",
	});
	
	const docs_step = b.step("docs", "Generate docs");
	docs_step.dependOn(&install_docs.step);
	docs_step.dependOn(&docs.step);

}