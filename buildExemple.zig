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

    const Prog = b.addExecutable("Exemple", "src-zig/Exemple.zig");
    Prog.setTarget(target);
    Prog.addPackagePath("cursed", "deps/curse/cursed.zig");
    Prog.addPackagePath("forms", "deps/curse/forms.zig");
    Prog.addPackagePath("dds", "deps/curse/dds.zig");
    Prog.addPackagePath("utils", "deps/curse/utils.zig");
    Prog.setBuildMode(mode);
    Prog.install();

}
