///-------------------------------
/// FORMS
///-------------------------------
const std = @import("std");
const dds= @import("dds.zig");
const Tkey= @import("cursed.zig").KEY;
const term= @import("cursed.zig");

const os = std.os;
const io = std.io;


const allocator = std.heap.page_allocator;



const TERMINAL_CHAR = struct {
  ch : const u8,
  style : dds.Styled,
  bg : dds.BackgroundColor,
  fg : dds.ForegroundColor,
  on:bool
};



pub fn displayPanel (vpnl: pnl.PANEL) void {
  // display matrice PANEL
  if ( !vpnl.actif ) return ;
  const stdout = io.getStdOut();
  var bufout = std.io.bufferedWriter(stdout.writer());

  for (vpnl.buf.items) |pnlx, x| {
    for (pnlx.items) |pnln, y| {
      term.gotoXY(x + pnln.posx , y + pnln.posy);
      if ( pnln.buf[y].on ) {
        term.setBackgroundColor(pnln.buf[y].bg);
        term.setForegroundColor(pnln.buf[y].fg);
        term.writeStyled(pnln.buf[y].ch,pnln.buf[y].style);
      } else {
        //setStyle(pnl.attribut.styled);
        term.setBackgroundColor(pnln.attribut.backgr);
        term.setForegroundColor(pnln.attribut.foregr);
        term.writeStyled(" ",pnln.attribut.styled);
      }
    }
  }
  try bufout.flush();
}

pub const  btn = struct {

  pub const BUTTON = struct {
    key:Tkey,
    text : dds.text,
    ctrl : dds.ctrl,
    actif : dds.actif
  };

  fn newButton(vkey:Tkey, vtext:dds.text, vctrl:dds.ctrl, vactif:dds.actif) BUTTON {

    const xbutton = BUTTON {
      .key = vkey,
      .text = vtext,
      .ctrl = vctrl,
      .actif = vactif
    };
    return xbutton ;

  }


};

pub const box = struct {

  // define attribut default BORDER
  pub const AtrBorder : dds.ZONATRB = .{
      .styled=[_]i32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgred

  };

  // define attribut default TITLE BORDER
  pub const BorderTitle : dds.ZONATRB = .{
      .styled=[_]i32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.styleBright),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgWhite,
      .foregr = dds.ForegroundColor.fgBlack
  };


  /// BORDER
  pub const BORDER = struct {
    name: dds.name ,
    posx: dds.posx,
    posy: dds.posy ,
    lines: dds.lines,
    cols: dds.cols,
    cadre: dds.CADRE,
    attribut:dds.attribut,
    title:dds.title,
    titleAttibut: dds.attribut,
    actif:dds.actif
    };


  pub fn newBorder(vname:dds.name,
                  vposx:dds.posx, vposy:dds.posy,
                  vlines:dds.lines,
                  vcols:dds.cols,
                  vcadre:dds.CADRE,
                  vattribut:dds.attribut,
                  vtitle:dds.title,
                  vtitleAttibut: dds.attribut,
                  vactif:dds.actif
                  ) BORDER {

        const xborder = BORDER {
            .name = vname,
            .posx = vposx,
            .posy = vposy,
            .lines = vlines,
            .cols = vcols,
            .cadre = vcadre,
            .attribut = vattribut,
            .tilte = vtitle,
            .titleAtribut = vtitleAttibut,
            .actif = vactif
        };
    return xborder;

  }

    pub fn printBorder(vpnl : pnl.PANEL , vbox: BORDER) void {

      const ACS_Hlines  = "_";
      const ACS_Vlines  = "│";
      const ACS_UCLEFT  = "┌";
      const ACS_UCRIGHT = "┐";
      const ACS_LCLEFT  = "└";
      const ACS_LCRIGHT = "┘";

      const ACS_Hline2    = "═";
      const ACS_Vline2    = "║";
      const ACS_UCLEFT2   = "╔";
      const ACS_UCRIGHT2  = "╗";
      const ACS_LCLEFT2   = "╚";
      const ACS_LCRIGHT2  = "╝";

      var trait: []u8 = "";
      var edt :bool   = undefined ;

      var x  = vbox.posx ;
      var row: usize = 1 ;
      var y: usize = 0 ;
      var col: usize = 0 ;
      var npos: usize = 0;
      var n: usize = 0;

      while (row <= vbox.lines) {
        y = vbox.posy;
        col = 1;
        while ( col <= vbox.cols ){
          edt = false;
          if (row == 1) {
              if (col == 1) {
                if ( dds.CADRE.line1 == vbox.cadre ) {
                    trait = ACS_UCLEFT;
                } else  trait = ACS_UCLEFT2 ;
                edt = true;
              }
              if ( col == vbox.cols ) {
                if (dds.CADRE.line1 == vbox.cadre) {
                  trait = ACS_UCRIGHT;
                } else  trait = ACS_UCRIGHT2 ;
                edt = true;
              }
              if ( col > 1 and col < vbox.cols ) {
                if (dds.CADRE.line1 == vbox.cadre ) {
                  trait = ACS_Hlines;
                } else  trait = ACS_Hline2;
                edt = true;
              }
          } else if ( row == vbox.lines ) {
              if (col == 1) {
                if ( dds.CADRE.line1 == vbox.cadre ) {
                  trait = ACS_LCLEFT;
                } else  trait = ACS_LCLEFT2;
                edt = true;
              }
              if ( col == vbox.cols ) {
                if ( dds.CADRE.line1 == vbox.cadre ) {
                  trait = ACS_LCRIGHT;
                } else  trait = ACS_LCRIGHT2 ;
                edt = true ;
              }
              if ( col > 1 and col < vbox.cols ) {
                if ( dds.CADRE.line1 == vbox.cadre ) {
                  trait = ACS_Hlines;
                } else  trait = ACS_Hline2 ;
                edt = true;
              }
          } else if ( row > 1 and row < vbox.lines ) {
            if ( col == 1 or col == vbox.cols ) {
              if ( dds.CADRE.line1 == vbox.cadre ) {
                trait = ACS_Vlines;
              } else trait = ACS_Vline2 ;
              edt = true;
            }
          }
          if  ( edt) {
            npos = vbox.cols * x ;
            n =  npos + y;
            vpnl.buf.append( pnl.buf (
              trait,
              vbox.attribut.styled,
              vbox.attribut.backgr,
              vbox.attribut.foregr,
              true
            ));
          }
          y += 1;
          col += 1;
        }
        x += 1;
        row +=1 ;
      }
      if (vbox.title > "" ) {

        if (vbox.title.len() > vbox.cols - 2 ) return ;

        npos = vbox.cols * vbox.posx ;
        n =  npos + (((vbox.cols - vbox.title.len() ) / 2) + vbox.posy) ;
        for (vbox.title) | ch | {
          vpnl.buf[n].ch  = ch;
          vpnl.buf[n].bg  =  vbox.titlebackgr;
          vpnl.buf[n].fg  =  vbox.titleforegr;
          vpnl.buf[n].style = vbox.titlestyle;
          vpnl.buf[n].on = true;
          n +=1 ;
        }
      }

    }

};




