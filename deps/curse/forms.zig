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
        Invalide_Grid,
        Invalide_Grid_Buf,
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

    var iter = utl.iteratStr.iterator(vlbl.text);
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

      var wlen : usize = utl.nbrCharStr(vfram.title);

      var n:    usize = 0 ;
      var x:usize = vfram.posx - 1 ;

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
        var iter = utl.iteratStr.iterator(vfram.title);
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
        var iter = utl.iteratStr.iterator(button.key);
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
        iter = utl.iteratStr.iterator(button.title);
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

  // define MENU
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

    xitems: []const[]const u8,
    nbr: usize,
    selMenu : usize,
    actif: bool
  };

  pub fn initMenu(vname: [] const u8,
                vposx: usize, vposy: usize,
                vlines: usize,
                vcols: usize,
                vattribut: dds.ZONATRB,
                vattrbar: dds.ZONATRB,
                vattrcell: dds.ZONATRB,
                vcadre : dds.CADRE,
                vmnuvh : dds.MNUVH,
                vitems: []const[]const u8
                ) MENU {



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
            .xitems  = vitems,
            .nbr = 0,
            .selMenu = 0,
            .actif = true
        };

        for (xmenu.xitems) |_| {
          xmenu.nbr +=1;
        }

    return xmenu;
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

    var x :usize =  vmnu.posx - 1 ;

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

    printMenu(vpnl, vmnu);

    term.onMouse();
    term.cursHide();


    if (npos > vmnu.nbr or npos == 0 )  pos = 0  ;

    n = 0;
    h = 0;
    for (vmnu.xitems) | cell |  {
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
      h += utl.nbrCharStr(cell);
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

    term.onMouse();
    term.cursHide();


    mnu.displayMenu(vpnl,vmnu,npos);

    if (npos > vmnu.nbr or npos == 0 )  pos = 0  ;
    term.flushIO();
    while (true) {
      n = 0;
      h = 0;
      for (vmnu.xitems) | cell |  {

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
        h += utl.nbrCharStr(cell);
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
      //std.debug.print("pos: {d}  nbritem:{d} ",.{pos,vmnu.nbr });
      switch (Tkey.Key) {
        .esc => {
          term.offMouse();
          return 0;
        },
        .enter => {
          term.offMouse();
          return pos + 1;
        },
        .down  => { if (pos < vmnu.nbr - 1 )  pos +=1; } ,
        .up    => { if (pos > 0 )  pos -=1; },
        .right => { if (pos < vmnu.nbr - 1 )  pos +=1; },
        .left  => { if (pos > 0 ) pos -=1; },
        else => {},
      }
    }
  }

};


//-------------------------------------------------------
// management grid
// ----------------
// PadingCell()
// setPageGrid()
// initGrid()
// setActif()
// getLenHeaders()
// countColumns()
// countRows()
// setHeaders()
// toRefColors()
// newCell()
// setCellEditCar()
// getcellLen()
// getHeadersText()
// getHeadersType()
// getHeadersCar()
//
// getRowsText()
// addRows()
// dltRows()   No test
// resetRows()
// resetGrid() No test
// GridBox()
// printGridHeader()
// printGridRows()
// ioGrid()
// ----------------
// defined GRID

