    ///-----------------------
    /// build (library)
    /// zig 0.12.0 dev
    ///-----------------------

const std = @import("std");


pub fn build(b: *std.Build) void {
    var flags = std.ArrayList([]const u8).init(b.allocator);

    const THREADSAFE = enum { SINGLETHREAD, MULTITHREAD, SERIALIZED };
    switch (b.option(THREADSAFE, "SQLITE_THREADSAFE", "SQLITE_THREADSAFE") orelse .SERIALIZED) {
        .SINGLETHREAD => flags.append("-DSQLITE_THREADSAFE=0") catch @panic("OOM"),
        .SERIALIZED => flags.append("-DSQLITE_THREADSAFE=1") catch @panic("OOM"),
        .MULTITHREAD => flags.append("-DSQLITE_THREADSAFE=2") catch @panic("OOM"),
    }

    if (b.option(bool, "SQLITE_ENABLE_COLUMN_METADATA", "SQLITE_ENABLE_COLUMN_METADATA") orelse false)
        flags.append("-DSQLITE_ENABLE_COLUMN_METADATA") catch @panic("OOM");

    if (b.option(bool, "SQLITE_ENABLE_DBSTAT_VTAB", "SQLITE_ENABLE_DBSTAT_VTAB") orelse false)
        flags.append("-DSQLITE_ENABLE_DBSTAT_VTAB") catch @panic("OOM");

    if (b.option(bool, "SQLITE_ENABLE_FTS3", "SQLITE_ENABLE_FTS3") orelse false)
        flags.append("-DSQLITE_ENABLE_FTS3") catch @panic("OOM");

    if (b.option(bool, "SQLITE_ENABLE_FTS4", "SQLITE_ENABLE_FTS4") orelse false)
        flags.append("-DSQLITE_ENABLE_FTS4") catch @panic("OOM");

    if (b.option(bool, "SQLITE_ENABLE_FTS5", "SQLITE_ENABLE_FTS5") orelse false)
        flags.append("-DSQLITE_ENABLE_FTS5") catch @panic("OOM");

    if (b.option(bool, "SQLITE_ENABLE_GEOPOLY", "SQLITE_ENABLE_GEOPOLY") orelse false)
        flags.append("-DSQLITE_ENABLE_GEOPOLY") catch @panic("OOM");

    if (b.option(bool, "SQLITE_ENABLE_ICU", "SQLITE_ENABLE_ICU") orelse false)
        flags.append("-DSQLITE_ENABLE_ICU") catch @panic("OOM");

    if (b.option(bool, "SQLITE_ENABLE_MATH_FUNCTIONS", "SQLITE_ENABLE_MATH_FUNCTIONS") orelse false)
        flags.append("-DSQLITE_ENABLE_MATH_FUNCTIONS") catch @panic("OOM");

    if (b.option(bool, "SQLITE_ENABLE_RBU", "SQLITE_ENABLE_RBU") orelse false)
        flags.append("-DSQLITE_ENABLE_RBU") catch @panic("OOM");

    if (b.option(bool, "SQLITE_ENABLE_RTREE", "SQLITE_ENABLE_RTREE") orelse false)
        flags.append("-DSQLITE_ENABLE_RTREE") catch @panic("OOM");

    if (b.option(bool, "SQLITE_ENABLE_STAT4", "SQLITE_ENABLE_STAT4") orelse false)
        flags.append("-DSQLITE_ENABLE_STAT4") catch @panic("OOM");

    if (b.option(bool, "SQLITE_OMIT_DECLTYPE", "SQLITE_OMIT_DECLTYPE") orelse false)
        flags.append("-DSQLITE_OMIT_DECLTYPE") catch @panic("OOM");

    if (b.option(bool, "SQLITE_OMIT_JSON", "SQLITE_OMIT_JSON") orelse false)
        flags.append("-DSQLITE_OMIT_JSON") catch @panic("OOM");

    if (b.option(bool, "SQLITE_USE_URI", "SQLITE_USE_URI") orelse false)
        flags.append("-DSQLITE_USE_URI") catch @panic("OOM");

    if (b.option(bool, "SQLITE_OMIT_DEPRECATED", "SQLITE_OMIT_DEPRECATED") orelse false)
        flags.append("-DSQLITE_OMIT_DEPRECATED") catch @panic("OOM");



    const sqlite_mod = b.addModule("sqlite", .{
        .root_source_file = b.path( "./sqlite/sqlite.zig" ),
    });



    sqlite_mod.addSystemIncludePath(.{ .cwd_relative ="/usr/bin/sqlite3.h"});
    sqlite_mod.link_libc = true;
    sqlite_mod.addObjectFile(.{.cwd_relative = "/usr/lib/libsqlite3.so"});

    
    const libsql_mod = b.addModule("library", .{
        .root_source_file = b.path( "library.zig" ),
        .imports = &.{
        .{ .name = "sqlite",    .module = sqlite_mod },

        },
    });


    _ = libsql_mod;



}
