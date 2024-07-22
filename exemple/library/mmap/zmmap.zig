	///-----------------------
	/// gestion file mmap
	/// emulation *LDA IBM
	/// zig 0.12.0 dev
	///-----------------------

const std = @import("std");
const cry = @import("crypto");



const fs = std.fs;

const allocZmmap = std.heap.page_allocator;
//-----------------------
// crypto
//-----------------------
pub const Aes256Gcm = cry.AesGcm(std.crypto.core.aes.Aes256);

// key and nonce crypto
// var key:   [Aes256Gcm.key_length]u8   = undefined; // len 32
// var nonce: [Aes256Gcm.nonce_length]u8 = undefined; // len 12 
// var tag:   [Aes256Gcm.tag_length]u8   = undefined; // len 16
var dta:   []const u8 = undefined; // data crypter 
var cipher: []u8 = undefined;
var decipher: []u8 = undefined;

//-----------------------
var mmapOK : bool = false;
var echoOK : bool = false;

const dirfile = "./qtemp";

var cDIR = std.fs.cwd();

// name seq = times
var	parmTimes: [] const u8 = undefined;

var ztext  : [:0]u8 = undefined ;
var	zcrpt  : [:0]u8 = undefined ;


//==================================================
const ZMMAP = struct {
	fileKEY   : []const u8 ,
	fileNONCE : []const u8 ,
	fileTAG   : []const u8 ,
	fileUDS   : []const u8 ,
	fileLOG   : []const u8 ,
	ZKEY   :fs.File ,
	ZNONCE :fs.File ,
	ZTAG   :fs.File ,
	ZUDS   :fs.File ,
	ZLOG   :fs.File ,
	
	key:   [Aes256Gcm.key_length]u8		, // len 32
	nonce: [Aes256Gcm.nonce_length]u8	, // len 12 
	tag:   [Aes256Gcm.tag_length]u8		, // len 16
};


var COM : ZMMAP = undefined ;
var SAVCOM : ZMMAP = undefined;
var	sav_parmTimes: [] const u8 = undefined;
var sav_mmapOK : bool = false ;
var sav_echoOK : bool = false ;

pub fn savEnvMmap() void  {

	SAVCOM = COM ;
	sav_mmapOK = mmapOK;
	sav_echoOK = echoOK;
	sav_parmTimes = parmTimes;

	COM = undefined ;
	mmapOK = false;
	echoOK = false;
}

pub fn rstEnvMmap() void  {

	released();

	COM = SAVCOM ;
	mmapOK = sav_mmapOK;
	echoOK = sav_echoOK;
	parmTimes = sav_parmTimes ;
	

	SAVCOM = undefined ;
	sav_mmapOK = false;
	sav_echoOK = false;
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
		.echo = undefined ,
		 // alpha numeric
		.zuds = undefined , 
		};
	LDA.user = std.posix.getenv("USER") orelse "INITLDA";
}


//-------------------------------------------
// create communication  this file MAP
//-------------------------------------------
fn setNameFile() void {
	COM.fileKEY	   = std.fmt.allocPrintZ(allocZmmap,"KEY{s}"   ,.{parmTimes})  catch unreachable;
	COM.fileNONCE  = std.fmt.allocPrintZ(allocZmmap,"NONCE{s}" ,.{parmTimes})  catch unreachable;
	COM.fileTAG    = std.fmt.allocPrintZ(allocZmmap,"TAG{s}"   ,.{parmTimes})  catch unreachable;
	COM.fileUDS	   = std.fmt.allocPrintZ(allocZmmap,"UDS{s}"   ,.{parmTimes})  catch unreachable;
	COM.fileLOG	   = std.fmt.allocPrintZ(allocZmmap,"LOG{s}"   ,.{parmTimes})  catch unreachable;
}

