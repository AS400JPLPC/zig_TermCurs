const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
 
    // zig-src            source projet
    // zig-src/deps       curs/ form / outils ....
    // src_c              source c/c++
    // zig-src/srcgo      source go-lang 
    // zig-src/srcgo/lib  lib.so source.h

    

    // Definition of dependencies
    const pkgs = struct {


        const match = std.build.Pkg{
          .name = "match",
          .source = .{ .path = "./deps/curse/match.zig"},
          .dependencies = &[_]std.build.Pkg {},
        };

        const dds = std.build.Pkg{
            .name = "dds",
            .source = .{ .path = "./deps/curse/dds.zig"},
            .dependencies = &[_]std.build.Pkg {},
        };

        const cursed = std.build.Pkg{
            .name = "cursed",
            .source = .{ .path = "./deps/curse/cursed.zig"},
            .dependencies = &[_]std.build.Pkg {
                dds,
            },
        };

        const utils = std.build.Pkg{
            .name = "utils",
            .source = .{ .path = "./deps/curse/utils.zig"},
            .dependencies = &[_]std.build.Pkg {
                dds,
            },
        };


        const forms = std.build.Pkg{
            .name = "forms",
            .source = .{ .path = "./deps/curse/forms.zig"},
            .dependencies = &[_]std.build.Pkg {
                dds,
                cursed,
                utils,
                match,
            },
        };

    };


    // Building the executable
    const Prog = b.addExecutable("Exemple", "./Exemple.zig");
    Prog.setTarget(target);
    Prog.addIncludePath("./lib/");
    Prog.linkLibC();
    Prog.addPackage(pkgs.dds);
    Prog.addPackage(pkgs.cursed);
    Prog.addPackage(pkgs.utils);
    Prog.addPackage(pkgs.forms);
    Prog.addPackage(pkgs.match);
    Prog.setBuildMode(mode);

    const install_exe = b.addInstallArtifact(Prog);
    b.getInstallStep().dependOn(&install_exe.step);
    
  
    //Build step to generate docs:  
    //const docs = b.addTest("./Exemple.zig"); BEUG 
    const docs = Prog;
    docs.setBuildMode(mode);
    docs.emit_docs = .emit;  

    const docs_step = b.step("docs", "Generate docs");
    docs_step.dependOn(&docs.step);

     // test


    const tests = b.addTest( "./Exemple.zig");

    tests .setTarget(target);
    tests .addIncludePath("./lib/");
    tests .linkLibC();
    tests .addPackage(pkgs.dds);
    tests .addPackage(pkgs.cursed);
    tests .addPackage(pkgs.utils);
    tests .addPackage(pkgs.forms);
    tests .addPackage(pkgs.match);
    tests .setBuildMode(mode);
  
     // test
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&tests.step );



}