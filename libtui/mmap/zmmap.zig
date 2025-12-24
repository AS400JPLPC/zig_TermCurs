    ///-----------------------
    /// gestion file mmap
    /// emulation *LDA IBM
    ///-----------------------

const std = @import("std");
const cry = @import("crypto");

var stdin = std.fs.File.stdin();
var stdout = std.fs.File.stdout().writerStreaming(&.{});
//=======================================================================
// For debeug
inline fn Print( comptime format: []const u8, args: anytype) void {
    stdout.interface.print(format, .{args}) catch  {} ;
 }
inline fn WriteAll( args: [] const u8) void {
    stdout.interface.writeAll(args) catch  {} ;
 }

fn Pause() void {
    stdout.interface.print("Pause \n",.{}) catch  {} ;
    var buf: [16]u8 =  [_]u8{0} ** 16;
    var c  : usize = 0;
    while (c == 0) {
        c = stdin.read(&buf) catch unreachable;
    }
}
// return error
pub fn Perror(msg :  [] const u8) noreturn{
    stdout.interface.print("please fix:  {s}\n",.{msg}) catch unreachable;
    var buf: [16]u8 =  [_]u8{0} ** 16;
    var c  : usize = 0;
    while (c == 0) {
        c = stdin.read(&buf) catch unreachable;
    }
 @panic(msg);
}

// retrieve timstamp nanoseconds tested Linux
fn TSnano() i128 {
    return std.time.nanoTimestamp();
}

fn milliTimestamp() i64 {
    return @as(i64, @intCast(@divFloor(TSnano(), std.time.ns_per_ms)));
}

//=======================================================================


const errmap = error{
    violation_integrite_rcvkey_fileKEY,
    violation_integrite_rcvnonce_fileNONCE,
    violation_integrite_rcvtag_fileTAG,
    violation_integrite_sendtag_fileTAG,
    violation_integrite_rcvuds_fileUDS,
    violation_integrite_senduds_fileUDS,
    violation_integrite_rcvlog_fileLCI,
    violation_integrite_sendlog_fileLCI,
   
    violation_integrite_fileKEY_not_found,
    violation_integrite_fileKEY_found,
    violation_integrite_fileNONCE_not_found,
    violation_integrite_fileNONCE_found,
    
    violation_integrite_fileTAG_not_found,
    violation_integrite_fileTAG_found,
    violation_integrite_fileUDS_not_found,
    violation_integrite_fileUDS_found,
    violation_integrite_fileLCI_not_found,
    violation_integrite_fileLCI_found,

    violation_integrite_filePWR_found,   
    violation_integrite_filePWR_not_found, 
   
};
const fs = std.fs;

const allocZmmap = std.heap.page_allocator;
//-----------------------
// crypto
//-----------------------
pub const Aes256Gcm = cry.AesGcm(std.crypto.core.aes.Aes256);

// key and nonce crypto
// var dta:   []const u8 = undefined; // data crypter 
var cipher: []u8 = undefined;
var decipher: []u8 = undefined;

//-----------------------
var mmapOK : bool = false;
var echoOK : bool = false;

const dirfile = "./qtemp";

var cDIR = std.fs.cwd();

// name seq = times
var    parmTimes: [] const u8 = undefined;

var ztext  : []u8 = undefined ;
var    zcrpt  : []u8 = undefined ;


//==================================================
const ZMMAP = struct {
    fileKEY   : []const u8 ,
    fileNONCE : []const u8 ,
    fileTAG   : []const u8 ,
    fileUDS   : []const u8 ,
    fileLCI   : []const u8 ,
    filePWR   : []const u8 ,

    ZKEY   :fs.File ,
    ZNONCE :fs.File ,
    ZTAG   :fs.File ,
    ZUDS   :fs.File ,
    ZLCI   :fs.File ,
    ZPWR   :fs.File ,

    // key and nonce crypto
    key:   [Aes256Gcm.key_length]u8        , // len 32
    nonce: [Aes256Gcm.nonce_length]u8      , // len 12 
    tag:   [Aes256Gcm.tag_length]u8        , // len 16
};


