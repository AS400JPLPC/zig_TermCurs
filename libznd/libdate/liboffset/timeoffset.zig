const std = @import("std");
const lmdb = @import("lmdb");

const allocTZ = std.heap.page_allocator;

var env : lmdb.Environment = undefined;
var db  : lmdb.Database = undefined;
var tr : lmdb.Transaction = undefined; 
var cursor : lmdb.Cursor = undefined;

var tbl_key = std.ArrayList([] const u8).init(allocTZ);
var tbl_offset =  std.ArrayList(i32).init(allocTZ);

const lib = "/tmp/Timezone";



//--------------------------------
// International timezone recovery
//--------------------------------
pub fn writeTimezone() void {

    const timesStamp_ms :i64 = @bitCast(std.time.milliTimestamp());

    const user = std.posix.getenv("USER") orelse "INITTIMEZONE";

    const fileTZ = std.fmt.allocPrintZ(allocTZ,"/tmp/{s}{d}.txt" ,.{user,timesStamp_ms})  catch unreachable;
    defer allocTZ.free(fileTZ);
    
    const batch = std.fmt.allocPrintZ(allocTZ,"/tmp/{s}{d}.sh" ,.{user,timesStamp_ms})  catch unreachable;
    defer allocTZ.free(batch);

    const file = std.fs.cwd().createFile(batch, .{.read = true, .truncate = true,.exclusive = false, })
            catch |err| {
                    const s = @src();
                    @panic( std.fmt.allocPrint(allocTZ,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s} creatFile({s})  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,batch, err, })
                    	catch unreachable);
            };



    // Construire le script Bash ligne par ligne
    var lines = std.ArrayList([]const u8).init(allocTZ);
    defer lines.clearAndFree();

    lines.append("#!/bin/bash") catch unreachable;
    lines.append("format='%z'") catch unreachable;
    lines.append("zoneinfo=/usr/share/zoneinfo/") catch unreachable;
    lines.append("if command -v timedatectl >/dev/null; then") catch unreachable;
    lines.append("    tzlist=$(timedatectl list-timezones)") catch unreachable;
    lines.append("fi \n") catch unreachable;
    lines.append("line=\"\" \n") catch unreachable;
    lines.append("grep -i \"$search\" <<< \"$tzlist\" | while read z") catch unreachable;
    lines.append("do \n") catch unreachable;
    lines.append("    d=$(TZ=$z date +\"$format\")") catch unreachable;
    lines.append("    printf -v line \"%-32s%s%s%s\" \"$z\"\"|\"\"$d\"\"|\"") catch unreachable;
    lines.append(std.fmt.allocPrint(allocTZ, "    echo \"$line\" >> {s}", .{fileTZ}) catch unreachable) catch unreachable;
    lines.append("done") catch unreachable;
    lines.append(std.fmt.allocPrint(allocTZ, "echo \"END\" >> {s}", .{fileTZ}) catch unreachable ) catch unreachable;
    lines.append("exit 0") catch unreachable;

    // ecriture du code source batch
    for (lines.items) |line| {
       _= file.write(line) catch unreachable;
       _= file.write("\n") catch unreachable;
    }
    file.close();

    permission(batch);


    execute(batch);

    readFileTZ(fileTZ);




    const Base =lmdb.createDir(lib);

    // We start by creating an Environment
    env = lmdb.Environment.init(Base.dir, .{}) catch unreachable;
    defer env.deinit();

    // Next we get a Database handler
    db = env.openDatabase(null)  catch unreachable;

    // To write data, we begin a RW transaction
    tr = env.beginTransaction(.ReadAndWrite)  catch unreachable;

    // And use the Transaction to interact with the Database
    const BaseTR  = tr.withDatabase(db) ;

    // Finally, we put some data
    var idx : usize = 0;
    while( idx < tbl_key.items.len)  {
// std.debug.print("{s}  {d}\n",.{tbl_key.items[idx],tbl_offset.items[idx]});
        BaseTR.putInt32(tbl_key.items[idx], tbl_offset.items[idx])  catch unreachable;
        idx += 1;
    }

    // And commit
    tr.commit() catch unreachable;

    tbl_key.clearAndFree();
    tbl_offset.clearAndFree();

}


