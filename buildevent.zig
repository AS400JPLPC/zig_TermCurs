const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // examples
	
	// zig-src   source projet
	// zig-deps  depot
	// src_c     source c/c++

    const event = b.addExecutable("event", "src-zig/event.zig");
    event.setTarget(target);
    event.addPackagePath("mibu", "deps/mibu/main.zig");
    event.setBuildMode(mode);
    event.install();

    const run_cmd = event.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("runEvent", "Run the app");
    run_step.dependOn(&run_cmd.step);


}
