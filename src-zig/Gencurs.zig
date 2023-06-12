const std = @import("std");

const dds = @import("deps/curse/dds.zig");

// terminal Fonction
const term = @import("deps/curse/cursed.zig");
// keyboard
const kbd = @import("deps/curse/cursed.zig").kbd;

// error
const dsperr = @import("deps/curse/forms.zig").dsperr;
// frame
const frm = @import("deps/curse/forms.zig").frm;
// panel
const pnl = @import("deps/curse/forms.zig").pnl;
// button
const btn = @import("deps/curse/forms.zig").btn;
// label
const lbl = @import("deps/curse/forms.zig").lbl;
// menu
const mnu = @import("deps/curse/forms.zig").mnu;
// grid
const grd = @import("deps/curse/forms.zig").grd;
// flied
const fld = @import("deps/curse/forms.zig").fld;
/// line horizontal
const lnh = @import("deps/curse/forms.zig").lnh;
// line vertival
const lnv = @import("deps/curse/forms.zig").lnv;

// tools utility
const utl = @import("deps/curse/utils.zig");

// tools regex
const reg = @import("deps/curse/match.zig");



 // Descrption PANEL
const mdlPanel = @import("./mdlPanel.zig");

// Descrption Objet
const mdlObjet = @import("./mdlObjet.zig");



const allocator = std.heap.page_allocator;

var NPANEL = std.ArrayList(pnl.PANEL).init(allocator);

//================================
// defined var global


var Tkey : term.Keyboard = undefined ;
var nPnl : usize  = 0;
var nopt : usize  = 0;


const choix = enum {
  panel,
  objet,
  source,
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
  const termSize = term.getSize() catch |err| {dsperr.errorForms(err); return;};


  fld.myMouse = true ; // active display cursor x/y mouse

 var base = pnl.initPanel("base",
                  1, 1,
                  termSize.height,
                  termSize.width ,
                  dds.CADRE.line1,
                  "") ;
    //-------------------------------------------------
  //the menu is not double buffered it is not a Panel

  base.menu.append(mnu.newMenu(
                      "Screen",               // name
                      2, 2,                   // posx, posy  
                      dds.CADRE.line1,        // type line fram
                      dds.MNUVH.vertical,     // type menu vertical / horizontal
                      &.{
                      "Panel..",              // item
                      "Objet..",
                      "Source.",
                      "Exit...",
                      }
                      )) catch unreachable ;

  const  menu = enum (u8)  {

    Screen = 0 ,       // creat panel, objet  , source , exit
  };
  





  while (true) {

    term.cls();
    if (nPnl == 0) {
      pnl.printPanel(&base);
      nopt = mnu.ioMenu(&base,base.menu.items[@enumToInt(menu.Screen)],0);
      term.cls();
      if (nopt == @enumToInt(choix.exit )) { break; }
      if (nopt == @enumToInt(choix.panel)) mdlPanel.fnPanel(&NPANEL) catch unreachable;
      if (nopt == @enumToInt(choix.objet)) mdlObjet.fnPanel(&NPANEL) catch unreachable;
    }
    nPnl = 0;

    //if (Tkey.Key == kbd.F3) break; // end work
  }
term.disableRawMode(); 
}

