    ///-----------------------
    /// build (library)
    ///-----------------------

const std = @import("std");

pub fn build(b: *std.Build) void {

    const lmdb = b.addModule("lmdb", .{ .root_source_file = b.path("./lmdb/lmdb.zig") });

    lmdb.addSystemIncludePath(.{ .cwd_relative ="/usr/include/lmdb.h"});
    lmdb.link_libc = true;
    lmdb.addObjectFile(.{.cwd_relative = "/usr/lib/liblmdb.so"});

    
    const liboffset = b.addModule("timeoffset", .{
        .root_source_file = b.path("./liboffset/timeoffset.zig") ,
        .imports = &.{
    	    .{ .name = "lmdb", .module = lmdb },
        },
    });

    
    const timezones_mod = b.addModule("timezones", .{
        .root_source_file = b.path( "./datetime/timezones.zig" ),
        
    });

    
    const datetime_mod = b.addModule("datetime", .{
        .root_source_file = b.path( "./datetime/datetime.zig" ),
        .imports= &.{
        .{ .name = "timezones", .module = timezones_mod},
        .{ .name = "timeoffset", .module = liboffset},
        },
    });

    
    const libdate_mod = b.addModule("library", .{
        .root_source_file = b.path( "library.zig" ),
        .imports = &.{
        .{ .name = "datetime",    .module = datetime_mod },
        .{ .name = "timezones", .module = timezones_mod },
        },
    });

    _=libdate_mod;

}