fn creatFileMMAP() void {


	const timesStamp_ms: u64 = @bitCast(std.time.milliTimestamp());

	parmTimes = std.fmt.allocPrintZ(allocZmmap,"{d}" ,.{std.fmt.fmtIntSizeDec(timesStamp_ms)})  catch unreachable;


 
	setNameFile();

	cDIR = std.fs.cwd().openDir(dirfile,.{}) catch unreachable;

	COM.ZKEY = cDIR.createFile(COM.fileKEY , .{ .read = true, .truncate =true , .exclusive = false}) catch |e|
				@panic(std.fmt.allocPrint(allocZmmap,"err isFile Open CREAT FILEKEY  .{any}\n", .{e})
				catch unreachable);
	// ZKEY.close();


	COM.ZNONCE = cDIR.createFile(COM.fileNONCE , .{ .read = true, .truncate =true , .exclusive = false}) catch |e|
				@panic(std.fmt.allocPrint(allocZmmap,"err isFile Open CREAT FILENONCE .{any}\n", .{e})
				catch unreachable);
	// ZNONCE.close();


	COM.ZTAG = cDIR.createFile(COM.fileTAG , .{ .read = true, .truncate =true , .exclusive = false}) catch |e|
				@panic(std.fmt.allocPrint(allocZmmap,"err isFile Open CREAT FILETAG .{any}\n", .{e})
				catch unreachable);
	// ZTAG.close();


	COM.ZUDS = cDIR.createFile(COM.fileUDS , .{ .read = true, .truncate =true , .exclusive = false}) catch |e|
				@panic(std.fmt.allocPrint(allocZmmap,"err isFile Open CREAT FILEUDS .{any}\n", .{e})
				catch unreachable);
	// ZUDS.close();


	COM.ZLOG = cDIR.createFile(COM.fileLOG , .{ .read = true, .truncate =true , .exclusive = false}) catch |e|
				@panic(std.fmt.allocPrint(allocZmmap,"err isFile Open CREAT FILELOG .{any}\n", .{e})
				catch unreachable);
	// ZLOG.close();
}

fn setOpenFile() void {


	setNameFile();

	cDIR = std.fs.cwd().openDir(dirfile,.{}) catch unreachable;


	COM.ZKEY = cDIR.openFile(COM.fileKEY , .{.mode=.read_write}) catch |e| {
		 @panic(std.fmt.allocPrint(allocZmmap,"\n{any} mmap fileKEY error open   {s}\n",.{e,COM.fileKEY })
			catch unreachable);
	};	


	COM.ZNONCE = cDIR.openFile(COM.fileNONCE , .{.mode=.read_write}) catch |e| {
		 @panic(std.fmt.allocPrint(allocZmmap,"\n{any} mmap fileNONCE error open   {s}\n",.{e,COM.fileNONCE })
			catch unreachable);
	};	


	COM.ZTAG = cDIR.openFile(COM.fileTAG , .{.mode=.read_write}) catch |e| {
		 @panic(std.fmt.allocPrint(allocZmmap,"\n{any} mmap fileTAG error open   {s}\n",.{e,COM.fileTAG })
			catch unreachable);
	};


	COM.ZUDS = cDIR.openFile(COM.fileUDS , .{.mode=.read_write}) catch |e| {
		 @panic(std.fmt.allocPrint(allocZmmap,"\n{any} mmap fileUDS error open   {s}\n",.{e,COM.fileUDS })
			catch unreachable);
	};


	COM.ZLOG = cDIR.openFile(COM.fileLOG , .{.mode=.read_write}) catch |e| {
		 @panic(std.fmt.allocPrint(allocZmmap,"\n{any} mmap fileLOG error open   {s}\n",.{e,COM.fileLOG })
			catch unreachable);
	};
}




