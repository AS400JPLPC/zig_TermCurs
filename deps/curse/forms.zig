///-------------------------------
/// FORMS
///-------------------------------
const std = @import("std");
const dds= @import("dds.zig");
const kbd= @import("cursed.zig").kbd;
const term= @import("cursed.zig");
const utl = @import("utils.zig");


const os = std.os;
const io = std.io;


const allocator = std.heap.page_allocator;

/// Errors that may occur when using String
const ErrForms = error{
        Invalide_Panel,
        Invalide_Menu,
    };


const TERMINAL_CHAR = struct {
  ch :   [] const u8,
  attribut:dds.ZONATRB,
  on:bool
};


// defined Label
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
      .foregr = dds.ForegroundColor.fgGreen,
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
    return vpnl.label.items[n].name;
  }

  pub fn printLabel(vpnl: pnl.PANEL, vlbl : LABEL ) void {
    // assigne LABEL to matrice for display
    var npos = vpnl.cols * vlbl.posx;
    var n =  npos + vlbl.posy;

    var iter = utl.iteratS.iterator(vlbl.text);
    while (iter.next()) |ch| {
      if (vlbl.actif == true) {
        vpnl.buf.items[n].ch = ch ;
        vpnl.buf.items[n].attribut = vlbl.attribut;
        vpnl.buf.items[n].on = true;
      }
      else {
        vpnl.buf.items[n].ch = " ";
        vpnl.buf.items[n].attribut  = vpnl.attribut;
        vpnl.buf.items[n].on = false;
      }
      n += 1;
    }
  }
};


// defined Trait and Frame for Panel
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
      // assigne FRAME to init matrice for display
      if (dds.CADRE.line0 == vfram.cadre ) return ;

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

      var row:  usize = 1 ;
      var y:    usize = 0 ;
      var col:  usize = 0 ;
      var npos: usize = 0 ;

      var wlen : usize = utl.Lenw(vfram.title);

      var n:    usize = 0 ;
      var x :usize = 1;

      x  = vfram.posx - 1 ;

      while (row <= vfram.lines) {
        y = vfram.posy - 1;
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
          if  ( edt ) {
              npos =  vfram.cols * x;
              n =  npos  + y;
              vpnl.buf.items[n].ch = trait ;
              vpnl.buf.items[n].attribut = vfram.attribut;
              vpnl.buf.items[n].on = true;
          }

          y += 1;
          col += 1;
        }
        x += 1;
        row +=1 ;
      }

      if (wlen > vfram.cols - 2 or wlen == 0 )  return ;
        npos = vfram.posx;
        n =  npos + (((vfram.cols - wlen ) / 2)) - 1 ;
        var iter = utl.iteratS.iterator(vfram.title);
        while (iter.next()) |ch| {
          vpnl.buf.items[n].ch = ch ;
          vpnl.buf.items[n].attribut = vfram.titleAttribut;
          vpnl.buf.items[n].on = true;
          n +=1;
         }
    }

};


