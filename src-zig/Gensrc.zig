	///-----------------------
	/// prog mdlGrid 
	/// zig 0.13.0 dev
	///-----------------------

const std = @import("std");

/// terminal Fonction
const term = @import("cursed");
// keyboard
const kbd = @import("cursed").kbd;

// error
const dsperr = @import("forms").dsperr;

// full delete for produc
const forms = @import("forms");

// frame
const frm = @import("forms").frm;
// panel
const pnl = @import("forms").pnl;
// button
const btn = @import("forms").btn;
// label
const lbl = @import("forms").lbl;
// flied
const fld = @import("forms").fld;
// line horizontal
const lnh = @import("forms").lnh;
// line vertival
const lnv = @import("forms").lnv;

// grid
const grd = @import("grid").grd;
// menu
const mnu = @import("menu").mnu;

// tools utility
const utl = @import("utils");

// tools regex
const reg = @import("mvzr");


// management JSON
const mdlFile = @import("mdlFile");

// REFERENCE CONTROL
const deb_Log = @import("logsrc").openFile;   // open  file
const del_Log = @import("logsrc").deleteFile; // delete file
const end_Log = @import("logsrc").closeFile;  // close file
const new_Line = @import("logsrc").newLine;   // new line
const pref	  = @import("logsrc").scoped;     // print file 

const allocator = std.heap.page_allocator;


	// PANEL = FORMULAIRE
	// SFLD = GRID 
	// program can display subfile records only by issuing an output operation to the subfile-control record format
	// COMBO = GRID
	// drop-down list of predefined values.
	// MENU = list: behaves like a choice with an index return


	pub const OBJTYPE = enum { PANEL, SFLD ,COMBO , MENU };
	
	pub const DEFOBJET = struct {
		name:  []const u8,
		index: usize,
		objtype: OBJTYPE,
	};
	pub const DEFJOB = struct {
		panel: []const u8,
		key: usize,
		field: []const u8,
		index: usize,
		func:  []const u8,
		fgrid: []const u8,
		task:  []const u8,
		call:  []const u8,
	};

var NOBJET = std.ArrayList(DEFOBJET).init(allocator);
var NJOB   = std.ArrayList(DEFJOB).init(allocator);

var NPANEL = std.ArrayList(pnl.PANEL).init(allocator);
var NGRID  = std.ArrayList(grd.GRID ).init(allocator);
var NMENU  = std.ArrayList(mnu.DEFMENU ).init(allocator);


var numPanel: usize = undefined;
var numGrid : usize = undefined;
var numMenu : usize = undefined;

var nopt : usize	= 0;


const choix = enum {
	dspf,
	list,
	linkcombo,
	output,
	clean,
	exit
};








fn strToUsize(v: []const u8) usize {
	if (v.len == 0) return 0;
	return std.fmt.parseUnsigned(u64, v, 10) catch |err| {
		@panic(@errorName(err));
	};
}

fn usizeToStr(v: usize) []const u8 {
	return std.fmt.allocPrint(utl.allocUtl, "{d}", .{v}) catch |err| {
		@panic(@errorName(err));
	};
}


// main----------------------------------