var COM : ZMMAP = undefined ;
var SAVCOM : ZMMAP = undefined;
var sav_parmTimes: [] const u8 = undefined;


pub fn savEnvMmap() void  {
 
    SAVCOM = COM ;
    sav_parmTimes = parmTimes;
    COM = undefined ;
 }

pub fn rstEnvMmap() void  {

    released();

    COM = SAVCOM ;
    parmTimes = sav_parmTimes ;
    

    SAVCOM = undefined ;
    sav_parmTimes = undefined;
}

//==================================================
pub const COMLDA = struct { 
    reply : bool ,
    abort : bool ,
    user : [] const u8 ,

    init : [] const u8 ,
    echo : [] const u8 ,
    // alpha numeric
    zuds : [] const u8 ,
};

var LDA : COMLDA = undefined;
fn initLDA() void {
    LDA = COMLDA{
        .reply = true ,
        .abort = false,
        .user = undefined ,
        .init = undefined ,
        .echo = "" ,
         // alpha numeric
        .zuds = undefined , 
        };
        
    LDA.user = std.posix.getenv("USER") orelse "INITLDA";
}



//-------------------------------------------
// isFile
//-------------------------------------------
fn isFile(name: []const u8 ) bool {
    const xDIR = std.fs.cwd().openDir(dirfile,.{}) catch unreachable;
       xDIR.access(name, .{}) catch |e| switch (e) {
        error.FileNotFound => return false,
                else => { Perror(std.fmt.allocPrint(allocZmmap,"{}",.{e}) catch unreachable); },
    };
  
    return true;
}


//-------------------------------------------
// create communication  this file MAP
//-------------------------------------------
fn setNameFile() void {
    COM.fileKEY   = std.fmt.allocPrint(allocZmmap,"KEY{s}"   ,.{parmTimes})  catch unreachable;
    COM.fileNONCE = std.fmt.allocPrint(allocZmmap,"NONCE{s}" ,.{parmTimes})  catch unreachable;
    COM.fileTAG   = std.fmt.allocPrint(allocZmmap,"TAG{s}"   ,.{parmTimes})  catch unreachable;
    COM.fileUDS   = std.fmt.allocPrint(allocZmmap,"UDS{s}"   ,.{parmTimes})  catch unreachable;
    COM.fileLCI   = std.fmt.allocPrint(allocZmmap,"LCI{s}"   ,.{parmTimes})  catch unreachable;
    COM.filePWR   = std.fmt.allocPrint(allocZmmap,"PWR{s}"   ,.{parmTimes})  catch unreachable;
}



