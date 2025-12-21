///-----------------------
/// build excallpgm
///-----------------------

const std = @import("std");


pub fn build(b: *std.Build) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});


    // Definition of module
    const zenlib_tui = b.dependency("libtui", .{});
    // const logger  = b.dependency("libtui", .{}).module("logger");

    // Building the executable

    const Prog = b.addExecutable(.{
        .name = "exCallpgm",
        .root_module = b.createModule(.{
            .root_source_file = b.path( "./exCallpgm.zig" ),
            .target = target,
            .optimize = optimize,
        }),
    });


    // Prog.linkLibC();
    // Prog.addObjectFile(.{.cwd_relative = "/usr/lib/libpcre2-posix.so"});

    Prog.root_module.addImport("alloc",zenlib_tui.module("alloc"));

    Prog.root_module.addImport("cursed",   zenlib_tui.module("cursed"));

    Prog.root_module.addImport("utils",    zenlib_tui.module("utils"));

    Prog.root_module.addImport("mvzr",     zenlib_tui.module("mvzr"));
    
    Prog.root_module.addImport("forms",    zenlib_tui.module("forms"));
    
    Prog.root_module.addImport("grid" ,    zenlib_tui.module("grid"));
    
    Prog.root_module.addImport("menu" ,    zenlib_tui.module("menu"));
    
    Prog.root_module.addImport("callpgm" , zenlib_tui.module("callpgm"));

    // Prog.root_module.addImport("logger" , zenlib_tui.module("logger"));

        
    const install_exe = b.addInstallArtifact(Prog, .{});
    b.getInstallStep().dependOn(&install_exe.step); 



}
