const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

var cDIR = std.fs.cwd();
var ZCOM :fs.File = undefined;
const dirfile = "/tmp/";
const filename = "zig-cookbook-01-02.txt";
const file_size = 4096;

 

pub fn main() !void {
    if (.windows == @import("builtin").os.tag) {
        std.debug.print("MMap is not supported in Windows\n", .{});
        return;
    }

    cDIR = std.fs.cwd().openDir(dirfile,.{}) catch unreachable;
    ZCOM = cDIR.openFile(filename, .{.mode=.read_write}) catch unreachable;
    defer ZCOM.close();

    // // Before mmap, we need to ensure file isn't empty
     try ZCOM.setEndPos(file_size);

    const md = try ZCOM.metadata();
    print("File size: {d}\n", .{md.size()});

     print("File_handle {d}\n", .{ZCOM.handle});

    const  ptr = std.os.mmap(
        null,
        file_size,
        std.os.PROT.READ | std.os.PROT.WRITE,
        // std.os.linux.MAP_TYPE.SHARED | std.os.linux.MAP_TYPE.PRIVATE,
        .{.TYPE =.SHARED_VALIDATE},
        ZCOM.handle,
        0
    ) catch unreachable;
    defer std.os.munmap(ptr);
   // Read file via mmap
    print("File body: {s}\n", .{ptr});

 
    
    // Write file via mmap
    std.mem.copyForwards(u8, ptr, "bonjour j\'ai bien reçu le message");

    // Read file via mmap
    print("File End: {s}\n", .{ptr});

    // try fs.cwd().deleteFile(filename);
    
}