fn creatFileMMAP() void {

    cDIR = std.fs.cwd().openDir(dirfile,.{}) catch unreachable;

 
    COM.ZKEY =
    cDIR.createFile(COM.fileKEY , .{ .read = true, .truncate =true , .exclusive = false, .lock =.shared}) catch |e|
                @panic(std.fmt.allocPrint(allocZmmap,"err isFile Open CREAT FILEKEY  .{any}\n", .{e})
                catch unreachable);
    // ZKEY.close();


    COM.ZNONCE =
    cDIR.createFile(COM.fileNONCE , .{ .read = true, .truncate =true , .exclusive = false, .lock =.shared}) catch |e|
                @panic(std.fmt.allocPrint(allocZmmap,"err isFile Open CREAT FILENONCE .{any}\n", .{e})
                catch unreachable);
    // ZNONCE.close();


    COM.ZTAG =
     cDIR.createFile(COM.fileTAG , .{ .read = true, .truncate =true , .exclusive = false, .lock =.shared}) catch |e|
                @panic(std.fmt.allocPrint(allocZmmap,"err isFile Open CREAT FILETAG .{any}\n", .{e})
                catch unreachable);
    // ZTAG.close();


    COM.ZUDS =
    cDIR.createFile(COM.fileUDS , .{ .read = true, .truncate =true , .exclusive = false, .lock =.shared}) catch |e|
                @panic(std.fmt.allocPrint(allocZmmap,"err isFile Open CREAT FILEUDS .{any}\n", .{e})
                catch unreachable);
    // ZUDS.close();


    COM.ZLCI =
    cDIR.createFile(COM.fileLCI , .{ .read = true, .truncate =true , .exclusive = false, .lock =.shared}) catch |e|
                @panic(std.fmt.allocPrint(allocZmmap,"err isFile Open CREAT FILELCI .{any}\n", .{e})
                catch unreachable);
    // ZLCI.close();

    COM.ZPWR =
    cDIR.createFile(COM.filePWR , .{ .read = true, .truncate =true , .exclusive = false, .lock =.shared}) catch |e|
                @panic(std.fmt.allocPrint(allocZmmap,"err isFile Open CREAT FILEPWR .{any}\n", .{e})
                catch unreachable);
}

fn setOpenFile() void {
           
    cDIR = std.fs.cwd().openDir(dirfile,.{}) catch unreachable;


    COM.ZKEY = cDIR.openFile(COM.fileKEY , .{.mode=.read_write , .lock =.shared}) catch |e| {
        @panic(std.fmt.allocPrint(allocZmmap,"\n{any} mmap fileKEY error open   {s}\n",.{e,COM.fileKEY })
            catch unreachable);
    };    


    COM.ZNONCE = cDIR.openFile(COM.fileNONCE , .{.mode=.read_write , .lock =.shared}) catch |e| {
         @panic(std.fmt.allocPrint(allocZmmap,"\n{any} mmap fileNONCE error open   {s}\n",.{e,COM.fileNONCE })
            catch unreachable);
    };    


    COM.ZTAG = cDIR.openFile(COM.fileTAG , .{.mode=.read_write , .lock =.shared}) catch |e| {
         @panic(std.fmt.allocPrint(allocZmmap,"\n{any} mmap fileTAG error open   {s}\n",.{e,COM.fileTAG })
            catch unreachable);
    };


    COM.ZUDS = cDIR.openFile(COM.fileUDS , .{.mode=.read_write , .lock =.shared}) catch |e| {
         @panic(std.fmt.allocPrint(allocZmmap,"\n{any} mmap fileUDS error open   {s}\n",.{e,COM.fileUDS })
            catch unreachable);
    };


    COM.ZLCI = cDIR.openFile(COM.fileLCI , .{.mode=.read_write , .lock =.shared}) catch |e| {
         @panic(std.fmt.allocPrint(allocZmmap,"\n{any} mmap fileLCI error open   {s}\n",.{e,COM.fileLCI })
            catch unreachable);
    };


    COM.ZPWR = cDIR.openFile(COM.filePWR , .{.mode=.read_write , .lock =.shared}) catch |e| {
         @panic(std.fmt.allocPrint(allocZmmap,"\n{any} mmap fileLCI error open   {s}\n",.{e,COM.filePWR })
            catch unreachable);
    };
}




//--------------------------
// READ TAsG
//--------------------------
fn readTAG() !void {

    var zlen :usize =  COM.ZTAG.getEndPos() catch unreachable;


    const  rcvtag = std.posix.mmap(
        null,
        zlen ,
        std.posix.PROT.READ ,
        .{.TYPE =.SHARED_VALIDATE} ,
        COM.ZTAG.handle,
        0
    ) catch return errmap.violation_integrite_rcvtag_fileTAG;
    defer std.posix.munmap(rcvtag);

    var ztag: []u8 = undefined ;
    ztag = std.fmt.allocPrint(allocZmmap,"{s}",.{rcvtag}) catch unreachable;
    defer allocZmmap.free(ztag);


    zlen = ztag.len;
    for ( 0.. COM.tag.len - 1) |x| {COM.tag[x]= 0; }
    var it = std.mem.splitScalar(u8, ztag[0..zlen], '|');
    var i : usize = 0;
    while (it.next()) |chunk| :( i += 1) {
        COM.tag[i] = std.fmt.parseInt(u8,chunk,10) catch unreachable;
    }

}




