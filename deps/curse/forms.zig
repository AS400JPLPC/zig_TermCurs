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


pub const frm = struct {

  // define attribut default FRAME
  pub const AtrFrame : dds.ZONATRB = .{
      .styled=[_]u32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgRed

  };

  // define attribut default TITLE FRAME
  pub const AtrTitle : dds.ZONATRB = .{
      .styled=[_]u32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.styleBright),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgWhite,
      .foregr = dds.ForegroundColor.fgBlack
  };


  /// FRAME

  pub const FRAME = struct {
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

  pub fn newFrame(vname:[]const u8,
                  vposx:usize, vposy:usize,
                  vlines:usize,
                  vcols:usize,
                  vcadre:dds.CADRE,
                  vattribut:dds.ZONATRB,
                  vtitle:[]const u8,
                  vtitleAttribut:dds.ZONATRB,
                  ) FRAME {

        const xframe = FRAME {
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
    return xframe;

  }

    pub fn printFrame(vpnl : pnl.PANEL , vfram: FRAME) void {

      const ACS_Hlines  = "─";
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

      var x  = vfram.posx ;
      var row: usize = 1 ;
      var y: usize = 0 ;
      var col: usize = 0 ;


      while (row <= vfram.lines) {
        y = vfram.posy;
        col = 1;
        while ( col <= vfram.cols ){
          edt = false;
          if (row == 1) {
              if (col == 1) {
                if ( dds.CADRE.line1 == vfram.cadre ) {
                    trait = ACS_UCLEFT;
                } else  trait = ACS_UCLEFT2 ;
                edt = true;
              }
              if ( col == vfram.cols ) {
                if (dds.CADRE.line1 == vfram.cadre) {
                  trait = ACS_UCRIGHT;
                } else  trait = ACS_UCRIGHT2 ;
                edt = true;
              }
              if ( col > 1 and col < vfram.cols ) {
                if (dds.CADRE.line1 == vfram.cadre ) {
                  trait = ACS_Hlines;
                } else  trait = ACS_Hline2;
                edt = true;
              }
          } else if ( row == vfram.lines ) {
              if (col == 1) {
                if ( dds.CADRE.line1 == vfram.cadre ) {
                  trait = ACS_LCLEFT;
                } else  trait = ACS_LCLEFT2;
                edt = true;
              }
              if ( col == vfram.cols ) {
                if ( dds.CADRE.line1 == vfram.cadre ) {
                  trait = ACS_LCRIGHT;
                } else  trait = ACS_LCRIGHT2 ;
                edt = true ;
              }
              if ( col > 1 and col < vfram.cols ) {
                if ( dds.CADRE.line1 == vfram.cadre ) {
                  trait = ACS_Hlines;
                } else  trait = ACS_Hline2 ;
                edt = true;
              }
          } else if ( row > 1 and row < vfram.lines ) {
            if ( col == 1 or col == vfram.cols ) {
              if ( dds.CADRE.line1 == vfram.cadre ) {
                trait = ACS_Vlines;
              } else trait = ACS_Vline2 ;
              edt = true;
            }
          }
          if  ( edt and vfram.cadre != dds.CADRE.line0) {
            term.gotoXY(x,y);
            term.writeStyled(trait,vfram.attribut);
          }
          else {
            term.gotoXY(x,y);
            term.writeStyled(" ",vpnl.attribut);
          }
          y += 1;
          col += 1;
        }
        x += 1;
        row +=1 ;
      }
      if (vfram.title.len > 0 and vfram.cadre != dds.CADRE.line0) {
        var iter = utl.iteratS.iterator(vfram.title);
        var wlen : usize = 0;
        while (iter.next()) |_| { wlen += 1 ; }
        if (wlen > vfram.cols - 2 ) return ;
        term.gotoXY(vfram.posx , ((vfram.cols - vfram.title.len ) / 2) + vfram.posy);
        term.writeStyled(vfram.title,vfram.titleAttribut);
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

    frame: frm.FRAME ,

    //frame: std.ArrayList(frame.FRAME).init(allocator),

    label: std.ArrayList(lbl.LABEL),

    //button: std.ArrayList(btn.BUTTON).init(allocator),

    //funcKey:std.ArrayList(Tkey).init(allocator),

    mouse: bool,

    actif: bool
  };



  pub fn newPanel(vname: [] const u8,
                  vposx: usize, vposy: usize,
                  vlines: usize,
                  vcols: usize,
                  vAttribut: dds.ZONATRB,
                  vcadre : dds.CADRE,
                  vAtrFrame: dds.ZONATRB,
                  vtitle: [] const u8 ,
                  vFrameTitle: dds.ZONATRB) ErrForms! PANEL {

    var xpanel = PANEL {
          .name   = vname,
          .posx   = vposx,
          .posy   = vposy,
          .lines  = vlines,
          .cols   = vcols,
          .attribut = vAttribut,
          .mouse  = false,
          .actif  = true,
          .frame = undefined,
          .label  = std.ArrayList(lbl.LABEL).init(allocator),
      };


    // init frame Panel
    xpanel.frame = frm.newFrame(xpanel.name,
                              xpanel.posx , xpanel.posy,
                              xpanel.lines, xpanel.cols,
                              vcadre, vAtrFrame,
                              vtitle, vFrameTitle );

    return xpanel;

  }

  pub fn initPanel(vname: [] const u8,
                  vposx: usize, vposy: usize,
                  vlines: usize,
                  vcols: usize,
                  vAtrPanel: dds.ZONATRB,
                  vcadre : dds.CADRE,
                  vAtrFrame: dds.ZONATRB,
                  vtitle: [] const u8,
                  vFrameTitle: dds.ZONATRB) PANEL {

      var result_1 = pnl.newPanel(vname, vposx , vposy ,
                                  vlines , vcols,
                                  vAtrPanel,
                                  vcadre,
                                  vAtrFrame,
                                  vtitle,
                                  vFrameTitle
                                  ) catch |ErrForms| blk: {
                                      std.debug.print("newPanel err={}\n", .{ErrForms});
                                      break :blk null;
                                    };

      var panel : PANEL = undefined;
      if (result_1) |xpanel| {
        panel = xpanel;
      }
      return panel ;
  }




  /// print PANEL
  pub fn printPanel  (vpnl: PANEL) void {
    // assigne PANEL and all OBJECT to matrice for display

    // FRAME (window panel)
    frm.printFrame(vpnl,vpnl.frame);

    // LABEL
    for (vpnl.label.items) |lblprt| {
      if (lblprt.actif)  {
        if (vpnl.frame.cadre == dds.CADRE.line0) term.gotoXY(vpnl.posx + lblprt.posx - 1,vpnl.posy + lblprt.posy - 1)
        else term.gotoXY(vpnl.posx + lblprt.posx ,vpnl.posy + lblprt.posy );
        term.writeStyled(lblprt.text,lblprt.attribut);
      }
    }

    term.flushIO();
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

    var panel = pnl.initPanel("panel-0", 1 , 1 ,10 ,20, pnl.AtrPanel,dds.CADRE.line1,frm.AtrFrame,"TITRE",frm.AtrTitle);

    pnl.printPanel(panel);
}

