const std = @import("std");


const dds = @import("dds");

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
// menu
const mnu = @import("forms").mnu;
// flied
const fld = @import("forms").fld;
// line horizontal
const lnh = @import("forms").lnh;
// line vertival
const lnv = @import("forms").lnv;


// grid
const grd = @import("grid").grd;

// tools utility
const utl = @import("utils");

// tools regex
const reg = @import("match");

// Descrption PANEL
const mdlPanel = @import("mdlPanel");

// Descrption Objet
const mdlObjet = @import("mdlObjet");

// sauvegarde JSON
const mdlFile = @import("mdlFile");


const allocator = std.heap.page_allocator;

var NPANEL = std.ArrayList(pnl.PANEL).init(allocator);


//================================
// defined var global



var nopt : usize	= 0;


const choix = enum {
	panel,
	objet,
	sjson,
	rjson,
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
					dds.CADRE.line1,
					"") ;
	//-------------------------------------------------
	//the menu is not double buffered it is not a Panel

	base.menu.append(mnu.newMenu(
					"Screen",				 // name
					2, 2,					 // posx, posy	
					dds.CADRE.line1,		// type line fram
					dds.MNUVH.vertical,	 // type menu vertical / horizontal
					&.{
					"Panel..",				// item
					"Objet..",
					"SavJson.",
					"RstJson",
					"Exit...",
					}
					)) catch unreachable ;

	const	menu = enum (u8)	{

	Screen = 0 ,	// creat panel, objet	, source , exit
	};



	while (true) {

	pnl.printPanel(base);
	nopt = mnu.ioMenu(base,base.menu.items[@intFromEnum(menu.Screen)],0);

	if (nopt == @intFromEnum(choix.exit )) { break; }

	if (nopt == @intFromEnum(choix.panel)) mdlPanel.fnPanel(&NPANEL) ;
	if (nopt == @intFromEnum(choix.objet)) mdlObjet.fnPanel(&NPANEL) ;
	if (nopt == @intFromEnum(choix.sjson)) try mdlFile.wrkJson(&NPANEL,true) ;
	if (nopt == @intFromEnum(choix.rjson)) try mdlFile.wrkJson(&NPANEL,false) ;

	if (NPANEL.items.len == 0 ) dds.deinitStr();


	
	}
	term.disableRawMode();
}