pub fn main() !void {
	//term.offscrool();
	// open terminal and config and offMouse , cursHide->(cursor hide)
	term.enableRawMode();
	defer term.disableRawMode() ;

	// Initialisation
	term.titleTerm("DESIGNER");


	term.resizeTerm(44,168);
	const termSize = term.getSize();


	fld.MouseDsp = true ; // active display cursor x/y mouse

	const base : *pnl.PANEL = pnl.newPanelC("base",
					1, 1,
					termSize.height,
					termSize.width ,
					forms.CADRE.line1,
					"") ;
	//-------------------------------------------------
	//the menu is not double buffered it is not a Panel

	const MenuPrincipal = mnu.newMenu(
					"Screen",				// name
					2, 2,					// posx, posy
					mnu.CADRE.line1,		// type line fram
					mnu.MNUVH.vertical,		// type menu vertical / horizontal
					&.{
					"Dspf",
					"List",
					"Link-Combo",
					"outSrc",
					"Clear *all",
					"Exit...",
					}
					) ;

		pnl.printPanel(base);
	while (true) {

		pnl.printPanel(base);
		term.deinitTerm();
		utl.deinitUtl();


		nopt = mnu.ioMenu(MenuPrincipal,0);

		if (nopt == @intFromEnum(choix.exit )) { break; }
		if (nopt == @intFromEnum(choix.list ))  controlRef(NOBJET, NJOB) ;
		if (nopt == @intFromEnum(choix.linkcombo ))  linkCombo(base) ;
		if (nopt == @intFromEnum(choix.dspf)) { 
			try mdlFile.wrkJson(&NPANEL, &NGRID, &NMENU, false) ;// use mdlRjson  
			if (NPANEL.items.len > 0) {
				for( NPANEL.items,0..) | p , i | {
					NOBJET.append(DEFOBJET {.name = p.name, .index = i, .objtype = OBJTYPE.PANEL}) catch unreachable;
					
					for( p.field.items,0..) | f , x | {
					NJOB.append(DEFJOB {.panel = p.name, .key = i , .field = f.name, .index = x,
					.func = f.procfunc , .fgrid ="",
					.task = f.proctask , .call =f.typecall}) catch unreachable;

					}
				}
				for( NMENU.items,0..) | m , i | {
					NOBJET.append(DEFOBJET {.name = m.name,.index = i, .objtype = OBJTYPE.MENU}) catch unreachable;
				}
				for( NGRID.items,0..) | m , i | {
					  if (m.name[0] == 'C')
					  	NOBJET.append(DEFOBJET {.name = m.name,.index = i, .objtype = OBJTYPE.COMBO}) catch unreachable
					  else
					  	NOBJET.append(DEFOBJET {.name = m.name,.index = i, .objtype = OBJTYPE.SFLD}) catch unreachable;

				}		
			}
			
		}
		
	
	}
	term.disableRawMode();
}