//--------------------------
// READ TAsG
//--------------------------
fn readTAG() void {

	var zlen :usize =  COM.ZTAG.getEndPos() catch unreachable;


	const  rcvtag = std.posix.mmap(
		null,
		@sizeOf(u8) * zlen ,
		std.posix.PROT.READ | std.posix.PROT.WRITE,
		.{.TYPE =.SHARED_VALIDATE} ,
		COM.ZTAG.handle,
		0
	) catch @panic(" violation intégrité readTAG rcvtag ") ;  // si pblm violation intégrité
	defer std.posix.munmap(rcvtag);

	var ztag: [:0]u8 = undefined ;
	ztag = std.fmt.allocPrintZ(allocZmmap,"{s}",.{rcvtag}) catch unreachable;
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
   
fn writeTAG() void {

	const ztag :[:0]u8 = std.fmt.allocPrintZ(allocZmmap,
		"{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}|{d}"
		,.{
			COM.tag[0],COM.tag[1],COM.tag[2],COM.tag[3],COM.tag[4],
			COM.tag[5],COM.tag[6],COM.tag[7],COM.tag[8],COM.tag[9],
			COM.tag[10],COM.tag[11],COM.tag[12],COM.tag[13],COM.tag[14],COM.tag[15],
		}) catch unreachable;
	defer allocZmmap.free(ztag);

	COM.ZTAG.setEndPos(ztag.len) catch unreachable;
	
	const  sendtag = std.posix.mmap(
		null,
		@sizeOf(u8) * ztag.len,
		std.posix.PROT.READ | std.posix.PROT.WRITE,
		.{.TYPE =.SHARED_VALIDATE} ,
		COM.ZTAG.handle,
		0
	) catch @panic(" violation intégrité zmmap writeTAG") ;  // si pblm violation intégrité
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
// isFile
//-------------------------------------------
fn isFile(name: []const u8 ) bool {

	
	var file = cDIR.createFile(name, .{ .read = true }) catch |e|
		switch (e) {
			error.PathAlreadyExists => return true,
			else =>return false,
		};

	defer file.close();
	
	return true;
}

//-------------------------------------------
//restore base null
//-------------------------------------------
// released acces initMmap for new communication
pub fn released() void { 
	if (mmapOK == false) return;


		COM.ZKEY.close();
		if ( isFile(COM.fileKEY) ) cDIR.deleteFile(COM.fileKEY) catch unreachable;
		
		COM.ZNONCE.close();	   
		if ( isFile(COM.fileNONCE) ) cDIR.deleteFile(COM.fileNONCE) catch unreachable;
		
		COM.ZTAG.close();
		cDIR.deleteFile(COM.fileTAG) catch unreachable;

		COM.ZLOG.close();
		cDIR.deleteFile(COM.fileLOG) catch unreachable;

		COM.ZUDS.close();
		cDIR.deleteFile(COM.fileUDS) catch unreachable;

	initLDA();
	mmapOK = false;
	echoOK = false;

}

//===========================================================================


//-------------------------------------------
// init Maitre
//-------------------------------------------
pub fn masterMmap() ! COMLDA {


	if (mmapOK == true ) @panic(std.fmt.allocPrintZ(allocZmmap,"process already initalized",.{}) catch unreachable);

	COM = undefined ;
	creatFileMMAP();
	
	//----------------------------
	// KEY
	//----------------------------



	for ( 0.. COM.key.len - 1) |x| { COM.key[x]= 0; }
	std.crypto.random.bytes(&COM.key);


	 const zkey :[:0]u8 = std.fmt.allocPrintZ(allocZmmap,
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
		@sizeOf(u8) * zkey.len,
		std.posix.PROT.READ | std.posix.PROT.WRITE,
		.{.TYPE =.SHARED_VALIDATE} ,
		COM.ZKEY.handle,
		0
	) catch @panic(" violation intégrité initMAP fileKEY") ; 
	defer std.posix.munmap(sendkey);

	std.mem.copyForwards(u8, sendkey,zkey);


//----------------------------
// NONCE
//---------------------------- 
	for ( 0.. COM.nonce.len - 1) |x| { COM.nonce[x]= 0; }
	std.crypto.random.bytes(&COM.nonce);


	const znonce :[:0]u8 = std.fmt.allocPrintZ(allocZmmap,
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
		@sizeOf(u8) * znonce.len,
		std.posix.PROT.READ | std.posix.PROT.WRITE,
		.{.TYPE =.SHARED_VALIDATE} ,
		COM.ZNONCE.handle,
		0
	) catch @panic(" violation intégrité initMAP fileNONCE") ;
	defer std.posix.munmap(sendnonce);

	std.mem.copyForwards(u8, sendnonce,znonce);


//----------------------------
// TAG
//---------------------------- 

	for ( 0.. COM.tag.len - 1) |x| { COM.tag[x]= 0; }
	const ztag :[:0]u8 = std.fmt.allocPrintZ(allocZmmap,
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
		@sizeOf(u8) * ztag.len,
		std.posix.PROT.READ | std.posix.PROT.WRITE,
		.{.TYPE =.SHARED_VALIDATE} ,
		COM.ZTAG.handle,
		0
	)  catch @panic(" violation intégrité initMAP fileTAG") ;
	defer std.posix.munmap(sendtag);
	
	std.mem.copyForwards(u8, sendtag,ztag);




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
	if (mmapOK == true ) @panic(std.fmt.allocPrintZ(allocZmmap,"process already initalized",.{}) catch unreachable);
	if (echoOK == true ) @panic(std.fmt.allocPrintZ(allocZmmap,"process already initalized",.{}) catch unreachable);

	parmTimes = std.fmt.allocPrintZ(allocZmmap,"{s}" ,.{timesParm})  catch unreachable;
	
	COM = undefined ;
	
	setOpenFile();


//--------------------------
// recover KEY
//--------------------------

	var zlen :usize =  COM.ZKEY.getEndPos() catch unreachable;
 
	const rcvkey = std.posix.mmap(
		null,
		@sizeOf(u8) * zlen,
		std.posix.PROT.READ | std.posix.PROT.WRITE,
		.{.TYPE =.SHARED_VALIDATE} ,
		COM.ZKEY.handle,
		0
	) catch @panic(" violation intégrité echoMAP fileKEY") ;  
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
		@sizeOf(u8) * zlen,
		std.posix.PROT.READ | std.posix.PROT.WRITE,
		.{.TYPE =.SHARED_VALIDATE} ,
		COM.ZNONCE.handle,
		0
	) catch @panic(" violation intégrité echoMAP fileZNONCE") ;
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
		@sizeOf(u8) * zlen,
		std.posix.PROT.READ | std.posix.PROT.WRITE,
		.{.TYPE =.SHARED_VALIDATE} ,
		COM.ZTAG.handle,
		0
	) catch @panic(" violation intégrité echoMAP fileZNONCE") ;
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
	mmapOK = true;
	echoOK = true;
	return LDA;
}






