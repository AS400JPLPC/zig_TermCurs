const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();


// zig-src   source projet
// zig-deps  depot
// src_c     source c/c++
//     test.addPackagePath("curse", "deps/curse/main.zig");

    const code = b.addExecutable("code", "src-zig/code.zig");
    code.setTarget(target);
    code.addPackagePath("style", "deps/curse/style.zig");
    code.addPackagePath("label", "deps/curse/label.zig");
    code.setBuildMode(mode);
    code.install();

}