//---------------------------------
// Reading the application timezone
//---------------------------------
pub fn readTimezone(keytmz : []const u8) i32 {
    
    const Base =lmdb.openDir(lib);
    // We start by creating an Environment
    env = lmdb.Environment.init(Base.dir, .{}) catch unreachable;
    defer env.deinit();

    // Next we get a Database handler
    db = env.openDatabase(null) catch unreachable;

    // Next, we start a RO transaction to read the data
    tr = env.beginTransaction(.ReadOnly) catch unreachable;


    const BaseTR = tr.withDatabase(db) ;


    // We can read values by key
    const value = BaseTR.getInt32(keytmz) catch unreachable;


    tr.commit() catch unreachable;

    return value;
}


// Permission to run batch to obtain timezone list
// The terminal is ignored
fn permission( SRC_batch :[]const u8) void {
    // the command to run
    const argv = [_][]const u8{ "/bin/chmod","+x",SRC_batch };

    var proc = std.process.Child.init(&argv, allocTZ);

    proc.stdin_behavior = .Ignore;
    proc.stdout_behavior = .Ignore;
    proc.stderr_behavior = .Ignore;

    proc.spawn() catch unreachable;
    _= proc.wait() catch unreachable;
}

// Run the batch program
fn execute( SRC_batch :[]const u8) void {

    const argv = [_][]const u8{ "/bin/sh","-c",SRC_batch, };

    var proc = std.process.Child.init(&argv, allocTZ);

    proc.stdin_behavior = .Ignore;
    proc.stdout_behavior = .Ignore;
    proc.stderr_behavior = .Ignore;

    proc.spawn() catch unreachable;
    _= proc.wait() catch unreachable;

    const cDIR = std.fs.cwd().openDir("/tmp", .{}) catch |err| {
        const s = @src();
        @panic( std.fmt.allocPrint(allocTZ,"\n\n\r file:{s} line:{d} column:{d} func:{s} OpenDir err:{}\n\r",
            .{s.file, s.line, s.column,s.fn_name,err})  catch unreachable );
    };

    cDIR.deleteFile(SRC_batch) catch unreachable;
}

// We read the file and analyze it to create a table
fn readFileTZ( fbatch :[]const u8)  void {
    const file = std.fs.cwd().openFile(fbatch, .{}) catch |err| {
            const s = @src();
            @panic( std.fmt.allocPrint(allocTZ,
            "\n\n\r file:{s} line:{d} column:{d} func:{s} openFile({s}) Invalid  err:{} \n\r"
            ,.{s.file, s.line, s.column,s.fn_name,fbatch, err, })
            	catch unreachable);
    };


    const file_size = file.getEndPos() catch unreachable;
	var buffer : []u8= allocTZ.alloc(u8, file_size) catch unreachable ;


	_= file.read(buffer[0..buffer.len]) catch unreachable;
    file.close();

    
	// Delete the timedatectl output file
	const cDIR = std.fs.cwd().openDir("/tmp", .{}) catch |err| {
        const s = @src();
            @panic( std.fmt.allocPrint(allocTZ,
            "\n\n\r file:{s} line:{d} column:{d} func:{s} openDir(/tmp)  err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,err})
                catch unreachable);
    };
    cDIR.deleteFile(fbatch) catch unreachable;

    var lmdbkey :[] const u8 = undefined;
    var lmdboffset  :[] const u8 = undefined;
    var hours   : i32 = 0;
    var minutes : i32 = 0;
    var totalminutes  : i32 = 0;
    // traitement de la commande timedatectl
    var lines = std.mem.splitAny(u8, buffer, "\n");
    while (lines.next()) |line | {
        if (std.mem.eql(u8,line,"END")) break;

        // Separating region and offset
        var parts = std.mem.splitScalar(u8, line, '|');
        lmdbkey =  parts.first();
        lmdboffset = parts.next() .? ;
        hours = 0;
        minutes = 0;
        totalminutes = 0;
        const sign: i32 = if(lmdboffset[0] == '-') -1 else 1;
        hours = std.fmt.parseInt(i32, lmdboffset[1..3], 10) catch unreachable;
        minutes = std.fmt.parseInt(i32, lmdboffset[3..5], 10) catch unreachable;
        totalminutes  = (hours * 60 + minutes) * sign;

        tbl_key.append(lmdbkey) catch unreachable;
        tbl_offset.append(totalminutes ) catch unreachable;

    }

}