pub const  grd = struct {

  // define attribut default GRID
  pub const AtrGrid : dds.ZONATRB = .{
      .styled=[_]u32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgWhite

  };

  // define attribut default TITLE GRID
  pub const AtrTitle : dds.ZONATRB = .{
      .styled=[_]u32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.styleUnderscore),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgGreen
  };


  // define attribut default CELL GRID
  pub const AtrCell : dds.ZONATRB = .{
      .styled=[_]u32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.styleItalic),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgCyan
  };

  // define attribut default CELL GRID
  pub const AtrCellBar : dds.ZONATRB = .{
      .styled=[_]u32{@enumToInt(dds.Style.styleReverse),
                    @enumToInt(dds.Style.styleItalic),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgCyan
  };
  // use default Style separator
  pub var gridStyle : [] const u8 = "│";
  pub var gridnoStyle : [] const u8 = " ";

  pub const CELL = struct {
    text:     [] const u8,
    long:     usize,
    reftyp:   dds.REFTYP,
    posy:     usize,
    edtcar:   []const u8,
    atrCell:  dds.ZONATRB
  };


  const ArgData = struct {
    buf : std.ArrayList([] const u8) = std.ArrayList([] const u8).init(allocator),
   };


  /// define GRID
  pub const GRID = struct {
    name:  [] const u8,
    posx:   usize,
    posy:   usize,

    lines:  usize,
    cols:   usize,

    pageRows:  usize,

    data:     std.MultiArrayList(ArgData),
    headers:  std.ArrayList(CELL),

    separator:  [] const u8,

    attribut: dds.ZONATRB,
    atrTitle: dds.ZONATRB,
    atrCell:  dds.ZONATRB,
    cadre:    dds.CADRE,
    actif:    bool,

    lignes: usize,
    pages:  usize,


    maxligne  : usize,
    cursligne : usize,
    curspage  : usize,

    buf:std.ArrayList(TERMINAL_CHAR)

  };


  fn padingCell( text:[] const u8 , cell :CELL) [] const u8 {

    var i: usize = 0;

    var e_FIELD : [] const u8 = text ;

    if (cell.reftyp == dds.REFTYP.PASSWORD) {
      i = 0;
      e_FIELD = "";
      while (i < utl.nbrCharStr(text) ) : ( i += 1 )  e_FIELD = try utl.concat(e_FIELD,"*");
    }

    if (cell.reftyp == dds.REFTYP.DIGIT_SIGNED or cell.reftyp == dds.REFTYP.DECIMAL_SIGNED) {
        if (utl.isDigit(text , 1) == true )   e_FIELD = try utl.concat("+", e_FIELD) ;
    }

    if  (cell.reftyp == dds.REFTYP.DIGIT or
        cell.reftyp == dds.REFTYP.DIGIT_SIGNED or
        cell.reftyp == dds.REFTYP.DECIMAL or
        cell.reftyp == dds.REFTYP.DECIMAL_SIGNED)
          e_FIELD = utl.alignString(e_FIELD,dds.ALIGNS.rigth,cell.long)
    else  e_FIELD = utl.alignString(e_FIELD,dds.ALIGNS.left,cell.long);


    if (cell.reftyp == dds.REFTYP.SWITCH) {
      if ( text == "true" or text == "1" ) e_FIELD = "◉"
      else e_FIELD = "◎";
    }

    if ( cell.edtcar != "")  e_FIELD =  try utl.concat(e_FIELD,cell.edtcar);

    return e_FIELD;

  }


  pub fn setPageGrid(self : *GRID  ) void {
    self.lignes = self.data.len ;
    if (self.lignes < self.pageRows)  self.pages = 1
    else {
      self.pages = self.lignes / (self.pageRows - 1) ;
      if  (  @rem(self.lignes ,  (self.pageRows - 1))  > 0 ) self.pages += 1;
    }
  }


  pub fn initGrid(vname: [] const u8 ,
              vposx: usize, vposy: usize, 
              vpageRows : usize , // nbr ligne  + header
              vseparator: [] const u8 ,
              vattribut : dds.ZONATRB ,
              vatrTilte : dds.ZONATRB ,
              vatrCell  : dds.ZONATRB ,
              vcadre    : dds.CADRE
              ) GRID {


    var xgrid = GRID{
      .name  = vname,
      .posx  = vposx,
      .posy  = vposy,
      .lines = vpageRows + 2 , //  row per page  + cadre 
      .cols  = 0,              
      .separator = vseparator ,
      .pageRows = vpageRows,
      .data = std.MultiArrayList(ArgData){},
      .headers = std.ArrayList(CELL).init(allocator),
      .actif = true,
      .attribut = vattribut,
      .atrTitle = vatrTilte,
      .atrCell  = vatrCell,
      .cadre = vcadre,
      .lignes  = 0,
      .pages  = 0,
      .maxligne = 0,
      .cursligne  = 0,
      .curspage  = 1,

      .buf    = std.ArrayList(TERMINAL_CHAR).init(allocator)
    };

    return xgrid ;
  }


  pub fn  getLenHeaders(self: *GRID) usize {
    var vlen :   usize = 0 ;

    for (self.headers.items) | xcell | {
      vlen += 1; // separator
      vlen += xcell.long;
      if (utl.cmpStr(xcell.edtcar,"") == false ) vlen += 1;
    }
    vlen += 1; // separator
    return vlen;

  }


  pub fn counColumns(self :*GRID) usize {
    return self.headers.items.len;
  }

  pub fn countRows(self :*GRID) usize {
    return self.data.len;
  }

  pub fn setHeaders(self : *GRID, vCell: std.ArrayList(CELL)) ! void  {
    self.cols = 0;
    for (vCell.items) |xcell| {
      self.cols += 1;
      self.headers.append(xcell) catch {unreachable;} ;
    }

    // this.lines + 2 = cadre + header    cols + separator
    // INIT doublebuffer

    var i:usize = (self.lines) * (getLenHeaders(self));
    var doublebuffer = TERMINAL_CHAR  { .ch =  " ",
                                        .attribut = self.attribut,
                                        .on = false};
    // init matrix
    while (true) {
        if (i == 0) break ;
        self.buf.append(doublebuffer) catch {return ErrForms.Invalide_Grid_Buf;};
        i -=1 ;
    }

  }


  // return color
  fn toRefColor(TextColor: dds.ForegroundColor) dds.ZONATRB {
    var vAtrCell = AtrCell ;

    switch(TextColor){
      .fgBlack   =>  vAtrCell.foregr = dds.ForegroundColor.fgBlack,
      .fgRed     =>  vAtrCell.foregr = dds.ForegroundColor.fgRed,
      .fgGreen   =>  vAtrCell.foregr = dds.ForegroundColor.fgGreen,
      .fgYellow  =>  vAtrCell.foregr = dds.ForegroundColor.fgYellow,
      .fgBlue    =>  vAtrCell.foregr = dds.ForegroundColor.fgBlue,
      .fgMagenta =>  vAtrCell.foregr = dds.ForegroundColor.fgMagenta,
      .fgCyan    =>  vAtrCell.foregr = dds.ForegroundColor.fgCyan,
      .fgWhite   =>  vAtrCell.foregr = dds.ForegroundColor.fgWhite,

      else => vAtrCell.foregr = dds.ForegroundColor.fgCyan,
    }
    return vAtrCell;
  }


  pub fn newCell(vtext: [] const u8, vlong : usize , vreftyp: dds.REFTYP , TextColor: dds.ForegroundColor )  CELL {

    var nlong: usize = 0 ;
    if (utl.nbrCharStr(vtext) > vlong )  nlong = utl.nbrCharStr(vtext)
    else nlong = vlong;



    var cell = CELL {
        .text   = vtext,
        .reftyp = vreftyp,
        .long   = nlong,
        .posy   = 0,
        .edtcar = "",
        .atrCell = toRefColor(TextColor)
      };

      return cell ;
  }

  pub fn setCellEditCar(self :  *CELL , vedtcar :[] const u8 ) void {
    self.edtcar = vedtcar;
  }

  pub fn getcellLen(cell : CELL) usize {
    return cell.long;
  }


  // return name from grid,headers
  pub fn getHeadersText(self: GRID, r :usize ) [] const u8 {
    return  self.header.items[r].text;
  }

  // return posy from grid,headers
  pub fn getHeadersPosy(self: GRID,  r :usize ) usize {
    return  self.header.items[r].posy;
  }

  // return type from grid,headers
  pub fn getHeadersType(self: GRID,  r :usize ) dds.REFTYP {
    return  self.header.items[r].reftyp;
  }


  // return Car from grid,headers
  pub fn getHeadersCar(self: GRID,  r :usize )  [] const u8 {
    return  self.header.items[r].edtcar;
  }


  // get text from grid,rows (multiArray)
  pub fn getRowsText(self: GRID,  r :usize, i:usize )  [] const u8 {
    return self.data.items(.buf)[r].items[i];
  }




  pub fn addRows(self: *GRID,  vrows: []const []const u8) void {
    const vlist = std.ArrayList([]const u8);
    var m = vlist.init(allocator);
    m.appendSlice(vrows) catch unreachable;
    //std.debug.print("m>{s}\n\r",.{m.items});
    self.data.append(allocator ,.{.buf = m}) catch unreachable;
    setPageGrid(self) ;
  }

  pub fn dltRows(self: *GRID,  r :usize )  void {
    self.data.orderedRemove(r);
    setPageGrid(self) ;
  }


  pub fn resetRows(self: *GRID) void {
    self.data.deinit(allocator);
    self.data = std.MultiArrayList(ArgData){};
    self.lignes  = 0;
    self.pages  = 0;
    self.maxligne = 0;
    self.cursligne  = 0;
    self.curspage  = 1;
  }


  pub fn resetGrid(self: *GRID) void {
    self.name  = "";
    self.posx  = 0;
    self.posy  = 0;
    self.lines = 0;
    self.cols  = 0;
    self.separator = "";
    self.pageRows = 0;
    self.data.deinit();
    self.headers.deinit();
    self.lignes  = 0;
    self.pages  = 0;
    self.maxligne = 0;
    self.cursligne  = 0;
    self.curspage  = 0;
  }


  // assigne BOX to matrice for GRID
  fn GridBox(self: *GRID ) void {

    if (dds.CADRE.line0 == self.cadre ) return;

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
    //var npos: usize = 0 ;
    var cols: usize = getLenHeaders(self);

    var n:    usize = 0 ;
    var x :usize = self.posx - 1 ;

    while (row <= self.lines) {
      y = self.posy - 1;
      col = 1;
      while ( col <= cols ){
        edt = false;
        if (row == 1) {
            if (col == 1) {
              if ( dds.CADRE.line1 == self.cadre ) {
                  trait = ACS_UCLEFT;
              } else  trait = ACS_UCLEFT2 ;
              edt = true;
            }
            if ( col == cols ) {
              if (dds.CADRE.line1 == self.cadre) {
                trait = ACS_UCRIGHT;
              } else  trait = ACS_UCRIGHT2 ;
              edt = true;
            }
            if ( col > 1 and col < cols ) {
              if (dds.CADRE.line1 == self.cadre ) {
                trait = ACS_Hlines;
              } else  trait = ACS_Hline2;
              edt = true;
            }
        } else if ( row == self.lines ) {
            if (col == 1) {
              if ( dds.CADRE.line1 == self.cadre ) {
                trait = ACS_LCLEFT;
              } else  trait = ACS_LCLEFT2;
              edt = true;
            }
            if ( col == cols ) {
              if ( dds.CADRE.line1 == self.cadre ) {
                trait = ACS_LCRIGHT;
              } else  trait = ACS_LCRIGHT2 ;
              edt = true ;
            }
            if ( col > 1 and col < cols ) {
              if ( dds.CADRE.line1 == self.cadre ) {
                trait = ACS_Hlines;
              } else  trait = ACS_Hline2 ;
              edt = true;
            }
        } else if ( row > 1 and row < self.lines ) {
          if ( col == 1 or col == cols ) {
            if ( dds.CADRE.line1 == self.cadre ) {
              trait = ACS_Vlines;
            } else trait = ACS_Vline2 ;
            edt = true;
          }
        }
        if  ( edt ) {
            self.buf.items[n].ch = trait ;
            self.buf.items[n].attribut = self.attribut;
            self.buf.items[n].on = true;
        }
        n +=1;
        y += 1;
        col += 1;
      }
      x += 1;
      row +=1 ;
    }
  }


  pub fn printGridHeader(self: *GRID) void {
    if (self.actif == false)  return;
    var buf : [] const u8 = "";
    const Blanc = " ";
    var pos : usize = 0 ;
    for (self.headers.items) |_ , z| {
      self.headers.items[z].posy =pos;
      if (self.headers.items[z].edtcar.len == 0) pos = pos +  self.headers.items[z].long  + 1
      else  pos = pos + self.headers.items[z].long  + 1  + 1;
    }

    for (self.headers.items) |cellx| {
      if (utl.cmpStr(cellx.edtcar , "") == true )
        buf = std.fmt.allocPrint(allocator,
          "{s}{s}{s}", .{ buf,self.separator, utl.alignStr(" ",dds.ALIGNS.left,cellx.long) }) catch unreachable
      else
        buf = std.fmt.allocPrint(allocator,
          "{s}{s}{s}{s}", .{ buf,self.separator, utl.alignStr(" ",dds.ALIGNS.left,cellx.long),Blanc }) catch unreachable;
    }
    buf = std.fmt.allocPrint(allocator,"{s}{s}", .{ buf,self.separator}) catch unreachable;

    var x :usize = 1;
    var y :usize = 0;
    var n :usize = 0;

    while (x <= self.lines) : (x += 1) {
      y = 1;
      var iter = utl.iteratStr.iterator(buf);
      while (iter.next()) |ch| : ( n += 1 ) {
          self.buf.items[n].ch = ch;
          self.buf.items[n].attribut  = self.attribut;
          self.buf.items[n].on = false;
      }

    }

    buf ="";
    for (self.headers.items) |cellx| {
      if ( cellx.reftyp  == dds.REFTYP.DIGIT or
        cellx.reftyp == dds.REFTYP.DIGIT_SIGNED or
        cellx.reftyp == dds.REFTYP.DECIMAL or
        cellx.reftyp == dds.REFTYP.DECIMAL_SIGNED)

          buf = std.fmt.allocPrint(allocator,
          "{s}{s}{s}", .{ buf,self.separator, utl.alignStr(cellx.text,dds.ALIGNS.rigth,cellx.long) }) catch unreachable

      else buf = std.fmt.allocPrint(
          allocator,
          "{s}{s}{s}", .{ buf,self.separator, utl.alignStr(cellx.text,dds.ALIGNS.left,cellx.long) }) catch unreachable;

      if (utl.cmpStr(cellx.edtcar , "") == false ) buf = std.fmt.allocPrint(allocator,"{s}{s}", .{ buf,Blanc}) catch unreachable;
    }

    n = getLenHeaders(self);
    var iter = utl.iteratStr.iterator(buf);
    while (iter.next()) |ch| : ( n += 1) {
      self.buf.items[n].ch = ch;
      self.buf.items[n].attribut  = self.atrTitle;
      self.buf.items[n].on = true;
    }

    // this.lines + 2 = cadre + header
    GridBox(self );

    x = 1;
    y = 0;
    n = 0;
    while (x <= self.lines) : (x += 1) {
      y = 1;
      while (y <= getLenHeaders(self)) : (y += 1) {
        term.gotoXY(x + self.posx - 1  , y + self.posy - 1 );
        term.writeStyled(self.buf.items[n].ch,self.buf.items[n].attribut);
        n += 1;
      }
    }

  }

  pub fn printGridRows(self: *GRID) void {
    if (self.actif == false)  return;
    var nposy : usize =  (getLenHeaders(self) * 2) + 1;
    var n : usize = 0;
    var x : usize = 0;
    var y : usize = 0;
    var h : usize = 0;
    var nColumns : usize = counColumns(self) ;
    var start : usize = 0 ;
    var l : usize = 0;
    var buf : [] const u8 = "";
    self.maxligne = 0;
    if (self.curspage == 0)  start = 0
    else  start = (self.pageRows - 1 ) * (self.curspage - 1 ) ;

    var r: usize = 0;
    while (r < self.pageRows - 1) : (r += 1 ) {
      l = r + start ;
      if (l < self.lignes)  {
        self.maxligne = r;
        h= 0;
        while (h < nColumns ) : (h += 1) {
          //n = n + self.posx  * r ;
          buf  = self.data.items(.buf)[l].items[h];
          var iter = utl.iteratStr.iterator(buf);
            n = nposy + self.headers.items[h].posy;
            while (iter.next()) |ch| : ( n += 1) {
              self.buf.items[n].ch = ch;
              self.buf.items[n].attribut  = self.headers.items[h].atrCell;
              self.buf.items[n].on = true;
              
              if (self.cursligne == l or self.cursligne == r) self.buf.items[n].attribut = AtrCellBar
              else  self.buf.items[n].attribut = AtrCell;      
            }
          //n =  n + self.headers.items[h].long;
        }
      nposy = nposy + getLenHeaders(self) ;
        
      }
    }  

    x = 1;
    y = 0;
    n = 0;
    while (x <= self.lines) : (x += 1) {
      y = 1;
      while (y <= getLenHeaders(self)) : (y += 1) {
        term.gotoXY(x + self.posx - 1  , y + self.posy - 1 );
        term.writeStyled(self.buf.items[n].ch,self.buf.items[n].attribut);
        n += 1;
      }
    }

  }


  //----------------------------------------------------------------
  // Management GRID enter = select  1..n 0 = abort (Escape)
  // Turning on the mouse
  // UP DOWn PageUP PageDown
  // Automatic alignment based on the type reference
  //----------------------------------------------------------------
  


  pub const GridSelect = struct {
     Key: term.kbd ,
     Buf : std.ArrayList([]const u8)
  };

  pub fn ioGrid(self: *GRID ) GridSelect {

    var gSelect : GridSelect = .{
      .Key = term.kbd.none,
      .Buf = std.ArrayList([]const u8).init(allocator)
    };

    if ( self.actif == false ) return gSelect ; 

    gSelect.Key = term.kbd.none;


    var CountLigne : usize = 0;
    self.cursligne = 0;
    printGridHeader(self) ;
    
    term.cursHide();
    term.onMouse();


    var grid_key : term.Keyboard = undefined ;
    while (true) {
      
      printGridRows(self);
      

      grid_key = kbd.getKEY();
      
      if (grid_key.Key == kbd.mouse) {
        grid_key.Key = kbd.none;
        switch (term.MouseInfo.scrollDir) {
          term.ScrollDirection.msUp =>    grid_key.Key = kbd.up,
          term.ScrollDirection.msDown =>  grid_key.Key = kbd.down,
          else => {}
        }

        switch (term.MouseInfo.button) {
          term.MouseButton.mbLeft  =>  grid_key.Key = kbd.enter,
          term.MouseButton.mbRight =>  grid_key.Key = kbd.enter,
          else => {}
        }

        if (grid_key.Key == kbd.none ) continue;
      }

      switch (grid_key.Key) {
        .esc => {
          self.cursligne = 0;
          gSelect.Key = kbd.esc;
          gSelect.Buf = undefined;
          term.offMouse();
          return gSelect;
        },
        .enter  =>
          if (self.lignes > 0 ) {
            gSelect.Key = kbd.enter;
            if (self.curspage > 0) {
              CountLigne =  (self.pageRows - 1) * (self.curspage - 1 );
              CountLigne += self.cursligne;
            }
            gSelect.Buf = self.data.items(.buf)[CountLigne];
            term.offMouse();
            self.cursligne = 0;
            return gSelect;
          },
        .up     =>
          if (CountLigne > 0 ) {
            CountLigne -= 1 ;
            self.cursligne -= 1 ;
          },
        .down   =>
          if (CountLigne < self.maxligne) {
            CountLigne += 1;
            self.cursligne += 1;
          },
        .pageUp =>
          if (self.curspage > 1 ) {
            self.curspage -=1;
            self.cursligne = 0;
            CountLigne = 0;
            printGridHeader(self);
          },
        .pageDown =>
          if (self.curspage < self.pages ) {
            self.curspage += 1;
            self.cursligne = 0;
            CountLigne = 0;
            printGridHeader(self);
          },
        else => {}
      }
    }
  }


  pub fn ioCombo(self: *GRID , pos : usize) GridSelect {
    var CountLigne : usize = 0;
    var gSelect : GridSelect = .{
      .Key = term.kbd.none,
      .Buf = std.ArrayList([]const u8).init(allocator)
    };

    if ( self.actif == false ) return gSelect ; 

    gSelect.Key = term.kbd.none;

    if (pos == 0 )  self.cursligne = 0
    else { 
      var r :usize = 0;
      var n :usize = 0;
      self.curspage = 0;
      while (r < self.lignes) : ( r +=1 ) {
        n += 1;
        if (n == self.pageRows - 1) { self.curspage +=1 ; n= 0;}
        if (r == pos) {
          self.cursligne = r;
          
          break ;
        }
      }
      CountLigne = self.cursligne;
      if ( n > 0 ) self.curspage += 1;
    }
    
    printGridHeader(self) ;

    term.cursHide();
    term.onMouse();

    var grid_key : term.Keyboard = undefined ;
    while (true) {
      
      printGridRows(self);
      

      grid_key = kbd.getKEY();
      
      if (grid_key.Key == kbd.mouse) {
        grid_key.Key = kbd.none;
        switch (term.MouseInfo.scrollDir) {
          term.ScrollDirection.msUp =>    grid_key.Key = kbd.up,
          term.ScrollDirection.msDown =>  grid_key.Key = kbd.down,
          else => {}
        }

        switch (term.MouseInfo.button) {
          term.MouseButton.mbLeft  =>  grid_key.Key = kbd.enter,
          term.MouseButton.mbRight =>  grid_key.Key = kbd.enter,
          else => {}
        }

        if (grid_key.Key == kbd.none ) continue;
      }

      switch (grid_key.Key) {
        .esc => {
          self.cursligne = 0;
          gSelect.Key = kbd.esc;
          gSelect.Buf = undefined;
          term.offMouse();
          return gSelect;
        },
         .enter  =>
          if (self.lignes > 0 ) {
            gSelect.Key = kbd.enter;
            gSelect.Buf = self.data.items(.buf)[self.cursligne];
            term.offMouse();
            self.cursligne = 0;
            return gSelect;
          },
        .up     =>
          if (CountLigne > 0 ) {
            CountLigne -= 1 ;
            self.cursligne -= 1 ;
          },
        .down   =>
          if (CountLigne < self.maxligne and self.cursligne < self.maxligne ) {
            CountLigne += 1;
            self.cursligne += 1;
          },
        .pageUp =>
          if (self.curspage > 1 ) {
            self.curspage -=1;
            self.cursligne = 0;
            CountLigne = 0;
            printGridHeader(self);
          },
        .pageDown =>
          if (self.curspage < self.pages ) {
            self.curspage += 1;
            self.cursligne = 0;
            CountLigne = 0;
            printGridHeader(self);
          },
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

    grid: std.ArrayList(grd.GRID),

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
          .grid   = std.ArrayList(grd.GRID).init(allocator),
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
                                  ) catch  blk: {
                                      std.debug.print("newPanel err={}\n", .{ErrForms.Invalide_Panel});
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

test "testforms" {
  term.enableRawMode();
  defer term.disableRawMode() ;

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

  var panel = pnl.initPanel("panel-0", 1 , 1 ,30 ,50, pnl.AtrPanel,dds.CADRE.line1,frm.AtrFrame,"TITRE",frm.AtrTitle);

  panel.label.append(xlabel) catch {return;} ;
  panel.button.append(xbutton) catch {return;} ;
  pnl.printPanel(panel);

  panel.grid.append(grd.initGrid(
                "Grid01",
                20, 2,
                7,
                grd.gridStyle,
                grd.AtrGrid,
                grd.AtrTitle,
                grd.AtrCell,
                dds.CADRE.line1,
                )) catch unreachable ;

  var Cell = std.ArrayList(grd.CELL).init(allocator);
  Cell.append(grd.newCell("ID",3,dds.REFTYP.DIGIT,dds.ForegroundColor.fgGreen)) catch unreachable ;
  Cell.append(grd.newCell("Name",15,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgYellow)) catch unreachable ;
  Cell.append(grd.newCell("animal",20,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgWhite)) catch unreachable ;
  //Cell.append(grd.newCell("prix",8,dds.REFTYP.DECIMAL,dds.ForegroundColor.fgWhite)) catch unreachable ;
  // setCellEditCar(g_prix,"€")
  Cell.append(grd.newCell("HS",1,dds.REFTYP.SWITCH,dds.ForegroundColor.fgWhite)) catch unreachable ;
  grd.setHeaders(&panel.grid.items[0], Cell) catch unreachable ;
  grd.printGridHeader(&panel.grid.items[0]);
  //std.debug.print("len haeder:{}",.{grd.getLenHeaders(&panel.grid.items[0])});
  
  grd.addRows(&panel.grid.items[0] , &.{"01", "Adam","Aigle","1"});
  grd.addRows(&panel.grid.items[0] , &.{"02", "eve", "poisson","0"});
  
  grd.addRows(&panel.grid.items[0] , &.{"03", "Rouge","Aigle","0"});
  grd.addRows(&panel.grid.items[0] , &.{"04", "Bleu", "poisson","0"});
  grd.addRows(&panel.grid.items[0] , &.{"05", "Bleu5", "poisson","0"});
  grd.addRows(&panel.grid.items[0] , &.{"06", "Bleu6", "poisson","0"});
  grd.addRows(&panel.grid.items[0] , &.{"07", "Bleu7", "poisson","0"});
  grd.addRows(&panel.grid.items[0] , &.{"08", "Bleu8", "poisson","0"});
  grd.addRows(&panel.grid.items[0] , &.{"09", "Bleu9", "poisson","0"});
  grd.addRows(&panel.grid.items[0] , &.{"10", "Bleu10", "poisson","0"});
  grd.addRows(&panel.grid.items[0] , &.{"11", "Bleu11", "poisson","0"});

  var Gkey :grd.GridSelect = undefined ;

  Gkey =grd.ioCombo(&panel.grid.items[0],3);
  std.debug.print("key:{} \r\n",.{Gkey.Key});
  if ( Gkey.Key != kbd.esc ) std.debug.print("buf:{s} \r\n",.{Gkey.Buf.items[1]});

}
