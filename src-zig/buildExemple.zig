const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
 
// zig-src   source projet
// zig-deps  depot
// src_c     source c/c++
// test.addPackagePath("curse", "deps/curse/main.zig");

    const Prog = b.addExecutable("Exemple", "./Exemple.zig");
    Prog.setTarget(target);
    Prog.setBuildMode(mode);
    Prog.install();

    
    
    //Build step to generate docs:
    const docs = b.addTest("./Exemple.zig");
    docs.setBuildMode(mode);
    docs.emit_docs = .emit;
    
    const docs_step = b.step("docs", "Generate docs");
    docs_step.dependOn(&docs.step);


}