//--------------------------
// WRITE TAG
//--------------------------
   
fn writeTAG() !void {

    const ztag :[]u8 = std.fmt.allocPrint(allocZmmap,
        "{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}"
        ,.{
            COM.tag[0],COM.tag[1],COM.tag[2],COM.tag[3],COM.tag[4],
            COM.tag[5],COM.tag[6],COM.tag[7],COM.tag[8],COM.tag[9],
            COM.tag[10],COM.tag[11],COM.tag[12],COM.tag[13],COM.tag[14],COM.tag[15],
        })
        catch |err| { Perror(std.fmt.allocPrint(allocZmmap,"{}",.{err}) catch unreachable);  return err; };
    defer allocZmmap.free(ztag);

    COM.ZTAG.setEndPos(ztag.len) catch unreachable;
    const  sendtag = std.posix.mmap(
        null,
        ztag.len,
        std.posix.PROT.READ | std.posix.PROT.WRITE,
        .{.TYPE =.SHARED_VALIDATE} ,
        COM.ZTAG.handle,
        0
    ) catch return errmap.violation_integrite_sendtag_fileTAG;
    defer std.posix.munmap(sendtag);
    
    std.mem.copyForwards(u8, sendtag,ztag);

}

//===========================================================================

//-------------------------------------------
// name file mmap
//-------------------------------------------
// name file / mmap
pub fn getParm() [] const u8 { return parmTimes;}


// read DATAAREA LDA
pub fn getLDA() COMLDA { return LDA;}


//-------------------------------------------
//restore base null
//-------------------------------------------
// released acces initMmap for new communication
pub fn released() void { 



        if ( isFile(COM.fileKEY) ) COM.ZKEY.close();
        if ( isFile(COM.fileKEY) ) cDIR.deleteFile(COM.fileKEY) catch unreachable;
        
        if ( isFile(COM.fileKEY) ) COM.ZNONCE.close();       
        if ( isFile(COM.fileNONCE) ) cDIR.deleteFile(COM.fileNONCE) catch unreachable;
        
        if ( isFile(COM.fileTAG) ) COM.ZTAG.close();
        if ( isFile(COM.fileTAG) ) cDIR.deleteFile(COM.fileTAG) catch unreachable;

        if ( isFile(COM.fileLCI) ) COM.ZLCI.close();
        if ( isFile(COM.fileLCI) ) cDIR.deleteFile(COM.fileLCI) catch unreachable;

        if ( isFile(COM.fileUDS) ) COM.ZUDS.close();
        if ( isFile(COM.fileUDS) ) cDIR.deleteFile(COM.fileUDS) catch unreachable;

        if ( isFile(COM.filePWR) ) COM.ZPWR.close();
        if ( isFile(COM.filePWR) ) cDIR.deleteFile(COM.filePWR) catch unreachable;

    initLDA();

}
//-------------------------------------------
//fermeture all base
//-------------------------------------------
// released acces initMmap for new communication
pub fn closeAll() void { 



        if ( isFile(COM.fileKEY) ) COM.ZKEY.close();
        if ( isFile(COM.fileKEY) ) cDIR.deleteFile(COM.fileKEY) catch unreachable;
        
        if ( isFile(COM.fileKEY) ) COM.ZNONCE.close();       
        if ( isFile(COM.fileNONCE) ) cDIR.deleteFile(COM.fileNONCE) catch unreachable;
        
        if ( isFile(COM.fileTAG) ) COM.ZTAG.close();
        if ( isFile(COM.fileTAG) ) cDIR.deleteFile(COM.fileTAG) catch unreachable;

        if ( isFile(COM.fileLCI) ) COM.ZLCI.close();
        if ( isFile(COM.fileLCI) ) cDIR.deleteFile(COM.fileLCI) catch unreachable;

        if ( isFile(COM.fileUDS) ) COM.ZUDS.close();
        if ( isFile(COM.fileUDS) ) cDIR.deleteFile(COM.fileUDS) catch unreachable;

        if ( isFile(COM.filePWR) ) COM.ZPWR.close();
        if ( isFile(COM.filePWR) ) cDIR.deleteFile(COM.filePWR) catch unreachable;

}

