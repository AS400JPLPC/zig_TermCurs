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
    const cursed = b.dependency("library", .{}).module("cursed");
    const utils  = b.dependency("library", .{}).module("utils");
	const forms  = b.dependency("library", .{}).module("forms");
    const grid   = b.dependency("library", .{}).module("grid");
	const menu   = b.dependency("library", .{}).module("menu");
	const mvzr   = b.dependency("library", .{}).module("mvzr");


	// Building the executable

	const Prog = b.addExecutable(.{
	.name = "mdlSrc",
	.root_source_file = b.path( "./mdlSrc.zig" ),
	.target = target,
	.optimize = optimize,
	});


	
	Prog.root_module.addImport("cursed", cursed);

	Prog.root_module.addImport("utils", utils);

	Prog.root_module.addImport("mvzr", mvzr);
	
	Prog.root_module.addImport("forms", forms);
	 
	Prog.root_module.addImport("grid" , grid);
	
	Prog.root_module.addImport("menu" , menu);




	b.installArtifact(Prog);





}
