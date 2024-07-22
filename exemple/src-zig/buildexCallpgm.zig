	///-----------------------
	/// build excallpgm
	/// zig 0.13.0 dev
	///-----------------------

const std = @import("std");


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
    const cursed = b.dependency("library", .{}).module("cursed");
    const utils  = b.dependency("library", .{}).module("utils");
	const forms  = b.dependency("library", .{}).module("forms");
    const grid   = b.dependency("library", .{}).module("grid");
	const menu   = b.dependency("library", .{}).module("menu");
	const mvzr   = b.dependency("library", .{}).module("mvzr");
	const callpgm  = b.dependency("library", .{}).module("callpgm");
	// const logger  = b.dependency("library", .{}).module("logger");

	// Building the executable
	
	const Prog = b.addExecutable(.{
	.name = "exCallpgm",
	.root_source_file = b.path("./exCallpgm.zig" ),
	.target = target,
	.optimize = optimize,
	});

	Prog.linkLibC();
	Prog.addObjectFile(.{.cwd_relative = "/usr/lib/libpcre2-posix.so"});

	Prog.root_module.addImport("cursed", cursed);

	Prog.root_module.addImport("utils", utils);

	Prog.root_module.addImport("mvzr", mvzr);
	
	Prog.root_module.addImport("forms", forms);
	
	Prog.root_module.addImport("grid" , grid);
	
	Prog.root_module.addImport("menu" , menu);
	
	Prog.root_module.addImport("callpgm" , callpgm);
	
	const install_exe = b.addInstallArtifact(Prog, .{});
	b.getInstallStep().dependOn(&install_exe.step); 



}