//===========================================================================


//-------------------------------------------
// init Maitre
//-------------------------------------------
pub fn masterMmap() !COMLDA {

    COM = undefined ;
    const timesStamp_ms: u64 =@intCast(milliTimestamp());

    parmTimes = std.fmt.allocPrint(allocZmmap,"{d}" ,.{timesStamp_ms})  catch unreachable;


    setNameFile();

    if ( isFile(COM.fileKEY) ) return errmap.violation_integrite_fileKEY_found;
    if ( isFile(COM.fileNONCE) ) return errmap.violation_integrite_fileNONCE_found;
    if ( isFile(COM.fileTAG) ) return errmap.violation_integrite_fileTAG_found;
    if ( isFile(COM.fileUDS) ) return errmap.violation_integrite_fileUDS_found;
    if ( isFile(COM.fileLCI) ) return errmap.violation_integrite_fileLCI_found;
    if ( isFile(COM.filePWR) ) return errmap.violation_integrite_filePWR_found;
   
    creatFileMMAP();

    //----------------------------
    // KEY
    //----------------------------



    for ( 0.. COM.key.len - 1) |x| { COM.key[x]= 0; }
    std.crypto.random.bytes(&COM.key);


     const zkey :[]u8 = std.fmt.allocPrint(allocZmmap,
"{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}"
    ,.{
        COM.key[0],COM.key[1],COM.key[2],COM.key[3],COM.key[4],COM.key[5],COM.key[6],
        COM.key[7],COM.key[8],COM.key[9],
        COM.key[10],COM.key[11],COM.key[12],COM.key[13],COM.key[14],COM.key[15],COM.key[16],
        COM.key[17],COM.key[18],COM.key[19],
        COM.key[20],COM.key[21],COM.key[22],COM.key[23],COM.key[24],COM.key[25],COM.key[26],
        COM.key[27],COM.key[28],COM.key[29],
        COM.key[30],COM.key[31],
    }) catch unreachable;
    defer allocZmmap.free(zkey);


    COM.ZKEY.setEndPos(zkey.len) catch unreachable;
    
    const  sendkey = std.posix.mmap(
        null,
        zkey.len,
        std.posix.PROT.READ | std.posix.PROT.WRITE,
        .{.TYPE =.SHARED_VALIDATE} ,
        COM.ZKEY.handle,
        0
    ) catch return errmap.violation_integrite_rcvkey_fileKEY;   
    defer std.posix.munmap(sendkey);

    std.mem.copyForwards(u8, sendkey,zkey);


//----------------------------
// NONCE
//---------------------------- 
    for ( 0.. COM.nonce.len - 1) |x| { COM.nonce[x]= 0; }
    std.crypto.random.bytes(&COM.nonce);

    const znonce :[]u8 = std.fmt.allocPrint(allocZmmap,
        "{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}"
        ,.{
            COM.nonce[0],COM.nonce[1],COM.nonce[2],COM.nonce[3],COM.nonce[4],
            COM.nonce[5],COM.nonce[6],COM.nonce[7],COM.nonce[8],COM.nonce[9],
            COM.nonce[10],COM.nonce[11],
        }) catch unreachable;
    defer allocZmmap.free(znonce);



    COM.ZNONCE.setEndPos(znonce.len) catch unreachable;

    const sendnonce = std.posix.mmap(
        null,
        znonce.len,
        std.posix.PROT.READ | std.posix.PROT.WRITE,
        .{.TYPE =.SHARED_VALIDATE} ,
        COM.ZNONCE.handle,
        0
     ) catch return errmap.violation_integrite_rcvnonce_fileNONCE;   
    defer std.posix.munmap(sendnonce);

    std.mem.copyForwards(u8, sendnonce,znonce);


//----------------------------
// TAG
//---------------------------- 

    for ( 0.. COM.tag.len - 1) |x| { COM.tag[x]= 0; }
    const ztag :[]u8 = std.fmt.allocPrint(allocZmmap,
        "{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}"
        ,.{
            COM.tag[0],COM.tag[1],COM.tag[2],COM.tag[3],COM.tag[4],
            COM.tag[5],COM.tag[6],COM.tag[7],COM.tag[8],COM.tag[9],
            COM.tag[10],COM.tag[11],COM.tag[12],COM.tag[13],COM.tag[14],COM.tag[15],
        }) catch unreachable;
    defer allocZmmap.free(ztag);

    COM.ZTAG.setEndPos(ztag.len) catch unreachable;

    const sendtag = std.posix.mmap(
        null,
        ztag.len,
        std.posix.PROT.READ | std.posix.PROT.WRITE,
        .{.TYPE =.SHARED_VALIDATE} ,
        COM.ZTAG.handle,
        0
    ) catch return errmap.violation_integrite_sendtag_fileTAG;
  
    defer std.posix.munmap(sendtag);
    
    std.mem.copyForwards(u8, sendtag,ztag);



        COM.ZKEY.close();
        COM.ZNONCE.close();
//-------------------------------------------
// init parameter LDA
//-------------------------------------------
    initLDA();

    mmapOK = true ;

    return LDA;
}

