	///-----------------------
	/// prog Gencurs 
	/// zig 0.12.0 dev
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
const reg = @import("match");

// Description PANEL
const mdlPanel = @import("mdlPanel");

// Description FORMULAIRE
const mdlForms = @import("mdlForms");

// Description GRID
const mdlGrids = @import("mdlGrids");

// sauvegarde JSON
const mdlFile = @import("mdlFile");


const allocator = std.heap.page_allocator;

var NPANEL = std.ArrayList(pnl.PANEL).init(allocator);
var NGRID  = std.ArrayList(grd.GRID ).init(allocator);

//================================
// defined var global



var nopt : usize	= 0;


const choix = enum {
	panel,
	forms,
	grid,
	menu,
	sjson,
	rjson,
	clean,
	exit
};


// main----------------------------------

pub fn main() !void {
	//term.offscrool();
	// open terminal and config and offMouse , cursHide->(cursor hide)
	term.enableRawMode();
	defer term.disableRawMode() ;

	// Initialisation
	term.titleTerm("DESIGNER");


	//term.resizeTerm(52,172);
	const termSize = term.getSize();


	fld.MouseDsp = true ; // active display cursor x/y mouse

	var base : *pnl.PANEL = pnl.newPanelC("base",
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
					"Panel..",
					"Forms..",
					"Grid...",
					"Menu...",
					"SavJson.",
					"RstJson",
					"Testclean",
					"Exit...",
					}
					) ;


	while (true) {

	pnl.printPanel(base);
	term.deinitTerm();
	grd.deinitGrid();
	utl.deinitUtl();


	nopt = mnu.ioMenu(MenuPrincipal,0);

	if (nopt == @intFromEnum(choix.exit )) { break; }

	if (nopt == @intFromEnum(choix.panel)) mdlPanel.fnPanel(&NPANEL) ;
	if (nopt == @intFromEnum(choix.forms)) mdlForms.fnPanel(&NPANEL) ;
	// if (nopt == @intFromEnum(choix.grid))  mdlGrids.fnPanel(&NPANEL, &NGRID) ;
	// if (nopt == @intFromEnum(choix.menu))  mdlMenus.fnPanel(&NPANEL, &NMENU) ;
	if (nopt == @intFromEnum(choix.sjson)) try mdlFile.wrkJson(&NPANEL,true) ;
	if (nopt == @intFromEnum(choix.rjson)) try mdlFile.wrkJson(&NPANEL,false) ;
	// simulation for test clean allocator
	if (nopt == @intFromEnum(choix.clean)) {
		pnl.freePanel(base);

		term.deinitTerm();
		grd.deinitGrid();
		utl.deinitUtl();
		forms.deinitForms();

		if (NPANEL.items.len > 0) {
		NPANEL.clearAndFree();
		NPANEL.deinit();
		}
		if (NGRID.items.len > 0) {
		NGRID.clearAndFree();
		NGRID.deinit();
		}
		base = pnl.newPanelC("base",
					1, 1,
					termSize.height,
					termSize.width ,
					forms.CADRE.line1,
					"") ;

	}
	
	}
	term.disableRawMode();
}
