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


    // Definition of module




    // Building the executable

    const Prog = b.addExecutable("testreg","./testreg.zig");
    Prog.setTarget(target);
    Prog.addIncludePath("./lib/");
    Prog.linkLibC();
    Prog.setBuildMode(mode);

    const install_exe = b.addInstallArtifact(Prog);
    b.getInstallStep().dependOn(&install_exe.step);


}