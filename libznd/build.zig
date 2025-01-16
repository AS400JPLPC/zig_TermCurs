    ///-----------------------
    /// build (library)
    ///-----------------------

const std = @import("std");

pub fn build(b: *std.Build) void {

    const decimal_mod = b.addModule("decimal", .{
        .root_source_file = b.path( "./number/decimal.zig" ),
    });
    
    decimal_mod.addSystemIncludePath(.{ .cwd_relative ="/usr/include/mpnumeric.h"});
    decimal_mod.link_libc = true;
    decimal_mod.addObjectFile(.{.cwd_relative = "/usr/lib/libmpdec.so"});



    const zfield_mod = b.addModule("zfield", .{
        .root_source_file = b.path( "./zfield/zfield.zig" ),
    });



    const timezones_mod = b.addModule("timezones", .{
        .root_source_file = b.path( "./datetime/timezones.zig" ),
    });
    const datetime_mod = b.addModule("datetime", .{
        .root_source_file = b.path( "./datetime/datetime.zig" ),
        .imports= &.{
        .{ .name = "timezones", .module = timezones_mod},
        },
    });



    const libznd = b.addModule("library", .{
        .root_source_file = b.path( "library.zig" ),
        .imports = &.{
        .{ .name = "decimal",   .module = decimal_mod },
        .{ .name = "zfield",    .module = zfield_mod },   
        .{ .name = "datetime",  .module = datetime_mod },
        .{ .name = "timezones", .module = timezones_mod },
        },
    });


    _=libznd;

}
