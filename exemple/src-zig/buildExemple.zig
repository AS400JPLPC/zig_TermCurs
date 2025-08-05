///-----------------------
/// build Exemple
///-----------------------

const std = @import("std");


pub fn build(b: *std.Build) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});


    // Definition of module
    // ===========================================================

    const zenlib_tui = b.dependency("libtui", .{});

     // Building the executable

    const Prog = b.addExecutable(.{
        .name = "Exemple",
        .root_module = b.createModule(.{
            .root_source_file = b.path( "./Exemple.zig" ),
            .target = target,
            .optimize = optimize,
        }),
    });


    Prog.root_module.addImport("cursed",   zenlib_tui.module("cursed"));

    Prog.root_module.addImport("utils",    zenlib_tui.module("utils"));

    Prog.root_module.addImport("mvzr",     zenlib_tui.module("mvzr"));
    
    Prog.root_module.addImport("forms",    zenlib_tui.module("forms"));
    
    Prog.root_module.addImport("grid" ,    zenlib_tui.module("grid"));
    
    Prog.root_module.addImport("menu" ,    zenlib_tui.module("menu"));
    
    Prog.root_module.addImport("callpgm" , zenlib_tui.module("callpgm"));

    b.installArtifact(Prog);

    
    // Building the executable

    const docs = b.addTest(.{
        .name = "Exemple",
        .root_module = b.createModule(.{
            .root_source_file = b.path( "./Exemple.zig" ),
            .target = target,
            .optimize = optimize,
        }),
    });
  

    docs.root_module.addImport("cursed",   zenlib_tui.module("cursed"));

    docs.root_module.addImport("utils",    zenlib_tui.module("utils"));

    docs.root_module.addImport("mvzr",     zenlib_tui.module("mvzr"));
    
    docs.root_module.addImport("forms",    zenlib_tui.module("forms"));
    
    docs.root_module.addImport("grid" ,    zenlib_tui.module("grid"));
    
    docs.root_module.addImport("menu" ,    zenlib_tui.module("menu"));
    
    docs.root_module.addImport("callpgm" , zenlib_tui.module("callpgm"));

    
    const install_docs = b.addInstallDirectory(.{
        .source_dir = docs.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "../Docs_Exemple",
    });
    const docs_step = b.step("docs", "Generate docs");
    docs_step.dependOn(&install_docs.step);
    docs_step.dependOn(&docs .step);
}
