///-------------------------------
/// FORMS
///-------------------------------
const std = @import("std");
const dds= @import("dds.zig");
const Tkey= @import("cursed.zig").KEY;
const term= @import("cursed.zig");
const utl = @import("utils.zig");


const os = std.os;
const io = std.io;


const allocator = std.heap.page_allocator;

/// Errors that may occur when using String
pub const ErrForms = error{
        InvalidePanel,
    };

const TERMINAL_CHAR = struct {
  ch :   [] const u8,
  attribut:dds.ZONATRB,
  on:bool
};










pub const  lbl = struct {

  // define attribut default LABEL
  pub const AtrLabel : dds.ZONATRB = .{
      .styled=[_]u32{@enumToInt(dds.Style.styleBright),
                    @enumToInt(dds.Style.styleItalic),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgGreen,
  };

  // define attribut default TITLE
  pub const AtrTitle : dds.ZONATRB = .{
      .styled=[_]u32{@enumToInt(dds.Style.styleBright),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgCyan,
  };

  pub const LABEL = struct {
    name :  []const u8,
    posx:   usize,
    posy:   usize,
    attribut:dds.ZONATRB,
    text:   []const u8,
    title:  bool,
    actif:  bool
    };


  // func LABEL
  pub fn newLabel(vname: [] const u8, vposx:usize, vposy:usize,
              vtext: [] const u8,
              vattribut : dds.ZONATRB,) LABEL {

        const xlabel = LABEL {
            .name = vname,
            .posx = vposx ,
            .posy = vposy,
            .attribut = vattribut,
            .text = vtext,
            .title = false,
            .actif = true
        };

        return xlabel;
  }

  // func TITLE
  pub fn newTile(vname: [] const u8, vposx:usize, vposy:usize,
              vtext: [] const u8,
              vattribut : dds.ZONATRB) LABEL {

        const xlabel = LABEL{
            .name = vname,
            .posx = vposx ,
            .posy = vposy,
            .attribut = vattribut,
            .text = vtext,
            .title = true,
            .actif = true,
        };

        return xlabel;
  }

  pub fn getName(vpnl:pnl.PANEL , n: dds.index) []u8 {
    return vpnl.label[n].name;
  }

};


pub const box = struct {

  // define attribut default BORDER
  pub const AtrBorder : dds.ZONATRB = .{
      .styled=[_]u32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgRed

  };

  // define attribut default TITLE BORDER
  pub const BorderTitle : dds.ZONATRB = .{
      .styled=[_]u32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.styleBright),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgWhite,
      .foregr = dds.ForegroundColor.fgBlack
  };


  /// BORDER

  pub const BORDER = struct {
    name :  []const u8,
    posx:   usize,
    posy:   usize,
    lines:  usize,
    cols:   usize,
    cadre:  dds.CADRE,
    attribut:dds.ZONATRB,
    title:  []const u8,
    titleAttribut: dds.ZONATRB,
    actif:  bool
    };

  pub fn newBorder(vname:[]const u8,
                  vposx:usize, vposy:usize,
                  vlines:usize,
                  vcols:usize,
                  vcadre:dds.CADRE,
                  vattribut:dds.ZONATRB,
                  vtitle:[]const u8,
                  vtitleAttribut:dds.ZONATRB,
                  ) BORDER {

        const xborder = BORDER {
            .name = vname,
            .posx = vposx,
            .posy = vposy,
            .lines = vlines,
            .cols = vcols,
            .cadre = vcadre,
            .attribut = vattribut,
            .title = vtitle,
            .titleAttribut = vtitleAttribut,
            .actif = true
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

      var trait: []const u8 = "";
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
            term.gotoXY(x,y);
            term.writeStyled(trait,vbox.titleAttribut);
            vpnl.buf.items[n].ch  = trait;
            vpnl.buf.items[n].attribut  =  vbox.attribut;
            vpnl.buf.items[n].on = true;
          }
          y += 1;
          col += 1;
        }
        x += 1;
        row +=1 ;
      }
      if (vbox.title.len > 0 ) {
        for (vbox.title) |_, index| {
          _ = index;
        }
        if (vbox.title.len > vbox.cols - 2 ) return ;

        npos = vbox.cols * vbox.posx ;
        n =  npos + (((vbox.cols - vbox.title.len ) / 2) + vbox.posy) ;

        var svar = vbox.title;
        var iter = utl.iteratS.iterator(svar);
        term.gotoXY(vbox.posx , ((vbox.cols - vbox.title.len ) / 2));
        while (iter.next()) |ch| {
                            //try stdout.writer().print("\n\r iter outils => {s}\n\r",.{ch});
          //vpnl.buf.items[n].ch  = ch;
          //vpnl.buf.items[n].attribut = vbox.titleAttribut;
          //vpnl.buf.items[n].on = true;
          term.writeStyled(ch,vbox.titleAttribut);
          n +=1 ;
        }
      }

    }

};




