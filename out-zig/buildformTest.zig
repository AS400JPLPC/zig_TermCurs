    ///-----------------------
    /// build Gencurs
    ///-----------------------

const std = @import("std");
// zi=g 0.12.0 dev

pub fn build(b: *std.Build) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});


    // ===========================================================
    const cursed = b.dependency("libtui", .{}).module("cursed");
    const utils  = b.dependency("libtui", .{}).module("utils");
    const forms  = b.dependency("libtui", .{}).module("forms");
    const grid   = b.dependency("libtui", .{}).module("grid");
    const menu   = b.dependency("libtui", .{}).module("menu");
    const mvzr   = b.dependency("libtui", .{}).module("mvzr");


    // Building the executable

    const Prog = b.addExecutable(.{
    .name = "formTest",
    .root_source_file = b.path( "./formTest.zig" ),
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
