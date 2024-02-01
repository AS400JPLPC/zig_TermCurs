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


	// Definition of module
	const match = b.createModule(.{
		.root_source_file = .{ .path = "./deps/curse/match.zig" },
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

	// Building the executable
	
	const Prog = b.addExecutable(.{
	.name = "exCallpgm",
	.root_source_file = .{ .path = "./exCallpgm.zig" },
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
	
	const install_exe = b.addInstallArtifact(Prog, .{});
	b.getInstallStep().dependOn(&install_exe.step); 



}
