//----------------------
//---2024-10-14 dmlSrc zig 0.14 dev
//----------------------

const std = @import("std");

/// terminal Fonction
const term = @import("cursed");

// menu
const mnu = @import("menu").mnu;

const allocator = std.heap.page_allocator;

var NMENU  = std.ArrayList(mnu.DEFMENU ).init(allocator);

//================================
// defined var global DSPF
//----------------------
const xmnu01 = enum {
			Repertoire,
			Table,
			Logique,
			Join,
			Exit,
			};


// menu horizontal spécifiue avec espace 10
var mnu01 = mnu.newMenuH(
			"mnu01",
			12, 43,
			mnu.CADRE.line1,
			10,
			&.{
			"Repertoire",
			"Table",
			"Logique",
			"Join",
			"Exit",
			}
			);


//----------------------
const xmnurep = enum {
			Work,
			List,
			Exit,
			};

// menu standard Vertical ou horizontal
const mnurep = mnu.newMenu(
			"mnurep",
			14, 43,
			mnu.CADRE.line1,
			mnu.MNUVH.vertical,
			&.{
			"Work",
			"List",
			"Exit",
			}
			);
		
//----------------------------------
// squelette
//----------------------------------
pub fn main() !void {

    // init terminal
	term.enableRawMode();
	defer term.disableRawMode() ;

	// Initialisation
	term.titleTerm("MY-TITLE");
	term.resizeTerm(44,168);
	term.cls();
	
	
	var nopt : usize	= 0;
	var ntrt : usize	= 0;
	while (true) {
		nopt = mnu.ioMenu(mnu01,nopt);
		if (nopt == @intFromEnum(xmnu01.Exit )) break;

		if (nopt == @intFromEnum(xmnu01.Repertoire)) {
			ntrt = 0 ;
			while (true) {
				ntrt = mnu.ioMenu(mnurep,ntrt);
				if (ntrt == @intFromEnum(xmnurep.Exit )) {term.cls();break; }
			}
		}
	}	
}

