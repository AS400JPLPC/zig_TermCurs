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
const deb_Log = @import("logger").openFile;   // open  file
const end_Log = @import("logger").closeFile;  // close file
const pref	  = @import("logger").scoped;     // print file 

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
		field: []const u8,
		index: usize,
		func:  []const u8,
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
					"outSrc",
					"clear *all",
					"Exit...",
					}
					) ;

		pnl.printPanel(base);
	while (true) {

		// pnl.printPanel(base);
		term.deinitTerm();
		utl.deinitUtl();


		nopt = mnu.ioMenu(MenuPrincipal,0);

		if (nopt == @intFromEnum(choix.exit )) { break; }
		if (nopt == @intFromEnum(choix.dspf)) { 
			try mdlFile.wrkJson(&NPANEL, &NGRID, &NMENU, false) ;// use mdlRjson  
			if (NPANEL.items.len > 0) {
				for( NPANEL.items,0..) | p , i | {
					NOBJET.append(DEFOBJET {.name = p.name,.index = i, .objtype = OBJTYPE.PANEL}) catch unreachable;
					for( p.field.items,0..) | f , x | {
					NJOB.append(DEFJOB {.panel = p.name, .field = f.name, .index = x,
					.func = f.procfunc , .task = f.proctask , .call =f.typecall}) catch unreachable;

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
			controlRef(NOBJET, NJOB) ;
			
		}
		
	
	}
	term.disableRawMode();
}

fn controlRef(xobjet: std.ArrayList(DEFOBJET), xjob: std.ArrayList(DEFJOB)) void {

deb_Log("ref_01.txt");

pref(.main).info("OBJET\n", .{});

	for( xobjet.items) | m | {
		pref(.NOBJET).info("Name {s} \t Index {d} \t  type {}\n", .{m.name , m.index , m.objtype});
	}
pref(.main).info("FIELD\n", .{});

for( xobjet.items) |m | {
	pref(.NOBJET).info("Name {s} \t Index {d} \t  type {}\n", .{m.name , m.index , m.objtype});
	for( xjob.items) | f | {
		if (std.mem.eql(u8 ,m.name, f.panel)) { 
			if ( ! std.mem.eql(u8 ,f.func ,"") or ! std.mem.eql(u8 ,f.task ,"") or ! std.mem.eql(u8 ,f.call ,""))
			pref(.NJOB).info("Name: {s} \t0 field: {s}  \t Index: {d} \t func: {s} \t task: {s} \t call: {s} \t \n", 
			  .{f.panel , f.field , f.index , f.func , f.task, f.call});
		}
	}	
}
end_Log();
}