pub const  pnl = struct {

  // define attribut default PANEL
  pub const AtrPanel : dds.ZONATRB = .{
      .styled=[_]u32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgWhite
  };







  /// define PANEL
  pub const PANEL = struct {
    name:   [] const u8,
    posx:   usize,
    posy:   usize,

    lines:  usize,
    cols:   usize,

    attribut: dds.ZONATRB,

    border: box.BORDER ,

    //box: std.ArrayList(box.BORDER).init(allocator),

    label: std.ArrayList(lbl.LABEL),

    //button: std.ArrayList(btn.BUTTON).init(allocator),

    //funcKey:std.ArrayList(Tkey).init(allocator),


    buf:std.ArrayList(TERMINAL_CHAR),

    mouse: bool,

    actif: bool
  };



  pub fn newPanel(vname: [] const u8,
                  vposx: usize, vposy: usize,
                  vlines: usize,
                  vcols: usize,
                  vAttribut: dds.ZONATRB,
                  vcadre : dds.CADRE,
                  vAtrBorder: dds.ZONATRB,
                  vtitle: [] const u8 ,
                  vBorderTitle: dds.ZONATRB) ErrForms! PANEL {

    var xpanel = PANEL {
          .name   = vname,
          .posx   = vposx,
          .posy   = vposy,
          .lines  = vlines,
          .cols   = vcols,
          .attribut = vAttribut,
          .mouse  = false,
          .actif  = true,
          .border = undefined,
          .label  = std.ArrayList(lbl.LABEL).init(allocator),
          .buf    = std.ArrayList(TERMINAL_CHAR).init(allocator)
      };


    // INIT doublebuffer
    var i:usize = (xpanel.lines+1) * (xpanel.cols+1);
    var doublebuffer = TERMINAL_CHAR  { .ch =  "",
                                        .attribut = xpanel.attribut,
                                        .on = false};
    while (true) {
        if (i == 0) break ;
        xpanel.buf.append(doublebuffer) catch {return ErrForms.InvalidePanel;};
        i -=1 ;
    }

        // init border Panel
    xpanel.border = box.newBorder(xpanel.name,
                              xpanel.posx , xpanel.posy,
                              xpanel.lines, xpanel.cols,
                              vcadre, vAtrBorder,
                              vtitle, vBorderTitle );

    return xpanel;

  }

  pub fn initPanel(vname: [] const u8,
                  vposx: usize, vposy: usize,
                  vlines: usize,
                  vcols: usize,
                  vAtrPanel: dds.ZONATRB,
                  vcadre : dds.CADRE,
                  vAtrBorder: dds.ZONATRB,
                  vtitle: [] const u8,
                  vBorderTitle: dds.ZONATRB) PANEL {

      var result_1 = pnl.newPanel(vname, vposx , vposy ,
                                  vlines , vcols,
                                  vAtrPanel,
                                  vcadre,
                                  vAtrBorder,
                                  vtitle,
                                  vBorderTitle
                                  ) catch |err| blk: {
                                      std.debug.print("newPanel err={}\n", .{err});
                                      break :blk null;
                                    };

      var panel : PANEL = undefined;
      if (result_1) |xpanel| {
        panel = xpanel;
      }
      return panel ;
  }

  pub fn displayPanel (vpnl: pnl.PANEL) void {
  // display matrice PANEL
  if ( !vpnl.actif ) return ;
  for (vpnl.buf.items) | _, x| {
    for (vpnl.buf.items) |pnln, y| {
      term.gotoXY(x + vpnl.posx , y + vpnl.posy);
      if ( pnln.on == true ) {
        term.writeStyled(pnln.ch,pnln.attribut);
      } else {
        //setStyle(pnl.attribut.styled);
        term.writeStyled(" ",vpnl.attribut);
      }
    }
  }
  term.flushIO();
}


  /// print PANEL
  pub fn printPanel  (vpnl: PANEL) void {
    // assigne PANEL and all OBJECT to matrice for display

    std.debug.print("panel {s}",.{vpnl.name});
    box.printBorder(vpnl,vpnl.border);
    //}

    //for (vpnl.box) |nbox| {
    //  if (nbox.actif)  box.printBorder(vpnl,nbox) ;
    //}

    //displayPanel(vpnl);
  }




};






test "testForms" {
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
    term.gotoXY(5,10);
    term.writeStyled(text,AtrLabel );
    const text2  = "\nJPL\n";
    term.gotoXY(6,10);
    term.writeStyled(text2,AtrLabel );
    const xlabel = lbl.newLabel("Name-1",1,1,
                        "Jean-Pierre",
                        lbl.AtrLabel );
    term.writeStyled(xlabel.text,xlabel.attribut);

    var panel = pnl.initPanel("panel-0", 1 , 1 ,10 ,20, pnl.AtrPanel,dds.CADRE.line1,box.AtrBorder,"TITRE",box.BorderTitle);

    pnl.printPanel(panel);
}