// defined button
pub const btn = struct{

  // nbr espace intercaler
  pub var btnspc : usize =3 ;
  // define attribut default PANEL
  pub const AtrButton : dds.ZONATRB = .{
      .styled=[_]u32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgRed
  };
  pub const AtrTitle : dds.ZONATRB = .{
      .styled=[_]u32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.styleItalic),
                    @enumToInt(dds.Style.styleUnderscore),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgCyan
  };



  // define BUTTON
  pub const BUTTON = struct {
    key : [] const u8,
    show: bool,
    attribut:dds.ZONATRB,
    title: []const u8,
    titleAttribut: dds.ZONATRB,
    check: bool,
    actif: bool,
  };

  // func BUTTON
  pub fn newButton(
              vkey : [] const u8,
              vshow : bool,
              vattribut : dds.ZONATRB,
              vtitle: [] const u8,
              vtitleAttribut : dds.ZONATRB,
              vcheck:bool) BUTTON {

        const xbutton = BUTTON {
            .key = vkey,
            .show = vshow,
            .attribut = vattribut,
            .title = vtitle,
            .titleAttribut = vtitleAttribut,
            .check = vcheck,
            .actif = true
        };

        return xbutton;
  }


  pub fn printButton(vpnl: pnl.PANEL) void {
    // assigne LABEL to matrice for display
    var espace :usize = 3;
    var x :usize = 0;
    var y :usize = 0;

    if (vpnl.frame.cadre == dds.CADRE.line0 ) {
      x = vpnl.lines - 1;
      y = 1;
    }
    else {
      x = vpnl.lines - 2;
      y = 2;
    }

    var npos : usize = vpnl.cols * x ;
    var n =  npos + y;

    for (vpnl.button.items) |button| {

      if (button.show == true) {

        // text Function KEY
        var iter = utl.iteratS.iterator(button.key);
        while (iter.next()) |ch| {
          if (button.actif == true) {
            vpnl.buf.items[n].ch = ch ;
            vpnl.buf.items[n].attribut = button.attribut;
            vpnl.buf.items[n].on = true;
          }
          else {
            vpnl.buf.items[n].ch = " ";
            vpnl.buf.items[n].attribut  = vpnl.attribut;
            vpnl.buf.items[n].on = false;
          }
          n += 1;
        }
        n += 1;

        //text User
        iter = utl.iteratS.iterator(button.title);
        while (iter.next()) |ch| {
          if (button.actif == true) {
            vpnl.buf.items[n].ch = ch ;
            vpnl.buf.items[n].attribut = button.titleAttribut;
            vpnl.buf.items[n].on = true;
          }
          else {
            vpnl.buf.items[n].ch = " ";
            vpnl.buf.items[n].attribut  = vpnl.attribut;
            vpnl.buf.items[n].on = false;
          }
          n += 1;
        }
        n += espace;
      }
    }
  }

};


