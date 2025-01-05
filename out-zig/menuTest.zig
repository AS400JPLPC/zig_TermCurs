//----------------------
//---date text----------
//----------------------



const std = @import("std");
// terminal Fonction
const term = @import("cursed");

// menu Fonction
const mnu = @import("menu").mnu;

const allocator = std.heap.page_allocator;
var NMENU  = std.ArrayList(mnu.DEFMENU ).init(allocator);



//----------------------
// Define Global DSPF MENU
//----------------------
const xmnu01 = enum {
            Repertoire,
            Table,
            Logique,
            Join,
            Exit,
            };

const mnu01 = mnu.newMenu(
            "mnu01",
            12, 43,
            mnu.CADRE.line1,
            mnu.MNUVH.horizontal,
            &.{
            "Repertoire",
            "Table",
            "Logique",
            "Join",
            "Exit",
            }
            );



//----------------------
// Define Global DSPF MENU
//----------------------
const xmnurep = enum {
            Work,
            List,
            Exit,
            };

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

var nopt : usize = 0;
    while (true) {
    nopt = mnu.ioMenu(mnu01,nopt);
        if (nopt == @intFromEnum(xmnu01.Exit )) break;

        //--- ---

        }

}

