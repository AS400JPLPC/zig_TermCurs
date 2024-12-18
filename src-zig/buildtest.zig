    ///-----------------------
    /// build test
    ///-----------------------

const std = @import("std");
// zi=g 0.12.0 dev

pub fn build(b: *std.Build) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});


    // Definition of module
    // data commune
    // Definition of dependencies


    // ===========================================================
    const cursed = b.dependency("library", .{}).module("cursed");
    const utils  = b.dependency("library", .{}).module("utils");
    const forms  = b.dependency("library", .{}).module("forms");
    const grid   = b.dependency("library", .{}).module("grid");
    const menu   = b.dependency("library", .{}).module("menu");


    // Building the executable
    const Prog = b.addExecutable(.{
    .name = "test",
    .root_source_file =b.path( "./test.zig" ),
    .target = target,
    .optimize = optimize,
    });
    Prog.root_module.addImport("cursed", cursed);

    Prog.root_module.addImport("utils", utils);

    
    Prog.root_module.addImport("forms", forms);
     
    Prog.root_module.addImport("grid" , grid);
    
    Prog.root_module.addImport("menu" , menu);

    b.installArtifact(Prog);


}