// defined Menu
pub const  mnu = struct {

  // nbr espace intercaler
  pub var  mnuspc : usize =3 ;

  // define attribut default MENU
  pub const AtrMnu : dds.ZONATRB = .{
    .styled=[_]u32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
    .backgr = dds.BackgroundColor.bgBlack,
    .foregr = dds.ForegroundColor.fgRed

  };

  pub const AtrBar : dds.ZONATRB = .{
    .styled=[_]u32{@enumToInt(dds.Style.styleReverse),
                    @enumToInt(dds.Style.styleItalic),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
    .backgr = dds.BackgroundColor.bgBlack,
    .foregr = dds.ForegroundColor.fgWhite

  };

  pub const AtrCell : dds.ZONATRB= .{
    .styled=[_]u32{@enumToInt(dds.Style.styleBright),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
    .backgr = dds.BackgroundColor.bgBlack,
    .foregr = dds.ForegroundColor.fgWhite,
  };

  // define BUTTON
  pub const MENU = struct {

    name : [] const u8,
    posx : usize,
    posy : usize,
    lines: usize,
    cols : usize,

    cadre: dds.CADRE,
    mnuvh : dds.MNUVH,

    attribut: dds.ZONATRB,
    attrBar: dds.ZONATRB,
    attrCell: dds.ZONATRB,

    xitem: std.ArrayList([] const u8),
    selMenu : usize,
    actif: bool
  };

  fn newMenu(vname: [] const u8,
                vposx: usize, vposy: usize,
                vlines: usize,
                vcols: usize,
                vattribut: dds.ZONATRB,
                vattrbar: dds.ZONATRB,
                vattrcell: dds.ZONATRB,
                vcadre : dds.CADRE,
                vmnuvh : dds.MNUVH,
                vitem: std.ArrayList([] const u8)
                ) ErrForms! MENU {

     var xmenu = MENU {
            .name = vname,
            .posx   = vposx,
            .posy   = vposy,
            .lines  = vlines,
            .cols   = vcols,
            .attribut =vattribut,
            .attrBar = vattrbar,
            .attrCell= vattrcell,
            .cadre = vcadre,
            .mnuvh = vmnuvh,
            .xitem  = std.ArrayList([] const u8).init(allocator),
            .selMenu = 0,
            .actif = true
        };

        for (vitem.items) |cells| {
          xmenu.xitem.append(cells) catch {return ErrForms.Invalide_Menu;};
        }
        return xmenu;
  }

  pub fn initMenu(vname: [] const u8,
                vposx: usize, vposy: usize,
                vlines: usize,
                vcols: usize,
                vattribut: dds.ZONATRB,
                vattrbar: dds.ZONATRB,
                vattrcell: dds.ZONATRB,
                vcadre : dds.CADRE,
                vmnuvh : dds.MNUVH,
                vitem: std.ArrayList([] const u8)
                ) MENU {

    var result_1 = newMenu(vname,
                vposx , vposy ,
                vlines ,
                vcols ,
                vattribut ,
                vattrbar ,
                vattrcell ,
                vcadre  ,
                vmnuvh ,
                vitem
                )  catch |Err| blk: {
                        std.debug.print("newMenu err={}\n", .{Err});
                        break :blk null;
                        };

    var menu : MENU = undefined;
    if (result_1) |xmenu| {
      menu = xmenu;
    }
    return menu;
  }

  // print Menu
  fn printMenu(vpnl: pnl.PANEL, vmnu: MENU) void {

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

      var row:  usize = 1 ;
      var y:    usize = 0 ;
      var col:  usize = 0 ;

      var x :usize = 1;

      x  = vmnu.posx - 1 ;
    // if line 0 ex: directory tab
    if (dds.CADRE.line0 != vmnu.cadre ) {
      while (row <= vmnu.lines) {
        y = vmnu.posy - 1;
        col = 1;
        while ( col <= vmnu.cols ){
          edt = false;
          if (row == 1) {
              if (col == 1) {
                if ( dds.CADRE.line1 == vmnu.cadre ) {
                    trait = ACS_UCLEFT;
                } else  trait = ACS_UCLEFT2 ;
                edt = true;
              }
              if ( col == vmnu.cols ) {
                if (dds.CADRE.line1 == vmnu.cadre) {
                  trait = ACS_UCRIGHT;
                } else  trait = ACS_UCRIGHT2 ;
                edt = true;
              }
              if ( col > 1 and col < vmnu.cols ) {
                if (dds.CADRE.line1 == vmnu.cadre ) {
                  trait = ACS_Hlines;
                } else  trait = ACS_Hline2;
                edt = true;
              }
          } else if ( row == vmnu.lines ) {
              if (col == 1) {
                if ( dds.CADRE.line1 == vmnu.cadre ) {
                  trait = ACS_LCLEFT;
                } else  trait = ACS_LCLEFT2;
                edt = true;
              }
              if ( col == vmnu.cols ) {
                if ( dds.CADRE.line1 == vmnu.cadre ) {
                  trait = ACS_LCRIGHT;
                } else  trait = ACS_LCRIGHT2 ;
                edt = true ;
              }
              if ( col > 1 and col < vmnu.cols ) {
                if ( dds.CADRE.line1 == vmnu.cadre ) {
                  trait = ACS_Hlines;
                } else  trait = ACS_Hline2 ;
                edt = true;
              }
          } else if ( row > 1 and row < vmnu.lines ) {
            if ( col == 1 or col == vmnu.cols ) {
              if ( dds.CADRE.line1 == vmnu.cadre ) {
                trait = ACS_Vlines;
              } else trait = ACS_Vline2 ;
              edt = true;
            }
          }
          if  ( edt ) {
            term.gotoXY(row + vmnu.posx + vpnl.posx - 1  , col + vmnu.posy + vpnl.posy - 1);
            term.writeStyled(trait,vmnu.attribut);
          }
          else {
            term.gotoXY(row + vmnu.posx + vpnl.posx - 1 , col + vmnu.posy + vpnl.posy - 1);
            term.writeStyled(" ",vmnu.attribut);
          }

          y += 1;
          col += 1;
        }
        x += 1;
        row +=1 ;
      }
    }


  }

  fn displayMenu(vpnl: pnl.PANEL, vmnu:MENU, npos: usize) void {
    var pos : usize = npos;
    var n : usize = 0;
    var h : usize = 0;
    var nbrItem:usize = vmnu.xitem.items.len;

    printMenu(vpnl, vmnu);

    term.onMouse();
    term.cursHide();


    if (npos > nbrItem or npos == 0 )  pos = 0  ;

    n = 0;
    h = 0;
    for (vmnu.xitem.items) | cell |  {
      if (vmnu.mnuvh == dds.MNUVH.vertical) {
        if (vmnu.cadre == dds.CADRE.line0)
          term.gotoXY(vmnu.posx + vpnl.posx  + n  , vmnu.posy + vpnl.posy  )
        else
          term.gotoXY(vmnu.posx + vpnl.posx  + n + 1 , vmnu.posy + vpnl.posy + 1);
      }
      if (vmnu.mnuvh == dds.MNUVH.horizontal) {
        if (vmnu.cadre == dds.CADRE.line0 )
          term.gotoXY(vmnu.posx + vpnl.posx   , h   + vmnu.posy + vpnl.posy  )
        else
          term.gotoXY(vmnu.posx + vpnl.posx + 1  , h  +  vmnu.posy + vpnl.posy + 1);
      }
      //var xcell = utl.Trim(cell);
      if (pos == n)
        term.writeStyled(cell,vmnu.attrBar)
      else
        term.writeStyled(cell,vmnu.attrCell);

      n += 1;
      h += utl.Lenw(cell);
      if (vmnu.mnuvh == dds.MNUVH.horizontal) h += mnuspc;
    }
  }

  pub fn rstPanel( vsrc : MENU , vpnldst : pnl.PANEL) void {
    if (vpnldst.actif == false)  return ;
    if (vsrc.posx + vsrc.lines > vpnldst.posx + vpnldst.lines  )  return ;
    if (vsrc.posy + vsrc.cols > vpnldst.posy + vpnldst.cols  )  return ;
    var x :usize = 0;
    var y :usize = 0;
    var n :usize = 0;
    var npos : usize =  vsrc.posx - vpnldst.posx;
    while (x <= vsrc.lines) : (x += 1) {
        n = vpnldst.cols * npos + vsrc.posy - vpnldst.posy  ;
        y = 1;
        while (y <= vsrc.cols) : (y += 1) {
          n += 1;
          term.gotoXY(x + vsrc.posx   , y + vsrc.posy  );
          term.writeStyled(vpnldst.buf.items[n].ch,vpnldst.buf.items[n].attribut);
        }
      npos += 1;
      }
  }
  //----------------------------------------------------------------
  // menu processing enter = select  1..n 0 = abort (Escape)
  // Turning on the mouse
  // UP DOWN LEFT RIGHT
  // movement width the wheel and validation width the clik
  //----------------------------------------------------------------
  pub fn ioMenu(vpnl: pnl.PANEL, vmnu:mnu.MENU, npos: usize) usize {
    var pos : usize = 0;
    var n   : usize = 0;
    var h   : usize = 0;

    var nbrItem:usize = vmnu.xitem.items.len;
    term.onMouse();
    term.cursHide();


    mnu.displayMenu(vpnl,vmnu,npos);

    if (npos > nbrItem or npos == 0 )  pos = 0  ;
    term.flushIO();
    while (true) {
      n = 0;
      h = 0;
      for (vmnu.xitem.items) | cell |  {

        if (vmnu.mnuvh == dds.MNUVH.vertical) {
          if (vmnu.cadre == dds.CADRE.line0 )
            term.gotoXY(vmnu.posx + vpnl.posx  + n  , vmnu.posy + vpnl.posy )
          else
            term.gotoXY(vmnu.posx + vpnl.posx  + n + 1, vmnu.posy + vpnl.posy + 1);
          }
        if (vmnu.mnuvh == dds.MNUVH.horizontal) {
          if (vmnu.cadre == dds.CADRE.line0)
            term.gotoXY(vmnu.posx + vpnl.posx   , h  + vmnu.posy + vpnl.posy )
          else
            term.gotoXY(vmnu.posx + vpnl.posx  + 1, h +  vmnu.posy + vpnl.posy + 1);
        }
        if (pos == n)
          term.writeStyled(cell,vmnu.attrBar)
        else
          term.writeStyled(cell,vmnu.attrCell);

        n += 1;
        h += utl.Lenw(cell);
        if (vmnu.mnuvh == dds.MNUVH.horizontal) h += mnuspc;
      }

      var Tkey  = kbd.getKEY();

      if (Tkey.Key == kbd.mouse) {
        Tkey.Key = kbd.none;
        if (term.MouseInfo.action == term.MouseAction.maPressed) {
          if ( term.MouseInfo.scroll and term.MouseInfo.scrollDir == term.ScrollDirection.msUp ) {
            if (vmnu.mnuvh == dds.MNUVH.vertical)    Tkey.Key = kbd.up;
            if (vmnu.mnuvh == dds.MNUVH.horizontal)  Tkey.Key = kbd.left;
          }

          if (term.MouseInfo.scroll and term.MouseInfo.scrollDir == term.ScrollDirection.msDown) {
            if (vmnu.mnuvh == dds.MNUVH.vertical)    Tkey.Key = kbd.down;
            if (vmnu.mnuvh == dds.MNUVH.horizontal)  Tkey.Key = kbd.right;
          }
          if  (term.MouseInfo.button ==  term.MouseButton.mbLeft)  Tkey.Key = kbd.enter;
          if  (term.MouseInfo.button ==  term.MouseButton.mbRight) Tkey.Key = kbd.enter;
        //if (term.MouseInfo.action == term.MouseAction.maReleased ) key = kbd.Enter;
        }
      }
      //std.debug.print("pos: {d}  nbritem:{d}  {d}",.{pos,nbrItem , vmnu.xitem.items.len});
      switch (Tkey.Key) {
        .esc => {
          term.offMouse();
          return 0;
        },
        .enter => {
          term.offMouse();
          return pos + 1;
        },
        .down  => { if (pos < nbrItem - 1 )  pos +=1; } ,
        .up    => { if (pos > 0 )  pos -=1; },
        .right => { if (pos < nbrItem - 1 )  pos +=1; },
        .left  => { if (pos > 0 ) pos -=1; },
        else => {},
      }
    }
  }

};


// defined Panel
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

    button: std.ArrayList(btn.BUTTON),

    menu: std.ArrayList(mnu.MENU),

    // double buffer screen
    buf:std.ArrayList(TERMINAL_CHAR),

    mouse: bool,

    actif: bool
  };



  fn newPanel(vname: [] const u8,
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
          .button = std.ArrayList(btn.BUTTON).init(allocator),
          .menu   = std.ArrayList(mnu.MENU).init(allocator),
          .buf    = std.ArrayList(TERMINAL_CHAR).init(allocator)
      };


    // INIT doublebuffer
    var i:usize = (xpanel.lines+1) * (xpanel.cols+1);
    var doublebuffer = TERMINAL_CHAR  { .ch =  " ",
                                        .attribut = xpanel.attribut,
                                        .on = false};

    // init matrix
    while (true) {
        if (i == 0) break ;
        xpanel.buf.append(doublebuffer) catch {return ErrForms.Invalide_Panel;};
        i -=1 ;
    }


    // init frame Panel
    xpanel.frame = frm.newFrame(xpanel.name,
                              1 , 1,  // border panel
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


  pub fn displayPanel(vpnl: PANEL)  void {
  // display matrice PANEL
    if (vpnl.actif == false ) return ;
      var x :usize = 1;
      var y :usize = 0;
      var n :usize = 0;

      while (x <= vpnl.lines) : (x += 1) {
        y = 1;
        while (y <= vpnl.cols) : (y += 1) {
          term.gotoXY(x + vpnl.posx - 1  , y + vpnl.posy - 1 );
          term.writeStyled(vpnl.buf.items[n].ch,vpnl.buf.items[n].attribut);
          n += 1;
        }
      }
  }


  // clear matrix
  pub fn clsPanel( vpnl : PANEL) void {
    var x :usize = 1;
    var y :usize = 0;
    var n :usize = 0;

    while (x <= vpnl.lines) : (x += 1) {
        y = 1;
        while (y <= vpnl.cols) : (y += 1) {
          vpnl.buf.items[n].ch = " ";
          vpnl.buf.items[n].attribut  = vpnl.attribut;
          vpnl.buf.items[n].on = false;
          n += 1;
        }
      }
    displayPanel(vpnl);
  }

  pub fn rstPanel( vpnlsrc : PANEL , vpnldst : PANEL) void {
    if (vpnldst.actif == false)  return ;
    if (vpnlsrc.posx + vpnlsrc.lines > vpnldst.posx + vpnldst.lines  )  return ;
    if (vpnlsrc.posy + vpnlsrc.cols > vpnldst.posy + vpnldst.cols  )  return ;
    var x :usize = 1;
    var y :usize = 0;
    var n :usize = 0;
    var npos : usize =  vpnlsrc.posx - vpnldst.posx;
    while (x <= vpnlsrc.lines) : (x += 1) {
        n = vpnldst.cols * npos + vpnlsrc.posy - vpnldst.posy  ;
        y = 1;
        while (y <= vpnlsrc.cols) : (y += 1) {
          n += 1;
          term.gotoXY(x + vpnlsrc.posx - 1  , y + vpnlsrc.posy - 1 );
          term.writeStyled(vpnldst.buf.items[n].ch,vpnldst.buf.items[n].attribut);
        }
      npos += 1;
      }
  }

  /// print PANEL
  pub fn printPanel  (vpnl: PANEL) void {
    // assigne PANEL and all OBJECT to matrix for display

    // cursor HIDE par défault
    term.cursHide();

    // clear matrix
    clsPanel(vpnl);

    // FRAME (window panel)
    frm.printFrame(vpnl,vpnl.frame);

    // LABEL
    for (vpnl.label.items) |lblprt| {
      if (lblprt.actif) lbl.printLabel(vpnl, lblprt);
    }

    // BUTTON
    if (vpnl.button.items.len > 0) {

      btn.printButton(vpnl);
    }

    displayPanel(vpnl);
    term.flushIO();
  }



};






test "testForms" {
//pub fn main() !void {
    var raw_term = try term.enableRawMode();
    defer raw_term.disableRawMode() catch {};

    const xlabel = lbl.newLabel("Name- 1",1,1,
                        "Jean-Pierre",
                        lbl.AtrLabel );
    //term.writeStyled(xlabel.text,xlabel.attribut);

    const xbutton = btn.newButton(
                        kbd.str(kbd.F1),
                        true, // show
                        btn.AtrButton,
                        "Help Jean-Pierre",
                        btn.AtrTitle,
                        true  ); // check

    var panel = pnl.initPanel("panel-0", 1 , 1 ,10 ,30, pnl.AtrPanel,dds.CADRE.line1,frm.AtrFrame,"TITRE",frm.AtrTitle);

    panel.label.append(xlabel) catch {return;} ;
    panel.button.append(xbutton) catch {return;} ;
    pnl.printPanel(panel);
}

