    ///-----------------------
    /// build (library)
    ///-----------------------

const std = @import("std");

pub fn build(b: *std.Build) void {

    const decimal_mod = b.addModule("decimal", .{
        .root_source_file = b.path( "./decimal/decimal.zig" ),
    });
    

    const zfield_mod = b.addModule("zfield", .{
        .root_source_file = b.path( "./zfield/zfield.zig" ),
    });



    const lmdb = b.addModule("lmdb", .{ .root_source_file = b.path("./libdate/lmdb/lmdb.zig") });

    lmdb.addSystemIncludePath(.{ .cwd_relative ="/usr/include/lmdb.h"});
    lmdb.link_libc = true;
    lmdb.addObjectFile(.{.cwd_relative = "/usr/lib/liblmdb.so"});

    
    const liboffset = b.addModule("timeoffset", .{
        .root_source_file = b.path("./libdate/liboffset/timeoffset.zig") ,
        .imports = &.{
    	    .{ .name = "lmdb", .module = lmdb },
        },
    });

    
    const timezones_mod = b.addModule("timezones", .{
        .root_source_file = b.path( "./libdate/datetime/timezones.zig" ),
        
    });

    
    const datetime_mod = b.addModule("datetime", .{
        .root_source_file = b.path( "./libdate/datetime/datetime.zig" ),
        .imports= &.{
        .{ .name = "timezones", .module = timezones_mod},
        .{ .name = "timeoffset", .module = liboffset},
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