//-------------------------------------------
// init ECHO
//-------------------------------------------

pub fn echoMmap(timesParm : [] const u8 ) !COMLDA {

    parmTimes = std.fmt.allocPrint(allocZmmap,"{s}" ,.{timesParm})  catch unreachable;
    
    COM = undefined ;
    setNameFile(); 

    // test erreur et display 
    //const beug: bool = true;
    // if (beug == true ) return errmap.violation_integrite_rcvkey_fileKEY;

    if ( !isFile(COM.fileKEY) ) return errmap.violation_integrite_fileKEY_not_found;
    if ( !isFile(COM.fileNONCE) ) return errmap.violation_integrite_fileNONCE_not_found;
    if ( !isFile(COM.fileTAG) ) return errmap.violation_integrite_fileTAG_not_found;
    if ( !isFile(COM.fileUDS) ) return errmap.violation_integrite_fileUDS_not_found;
    if ( !isFile(COM.fileLCI) ) return errmap.violation_integrite_fileLCI_not_found;
    if ( !isFile(COM.filePWR) ) return errmap.violation_integrite_filePWR_not_found;

    setOpenFile();   
//--------------------------
// recover KEY
//--------------------------

    var zlen :usize =  COM.ZKEY.getEndPos() catch unreachable;
 
    const rcvkey = std.posix.mmap(
        null,
        zlen,
        std.posix.PROT.READ | std.posix.PROT.WRITE,
        .{.TYPE =.SHARED_VALIDATE} ,
        COM.ZKEY.handle,
        0
    ) catch return errmap.violation_integrite_rcvkey_fileKEY;
                     
    defer std.posix.munmap(rcvkey);


    for ( 0.. COM.key.len - 1) |x| {COM.key[x]= 0; }
    var ita = std.mem.splitScalar(u8, rcvkey[0..zlen], '|');
    var i : usize = 0;
    while (ita.next()) |chunk| :( i += 1) {
        COM.key[i] = std.fmt.parseInt(u8,chunk,10) catch unreachable;
    }
//--------------------------
// recover NONCE
//--------------------------


    zlen = COM.ZNONCE.getEndPos() catch unreachable;


    const rcvnonce = std.posix.mmap(
        null,
        zlen,
        std.posix.PROT.READ | std.posix.PROT.WRITE,
        .{.TYPE =.SHARED_VALIDATE} ,
        COM.ZNONCE.handle,
        0
     ) catch return errmap.violation_integrite_rcvnonce_fileNONCE;
        
    defer std.posix.munmap(rcvnonce);

    for ( 0.. COM.nonce.len - 1) |x| { COM.nonce[x]= 0; }
    var itb = std.mem.splitScalar(u8, rcvnonce[0..zlen], '|');
    i = 0;
    while (itb.next()) |chunk| :( i += 1) {
        COM.nonce[i] = std.fmt.parseInt(u8,chunk,10) catch unreachable;
    }



//--------------------------
// recover TAG
//--------------------------


    zlen = COM.ZTAG.getEndPos() catch unreachable;


    const rcvtag = std.posix.mmap(
        null,
        zlen,
        std.posix.PROT.READ | std.posix.PROT.WRITE,
        .{.TYPE =.SHARED_VALIDATE} ,
        COM.ZTAG.handle,
        0
    ) catch return errmap.violation_integrite_rcvtag_fileTAG;
      
    defer std.posix.munmap(rcvtag);

    for ( 0.. COM.tag.len - 1) |x| { COM.tag[x]= 0; }
    var itc = std.mem.splitScalar(u8, rcvtag[0..zlen], '|');
    i = 0;
    while (itc.next()) |chunk| :( i += 1) {
        COM.tag[i] = std.fmt.parseInt(u8,chunk,10) catch unreachable;
    }

//-------------------------------------------
// cleaner 
//-------------------------------------------
        COM.ZKEY.close();
        cDIR.deleteFile(COM.fileKEY) catch unreachable;

        COM.ZNONCE.close();       
        cDIR.deleteFile(COM.fileNONCE) catch unreachable;

        initLDA();

return LDA;
}





