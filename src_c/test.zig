const std = @import("std");
const fs = std.fs;
const print = std.debug.print;


var cDIR = std.fs.cwd();
var ZCOM :fs.File = undefined;
const dirfile = "/tmp/";
const filename = "zig-cookbook-01-02.txt";

const file_size = 4096;
const stdin = std.io.getStdIn().reader();

var ZDATA : [4096] u8 = undefined ;


const allocator = std.heap.page_allocator;

// var DATA :*align(4096); 
pub fn main() !void {
    if (.windows == @import("builtin").os.tag) {
        std.debug.print("MMap is not supported in Windows\n", .{});
        return;
    }
    // if (isFile(filename)) { ZCOM = cDIR.openFile(filename, .{.mode=.read_write})  catch |err| {
    //             @panic(std.fmt.allocPrint(allocator,"err Open.{any}\n", .{err}) catch unreachable);};} 
    // defer ZCOM.close();

    // ZCOM.setEndPos(file_size) catch unreachable;
    

    // const  ptr = std.os.mmap(
    //     null,
    //     file_size,
    //     std.os.PROT.READ | std.os.PROT.WRITE,
    //     std.os.linux.MAP.SHARED,
    //     ZCOM.handle,
    //     0
    // ) catch unreachable;
    // std.os.munmap(ptr);
    // const vtext : [] const  u8 = "hello zig cookbook";
    // const ztext = std.fmt.allocPrintZ(allocator,"{s}",.{vtext}) catch unreachable;
    // // Write file via mmap
    // std.mem.copyForwards(u8, ptr,ztext );

    // // Read file via mmap
    // print("File body: {s}\n", .{ptr});



    
    // Write file via mmapi
    const vtext : [] const  u8 = "hello zig cookbook";
    writeMap(vtext);
    //try fs.cwd().deleteFile(filename);


    
    
    var buf : [3]u8 = undefined;
    std.debug.print("stop 3/3 fin\r\n",.{});
    buf =    [_]u8{0} ** 3;
    _= try stdin.readUntilDelimiterOrEof(buf[0..], '\n');

    std.debug.print("{s}",.{ readMap()} );
//    try cDIR.deleteFile(filename);
    
    
    
    // Read file via mmap
    // print("File body: {s}\n", .{ptr});
}


 
pub fn  writeMap( Text: [] const  u8) void {

    if (isFile(filename)) { ZCOM = cDIR.openFile(filename, .{.mode=.read_write})  catch |err| {
                @panic(std.fmt.allocPrint(allocator,"err Open.{any}\n", .{err}) catch unreachable);};} 
    // defer ZCOM.close();

    ZCOM.setEndPos(file_size) catch unreachable;
    print("File Handle: {d}\n", .{ZCOM.handle});

    const  ptr = std.os.mmap(
        null,
        file_size,
        std.os.PROT.READ | std.os.PROT.WRITE,
        // std.os.linux.MAP.SHARED | std.os.linux.MAP.PRIVATE,
        .{.TYPE =.SHARED_VALIDATE} ,

        ZCOM.handle,
        0
    ) catch unreachable;
    defer std.os.munmap(ptr);

    std.debug.print("text  {d}\r\n  {s}\r\n {d}\r\n", .{Text.len , Text, ptr.len});


    const ztext = std.fmt.allocPrintZ(allocator,"{s}",.{Text}) catch unreachable;
    // Write file via mmap
    std.mem.copyForwards(u8, ptr,ztext );

    // Read file via mmap
    print("File body: {s}\n", .{ptr});
    
}

fn readMap()  [] const u8 {

    // const endfile = ZCOM.getEndPos() catch unreachable;
    const  rcvptr = std.os.mmap(
        null,
        file_size,
        std.os.PROT.READ | std.os.PROT.WRITE,
        // std.os.linux.MAP.SHARED | std.os.linux.MAP.PRIVATE,
        .{.TYPE =.SHARED_VALIDATE} ,
        ZCOM.handle,
        0
    ) catch unreachable;
    defer  std.os.munmap(rcvptr);

    print("File body: {s}\n", .{rcvptr});

    defer ZCOM.close();

    cDIR.deleteFile(filename) catch unreachable;

    const ztext = std.fmt.allocPrintZ(allocator,"{s}",.{rcvptr}) catch unreachable;

    return ztext;
}


fn isFile(name: []const u8 ) bool {

    
    cDIR = std.fs.cwd().openDir(dirfile,.{}) catch unreachable;

    ZCOM = cDIR.createFile(name, .{ .read = true, .truncate =true , .exclusive = true }) catch |e|
        switch (e) {
            error.PathAlreadyExists => return true,
            else => @panic(std.fmt.allocPrint(allocator,"err Open CREAT FILE.{any}\n", .{e}) catch unreachable)
,
        };

    return false;
}