//-------------------------------------------
pub fn  writeLDA( vLDA:*COMLDA) void {
	if (mmapOK == false) @panic(std.fmt.allocPrintZ(allocZmmap,"process not initalized",.{}) catch unreachable);

//--------------------------------------------------------
// reply = true  return message
// reply = false return not found answer 
// abort = true  caller exit not reply 
//--------------------------------------------------------

	
	ztext = undefined;
	ztext = std.fmt.allocPrintZ(allocZmmap,
		"{}|{}|{s}|{s}|{s}"
		,.{
			vLDA.reply,
			vLDA.abort,
			vLDA.user,
			vLDA.init,
			vLDA.echo,
		}) catch |err| @panic(std.fmt.allocPrintZ(allocZmmap,"{}",.{err}) catch unreachable);
	defer allocZmmap.free(ztext);


	COM.ZLOG.setEndPos(ztext.len) catch unreachable;

	const  sendlog = std.posix.mmap(
		null,
		@sizeOf(u8) * ztext.len,
		std.posix.PROT.READ | std.posix.PROT.WRITE,
		.{.TYPE =.SHARED_VALIDATE} ,
		COM.ZLOG.handle,
		0
	) catch |err| @panic(std.fmt.allocPrintZ(allocZmmap,"{}",.{err}) catch unreachable);

	defer std.posix.munmap(sendlog);

	// Write file via mmap
	std.mem.copyForwards(u8, sendlog,ztext);

	// -------------------------------------------------
	
	// crypt
	for ( 0.. COM.tag.len - 1) |x| { COM.tag[x]= 0; }
	cipher = undefined;
	cipher = std.mem.Allocator.alloc(allocZmmap,u8,vLDA.zuds.len) catch unreachable;
	Aes256Gcm.encrypt(cipher, &COM.tag, vLDA.zuds, COM.nonce, COM.key);
	defer allocZmmap.free(cipher);
	

	COM.ZUDS.setEndPos(cipher.len) catch unreachable;

	const  senduds = std.posix.mmap(
		null,
		@sizeOf(u8) * cipher.len,
		std.posix.PROT.READ | std.posix.PROT.WRITE,
		.{.TYPE =.SHARED_VALIDATE} ,
		COM.ZUDS.handle,
		0
	) catch |err| @panic(std.fmt.allocPrintZ(allocZmmap,"{}",.{err}) catch unreachable);

	defer std.posix.munmap(senduds);

	// Write file via mmap
	std.mem.copyForwards(u8, senduds,cipher);

	writeTAG();
}