//-------------------------------------------
pub fn  writeLDA( vLDA:*COMLDA) !void {
    
//--------------------------------------------------------
// reply = true  return message
// reply = false return not found answer 
// abort = true  caller exit not reply 
//--------------------------------------------------------
   
    ztext = undefined;
    ztext = std.fmt.allocPrint(allocZmmap,
        "{}|{}|{s}|{s}|{s}"
        ,.{
            vLDA.reply,
            vLDA.abort,
            vLDA.user,
            vLDA.init,
            vLDA.echo,
        }) catch |err| { Perror(std.fmt.allocPrint(allocZmmap,"{}",.{err}) catch unreachable);  return err; };
           defer allocZmmap.free(ztext);
           
    COM.ZLCI.setEndPos(ztext.len) catch unreachable;
    
    const  sendlci = std.posix.mmap(
        null,
        ztext.len,
        std.posix.PROT.READ | std.posix.PROT.WRITE,
        .{.TYPE =.SHARED_VALIDATE} ,
        COM.ZLCI.handle,
        0
    ) catch return errmap.violation_integrite_sendlog_fileLCI;
    defer std.posix.munmap(sendlci);

    // Write file via mmap
    std.mem.copyForwards(u8, sendlci,ztext);

    // -------------------------------------------------
    
    // crypt
    for ( 0.. COM.tag.len - 1) |x| { COM.tag[x]= 0; }
    cipher = undefined;
    cipher = std.mem.Allocator.alloc(allocZmmap,u8,vLDA.zuds.len) catch unreachable;
    Aes256Gcm.encrypt(cipher, &COM.tag, vLDA.zuds, COM.nonce, COM.key);
    defer allocZmmap.free(cipher);
    // -------------------------------------------------

    COM.ZUDS.setEndPos(cipher.len) catch unreachable;
    const  senduds = std.posix.mmap(
        null,
        cipher.len,
        std.posix.PROT.READ | std.posix.PROT.WRITE,
        .{.TYPE =.SHARED_VALIDATE} ,
        COM.ZUDS.handle,
        0
    ) catch return errmap.violation_integrite_senduds_fileUDS;
    defer std.posix.munmap(senduds);

    // Write file via mmap
    std.mem.copyForwards(u8, senduds,cipher);

    try writeTAG();
}