//---------------------------------
// choix panel
//---------------------------------
pub fn qryCellGrid(vpnl : *pnl.PANEL, vobjet: *std.ArrayList(DEFOBJET )) usize {
	const cellPos: usize = 0;
	var Gkey: grd.GridSelect = undefined;
	const Xcombo: *grd.GRID = grd.newGridC(
		"qryPanel",
		1,
		1,
		10,
		grd.gridStyle,
		grd.CADRE.line1,
	);
	defer Gkey.Buf.deinit();
	defer grd.freeGrid(Xcombo);
	defer grd.allocatorGrid.destroy(Xcombo);

	grd.newCell(Xcombo, "ID", 3, grd.REFTYP.UDIGIT, term.ForegroundColor.fgGreen);
	grd.newCell(Xcombo, "Name", 10, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
	grd.setHeaders(Xcombo);

	for (vobjet.items) |p| {
		if (p.objtype ==  OBJTYPE.PANEL  ){
		grd.addRows(Xcombo, &.{ usizeToStr(p.index), p.name});
		}
	}

	while (true) {
		Gkey = grd.ioCombo(Xcombo, cellPos);

		if (Gkey.Key == kbd.enter) {
			pnl.rstPanel(grd.GRID,Xcombo, vpnl);
			return strToUsize(Gkey.Buf.items[0]);
		}
		
		if (Gkey.Key == kbd.esc) {
			pnl.rstPanel(grd.GRID,Xcombo, vpnl);
			return 999;
		}
	}
}
// order GRID
pub fn linkCombo(vpnl :*pnl.PANEL ) void {
	const numOBJET = qryCellGrid(vpnl, &NOBJET);


	if (numOBJET == 999) return;

	
	var savObjet: std.ArrayList(DEFJOB) = std.ArrayList(DEFJOB).init(utl.allocUtl);

	for (NJOB.items) |p| {
		savObjet.append(p)  
		catch |err| { @panic(@errorName(err)); };
	}

	var Gkey: grd.GridSelect = undefined;
	const Origine: *grd.GRID = grd.newGridC(
		"Origine",
		2,
		2,
		20,
		grd.gridStyle,
		grd.CADRE.line1,
	);
	defer Gkey.Buf.clearAndFree();
	defer grd.freeGrid(Origine);
	defer grd.allocatorGrid.destroy(Origine);


	grd.newCell(Origine, "Key", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgWhite);
	grd.newCell(Origine, "name", 10, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
	grd.newCell(Origine, "field", 3, grd.REFTYP.TEXT_FREE , term.ForegroundColor.fgYellow);
	grd.newCell(Origine, "index", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgGreen);
	grd.newCell(Origine, "Func", 15, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
	grd.newCell(Origine, "COMBO", 15, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
	grd.setHeaders(Origine);

	while (true) {
		grd.resetRows(Origine);
		for (NJOB.items) |g| {
			if (! std.mem.eql(u8, g.func , "")) {
			
				const ridx = usizeToStr(numOBJET);
			

				const index = usizeToStr(g.index) ;
				grd.addRows(Origine, &.{ ridx, g.panel, g.field , index, g.func, g.fgrid });
			}
		}
		Gkey = grd.ioGrid(Origine,false);
		if (Gkey.Key == kbd.esc) break;	
	}

	if (Gkey.Key == kbd.esc) {
		NJOB.clearAndFree();
		NJOB.clearRetainingCapacity();

		for (savObjet.items) |p| {
			NJOB.append(p) 
			 catch |err| { @panic(@errorName(err)); };
		}

		savObjet.clearAndFree();
		savObjet.deinit();
	}
	term.cls();
}

 fn concatStr(a: []const u8, len: usize) []const u8 {
 	var b :[] const u8 = a;
 	while ( b.len < len ) {
		b = std.fmt.allocPrint(	utl.allocUtl,"{s} ",.{ b}) catch unreachable;
	}
	return b;	
}
fn controlRef(xobjet: std.ArrayList(DEFOBJET), xjob: std.ArrayList(DEFJOB)) void {

	del_Log("ref_01.txt");
	deb_Log("ref_01.txt");

	pref(.main).list("OBJET\n", .{});

		for( xobjet.items) | m | {
			pref(.NOBJET).objet("Name {s} \t Index {d} \t  type {}"
				, .{m.name , m.index , m.objtype});
		}

	new_Line();
	
	pref(.main).list("FIELD\n", .{});

	for( xobjet.items) |m | {
		if ( m.objtype == OBJTYPE.PANEL) {
		pref(.NOBJET).objet("Name {s} \t Index {d} \t  type {}"
			, .{m.name , m.index , m.objtype});
		
		for( xjob.items) | f | {
			if (std.mem.eql(u8 ,m.name, f.panel)) { 
				if ( ! std.mem.eql(u8 ,f.func ,"") or ! std.mem.eql(u8 ,f.task ,"") or ! std.mem.eql(u8 ,f.call ,"")){
				
				const field = concatStr(f.field ,15);
				const func  = concatStr(f.func  ,15);
				const fgrid = concatStr(f.fgrid ,15);
				const task  = concatStr(f.task  ,15);
				const call  = concatStr(f.call  ,15);
				pref(.NJOB).detail(
				"Name: {s} \t Key: {d} \t field: {s} \t Index: {d} \t func: {s} \t grid: {s} \t task: {s} \t call: {s}"
				,.{f.panel , f.key , field , f.index , func , fgrid, task, call});
				}
			}
		}

		new_Line();
	
		for( xjob.items) | e | {
			if (std.mem.eql(u8 ,m.name, e.panel)) { 
				if ( ! std.mem.eql(u8 ,e.func ,"") and std.mem.eql(u8 ,e.fgrid,"") ) {
					const field = concatStr(e.field ,15);
					const func  = concatStr(e.func  ,15);
					const fgrid = concatStr(e.fgrid ,15);
					pref(.NJOB).detail(
					"field: {s} \t Index: {d} \t func: {s} \t grid: {s} ERROR not assigned to combo"
					,.{field , e.index , func , fgrid});
				}
			}
		}
		}	
	}
	end_Log();
}

