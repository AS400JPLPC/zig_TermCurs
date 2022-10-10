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

    const forms = b.addExecutable("forms", "deps/curse/forms.zig");
    forms.setTarget(target);
    forms.addPackagePath("dds", "deps/curse/dds.zig");
    forms.addPackagePath("term", "deps/curse/cursed.zig");
    forms.setBuildMode(mode);
    forms.install();

    const run_cmd = forms.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("testeForms", "Run the app");
    run_step.dependOn(&run_cmd.step);


}
