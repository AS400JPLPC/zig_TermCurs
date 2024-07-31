	///-----------------------
	/// build Exemple
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
	// ===========================================================
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
	.name = "Exemple",
	.root_source_file = b.path( "./Exemple.zig" ),
	.target = target,
	.optimize = optimize,
	});


	Prog.root_module.addImport("cursed", cursed);

	Prog.root_module.addImport("utils", utils);

	Prog.root_module.addImport("mvzr", mvzr);
	
	Prog.root_module.addImport("forms", forms);
	
	Prog.root_module.addImport("grid" , grid);
	
	Prog.root_module.addImport("menu" , menu);
	
	Prog.root_module.addImport("callpgm" , callpgm);

	b.installArtifact(Prog);

	
	// Building the executable
	
	const docs = b.addTest(.{
	.name = "Exemple",
	.root_source_file = b.path( "./Exemple.zig" ),
	.target = target,
	.optimize = optimize,
	});
	

	docs.root_module.addImport("cursed", cursed);

	docs.root_module.addImport("utils", utils);

	docs.root_module.addImport("mvzr", mvzr);
	
	docs.root_module.addImport("forms", forms);
	
	docs.root_module.addImport("grid" , grid);
	
	docs.root_module.addImport("menu" , menu);
	
	docs.root_module.addImport("callpgm" , callpgm);

	
	const install_docs = b.addInstallDirectory(.{
		.source_dir = docs.getEmittedDocs(),
		.install_dir = .prefix,
		.install_subdir = "../Docs_Exemple",
	});
	const docs_step = b.step("docs", "Generate docs");
	docs_step.dependOn(&install_docs.step);
	docs_step.dependOn(&docs .step);
}