//-------------------------------------------
//  Read LDA 
//-------------------------------------------
pub fn readLDA() COMLDA {
	if (mmapOK == false) @panic(std.fmt.allocPrintZ(allocZmmap,"process not initalised",.{}) catch unreachable);

	var zlen :usize =  COM.ZLOG.getEndPos() catch unreachable;


	const  rcvlog = std.posix.mmap(
		null,
		@sizeOf(u8) * zlen ,
		std.posix.PROT.READ | std.posix.PROT.WRITE,
		.{.TYPE =.SHARED_VALIDATE} ,
		COM.ZLOG.handle,
		0
	) catch |err| @panic(std.fmt.allocPrintZ(allocZmmap,"{}",.{err}) catch unreachable);
	defer  std.posix.munmap(rcvlog);


	var it = std.mem.splitScalar(u8, rcvlog, '|');
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
			2  => LDA.user = std.fmt.allocPrintZ(allocZmmap,"{s}",.{chunk}) catch unreachable,
			3  => LDA.init = std.fmt.allocPrintZ(allocZmmap,"{s}",.{chunk}) catch unreachable,
			4  => LDA.echo = std.fmt.allocPrintZ(allocZmmap,"{s}",.{chunk}) catch unreachable,
			else => continue,
		}
	}
	
//--------------------------
// read data
//--------------------------
  
	zlen  =  COM.ZUDS.getEndPos() catch unreachable;


	const  rcvuds = std.posix.mmap(
		null,
		@sizeOf(u8) * zlen ,
		std.posix.PROT.READ | std.posix.PROT.WRITE,
		.{.TYPE =.SHARED_VALIDATE} ,
		COM.ZUDS.handle,
		0
	) catch |err| @panic(std.fmt.allocPrintZ(allocZmmap,"{}",.{err}) catch unreachable);
	defer  std.posix.munmap(rcvuds);


	readTAG();
	zlen = rcvuds.len;
	decipher = undefined;
	decipher = std.mem.Allocator.alloc(allocZmmap,u8,zlen) catch unreachable;
	defer allocZmmap.free(decipher);
	
	Aes256Gcm.decrypt(rcvuds, COM.tag, decipher, COM.nonce, COM.key) 
		catch |err| @panic(std.fmt.allocPrintZ(allocZmmap,"{}",.{err}) catch unreachable);

	LDA.zuds = undefined;
	LDA.zuds = std.fmt.allocPrint(allocZmmap,"{s}",.{decipher[0..zlen]}) catch unreachable;

	return LDA;
}

