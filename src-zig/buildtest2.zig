    ///-----------------------
    /// build test
    ///-----------------------

const std = @import("std");
// zi=g 0.12.0 dev

pub fn build(b: *std.Build) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});


    // Definition of module
    // data commune
    // Definition of dependencies



    // Building the executable
    const Prog = b.addExecutable(.{
    .name = "test2",
    .root_source_file =b.path( "./test2.zig" ),
    .target = target,
    .optimize = optimize,
    });

    b.installArtifact(Prog);


}
