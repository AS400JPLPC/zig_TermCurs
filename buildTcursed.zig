const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();


// examples
// zig-src  source projet
// zig-deps depot
// src_c    source c/c++

    const prog = b.addExecutable("Tcursed", "src-zig/Tcursed.zig");
    prog.setTarget(target);
    prog.addPackagePath("dds", "deps/curse/dds.zig");
    prog.addPackagePath("cursed", "deps/curse/cursed.zig");
    prog.addPackagePath("zig_string", "deps/string/zig_string.zig");
    //prog.addPackagePath("ziglyph", "deps/ziglyph/ziglyph.zig");
    prog.setBuildMode(mode);
    prog.install();

    const run_cmd = prog.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("tested", "Run the app");
    run_step.dependOn(&run_cmd.step);
}


