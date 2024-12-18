///------------------
/// test sdl2
///------------------
const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const Prog = b.addExecutable(.{
        .name = "Gterm",
        .root_source_file = .{ .path = "./Gterm.zig" },
        .target = target,
        .optimize = optimize,
    });

    Prog.linkSystemLibrary("SDL2");
    Prog.linkSystemLibrary("c");
    Prog.addObjectFile(.{ .cwd_relative = "/usr/lib/libSDL2.so" });

    const install_exe = b.addInstallArtifact(Prog, .{});
    b.getInstallStep().dependOn(&install_exe.step);
}
