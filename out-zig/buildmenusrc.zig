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
	const menu   = b.dependency("library", .{}).module("menu");


	// Building the executable

	const Prog = b.addExecutable(.{
	.name = "menusrc",
	.root_source_file = b.path( "./menusrc.zig" ),
	.target = target,
	.optimize = optimize,
	});


	
	Prog.root_module.addImport("cursed", cursed);

	Prog.root_module.addImport("utils", utils);

	Prog.root_module.addImport("menu" , menu);




	b.installArtifact(Prog);





}