pub const  pnl = struct {

  // define attribut default PANEL
  pub const AtrPanel : dds.ZONATRB = .{
      .styled=[_]i32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgwhite,
  };

  /// define PANEL
  pub const PANEL = struct {
    name: dds.name ,
    posx: dds.posx,
    posy: dds.posy ,

    lines: dds.lines,
    cols: dds.cols,

    attribut:dds.attribut,

    title:dds.title,

    border: box.BORDER ,

    box: std.ArrayList(box.BORDER).init(allocator),

    label: std.ArrayList(lbl.LABEL).init(allocator),

    button: std.ArrayList(btn.BUTTON).init(allocator),

    funcKey:std.ArrayList(Tkey).init(allocator),


    buf:std.ArrayList(TERMINAL_CHAR).init(allocator),

    mouse: bool,

    actif: dds.actif
  };



  pub fn newPanel(vname:dds.name,
                  vposx:dds.posx, vposy:dds.posy,
                  vlines:dds.lines,
                  vcols:dds.cols,
                  vattribut:dds.attribut,
                  vtitle:dds.title) PANEL {

      const xpanel = PANEL {
          .name = vname,
          .posx = vposx,
          .posy = vposy,
          .lines = vlines,
          .cols = vcols,
          .attribut = vattribut,
          .title = vtitle
      };

      return xpanel;

  }

  /// print PANEL
  pub fn printPanel  (vpnl: PANEL) void {
    // assigne PANEL and all OBJECT to matrice for display


    if ( vpnl.cadre.line1 == dds.CADRE.line1 or pnl.cadre == dds.CADRE.line2 ) {
        box.printBorder(pnl,pnl.border);
    }

    for (vpnl.box) |nbox| {
      if (nbox.actif)  box.printBorder(vpnl,nbox) ;
    }

    //displayPanel(pnl)
  }



};


pub const  lbl = struct {

  // define attribut default LABEL
  pub const AtrLabel : dds.ZONATRB = .{
      .styled=[_]i32{@enumToInt(dds.Style.styleBright),
                    @enumToInt(dds.Style.styleItalic),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgGreen,
  };

  // define attribut default TITLE
  pub const AtrTitle : dds.ZONATRB = .{
      .styled=[_]i32{@enumToInt(dds.Style.styleBright),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgCyan,
  };

  pub const LABEL = struct {
    name: dds.name ,
    posx: dds.posx,
    posy: dds.posy ,
    attribut:dds.attribut,
    text: dds.text,
    title: dds.title ,
    actif: dds.actif
  };

  // func LABEL
  pub fn newLabel(name: []const u8,posx:usize,posy:usize,
              text: []const u8,
              attribut : dds.ZONATRB,
              actif:bool) LABEL {

        const xlabel = LABEL {
            .name = name,
            .posx = posx ,
            .posy = posy,
            .attribut = attribut,
            .text = text,
            .title = false,
            .actif = actif
        };

        return xlabel;
  }

  // func TITLE
  pub fn newTile(name: []const u8,posx:usize,posy:usize,
              text: []const u8,
              attribut : dds.ZONATRB,
              actif:bool) LABEL {

        const xlabel = LABEL{
            .name = name,
            .posx = posx ,
            .posy = posy,
            .attribut = attribut,
            .text = text,
            .title = true,
            .actif = actif,
        };

        return xlabel;
  }

  pub fn getName(vpnl:pnl.PANEL , n: dds.index) []u8 {
    return vpnl.label[n].name;
  }

};






test "testeForms" {
//pub fn main() !void {
    const AtrLabel : dds.ZONATRB = .{
    .styled=[_]u32{@enumToInt(dds.Style.styleBright),
                   @enumToInt(dds.Style.styleItalic),
                   @enumToInt(dds.Style.notStyle),
                   @enumToInt(dds.Style.notStyle)},
    .backgr = dds.BackgroundColor.bgBlack,
    .foregr = dds.ForegroundColor.fgGreen,
    };

    var raw_term = try term.enableRawMode();
    defer raw_term.disableRawMode() catch {};
    var text : []const u8  = "東京市";
    term.writeStyled(text,AtrLabel );
    const text2  = "\nJPL\n";
    term.writeStyled(text2,AtrLabel );


}