//-------------------------------------------
//  Read LDA 
//-------------------------------------------
pub fn readLDA() !COMLDA {

    var zlen :usize =  COM.ZLCI.getEndPos() catch unreachable;
    const  rcvcli = std.posix.mmap(
        null,
        zlen ,
        std.posix.PROT.READ,
        .{.TYPE =.SHARED_VALIDATE} ,
        COM.ZLCI.handle,
        0
    ) catch return errmap.violation_integrite_rcvlog_fileLCI;
      defer  std.posix.munmap(rcvcli);
 
    var it = std.mem.splitScalar(u8, rcvcli, '|');
    var i: usize = 0;

    while (it.next()) |chunk| :( i += 1) {
        switch(i) {
            0 =>{
                if (std.mem.eql(u8,chunk, "true")) LDA.reply = true
                else  LDA.reply = false;
            },
            1 =>{
                if (std.mem.eql(u8,chunk, "true")) LDA.abort = true
                else  LDA.abort = false;
            },
            2  => LDA.user = std.fmt.allocPrint(allocZmmap,"{s}",.{chunk}) catch unreachable,
            3  => LDA.init = std.fmt.allocPrint(allocZmmap,"{s}",.{chunk}) catch unreachable,
            4  => LDA.echo = std.fmt.allocPrint(allocZmmap,"{s}",.{chunk}) catch unreachable,
            else => continue,
        }
    }
    
//--------------------------
// read data
//--------------------------
    zlen =  COM.ZUDS.getEndPos() catch unreachable;
    const  rcvuds = std.posix.mmap(
        null,
        zlen ,
        std.posix.PROT.READ ,
        .{.TYPE =.SHARED_VALIDATE} ,
        COM.ZUDS.handle,
        0
    ) catch return errmap.violation_integrite_rcvuds_fileUDS;
    defer  std.posix.munmap(rcvuds);

    try readTAG();
 
    zlen = rcvuds.len;
    decipher = undefined;
    decipher = std.mem.Allocator.alloc(allocZmmap,u8,zlen) catch unreachable;
    defer allocZmmap.free(decipher);
    
    Aes256Gcm.decrypt(rcvuds, COM.tag, decipher, COM.nonce, COM.key) 
        catch |err| { Perror(std.fmt.allocPrint(allocZmmap,"{}",.{err}) catch unreachable);  return err; };

    LDA.zuds = undefined;
    LDA.zuds = std.fmt.allocPrint(allocZmmap,"{s}",.{decipher[0..zlen]}) catch unreachable;


    return LDA;
}

pub fn unlock() void {
    
    COM.ZPWR.seekTo(0) catch unreachable;
    _=COM.ZPWR.write("N") catch unreachable;
}


pub fn lock() void {
    COM.ZPWR.seekTo(0) catch unreachable;
    _=COM.ZPWR.write("Y") catch unreachable;
 }

pub fn islock() bool {
    var buffer :[]u8 = allocZmmap.alloc( u8, 16) catch unreachable;
    defer allocZmmap.free(buffer);

    COM.ZPWR.seekTo(0) catch unreachable;
    _= COM.ZPWR.read(buffer[0..]) catch unreachable;
    return std.mem.eql(u8, "Y", buffer[0..1]);
 }
