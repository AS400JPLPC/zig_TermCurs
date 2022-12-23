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

    const utils = b.addExecutable("utils", "deps/curse/utils.zig");
    utils.setTarget(target);
    utils.setBuildMode(mode);
    utils.install();

    const run_cmd = utils.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("testUtils", "Run the app");
    run_step.dependOn(&run_cmd.step);


}
