const std = @import("std");
const utf = @import("std").unicode;

const dds = @import("dds");
const kbd = @import("cursed").kbd;
const term= @import("cursed");
const utl = @import("utils");
const reg = @import("match");

const os = std.os;
const io = std.io;

///-------------------------------
/// FORMS
///-------------------------------



// function special for developpeur
pub fn debeug(vline : usize, buf: [] const u8) void {
  
  const AtrDebug : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgYellow
  };

  term.getCursor();
  var Xterm = term.getSize() catch unreachable;
  term.gotoXY(Xterm.height,1) ;
  const allocator = std.heap.page_allocator;
  var msg =std.fmt.allocPrint(allocator,"linsrc:{d}  {s} ",.{vline, buf}) catch unreachable;
  term.writeStyled(msg,AtrDebug);
  _=term.kbd.getKEY();
  term.gotoXY(term.posCurs.x,term.posCurs.y);
  allocator.free(msg);
            
}


  

// function special for developpeur
// activat fld.myMouse = true
// read ioField -> getKEY()
 pub fn dspMouse(vpnl: *pnl.PANEL) void {
    const AtrDebug: dds.ZONATRB = .{
        .styled = [_]u32{ @intFromEnum(dds.Style.notStyle), @intFromEnum(dds.Style.notStyle), @intFromEnum(dds.Style.notStyle), @intFromEnum(dds.Style.notStyle) },
        .backgr = dds.BackgroundColor.bgBlack,
        .foregr = dds.ForegroundColor.fgRed,
    };
    const allocator = std.heap.page_allocator;
    var msg = std.fmt.allocPrint(allocator, "{d:0>2}{s}{d:0>3}", .{ term.MouseInfo.x, "/", term.MouseInfo.y }) catch unreachable;
    term.gotoXY(vpnl.posx + vpnl.lines - 1, (vpnl.posy + vpnl.cols - 1) - 7);
    term.writeStyled(msg, AtrDebug);
    term.gotoXY(term.MouseInfo.x, term.MouseInfo.y);
    allocator.free(msg);
}

// function special for developpeur
 pub fn dspCursor(vpnl: *pnl.PANEL, x_posx: usize, x_posy: usize) void {
    const AtrDebug: dds.ZONATRB = .{
        .styled = [_]u32{ @intFromEnum(dds.Style.notStyle), @intFromEnum(dds.Style.notStyle), @intFromEnum(dds.Style.notStyle), @intFromEnum(dds.Style.notStyle) },
        .backgr = dds.BackgroundColor.bgBlack,
        .foregr = dds.ForegroundColor.fgRed,
    };
    const allocator = std.heap.page_allocator;
    var msg = std.fmt.allocPrint(allocator, "{d:0>2}{s}{d:0>3}", .{ x_posx, "/", x_posy }) catch unreachable;
    term.gotoXY(vpnl.posx + vpnl.lines - 1, (vpnl.posy + vpnl.cols - 1) - 7);
    term.writeStyled(msg, AtrDebug);
    term.gotoXY(x_posx, x_posy);
    allocator.free(msg);
}


/// Errors that may occur when using String
pub const ErrForms = error{
        Invalide_append,
        Invalide_Panel,
        Invalide_Menu,
        Invalide_Grid,
        Invalide_Grid_Buf,
        grd_dltRows_Index_invalide,

        lbl_getIndex_Name_Label_Invalide,
        lbl_getName_Index_invalide,
        lbl_getPosx_Index_invalide,
        lbl_getPosy_Index_invalide,
        lbl_getText_Index_invalide,
        lbl_getActif_Index_invalide,

        lbl_setText_Index_invalide,
        lbl_setActif_Index_invalide,
        lbl_updateText_Index_invalide,

        lbl_dltRows_Index_invalide,

        btn_getIndex_Key_Button_Invalide,
        btn_getName_Index_invalide,
        btn_getKey_Index_invalide,
        btn_getShow_Index_invalide,
        btn_getText_Index_invalide,
        btn_getCheck_Index_invalide,
        btn_getActif_Index_invalide,

        btn_setShow_Index_invalide,
        btn_setText_Index_invalide,
        btn_setCheck_Index_invalide,  
        btn_setActif_Index_invalide,


        btn_dltRows_Index_invalide,

        mnu_getIndex_Name_Menu_Invalide,
        mnu_getName_Index_invalide,
        mnu_getPosx_Index_invalide,
        mnu_getPosy_Index_invalide,
        mnu_getText_Index_invalide,
        mnu_getActif_Index_invalide,

        mnu_dltRows_Index_invalide,


        fld_getIndex_Name_Field_Invalide,
        fld_getName_Index_invalide,
        fld_getPosx_Index_invalide,
        fld_getPosy_Index_invalide,
        fld_getRefType_Index_invalide,
        fld_getWidth_Index_invalide,
        fld_getScal_Index_invalide,
        fld_getNbrCar_Index_invalide,
        fld_gettofill_Index_invalide,
        fld_getProtect_Index_invalide,
        fld_getPading_Index_invalide,
        fld_getEdtcar_Index_invalide,
        fld_getRegex_Index_invalide,
        fld_getErrMsg_Index_invalide,
        fld_getHelp_Index_invalide,
        fld_getText_Index_invalide,
        fld_getSwitch_Index_invalide,
        fld_getErr_Index_invalide,
        fld_getFunc_Index_invalide,
        fld_getTask_Index_invalide,
        fld_getAttribut_Index_invalide,
        fld_getAtrProtect_Index_invalide,
        fld_getActif_Index_invalide,

        fld_setText_Index_invalide,
        fld_setSwitch_Index_invalide,
        fld_setProtect_Index_invalide,
        fld_setEdtcar_Index_invalide,
        fld_setRegex_Index_invalide,
        fld_setActif_Index_invalide,

        fld_dltRows_Index_invalide,


    };


// Shows serious programming errors
pub const  dsperr = struct {    
  pub fn errorForms(errpgm :anyerror ) void { 
    // define attribut default MSG Error
    const MsgErr : dds.ZONATRB = .{
        .styled=[_]u32{@intFromEnum(dds.Style.styleBlink),
                      @intFromEnum(dds.Style.notStyle),
                      @intFromEnum(dds.Style.notStyle),
                      @intFromEnum(dds.Style.notStyle)},
        .backgr = dds.BackgroundColor.bgBlack,
        .foregr = dds.ForegroundColor.fgYellow,
    };
    const xSize = term.getSize() catch unreachable;

    const allocator = std.heap.page_allocator;

    var msgerr:[]const u8 = std.fmt.allocPrint(allocator,"To report: {any} ",.{errpgm }) catch unreachable; 
    var x: usize  = xSize.height - 1 ;
    var y: usize  = 2; 
    term.gotoXY( x , y    );
    term.writeStyled(msgerr,MsgErr);
    while (true) {
      var e_key = kbd.getKEY();
      switch ( e_key.Key ) {
        .esc => break,
      else =>  {},
      }
    }
    allocator.free(msgerr); 
  }
};


// buffer terminal MATRIX
const TERMINAL_CHAR = struct {
  ch :   [] const u8,
  attribut:dds.ZONATRB,
  on:bool
};


// defined Label
pub const  lbl = struct {

  // define attribut default LABEL
  pub var AtrLabel : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.styleDim),
                    @intFromEnum(dds.Style.styleItalic),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgGreen,
  };

  // define attribut default TITLE
  pub var AtrTitle : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.styleBold),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
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


  // New LABEL
  pub fn newLabel(vname: [] const u8, vposx:usize, vposy:usize,
              vtext: [] const u8) LABEL {

        const xlabel = LABEL {
            .name = vname,
            .posx = vposx ,
            .posy = vposy,
            .attribut = AtrLabel,
            .text = vtext,
            .title = true,
            .actif = true,
        };

        return xlabel;
  }


  // New LABEL-TITLE
  pub fn newTitle(vname: [] const u8, vposx:usize, vposy:usize,
              vtext: [] const u8) LABEL {

        const xlabel = LABEL {
            .name = vname,
            .posx = vposx ,
            .posy = vposy,
            .attribut = AtrTitle,
            .text = vtext,
            .title = true,
            .actif = true,
        };

        return xlabel;
  }


  // return index-label  ---> arraylist panel-label
  pub fn getIndex(vpnl: *pnl.PANEL , name: [] const u8 )  ErrForms ! usize {

    for (vpnl.label.items, 0..) |l, idx| {
      if (std.mem.eql(u8, l.name, name)) return idx ;
    }
    return ErrForms.lbl_getIndex_Name_Label_Invalide;
  }

  // return name-label ---> arraylist panel-label
  pub fn getName(vpnl: *pnl.PANEL , n: usize) ErrForms ! [] const u8 {
    if ( n < vpnl.label.items.len) return vpnl.label.items[n].name;
    return ErrForms.lbl_getName_Index_invalide ;

  }

  // return posx-label ---> arraylist panel-label
  pub fn getPosx(vpnl: *pnl.PANEL , n: usize)  ErrForms ! usize {
    if ( n < vpnl.label.items.len) return vpnl.label.items[n].posx;
    return ErrForms.lbl_getPosx_Index_invalide ;
  }

  // return posy-label ---> arraylist panel-label
  pub fn getPosy(vpnl: *pnl.PANEL , n: usize)  ErrForms ! usize {
    if ( n < vpnl.label.items.len) return vpnl.label.items[n].posy;
    return ErrForms.lbl_getPosy_Index_invalide ;
  }

  // return Text-label ---> arraylist panel-label
  pub fn getText(vpnl: *pnl.PANEL , n: usize)  ErrForms ! usize {
    if ( n < vpnl.label.items.len) return vpnl.label.items[n].text;
    return ErrForms.lbl_getText_Index_invalide ;
  }

  // return ON/OFF-label ---> arraylist panel-label
  pub fn getActif(vpnl: *pnl.PANEL , n: usize)  ErrForms ! bool {
    if ( n < vpnl.label.items.len) return vpnl.label.items[n].actif;
    return ErrForms.lbl_getActif_Index_invalide ;
  }

  // Set TEXT -label ---> arraylist panel-label
  pub fn setText(vpnl: *pnl.PANEL , n: usize, val:[] const u8) ErrForms ! void {
    if ( n < vpnl.label.items.len)  vpnl.label.items[n].text = val
    else return ErrForms.lbl_setText_Index_invalide;
  }

  // Set ON/OFF -label ---> arraylist panel-label
  pub fn setActif(vpnl: *pnl.PANEL , n: usize, val :bool) ErrForms ! void {
    if ( n < vpnl.label.items.len) vpnl.label.items[n].actif = val
    else return ErrForms.lbl_setActif_Index_invalide;
  }

  // delete -label ---> arraylist panel-label
  pub fn dltRows(vpnl: *pnl.PANEL,  n :usize ) ErrForms ! void {
    if ( n < vpnl.label.items.len)  _= vpnl.label.orderedRemove(n)
    else return ErrForms.lbl_dltRows_Index_invalide;
  }

  // update Label and Display  ---> arraylist panel-label
  pub fn updateText(vpnl: *pnl.PANEL , n: usize, val:[] const u8) ErrForms ! void {
    if ( n < vpnl.label.items.len) {
      clsLabel(vpnl, vpnl.label.items[n]);
      vpnl.label.items[n].text = val;
      printLabel(vpnl, vpnl.label.items[n]);
      displayLabel(vpnl, vpnl.label.items[n]);
    } else return ErrForms.lbl_updateText_Index_invalide;
  }

  // assign -label MATRIX TERMINAL  ---> arraylist panel-label
  pub fn printLabel(vpnl: *pnl.PANEL, vlbl : LABEL ) void {
    var n  = (vpnl.cols * (vlbl.posx - 1)) + vlbl.posy - 1;
    var iter = utl.iteratStr.iterator(vlbl.text);
    defer iter.deinit();

    while (iter.next()) |ch| {
      if (vlbl.actif == true) {
        vpnl.buf.items[n].ch = ch ;
        vpnl.buf.items[n].attribut = vlbl.attribut;
        vpnl.buf.items[n].on = true;
      }
      else {
        vpnl.buf.items[n].ch = "";
        vpnl.buf.items[n].attribut  = vpnl.attribut;
        vpnl.buf.items[n].on = false;
      }
      n += 1;
    }
  }


  // matrix cleaning from label
  pub fn clsLabel(vpnl: *pnl.PANEL, vlbl : LABEL )  void {
    // display matrice PANEL
    if (vpnl.actif == false ) return ;
    if (vlbl.actif == false ) return ;
      var x :usize = vlbl.posx - 1;
      var y :usize = vlbl.posy - 1;
      var vlen = utl.nbrCharStr(vlbl.text);
      var n :usize = 0;
      var npos :usize = (vpnl.cols * (vlbl.posx - 1)) + vlbl.posy - 1 ;
      while (n < vlen) : (n += 1) {
        vpnl.buf.items[npos].ch = " ";
        vpnl.buf.items[npos].attribut  = vpnl.attribut;
        vpnl.buf.items[npos].on = false;
        term.gotoXY(x + vpnl.posx   , y + vpnl.posy + n  );
        term.writeStyled(vpnl.buf.items[npos].ch,vpnl.buf.items[npos].attribut);
        npos += 1;
      }
  }


  // display  MATRIX to terminal ---> arraylist panel-label
  fn displayLabel(vpnl: *pnl.PANEL, vlbl : LABEL )  void {
    // display matrice PANEL
    if (vpnl.actif == false ) return ;
      var x :usize = vlbl.posx - 1 ;
      var y :usize = vlbl.posy - 1;
      var vlen = utl.nbrCharStr(vlbl.text);
      var n :usize = 0;
      var npos :usize = (vpnl.cols * vlbl.posx) + vlbl.posy - 1 ;
      while (n < vlen) : (n += 1) {
        term.gotoXY(x + vpnl.posx   , y + vpnl.posy + n  );
        term.writeStyled(vpnl.buf.items[npos].ch,vpnl.buf.items[npos].attribut);
        npos += 1;
      }
  }
};


// defined Trait and Frame for Panel
pub const frm = struct {

  // define attribut default FRAME
  pub var AtrFrame : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.styleDim),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgRed

  };

  // define attribut default TITLE FRAME
  pub var AtrTitle : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.styleBold),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgWhite,
      .foregr = dds.ForegroundColor.fgBlue
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

    // define Fram 
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


    // write MATRIX TERMINAL  ---> arraylist panel-fram
    pub fn printFrame(vpnl : *pnl.PANEL , vfram: FRAME) void {

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
        defer iter.deinit();
        while (iter.next()) |ch| {
          vpnl.buf.items[n].ch = ch ;
          vpnl.buf.items[n].attribut = vfram.titleAttribut;
          vpnl.buf.items[n].on = true;
          n +=1;
        }
    }

};



// defined Line and vertical for Panel
pub const lnv = struct {

  // define attribut default FRAME
  pub var AtrLine : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.styleDim),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgYellow

  };



  /// LINE VERTICAL

  pub const LINE = struct {
    name :  []const u8,
    posx:   usize,
    posy:   usize,
    lines:  usize,
    cadre:  dds.LINE,
    attribut:dds.ZONATRB,
    actif:  bool
    };

    // define Fram 
    pub fn newLine(vname:[]const u8,
                    vposx:usize, vposy:usize,
                    vlines:usize,
                    vcadre:dds.LINE,
                    ) LINE {

          const xframe = LINE {
              .name = vname,
              .posx = vposx,
              .posy = vposy,
              .lines = vlines,
              .cadre = vcadre,
              .attribut = AtrLine,
              .actif = true
          };
      return xframe;

    }


    // write MATRIX TERMINAL  ---> arraylist panel-line
    pub fn printLine(vpnl : *pnl.PANEL , vline: LINE) void {
    if (vpnl.actif == false ) return ;
    if (vline.actif == false ) return ;

      // assigne FRAMELINE VERTICAL

      const ACS_Vlines  = "│";
      const ACS_Vline2    = "║";

      var row:  usize = 0 ;
      var npos: usize = 0 ;

      var n: usize = 0 ;
      var x: usize = vline.posx  ;

      var trait: []const u8 = "";

      while (row < vline.lines) {


        if ( dds.LINE.line1 == vline.cadre ) {
          trait = ACS_Vlines;
        } else trait = ACS_Vline2 ;
        npos =  vpnl.cols * x;
        n =  npos + vline.posy;
        vpnl.buf.items[n].ch = trait ;
        vpnl.buf.items[n].attribut = vline.attribut;
        vpnl.buf.items[n].on = true;
      
        row +=1 ;
        x += 1;
      }
    }

};


// defined Line and vertical for Panel
pub const lnh = struct {

  // define attribut default FRAME
  pub var AtrLine : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.styleDim),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgYellow

  };



  /// LINE VERTICAL

  pub const LINE = struct {
    name :  []const u8,
    posx:   usize,
    posy:   usize,
    cols:  usize,
    cadre:  dds.LINE,
    attribut:dds.ZONATRB,
    actif:  bool
    };

    // define Fram 
    pub fn newLine(vname:[]const u8,
                    vposx:usize, vposy:usize,
                    vcols:usize,
                    vcadre:dds.LINE,
                    ) LINE {

          const xframe = LINE {
              .name = vname,
              .posx = vposx,
              .posy = vposy,
              .cols = vcols,
              .cadre = vcadre,
              .attribut = AtrLine,
              .actif = true
          };
      return xframe;

    }


    // write MATRIX TERMINAL  ---> arraylist panel-line
    pub fn printLine(vpnl : *pnl.PANEL , vline: LINE) void {
    if (vpnl.actif == false ) return ;
    if (vline.actif == false ) return ;
      // assigne FRAMELINE VERTICAL

      const ACS_Hlines  = "─";
      const ACS_Hline2  = "═";

      var coln:  usize = 0 ;
      var npos: usize = 0 ;

      var n: usize = 0 ;
      var y: usize = vline.posy  ;

      var trait: []const u8 = "";

      npos =  vpnl.cols * vline.posx;

      while (coln < vline.cols) {


        if ( dds.LINE.line1 == vline.cadre ) {
          trait = ACS_Hlines;
        } else trait = ACS_Hline2 ;

        n =  npos + y;
        vpnl.buf.items[n].ch = trait ;
        vpnl.buf.items[n].attribut = vline.attribut;
        vpnl.buf.items[n].on = true;
      
        coln +=1 ;
        y += 1;
      }
    }

};



// defined button
pub const btn = struct{

  // nbr espace intercaler
  pub var btnspc : usize =3 ;
  // define attribut default PANEL
  pub var AtrButton : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.styleDim),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgRed
  };
  pub var AtrTitle : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.styleDim),
                    @intFromEnum(dds.Style.styleItalic),
                    @intFromEnum(dds.Style.styleUnderscore),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgdCyan,
  };



  // define BUTTON
  pub const BUTTON = struct {
    name: [] const u8,
    key : kbd,
    show: bool,
    check: bool,
    title: []const u8,
    attribut:dds.ZONATRB,
    titleAttribut: dds.ZONATRB,
    actif: bool,
  };

  // func BUTTON
  pub fn newButton(
              vkey : kbd,
              vshow : bool,
              vcheck:bool,
              vtitle: [] const u8) BUTTON {

        const xbutton = BUTTON {
            .name = kbd.enumToStr(vkey),
            .key  = vkey,
            .show = vshow,
            .check = vcheck,
            .title = vtitle,
            .attribut = AtrButton,
            .titleAttribut = AtrTitle,
            .actif = true
        };

        return xbutton;
  }

  // return index-button  ---> arraylist panel-button
  pub fn getIndex(vpnl: *pnl.PANEL , key: kbd  ) ErrForms ! usize {

    for (vpnl.button.item, 0..) |b ,idx  | {
      if (b.button.key == key) return idx;
    }
    return ErrForms.btn_getIndex_Key_Button_Invalide;
  }

  // return name-button  ---> arraylist panel-button
  pub fn getName(vpnl: *pnl.PANEL , n: usize) ErrForms ! [] const u8 {
    if ( n < vpnl.button.items.len) return vpnl.button.items[n].name;
    return ErrForms.btn_getName_Index_invalide ;

  }

  // return key-button  ---> arraylist panel-button
  pub fn getKey(vpnl: *pnl.PANEL , n: usize) ErrForms ! kbd {
    if ( n < vpnl.button.items.len) return vpnl.button.items[n].key;
    return ErrForms.btn_getKey_Index_invalide ;

  }

  // return show-button  ---> arraylist panel-button
  pub fn getShow(vpnl: *pnl.PANEL , n: usize) ErrForms ! bool {
    if ( n < vpnl.button.items.len) return vpnl.button.items[n].show;
    return ErrForms.btn_getShow_Index_invalide ;
  }

  // return text-button  ---> arraylist panel-button
  pub fn getTitle(vpnl: *pnl.PANEL , n: usize) ErrForms ! [] const u8 {
    if ( n < vpnl.button.items.len) return vpnl.button.items[n].title;
    return ErrForms.btn_getText_Index_invalide ;
  }

  // return check-button  ---> arraylist panel-button
  // work for field input-field
  pub fn getCheck(vpnl: *pnl.PANEL , n: usize) ErrForms ! bool {
    if ( n < vpnl.button.items.len) return vpnl.button.items[n].check;
    return ErrForms.btn_getCheck_Index_invalide ;
  }

  // return ON/OFF-button  ---> arraylist panel-button
  pub fn getActif(vpnl: *pnl.PANEL , n: usize) ErrForms ! bool {
    if ( n < vpnl.button.items.len) return vpnl.button.items[n].actif;
    return ErrForms.btn_getActif_Index_invalide ;
  }

  // set show-button  ---> arraylist panel-button
  pub fn setShow(vpnl: *pnl.PANEL , n: usize, val :bool) ErrForms ! void {
    if ( n < vpnl.button.items.len)  vpnl.button.items[n].show = val
    else return ErrForms.btn_setShow_Index_invalide ;
  }

  // set text-button  ---> arraylist panel-button
  pub fn setText(vpnl: *pnl.PANEL , n: usize, val:[] const u8) ErrForms ! void {
    if ( n < vpnl.button.items.len) vpnl.button.items[n].text = val
    else return ErrForms.btn_setText_Index_invalide ;
  }

  // set chek-button  ---> arraylist panel-button
  pub fn setCheck(vpnl: *pnl.PANEL , n: usize, val :bool) ErrForms ! void {
    if ( n < vpnl.button.items.len) vpnl.button.items[n].check = val
    else return ErrForms.btn_setCheck_Index_invalide ;
  }

  // set ON/OFF-button  ---> arraylist panel-button
  pub fn setActif(vpnl: *pnl.PANEL , n: usize, val :bool) ErrForms ! void {
    if ( n < vpnl.button.items.len) vpnl.button.items[n].actif = val
    else return ErrForms.btn_setActif_Index_invalide ;
  }



  // delete -button  ---> arraylist panel-button
  pub fn dltRows(vpnl:*pnl.PANEL,  n :usize ) ErrForms ! void {
    if ( n < vpnl.button.items.len) _= vpnl.button.orderedRemove(n)
    else return ErrForms.btn_dltRows_Index_invalide ;
  }


  // assign -button MATRIX TERMINAL  ---> arraylist panel-button
  pub fn printButton(vpnl: *pnl.PANEL) void {
    if (vpnl.actif == false ) return ;
  
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
        var iter = utl.iteratStr.iterator(button.name);
        defer iter.deinit();
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

        //text Title button
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

  // define attribut default CADRE
  pub var AtrMnu : dds.ZONATRB = .{
    .styled=[_]u32{@intFromEnum(dds.Style.styleDim),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
    .backgr = dds.BackgroundColor.bgBlack,
    .foregr = dds.ForegroundColor.fgRed

  };

  pub var AtrBar : dds.ZONATRB = .{
    .styled=[_]u32{@intFromEnum(dds.Style.styleReverse),
                    @intFromEnum(dds.Style.styleItalic),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
    .backgr = dds.BackgroundColor.bgBlack,
    .foregr = dds.ForegroundColor.fgWhite

  };

  pub var AtrCell : dds.ZONATRB= .{
    .styled=[_]u32{@intFromEnum(dds.Style.styleItalic),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
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
    actif: bool
  };

  // NEW MENU
  pub fn newMenu(vname: [] const u8,
                vposx: usize, vposy: usize,
                vcadre : dds.CADRE,
                vmnuvh : dds.MNUVH,
                vitems: []const[]const u8
                ) MENU {



    var xmenu = MENU {
            .name = vname,
            .posx   = vposx,
            .posy   = vposy,
            .lines  = 0,
            .cols   = 0,
            .attribut =AtrMnu,
            .attrBar = AtrBar,
            .attrCell= AtrCell,
            .cadre = vcadre,
            .mnuvh = vmnuvh,
            .xitems  = vitems,
            .nbr = 0,
            .actif = true
        };


        for (xmenu.xitems) |txt| {
          if (xmenu.cols < txt.len) xmenu.cols = txt.len;
          xmenu.nbr +=1;
        }
        xmenu.lines += xmenu.nbr + 2; //nbr ligne  + header =cadre
        xmenu.cols  += 2;
    return xmenu;
  }


  // return index-menu  ---> arraylist panel-menu
  pub fn getIndex(vpnl: *pnl.PANEL , name: [] const u8 )  ErrForms ! usize {

    for (vpnl.menu.items, 0..) |l, idx| {
      if (std.mem.eql(u8, l.name, name)) return idx;
    }
    return ErrForms.mnu_getIndex_Name_Menu_Invalide;
  }

  // return name-menu ---> arraylist panel-menu
  pub fn getName(vpnl: *pnl.PANEL , n: usize) ErrForms ! [] const u8 {
    if ( n < vpnl.menu.items.len) return vpnl.menu.items[n].name;
    return ErrForms.mnu_getName_Index_invalide ;

  }

  // return posx-menu ---> arraylist panel-menu
  pub fn getPosx(vpnl: *pnl.PANEL , n: usize)  ErrForms ! usize {
    if ( n < vpnl.menu.items.len) return vpnl.menu.items[n].posx;
    return ErrForms.mnu_getPosx_Index_invalide ;
  }

  // return posy-menu ---> arraylist panel-menu
  pub fn getPosy(vpnl: *pnl.PANEL , n: usize)  ErrForms ! usize {
    if ( n < vpnl.menu.items.len) return vpnl.menu.items[n].posy;
    return ErrForms.mnu_getPosy_Index_invalide ;
  }

  // return Text-menu ---> arraylist panel-menu
  pub fn getText(vpnl: *pnl.PANEL , n: usize)  ErrForms ! usize {
    if ( n < vpnl.menu.items.len) return vpnl.menu.items[n].text;
    return ErrForms.mnu_getText_Index_invalide ;
  }

  // return ON/OFF-menu ---> arraylist panel-menu
  pub fn getActif(vpnl: *pnl.PANEL , n: usize)  ErrForms ! bool {
    if ( n < vpnl.menu.items.len) return vpnl.menu.items[n].actif;
    return ErrForms.mnu_getActif_Index_invalide ;
  }


  // delete -menu ---> arraylist panel-menu
  pub fn dltRows(vpnl: *pnl.PANEL,  n :usize ) ErrForms ! void {
    if ( n < vpnl.button.items.len) _= vpnl.menu.orderedRemove(n)
    else return ErrForms.mnu_dltRows_Index_invalide ;
  }


  // assign -menu MATRIX TERMINAL  ---> arraylist panel-menu
  fn printMenu(vpnl: *pnl.PANEL, vmnu: MENU) void {
    if (vpnl.actif == false ) return ;
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
      while (row <= vmnu.lines) : (row +=1) {
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
            term.gotoXY(row + vmnu.posx + vpnl.posx - 2  , col + vmnu.posy + vpnl.posy - 2);
            term.writeStyled(trait,vmnu.attribut);
          }
          else {
            term.gotoXY(row + vmnu.posx + vpnl.posx - 2  , col + vmnu.posy + vpnl.posy - 2);
            term.writeStyled(" ",vmnu.attribut);
          }

          y += 1;
          col += 1;
        }
        x += 1;
      }
    }


  }

  // display  MATRIX to terminal ---> arraylist panel-menu
  fn displayMenu(vpnl: *pnl.PANEL, vmnu:MENU, npos: usize) void {
    var pos : usize = npos;
    var n : usize = 0;
    var h : usize = 0;

    var x :usize = vmnu.posx - 1;
    var y :usize = vmnu.posy - 1;

    printMenu(vpnl, vmnu);

    term.onMouse();
    term.cursHide();


    if (npos > vmnu.nbr or npos == 0 )  pos = 0  ;

    n = 0;
    h = 0;
    for (vmnu.xitems) | cell |  {
      if (vmnu.mnuvh == dds.MNUVH.vertical) {
        if (vmnu.cadre == dds.CADRE.line0)
          term.gotoXY(vpnl.posx + x + n  ,    vpnl.posy + y  )
        else
          term.gotoXY(vpnl.posx + x + n + 1 , vpnl.posy + y  + 1);
      }
      if (vmnu.mnuvh == dds.MNUVH.horizontal) {
        if (vmnu.cadre == dds.CADRE.line0 )
          term.gotoXY(vpnl.posx + x  ,    h   + vpnl.posy + y   )
        else
          term.gotoXY(vpnl.posx + x + 1  , h  + vpnl.posy + y  + 1);
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

  // restor -panel  MATRIX to terminal ---> arraylist panel-menu 
  pub fn rstPanel( vsrc : *MENU , vdst : *pnl.PANEL) void {
    if (vdst.actif == false)  return ;
    if (vsrc.posx + vsrc.lines > vdst.posx + vdst.lines  )  return ;
    if (vsrc.posy + vsrc.cols  > vdst.posy + vdst.cols  )  return ;
    var x :usize = 0;
    var y :usize = 0;
    var n :usize = 0;
    var npos : usize =  vsrc.posx - vdst.posx;
    while (x <= vsrc.lines) : (x += 1) {
        n = vdst.cols * npos + vsrc.posy - vdst.posy  ;
        y = 0;
        while (y <= vsrc.cols) : (y += 1) {
          term.gotoXY(x + vsrc.posx   , y + vsrc.posy  );
          term.writeStyled(vdst.buf.items[n].ch,vdst.buf.items[n].attribut);
          n += 1;
        }
      npos += 1;
    }
  }
  //----------------------------------------------------------------
  // menu  enter = select  1..n 0 = abort (Escape)
  // Turning on the mouse
  // UP DOWN LEFT RIGHT
  // movement width the wheel and validation width the clik
  //----------------------------------------------------------------
  pub fn ioMenu(vpnl: *pnl.PANEL, vmnu: MENU, npos: usize) usize {
    if (vpnl.actif == false ) return 999 ;
    if (vmnu.actif == false ) return 999 ;
    var pos : usize = npos;
    var n   : usize = 0;
    var h   : usize = 0;
    var x :usize = vmnu.posx - 1;
    var y :usize = vmnu.posy - 1;

    term.onMouse();
    term.cursHide();



    if (npos > vmnu.nbr or npos == 0 )  pos = 0;


    displayMenu(vpnl,vmnu,pos);


    term.flushIO();
    while (true) {
      n = 0;
      h = 0;
      for (vmnu.xitems) | cell |  {

        if (vmnu.mnuvh == dds.MNUVH.vertical) {
          if (vmnu.cadre == dds.CADRE.line0 )
            term.gotoXY(vpnl.posx + x  + n  ,   vpnl.posy + y )
          else
            term.gotoXY(vpnl.posx + x  + n + 1, vpnl.posy + y + 1);
          }
        if (vmnu.mnuvh == dds.MNUVH.horizontal) {
          if (vmnu.cadre == dds.CADRE.line0)
            term.gotoXY(vpnl.posx + x   ,   h + vpnl.posy + y )
          else
            term.gotoXY(vpnl.posx + x  + 1, h + vpnl.posy + y + 1);
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

      if (Tkey.Key == kbd.char and
          std.mem.eql(u8,Tkey.Char," " ) ) {Tkey.Key = kbd.enter; Tkey.Char ="";}


      if (Tkey.Key == kbd.mouse) {
        Tkey.Key = kbd.none;
        if (term.MouseInfo.scroll ) {
          if ( term.MouseInfo.scrollDir == term.ScrollDirection.msUp ) {
            if (vmnu.mnuvh == dds.MNUVH.vertical)    Tkey.Key = kbd.up;
            if (vmnu.mnuvh == dds.MNUVH.horizontal)  Tkey.Key = kbd.left;
          }

          if (term.MouseInfo.scrollDir == term.ScrollDirection.msDown) {
            if (vmnu.mnuvh == dds.MNUVH.vertical)    Tkey.Key = kbd.down;
            if (vmnu.mnuvh == dds.MNUVH.horizontal)  Tkey.Key = kbd.right;
          }
        }
        else {
          if (term.MouseInfo.action == term.MouseAction.maReleased ) continue;
          switch (term.MouseInfo.button) {
            term.MouseButton.mbLeft    =>  Tkey.Key = kbd.enter,
            term.MouseButton.mbMiddle  =>  Tkey.Key = kbd.enter,
            term.MouseButton.mbRight   =>  Tkey.Key = kbd.enter,
            else => {}
          }
        }
      }

      switch (Tkey.Key) {
        .none => continue,
        .esc  => {
          term.offMouse();
          return 9999;
        },
        .enter => {
          term.offMouse();
          return pos ;
        },
        .down  => { if (pos < vmnu.nbr - 1 )  pos +=1; } ,
        .up    => { if (pos > 0 ) pos -=1; },
        .right => { if (pos < vmnu.nbr - 1 )  pos +=1; },
        .left  => { if (pos > 0 ) pos -=1; },
        else => {},
      }
    }
  }

};




// defined INPUT_FIELD
pub const  fld = struct {


  pub fn ToStr(text : [] const u8 ) []const u8 {
    return std.fmt.allocPrint(dds.allocatorStr,"{s}",.{text}) catch unreachable; 
  }

  // define attribut default Fiel
  pub var AtrField : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgWhite
  };

  // field not input
  pub var AtrNil : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.styleDim),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgdWhite
  };

  // define attribut default func ioField
  pub var AtrIO : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.styleReverse),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgWhite,
  };

  // define attribut default Field protect
  pub var AtrProtect : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.styleItalic),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgCyan,
  };

  pub var AtrCursor : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgCyan,
  };


  pub var MsgErr : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgRed
  };


  /// define FIELD
  pub const FIELD = struct {
    name :  []const u8,
    posx:   usize,
    posy:   usize,
    attribut:dds.ZONATRB,
    atrProtect:dds.ZONATRB,
    reftyp: dds.REFTYP,
    width:  usize,
    scal:   usize,
    nbrcar: usize,        // nbrcar DECIMAL = (precision+scale + 1'.' ) + 1 this signed || other nbrcar =  ALPA..DIGIT..

    tofill: bool,          // tofill or FULL
    protect: bool,        // only display

    pading: bool,         // pading blank
    edtcar: []const u8,   // edtcar for monnaie		€ $ ¥ ₪ £ or %

    regex: []const u8,    //contrôle regex
    errmsg: []const u8,   //message this field

    help: []const u8,     //help this field

    text: []const u8,
    zwitch: bool,         // CTRUE CFALSE

    procfunc: []const u8,  //name proc

    proctask: []const u8,  //name proc

    actif:bool,
  };

  // for developpeur 
  pub var MouseDsp : bool = false ;





  // New Field String ---> arraylist panel-label
  // refence type
  // TEXT_FREE,
  // ALPHA,
  // ALPHA_UPPER,
  // ALPHA_NUMERIC,
  // ALPHA_NUMERIC_UPPER,
  // ALPHA_FULL,
  // PASSWORD,
  // YES_NO,
  fn initFieldString(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vreftyp: dds.REFTYP,
                    vwidth:  usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8,
                    vregex: []const u8) FIELD {

    var xfield = FIELD {   
        .name   = vname,
        .posx   = vposx,
        .posy   = vposy,
        .reftyp = vreftyp,
        .width  = vwidth,
        .scal   = 0,
        .nbrcar = vwidth,
        .tofill  = vtofill,
        .protect = false,
        .pading  = true,
        .edtcar ="",
        .regex  = "",
        .errmsg = verrmsg,
        .help   = vhelp,
        .text   = vtext,
        .zwitch = false,
        .procfunc  ="",
        .proctask  ="",
        .attribut  = AtrField,
        .atrProtect = AtrProtect,
        .actif  = true
    };
    if (vregex.len > 0 ) xfield.regex = std.fmt.allocPrint(dds.allocatorPnl,
      "{s}",.{vregex}) catch unreachable;
    return xfield;

  }

  // New Field String  ---> arraylist panel-lfield
  // refence type
  // .TEXT_FREE
  pub fn newFieldTextFree(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vwidth:  usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8,
                    vregex: []const u8) FIELD {

    return initFieldString(vname,  vposx, vposy,
                          dds.REFTYP.TEXT_FREE,
                          vwidth, vtext, vtofill, verrmsg, vhelp, vregex);
  }

  // New Field String  ---> arraylist panel-lfield
  // letter numeric punct 
  // refence type
  // .TEXT_FULL
  pub fn newFieldTextFull(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vwidth:  usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8,
                    vregex: []const u8) FIELD {

    return initFieldString(vname,  vposx, vposy,
                          dds.REFTYP.TEXT_FULL,
                          vwidth, vtext, vtofill, verrmsg, vhelp, vregex);
  }

  // New Field String  ---> arraylist panel-lfield
  // refence type
  // .ALPHA
  pub fn newFieldAlpha(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vwidth:  usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8,
                    vregex: []const u8) FIELD {
    
    return initFieldString(vname,  vposx, vposy,
                          dds.REFTYP.ALPHA,
                          vwidth, vtext, vtofill, verrmsg, vhelp, vregex);
  }

  // New Field String  ---> arraylist panel-lfield
  // refence type
  // .ALPHA_UPPER
  pub fn newFieldAlphaUpper(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vwidth:  usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8,
                    vregex: []const u8) FIELD {

    return initFieldString(vname,  vposx, vposy,
                          dds.REFTYP.ALPHA_UPPER,
                          vwidth, vtext, vtofill, verrmsg, vhelp, vregex);
  }

  // New Field String  ---> arraylist panel-lfield
  // refence type
  // .ALPHA_NUMERIC
  pub fn newFieldAlphaNumeric(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vwidth:  usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8,
                    vregex: []const u8) FIELD {

    return initFieldString(vname,  vposx, vposy,
                          dds.REFTYP.ALPHA_NUMERIC,
                          vwidth, vtext, vtofill, verrmsg, vhelp, vregex);
  }

  // New Field String  ---> arraylist panel-lfield
  // refence type
  // .ALPHA_NUMERIC
  pub fn newFieldAlphaNumericUpper(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vwidth:  usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8,
                    vregex: []const u8) FIELD {

    return initFieldString(vname,  vposx, vposy,
                          dds.REFTYP.ALPHA_NUMERIC_UPPER,
                          vwidth, vtext, vtofill, verrmsg, vhelp, vregex);
  }

  // New Field String  ---> arraylist panel-lfield
  // refence type
  // .PASSWORD
  pub fn newFieldPassword(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vwidth:  usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8,
                    vregex: []const u8) FIELD {

    return initFieldString(vname,  vposx, vposy,
                          dds.REFTYP.PASSWORD,
                          vwidth, vtext, vtofill, verrmsg, vhelp, vregex);
  }

  // New Field String  ---> arraylist panel-lfield
  // refence type
  // .YES_NO
  pub fn newFieldYesNo(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8) FIELD {


        var xfield = FIELD {   
            .name   = vname,
            .posx   = vposx,
            .posy   = vposy,
            .reftyp = dds.REFTYP.YES_NO ,
            .width  = 1,
            .scal   = 0,
            .nbrcar = 1,
            .tofill  = vtofill,
            .protect = false,
            .pading  = false,
            .edtcar = "",
            .regex  = "",
            .errmsg = verrmsg,
            .help   = vhelp,
            .text   = vtext,
            .zwitch = false,
            .procfunc  ="",
            .proctask  ="",
            .attribut  = AtrField,
            .atrProtect = AtrProtect,
            .actif  = true
          };
                    
    if (xfield.help.len == 0 ) xfield.help = "to validate Y or N " ;

    return xfield;
  }

  // New Field Switch ---> arraylist panel-field
  // refence type
  // SWITCH,
  pub fn newFieldSwitch(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vzwitch: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8) FIELD {

    var xfield = FIELD {   
        .name   = vname,
        .posx   = vposx,
        .posy   = vposy,
        .reftyp = dds.REFTYP.SWITCH ,
        .width  = 1,
        .scal   = 0,
        .nbrcar = 1,
        .tofill  = false,
        .protect = false,
        .pading  = false,
        .edtcar = "",
        .regex  = "",
        .errmsg = verrmsg,
        .help   = vhelp,
        .text   = "",
        .zwitch = vzwitch,
        .procfunc  ="",
        .proctask  ="",
        .attribut  = AtrField,
        .atrProtect = AtrProtect,
        .actif  = true
    };

    if (xfield.help.len == 0 ) xfield.help = "check ok= ✔ not= ◉  : Select espace bar " ;

    if (xfield.zwitch == true ) xfield.text = dds.STRUE
    else xfield.text = dds.SFALSE;

    return xfield;

  }

  // New Field Date ---> arraylist panel-field
  // refence type
  // DATE_FR,
  // regex fixe standard
  // Control yyyy = 0001-9999 as well as the traditional MM 02 DAY 28 or 29 values
  // I do not take into account the offset before 1500 ... etc.
  pub fn newFieldDateFR(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8) FIELD {


    var xfield = FIELD {   
        .name   = vname,
        .posx   = vposx,
        .posy   = vposy,
        .reftyp = dds.REFTYP.DATE_FR,
        .width  = 10,
        .scal   = 0,
        .nbrcar = 10,
        .tofill  = vtofill,
        .protect = false,
        .pading  = false,
        .edtcar ="",
        .regex  = "",         
        .errmsg = verrmsg,
        .help   = vhelp,
        .text   = vtext,
        .zwitch = false,
        .procfunc  ="",
        .proctask  ="",
        .attribut  = AtrField,
        .atrProtect = AtrProtect,
        .actif  = true
    };


    xfield.regex = std.fmt.allocPrint(dds.allocatorPnl,"{s}"
    ,.{"^(0[1-9]|[12][0-9]|3[01])[\\/](0[1-9]|1[012])[\\/][0-9]{4,4}$"}) catch unreachable;

    if (xfield.help.len == 0 ) xfield.help = "ex: date DD/MM/YYYY" ;

    return xfield;

  }

  // New Field Date ---> arraylist panel-field
  // refence type
  // DATE_US,
  // regex fixe standard
  // Control yyyy = 0001-9999 as well as the traditional MM 02 DAY 28 or 29 values
  // I do not take into account the offset before 1500 ... etc.
  pub fn newFieldDateUS(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8) FIELD {


    var xfield = FIELD {   
        .name   = vname,
        .posx   = vposx,
        .posy   = vposy,
        .reftyp = dds.REFTYP.DATE_US,
        .width  = 10,
        .scal   = 0,
        .nbrcar = 10,
        .tofill  = vtofill,
        .protect = false,
        .pading  = false,
        .edtcar ="",
        .regex  = "",         
        .errmsg = verrmsg,
        .help   = vhelp,
        .text   = vtext,
        .zwitch = false,
        .procfunc  ="",
        .proctask  ="",
        .attribut  = AtrField,
        .atrProtect = AtrProtect,
        .actif  = true
    };

    xfield.regex = std.fmt.allocPrint(dds.allocatorPnl,"{s}"
    ,.{"^(0[1-9]|1[012])[\\/](0[1-9]|[12][0-9]|3[01])[\\/][0-9]{4,4}$" }) catch unreachable;

    if (xfield.help.len == 0 ) xfield.help = "ex: date MM/DD/YYYY";

    return xfield;

  }


  // New Field Date ---> arraylist panel-field
  // refence type
  // DATE_ISO,
  // regex fixe standard
  // Control yyyy = 0001-9999 as well as the traditional MM 02 DAY 28 or 29 values
  // I do not take into account the offset before 1500 ... etc.
  pub fn newFieldDateISO(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8) FIELD {


    var xfield = FIELD {   
        .name   = vname,
        .posx   = vposx,
        .posy   = vposy,
        .reftyp = dds.REFTYP.DATE_ISO,
        .width  = 10,
        .scal   = 0,
        .nbrcar = 10,
        .tofill  = vtofill,
        .protect = false,
        .pading  = false,
        .edtcar ="",
        .regex  = "",         
        .errmsg = verrmsg,
        .help   = vhelp,
        .text   = vtext,
        .zwitch = false,
        .procfunc  ="",
        .proctask  ="",
        .attribut  = AtrField,
        .atrProtect = AtrProtect,
        .actif  = true
    };


    xfield.regex = std.fmt.allocPrint(dds.allocatorPnl,"{s}"
    ,.{"^([0-9]{4,4})[-](0[1-9]|1[012])[-](0[1-9]|[12][0-9]|3[01])$"}) catch unreachable;

    if (xfield.help.len == 0 )  xfield.help = "ex: date YYYY-MM-DD" ;

    return xfield;

  }


  // New Field Mail ---> arraylist panel-field
  // refence type
  // MAIL_ISO,
  // regex fixe standard
  pub fn newFieldMail(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vwidth:  usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8) FIELD {

    var xfield = FIELD {   
        .name   = vname,
        .posx   = vposx,
        .posy   = vposy,
        .reftyp = dds.REFTYP.MAIL_ISO,
        .width  = vwidth,
        .scal   = 0,
        .nbrcar = vwidth,
        .tofill  = vtofill,
        .protect = false,
        .pading  = true,
        .edtcar ="",
        .regex  ="",
        .errmsg = verrmsg,
        .help   = vhelp,
        .text   = vtext,
        .zwitch = false,
        .procfunc  ="",
        .proctask  ="",
        .attribut  = AtrField,
        .atrProtect = AtrProtect,
        .actif  = true
    };


      // https://stackoverflow.com/questions/201323/how-can-i-validate-an-email-address-using-a-regular-expression
      // chapitre RFC 6532 updates 5322 to allow and include full, clean UTF-8.
      xfield.regex = std.fmt.allocPrint(dds.allocatorPnl,"{s}"
      ,.{"^([-!#-\'*+\\/-9=?A-Z^-~]{1,64}(\\.[-!#-\'*+\\/-9=?A-Z^-~]{1,64})*|\"([]!#-[^-~ \t]|(\\[\t -~]))+\")@[0-9A-Za-z]([0-9A-Za-z-]{0,61}[0-9A-Za-z])?(\\.[0-9A-Za-z]([0-9A-Za-z-]{0,61}[0-9A-Za-z])?)+$"}) catch unreachable;
      
      if (xfield.help.len == 0 ) xfield.help = "ex: myname.myfirstname@gmail.com" ;
        
    return xfield;

  }


  // New Field telephone ---> arraylist panel-field
  // refence type
  // TELEPHONE,
  // regex fixe standard
  pub fn newFieldTelephone(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vwidth:  usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8,
                    vregex: []const u8) FIELD {

      var xfield = FIELD {   
        .name   = vname,
        .posx   = vposx,
        .posy   = vposy,
        .reftyp = dds.REFTYP.TELEPHONE,
        .width  = vwidth,
        .scal   = 0,
        .nbrcar = vwidth,
        .tofill  = vtofill,
        .protect = false,
        .pading  = true,
        .edtcar ="",
        .regex  = "",
        .errmsg = verrmsg,
        .help   = vhelp,
        .text   = vtext,
        .zwitch = false,
        .procfunc  ="",
        .proctask  ="",
        .attribut  = AtrField,
        .atrProtect = AtrProtect,
        .actif  = true
      };

      if (vregex.len > 0 ) xfield.regex = std.fmt.allocPrint(dds.allocatorPnl,
      "^{s}",.{vregex}) catch unreachable;
      // regex standar
      if (vregex.len == 0 ) xfield.regex = std.fmt.allocPrint(dds.allocatorPnl,"{s}"
      ,.{"^[+]{1,1}[(]{0,1}[0-9]{1,3}[)]([0-9]{1,3}){1,1}([-. ]?[0-9]{2,3}){2,4}$"}) catch unreachable;

      if (xfield.help.len == 0 ) xfield.help = "ex fr : +(33)6.12.131.141" ;

    return xfield;

  }

  // New Field Digit  ---> arraylist panel-lfield
  // refence type
  // .DIGIT unsigned
  pub fn newFieldUDigit(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vwidth:  usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8,
                    vregex: []const u8) FIELD {

    var xfield = FIELD {   
        .name   = vname,
        .posx   = vposx,
        .posy   = vposy,
        .reftyp = dds.REFTYP.UDIGIT,
        .width  = vwidth,
        .scal   = 0,
        .nbrcar = vwidth,
        .tofill  = vtofill,
        .protect = false,
        .pading  = true,
        .edtcar ="",
        .regex  = vregex,
        .errmsg = verrmsg,
        .help   = vhelp,
        .text   = vtext,
        .zwitch = false,
        .procfunc  ="",
        .proctask  ="",
        .attribut  = AtrField,
        .atrProtect = AtrProtect,
        .actif  = true
    };

      if (vregex.len == 0 ) {
        xfield.regex = std.fmt.allocPrint(dds.allocatorPnl,"^[0-9]{{1,{d}}}$",.{xfield.width}) catch unreachable;
      }
      if (xfield.help.len == 0 ) xfield.help = "ex: 0..9" ;

    return xfield;
  }

  // New Field DIGIT  ---> arraylist panel-lfield
  // refence type
  // .DIGIT SIGNED
  pub fn newFieldDigit(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vwidth:  usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8,
                    vregex: []const u8) FIELD {

    var xfield = FIELD {   
        .name   = vname,
        .posx   = vposx,
        .posy   = vposy,
        .reftyp = dds.REFTYP.DIGIT,
        .width  = vwidth,
        .scal   = 0,
        .nbrcar = 0,
        .tofill  = vtofill,
        .protect = false,
        .pading  = true,
        .edtcar ="",
        .regex  = vregex,
        .errmsg = verrmsg,
        .help   = vhelp,
        .text   = vtext,
        .zwitch = false,
        .procfunc  ="",
        .proctask  ="",
        .attribut  = AtrField,
        .atrProtect = AtrProtect,
        .actif  = true
    };
      xfield.nbrcar = xfield.width + xfield.scal  + 1 ;
      if (vregex.len == 0 ) {
        xfield.regex = std.fmt.allocPrint(dds.allocatorPnl,"^[+-][0-9]{{1,{d}}}$",.{xfield.width}) catch unreachable;
      }
      if (xfield.help.len == 0 ) xfield.help = "ex: +0..9" ;

    return xfield;
  }

  // New Field Decimal  ---> arraylist panel-lfield
  // refence type
  // .DECIMAL UNSIGNED
  pub fn newFieldUDecimal(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vwidth:  usize,
                    vscal:  usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8,
                    vregex: []const u8) FIELD {

    var xfield = FIELD {   
        .name   = vname,
        .posx   = vposx,
        .posy   = vposy,
        .reftyp = dds.REFTYP.UDECIMAL,
        .width  = vwidth,
        .scal   = vscal,
        .nbrcar = 0,
        .tofill  = vtofill,
        .protect = false,
        .pading  = true,
        .edtcar ="",
        .regex  = vregex,
        .errmsg = verrmsg,
        .help   = vhelp,
        .text   = vtext,
        .zwitch = false,
        .procfunc  ="",
        .proctask  ="",
        .attribut  = AtrField,
        .atrProtect = AtrProtect,
        .actif  = true
    };

    // caculate len = width add scal add .  
    if (vscal == 0 ) xfield.nbrcar = xfield.width 
    else xfield.nbrcar = xfield.width + xfield.scal  + 1 ;

    if (vregex.len == 0 ) {
      if (vscal == 0 ) xfield.regex = std.fmt.allocPrint(dds.allocatorPnl,
      "^[0-9]{{1,{d}}}$",.{vwidth})  catch unreachable
      else xfield.regex = std.fmt.allocPrint(dds.allocatorPnl,
      "^[0-9]{{1,{d}}}[.][0-9]{{{d}}}$",.{vwidth,vscal,})  catch unreachable;
    }
    if (xfield.help.len == 0 ) xfield.help = "ex: 12301 or 123.01" ;

    return xfield;
  }

  // New Field Decimal  ---> arraylist panel-lfield
  // refence type
  // .DECIMAL SIGNED
  pub fn newFieldDecimal(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vwidth: usize,
                    vscal:  usize,
                    vtext: []const u8,
                    vtofill: bool,
                    verrmsg: []const u8,
                    vhelp: []const u8,
                    vregex: []const u8) FIELD {

    var xfield = FIELD {   
        .name   = vname,
        .posx   = vposx,
        .posy   = vposy,
        .reftyp = dds.REFTYP.DECIMAL,
        .width  = vwidth,
        .scal   = vscal,
        .nbrcar = 0,
        .tofill  = vtofill,
        .protect = false,
        .pading  = true,
        .edtcar ="",
        .regex  = vregex,
        .errmsg = verrmsg,
        .help   = vhelp,
        .text   = vtext,
        .zwitch = false,
        .procfunc  ="",
        .proctask  ="",
        .attribut  = AtrField,
        .atrProtect = AtrProtect,
        .actif  = true
    };

    // caculate len = width add scal add + . 
    if (vscal == 0 ) xfield.nbrcar = xfield.width + 1
    else xfield.nbrcar = xfield.width + xfield.scal  + 2 ;
    if (vregex.len == 0 ) {

      if (vscal == 0 ) xfield.regex =  std.fmt.allocPrint(dds.allocatorPnl,
      "^[+-][0-9]{{1,{d}}}$",.{vwidth})  catch unreachable
      else xfield.regex = std.fmt.allocPrint(dds.allocatorPnl,
      "^[+-][0-9]{{1,{d}}}[.][0-9]{{{d}}}$",.{vwidth,vscal}) catch unreachable;

    }
    if (xfield.help.len == 0 ) xfield.help = "ex: +12301 or +123.01" ;

    return xfield;
  }


  // New Field Switch ---> arraylist panel-field
  // refence type
  // FUNC,
  pub fn newFieldFunc(vname: [] const u8,
                    vposx: usize, vposy: usize,
                    vwidth: usize,
                    vtext: []const u8,
                    vtofill: bool,
                    vprocfunc:  [] const u8,
                    verrmsg: []const u8,
                    vhelp: []const u8) FIELD {

    var xfield = FIELD {   
        .name   = vname,
        .posx   = vposx,
        .posy   = vposy,
        .reftyp = dds.REFTYP.FUNC,
        .width  = vwidth,
        .scal   = 0,
        .nbrcar = vwidth,
        .tofill  = vtofill,
        .protect = false,
        .pading  = false,
        .edtcar = "",
        .regex  = "",
        .errmsg = verrmsg,
        .help   = vhelp,
        .text   = vtext,
        .zwitch = false,
        .procfunc  =vprocfunc,
        .proctask  ="",
        .attribut  = AtrField,
        .atrProtect = AtrProtect,
        .actif  = true
    };

    if (xfield.help.len == 0 ) xfield.help = " Select espace bar " ;
    return xfield;

  }
  //========================================================================
  //========================================================================
  pub fn getIndex(vpnl: *pnl.PANEL , name: [] const u8 )  ErrForms ! usize {
    for (vpnl.field.items, 0..) |f, idx | {
      if (std.mem.eql(u8, f.name, name)) return idx;
    }
    return ErrForms.fld_getIndex_Name_Field_Invalide;
  }

  pub fn getName(vpnl: *pnl.PANEL , n: usize) ErrForms ! [] const u8 {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].name;
    return ErrForms.fld_getName_Index_invalide ;

  }
  pub fn getPosx(vpnl: *pnl.PANEL , n: usize)  ErrForms ! usize {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].posx;
    return ErrForms.fld_getPosx_Index_invalide ;
  }
  pub fn getPosy(vpnl: *pnl.PANEL , n: usize)  ErrForms ! usize {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].posy;
    return ErrForms.fld_getPosy_Index_invalide ;
  }
  pub fn getRefType(vpnl: *pnl.PANEL , n: usize)  ErrForms ! dds.REFTYP {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].reftyp;
    return ErrForms.fld_getRefType_Index_invalide ;
  }
  pub fn getWidth(vpnl: *pnl.PANEL , n: usize)  ErrForms ! usize {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].width;
    return ErrForms.fld_getWidth_Index_invalide ;
  }
  pub fn getScal(vpnl: *pnl.PANEL , n: usize)  ErrForms ! usize {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].scal;
    return ErrForms.fld_getScal_Index_invalide ;
  }
  pub fn getNbrCar(vpnl: *pnl.PANEL , n: usize)  ErrForms ! usize {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].nbrcar;
    return ErrForms.fld_getNbrCar_Index_invalide ;
  }
  pub fn gettofill(vpnl: *pnl.PANEL , n: usize)  ErrForms ! bool {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].tofill;
    return ErrForms.fld_gettofill_Index_invalide ;
  }
  pub fn getProtect(vpnl: *pnl.PANEL , n: usize)  ErrForms ! bool {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].protect;
    return ErrForms.fld_getProtect_Index_invalide ;
  }
  pub fn getPading(vpnl: *pnl.PANEL , n: usize)  ErrForms ! bool {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].pading;
    return ErrForms.fld_getPading_Index_invalide ;
  }
  pub fn getEdtcar(vpnl: *pnl.PANEL , n: usize)  ErrForms ! [] const u8 {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].edtcar;
    return ErrForms.fld_getEdtcar_Index_invalide ;
  }
  pub fn getRegex(vpnl: *pnl.PANEL , n: usize)  ErrForms ! [] const u8 {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].regex;
    return ErrForms.fld_getRegex_Index_invalide ;
  }
  pub fn getErrMsg(vpnl: *pnl.PANEL , n: usize)  ErrForms ! [] const u8 {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].errmsg;
    return ErrForms.fld_getErrMsg_Index_invalide ;
  }
  pub fn getHelp(vpnl: *pnl.PANEL , n: usize)  ErrForms ! [] const u8 {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].help;
    return ErrForms.fld_getHelp_Index_invalide ;
  }
  pub fn getText(vpnl: *pnl.PANEL , n: usize)  ErrForms ! [] const u8 {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].text;
    return ErrForms.fld_getText_Index_invalide ;
  }
  pub fn getSwitch(vpnl: *pnl.PANEL , n: usize)  ErrForms ! bool {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].zwitch;
    return ErrForms.fld_getSwitch_Index_invalide ;
  }
  pub fn getErr(vpnl: *pnl.PANEL , n: usize)  ErrForms ! bool {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].err;
    return ErrForms.fld_getErr_Index_invalide ;
  }
  pub fn getFunc(vpnl: *pnl.PANEL , n: usize)  ErrForms ! [] const u8 {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].procfunc;
    return ErrForms.fld_getFunc_Index_invalide ;
  }
  pub fn getTask(vpnl: *pnl.PANEL , n: usize)  ErrForms ! [] const u8 {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].proctask;
    return ErrForms.fld_getTask_Index_invalide ;
  }

  pub fn getAttribut(vpnl: *pnl.PANEL , n: usize)  ErrForms ! dds.ZONATRB {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].atribut;
    return ErrForms.fld_getAttribut_Index_invalide ;
  }
  pub fn getAtrProtect(vpnl: *pnl.PANEL , n: usize)  ErrForms ! dds.ZONATRB {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].atrProtect;
    return ErrForms.fld_AtrProtect_Index_invalide ;
  }
  pub fn getActif(vpnl: *pnl.PANEL , n: usize)  ErrForms ! bool {
    if ( n < vpnl.field.items.len) return vpnl.field.items[n].actif;
    return ErrForms.fld_getActif_Index_invalide ;
  }


  pub fn setText(vpnl: *pnl.PANEL , n: usize, val:[] const u8) ErrForms ! void {
    if ( n < vpnl.field.items.len) vpnl.field.items[n].text = val
    else return ErrForms.fld_setText_Index_invalide;
  }

  //  Input Field 
  pub fn setSwitch(vpnl: *pnl.PANEL , n: usize, val :bool)  ErrForms ! void {
    if ( n < vpnl.field.items.len) {
      vpnl.field.items[n].zwitch = val;
      vpnl.field.items[n].text = utl.boolToCbool(val);
    }
    else return ErrForms.fld_setSwitch_Index_invalide;

  }
  pub fn setProtect(vpnl: *pnl.PANEL , n: usize, val :bool)  ErrForms ! void {
    if ( n < vpnl.field.items.len)  vpnl.field.items[n].protect = val
    else return ErrForms.fld_setProtect_Index_invalide;
  }
  pub fn setEdtcar(vpnl: *pnl.PANEL , n: usize, val:[] const u8)  ErrForms ! void {
    if ( n < vpnl.field.items.len) vpnl.field.items[n].edtcar = val
    else return ErrForms.fld_setEdtcar_Index_invalide;
  }
  pub fn setRegex(vpnl: *pnl.PANEL , n: usize, val:[] const u8)  ErrForms ! void {
    if ( n < vpnl.field.items.len) vpnl.field.items[n].reftyp = val
    else return ErrForms.fld_setRegex_Index_invalide;
  }
  pub fn setTask(vpnl: *pnl.PANEL , n: usize, val :[]const u8)  ErrForms ! void {
    if ( n < vpnl.field.items.len) vpnl.field.items[n].proctask = val
    else return ErrForms.fld_setActif_Index_invalide;
  }
  pub fn setActif(vpnl: *pnl.PANEL , n: usize, val :bool)  ErrForms ! void {
    if ( n < vpnl.field.items.len) vpnl.field.items[n].actif = val
    else return ErrForms.fld_setActif_Index_invalide;
  }

  pub fn dltRows(vpnl: *pnl.PANEL,  n :usize ) ErrForms ! void {
    if ( n < vpnl.field.items.len)  _= vpnl.field.orderedRemove(n)
    else return ErrForms.fld_dltRows_Index_invalide;
  }


  // clear value ALL FIELD
  pub fn clearAll(vpnl: *pnl.PANEL) void {
    var n : usize = 0;
    for (vpnl.field.items) |_ | {
      vpnl.field.items[n].text = "";
      vpnl.field.items[n].zwitch = false;
      n += 1 ;
    }
  }
  pub fn clearField(vpnl: *pnl.PANEL , n: usize,)  void {
    if ( n > vpnl.field.items.len) return;
    vpnl.field.items[n].text = "";
    vpnl.field.items[n].zwitch = false;
  }


  // matrix cleaning from Field
  pub fn clsField(vpnl: *pnl.PANEL, vfld : FIELD )  void {
    // display matrice PANEL
    if (vpnl.actif == false ) return ;
    if (vfld.actif == false ) return ;
      var x :usize = vfld.posx - 1;
      var y :usize = vfld.posy - 1;
      var n :usize = 0;
      var npos :usize = (vpnl.cols * vfld.posx) + vfld.posy - 1 ;
      while (n < vfld.nbrcar) : (n += 1) {
        vpnl.buf.items[npos].ch = " ";
        vpnl.buf.items[npos].attribut  = vpnl.attribut;
        vpnl.buf.items[npos].on = false;
        term.gotoXY(x + vpnl.posx   , y + vpnl.posy - n  );
        term.writeStyled(vpnl.buf.items[npos].ch,vpnl.buf.items[npos].attribut);
        npos += 1;
      }
  }


  pub fn printField(vpnl: *pnl.PANEL, vfld : FIELD) void {
    if ( vpnl.actif == false ) return ; 
    // assigne FIELD to matrice for display
    var n = (vpnl.cols * (vfld.posx - 1)) + vfld.posy - 1;
    var nn: usize = 0;

    while (nn < vfld.nbrcar) : (nn += 1 ) {
      if (vfld.actif == true) {
        vpnl.buf.items[n].ch = " " ;
        if (vfld.protect == false) vpnl.buf.items[n].attribut = vfld.attribut
        else vpnl.buf.items[n].attribut  = vpnl.attribut;
        vpnl.buf.items[n].on = true;
      }
      else {
        vpnl.buf.items[n].ch = "";
        vpnl.buf.items[n].attribut  = vpnl.attribut;
        vpnl.buf.items[n].on = false;
      }
      n += 1;
    }

    // The err field takes precedence, followed by protection, followed by the base attribute
    n = (vpnl.cols * (vfld.posx - 1)) + vfld.posy - 1  ;

    var nfld = vfld.text;
    var nile = false ;
    if (nfld.len == 0 and !vfld.protect ) {
      nfld ="_";
      nile = true;
    }
    if (vfld.reftyp == dds.REFTYP.SWITCH) {
            nile = false;
            if ( vfld.zwitch ) nfld = dds.STRUE
            else nfld= dds.SFALSE;
    } 
    var iter = utl.iteratStr.iterator(nfld);
    defer iter.deinit();
    while (iter.next()) |ch| {
      if (vfld.actif == true ) {
        if (vfld.reftyp == dds.REFTYP.PASSWORD) vpnl.buf.items[n].ch = "*" 
        else vpnl.buf.items[n].ch = ch ;

        vpnl.buf.items[n].on = true;

        if (vfld.protect) vpnl.buf.items[n].attribut  = vfld.atrProtect
        else {
            if (nile)vpnl.buf.items[n].attribut  = AtrNil
            else vpnl.buf.items[n].attribut = vfld.attribut;
        }

      }
      n += 1;
    }
  }

  pub fn displayField(vpnl: *pnl.PANEL, vfld : FIELD )  void {
    // display matrice PANEL
    if (vpnl.actif == false ) return ;
    if (vfld.actif == false ) return ;
      var x :usize = vfld.posx - 1;
      var y :usize = vfld.posy - 1;
      var n :usize = 0;
      var npos :usize = (vpnl.cols * (vfld.posx - 1)) + vfld.posy - 1 ;
      while (n < vfld.nbrcar) : (n += 1) {
        term.gotoXY(x + vpnl.posx   , y + vpnl.posy + n  );
        term.writeStyled(vpnl.buf.items[npos].ch,vpnl.buf.items[npos].attribut);
        npos += 1;
      }
  }


  //----------------------------------------------------==
  // Input buffer management modeled on 5250/3270
  // inspiration ncurse
  // application hold principe and new langage
  //----------------------------------------------------==

  var e_FIELD : std.ArrayList([] const u8) = undefined;

  var e_switch: bool = false;

  fn nbrCarField() usize {
    var wl : usize =0;
    var iter = utl.iteratStr.iterator(utl.listToStr(e_FIELD));
    defer iter.deinit();
    while (iter.next()) |_|  { wl += 1 ;}
    return wl;
  }

  fn delete(n : usize) void {
    _=e_FIELD.orderedRemove(n);
    e_FIELD.append(" ") catch unreachable;
  }

  fn insert(c: [] const u8 , n : usize) void {
    _=e_FIELD.orderedRemove(nbrCarField() - 1);

    const allocator = std.heap.page_allocator;
    var x_FIELD = std.ArrayList([] const u8).init(allocator);
    defer x_FIELD.deinit();

    for ( e_FIELD.items) |ch | {
      x_FIELD.append(ch) catch unreachable ;
    }
    e_FIELD.clearRetainingCapacity();


    for ( x_FIELD.items ,0..) |ch , idx | {
      if ( n != idx) e_FIELD.append(ch) catch unreachable ;
      if ( n == idx) { 
        e_FIELD.append(c) catch unreachable ;
        e_FIELD.append(ch) catch unreachable ;
      } 
    }
  }



  fn istofill() bool {
    var text = utl.listToStr(e_FIELD);
    text = utl.trimStr(text);

    if (text.len == 0 ) return true ;
    return false ;
  }
  
  /// Check if it is a space
  fn isSpace(c: [] const u8) bool { 
    if ( std.mem.eql(u8, c, " ") ) return true;
    return false ;
  }

  /// if it is a KEY function
  fn isfuncKey(vpnl: *pnl.PANEL, e_key: term.Keyboard) bool {
    for ( vpnl.button.items) |xbtn| {
      if (xbtn.key == e_key.Key ) return true;
    }
    return false;
  }
  
  /// if it is a KEY function Check
  fn ischeckKey(vpnl: *pnl.PANEL, e_key: term.Keyboard) bool {
    for ( vpnl.button.items) |xbtn| {
      if (xbtn.key == e_key.Key and xbtn.check ) return true;
    }
    return false;
  }
  
  /// Hides the area entered with *
  fn password(s: std.ArrayList([] const u8)) [] const u8 {
    var i: usize = 0;
    var buf : [] const u8 = "";
    while ( i < s.items.len ) : (i += 1) {
        if ( std.mem.eql(u8,s.items[i]," " )) buf = utl.concatStr(buf," ") 
        else  buf = utl.concatStr(buf,"*");
    }
    return buf;
  }

  /// initialize the input field e_FIELD
  /// switch convert bool CTRUE /CFALSE
  /// the buffer displays field the text and completes with blanks
  fn initData(f:FIELD) void {
    e_FIELD.clearRetainingCapacity();
    if ( f.reftyp == dds.REFTYP.SWITCH) {
      if (e_switch == true ) 
        utl.addListStr(&e_FIELD  , dds.STRUE)  
      else
        utl.addListStr(&e_FIELD  , dds.SFALSE);
    }
    else {
        utl.addListStr(&e_FIELD  , f.text);
      var i:usize = 0 ;
      while (i < f.nbrcar - f.text.len) : ( i += 1) {
        e_FIELD.append(" ") catch unreachable;
      }
    }
  }


  fn msgHelp(vpnl: *pnl.PANEL, f : FIELD ) void {

    // define attribut default MSG Error
    const MsgHelp : dds.ZONATRB = .{
        .styled=[_]u32{@intFromEnum(dds.Style.notStyle),
                      @intFromEnum(dds.Style.notStyle),
                      @intFromEnum(dds.Style.notStyle),
                      @intFromEnum(dds.Style.notStyle)},
        .backgr = dds.BackgroundColor.bgBlack,
        .foregr = dds.ForegroundColor.fgRed
    };


    var x: usize  = vpnl.lines;
    var n: usize  = vpnl.cols * (x - 2) ;
    var y: usize  = 1 ;

    var msghlp:[]const u8 = utl.concatStr("Help : ", f.help) ;
    var boucle : bool= true ;

    if (vpnl.cols < (msghlp.len) )  msghlp = utl.subStr(msghlp,0,  vpnl.cols - 2) catch |err| {dsperr.errorForms(err); return;};

    // clear line button 
    while (y <= (vpnl.cols - 2) ) : (y += 1) {
      term.gotoXY(vpnl.posx + x  - 2   , y + vpnl.posy );
      term.writeStyled(" ",vpnl.attribut);
    }
    // display msgerr
    y = 1 ;
    term.gotoXY(vpnl.posx + x  - 2, y + vpnl.posy );
    term.writeStyled(msghlp,MsgHelp);

    while (boucle) {
      var e_key = kbd.getKEY();

      switch ( e_key.Key ) {
        .esc=>boucle = false,
      else =>  {},
      }
    }

    // restore line panel
    y = 1 ;
    while (y <= (vpnl.cols - 2)) : (y += 1) {
      n += 1;
      term.gotoXY( vpnl.posx + x  - 2, y + vpnl.posy);
      term.writeStyled(vpnl.buf.items[n].ch,vpnl.buf.items[n].attribut);
    }
  }

  ///------------------------------------------------
  /// Definition of the panel (window) on a lines
  /// Message display
  /// to exit press the Escape key
  /// restoration of the original panel lines
  ///------------------------------------------------

  pub fn msgErr(vpnl: *pnl.PANEL, f : FIELD,  info: [] const u8 ) void {

    term.gotoXY(vpnl.posx + f.posx - 1 , vpnl.posy + f.posy - 1);
    term.writeStyled(utl.listToStr(e_FIELD),MsgErr);


    var x: usize  = vpnl.lines;
    var n: usize  = vpnl.cols * (x - 2) ;
    var y: usize  = 1 ;

    var msgerr:[]const u8 = utl.concatStr("Info : ", info) ;
    var boucle : bool= true ;

    if (vpnl.cols < (msgerr.len) )  msgerr = utl.subStr(msgerr, 0,  vpnl.cols - 2) catch |err| {dsperr.errorForms(err); return;};

    // clear line button 
    while (y <= (vpnl.cols - 2) ) : (y += 1) {
      term.gotoXY(vpnl.posx + x  - 2   , y + vpnl.posy  );
      term.writeStyled(" ",vpnl.attribut);
    }
    // display msgerr
    y = 1 ;
    term.gotoXY(vpnl.posx + x  - 2, y + vpnl.posy   );
    term.writeStyled(msgerr,MsgErr);

    while (boucle) {
      var e_key = kbd.getKEY();

      switch ( e_key.Key ) {
        .esc=>boucle = false,
      else =>  {},
      }
    }

    // restore line panel
    while (y <= (vpnl.cols - 2)) : (y += 1) {
      n += 1;
      term.gotoXY( vpnl.posx + x  - 2, y + vpnl.posy  );
      term.writeStyled(vpnl.buf.items[n].ch,vpnl.buf.items[n].attribut);
    }
  }


  //====================================================
  // ioFIELD
  //====================================================
  
  pub fn ioField(vpnl: *pnl.PANEL, vfld : FIELD ) kbd  {
    if (vfld.protect or !vfld.actif)  return kbd.none;

    var e_posx :usize = vpnl.posx + vfld.posx - 1;
    var e_posy :usize = vpnl.posy + vfld.posy - 1;
    var e_curs :usize = e_posy ;
    var e_count :usize  = 0;
    const e_nbrcar:usize  = vfld.nbrcar;
    var statusCursInsert : bool = false ;
    var nfield :usize = 0 ;

    const allocator = std.heap.page_allocator;
    e_FIELD = std.ArrayList([] const u8).init(allocator);
    defer e_FIELD.deinit();
    
    e_switch = vfld.zwitch;
    const e_reftyp = vfld.reftyp;

    var tampon: [] const u8 = undefined;

    if ( e_posx == 0) return kbd.enter;
    
    vpnl.keyField = kbd.none;
    
    // prepare the switch edition
    initData(vfld);

    var Fkey : term.Keyboard = undefined ;
    var boucle : bool= true ;

    term.defCursor(dds.typeCursor.cBlink);

    term.onMouse();


    //===========================
    // boucle saisie
    //===========================
    while( boucle == true) {
      

      term.gotoXY(e_posx ,e_posy);
      switch(e_reftyp) {
        .PASSWORD =>  term.writeStyled(password(e_FIELD),AtrIO) ,
        .SWITCH   =>  if (e_switch) term.writeStyled(dds.STRUE,AtrIO)
                      else term.writeStyled(dds.SFALSE,AtrIO),
        else => term.writeStyled(utl.listToStr(e_FIELD),AtrIO)
      }

      term.gotoXY(e_posx,e_curs);

      if (statusCursInsert) term.defCursor(dds.typeCursor.cSteadyBar)  
      else term.defCursor(dds.typeCursor.cBlink); // CHANGE CURSOR FORM BAR/BLOCK

      switch(e_reftyp) {
        .PASSWORD => { 
                      if ( std.mem.eql(u8,e_FIELD.items[e_count] , " ")  ) term.writeStyled(" ", AtrCursor)
                      else term.writeStyled("*", AtrCursor);
        },
        else =>term.writeStyled(e_FIELD.items[e_count], AtrCursor),
      }
      term.gotoXY(e_posx,e_curs);
      term.cursShow();

      Fkey = kbd.getKEY();

      term.resetStyle();

      if (isfuncKey(vpnl,Fkey)) boucle = false
      else {
        if (Fkey.Key == kbd.mouse ) {
          Fkey.Key = kbd.none;

          if (term.MouseInfo.scroll ) {
              switch (term.MouseInfo.scrollDir) {
              term.ScrollDirection.msUp =>    Fkey.Key = kbd.up,
              term.ScrollDirection.msDown =>  Fkey.Key = kbd.down,
              else => {}
              }
          }
          else {
        
            if (term.MouseInfo.action == term.MouseAction.maReleased ) continue;
            
            if (MouseDsp) dspMouse(vpnl);  // active display Cursor x/y mouse

            switch (term.MouseInfo.button) {
              term.MouseButton.mbLeft    =>  Fkey.Key = kbd.left,

              term.MouseButton.mbMiddle  =>  Fkey.Key = kbd.enter,

              term.MouseButton.mbRight   =>  Fkey.Key = kbd.right,
              else => {}
            }
          }
        }



        switch(Fkey.Key) {
          .none => {
                  term.gotoXY(e_posx,e_curs);
          },
          .esc => {
                  initData(vfld) ;
          }, 
          .ctrlH => {
            if (  vfld.help.len > 0 ) msgHelp(vpnl,vfld);
          },
          .home => {
            e_count = 0;
            e_curs = e_posy;
          },
          .end => {
            tampon  = utl.listToStr(e_FIELD);
            if ( utl.trimStr(tampon).len > 0) {
              e_count = utl.trimStr(tampon).len - 1;
              e_curs  = e_posy + utl.trimStr(tampon).len - 1;
            }
            else {
              e_count = 0 ;
              e_curs  = e_posy;
            }
          },
          .right , .tab  => {
            if ( e_count < e_nbrcar - 1 and !isSpace(e_FIELD.items[0])) {
                e_count += 1;
                e_curs  += 1;
            }
          },
          .left , .stab=> {
            if( e_curs > e_posy) {
            e_count -= 1;
            e_curs  -= 1;
            }
          },
          .backspace => {
            if( e_reftyp != dds.REFTYP.SWITCH) {
              delete(e_count);
              tampon  = utl.listToStr(e_FIELD);
              if( e_count > 0 ) {
                e_count = utl.trimStr(tampon).len - 1 ;
                e_curs  = e_posy + e_count;
              }
              else {e_count = 0; e_curs  = e_posy ;}
            }
          },
          .delete=> {
            if( e_reftyp != dds.REFTYP.SWITCH) {
              if( e_count >= 0) {
                if (e_reftyp == dds.REFTYP.DIGIT  and e_count >= 0 or  e_reftyp == dds.REFTYP.DECIMAL and e_count >= 0 ) {
                    delete(e_count);
                  }
                  else if (e_reftyp != dds.REFTYP.DIGIT   and  e_reftyp != dds.REFTYP.DECIMAL)  {
                          delete(e_count);
                        }
              }
            }
          },
          .ins=> {
            if( statusCursInsert )  statusCursInsert = false
            else statusCursInsert = true;
          },
          .enter , .up , .down => {  // enrg to Field

            //check tofill and field.len > 0
            if (vfld.tofill and utl.trimStr(utl.listToStr(e_FIELD)).len == 0 ) {
              msgErr(vpnl,vfld,vfld.errmsg);
              e_curs = e_posy;
              e_count = 0;
              continue;
            }

            //check tofill and field.len > 0 and regexLen > 0 execute regex
            if ( vfld.regex.len > 0 and vfld.tofill and utl.trimStr(utl.listToStr(e_FIELD)).len > 0) {
                if ( ! reg.isMatch(utl.trimStr(utl.listToStr(e_FIELD)) ,vfld.regex) ) {
                  msgErr(vpnl,vfld,vfld.errmsg);
                  e_curs = e_posy;
                  e_count = 0 ;
                  continue;
                }
            }


            //write value keyboard to field.text return key
            nfield = getIndex(vpnl,vfld.name) catch unreachable;

            if (vfld.reftyp == dds.REFTYP.SWITCH) setSwitch(vpnl, nfield, e_switch ) catch unreachable
            
            else {
              
              setText(vpnl, nfield, ToStr(utl.trimStr(utl.listToStr(e_FIELD)))) catch unreachable;
            }
            vpnl.keyField = Fkey.Key; 
            // control is task 
            if ( vfld.proctask.len > 0) {
              Fkey.Key = kbd.task;
              break; 
            }
            

            break;          
          },
          .char=> {
            if (utl.isCarOmit(Fkey.Char) == false ) 
              switch(e_reftyp) {
                .TEXT_FREE=> {
                  if ( (e_count < e_nbrcar and isSpace(Fkey.Char) == false ) or
                    (isSpace(Fkey.Char) == true and e_count > 0 and e_count < e_nbrcar) ) {
                    
                    if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
                    else  e_FIELD.items[e_count] = Fkey.Char;

                    e_count += 1;
                    e_curs  += 1;
                    if (e_count == e_nbrcar) {
                      e_count -= 1;
                      e_curs  -= 1;
                    }
                    

                  }
                },
                .TEXT_FULL=> {
                  if ( (e_count < e_nbrcar and isSpace(Fkey.Char) == false ) or
                    (utl.isLetterStr(Fkey.Char) or utl.isDigitStr(Fkey.Char) or utl.isSpecialStr(Fkey.Char)) or
                    (isSpace(Fkey.Char) == true and e_count > 0 and e_count < e_nbrcar) ) {
                    
                    if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
                    else  e_FIELD.items[e_count] = Fkey.Char;

                    e_count += 1;
                    e_curs  += 1;
                    if (e_count == e_nbrcar) {
                      e_count -= 1;
                      e_curs  -= 1;
                    }
                    

                  }
                },
                .ALPHA, .ALPHA_UPPER => {
                  if ( (e_count < e_nbrcar and isSpace(Fkey.Char) == false ) and
                  (utl.isLetterStr(Fkey.Char) or std.mem.eql(u8, Fkey.Char, "-")) or
                  (isSpace(Fkey.Char) == true and e_count > 0 and e_count < e_nbrcar) ) {
                    
                    if (vfld.reftyp == .ALPHA_UPPER) Fkey.Char = utl.upperStr(Fkey.Char);

                    if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
                    else  e_FIELD.items[e_count] = Fkey.Char;

                    e_count += 1;
                    e_curs  += 1;
                    if (e_count == e_nbrcar) {
                      e_count -= 1;
                      e_curs  -= 1;
                    }
                  }
                },
                .ALPHA_NUMERIC, .ALPHA_NUMERIC_UPPER => {
                  if ( (e_count < e_nbrcar and isSpace(Fkey.Char) == false ) and
                  (utl.isLetterStr(Fkey.Char) or utl.isDigitStr(Fkey.Char) or std.mem.eql(u8, Fkey.Char, "-")) or
                  (isSpace(Fkey.Char) == true and e_count > 0 and e_count < e_nbrcar) ) {

                    if (vfld.reftyp == .ALPHA_NUMERIC_UPPER) Fkey.Char = utl.upperStr(Fkey.Char);

                    if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
                    else  e_FIELD.items[e_count] = Fkey.Char;

                    e_count += 1;
                    e_curs  += 1;
                    if (e_count == e_nbrcar) {
                      e_count -= 1;
                      e_curs  -= 1;
                    }
                  }
                },
                .PASSWORD => {
                  if ( (e_count < e_nbrcar and isSpace(Fkey.Char) == false ) and
                  (utl.isPassword(Fkey.Char) ) ) {

                    if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
                    else  e_FIELD.items[e_count] = Fkey.Char;

                    e_count += 1;
                    e_curs  += 1;
                    if (e_count == e_nbrcar) {
                      e_count -= 1;
                      e_curs  -= 1;
                    }
                  }
                },
                .YES_NO => {
                  if (std.mem.eql(u8, Fkey.Char, "Y")  or
                      std.mem.eql(u8, Fkey.Char, "y")  or 
                      std.mem.eql(u8, Fkey.Char, "N")  or 
                      std.mem.eql(u8, Fkey.Char, "n")  ) {
                    
                    Fkey.Char = utl.upperStr(Fkey.Char);

                    if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
                    else  e_FIELD.items[e_count] = Fkey.Char;
                    }
                },
                .UDIGIT => {
                  if (e_count < e_nbrcar and utl.isDigitStr(Fkey.Char)  and 
                    ! std.mem.eql(u8, Fkey.Char, "-") and
                    ! std.mem.eql(u8, Fkey.Char, "+")  ) {
                    
                    if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
                    else  e_FIELD.items[e_count] = Fkey.Char;

                    e_count += 1;
                    e_curs  += 1;
                    if (e_count == e_nbrcar) {
                      e_count -= 1;
                      e_curs  -= 1;
                    }
                  }
                },
                .DIGIT => {
                  if (e_count < e_nbrcar and utl.isDigitStr(Fkey.Char) and e_count > 0 or
                    (std.mem.eql(u8, Fkey.Char, "-") and e_count == 0) or
                    (std.mem.eql(u8, Fkey.Char, "+") and e_count == 0)) {
                    
                    if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
                    else  e_FIELD.items[e_count] = Fkey.Char;

                    e_count += 1;
                    e_curs  += 1;
                    if (e_count == e_nbrcar) {
                      e_count -= 1;
                      e_curs  -= 1;
                    }
                  }
                },
                .UDECIMAL => {
                  if (e_count < e_nbrcar and utl.isDigitStr(Fkey.Char) or 
                    (std.mem.eql(u8, Fkey.Char, ".") and e_count > 1) or
                    !std.mem.eql(u8, Fkey.Char, "-") and ! std.mem.eql(u8, Fkey.Char, "+") ) {

                    if (vfld.scal == 0 and std.mem.eql(u8, Fkey.Char, ".") ) continue ;
                    

                    if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
                    else  e_FIELD.items[e_count] = Fkey.Char;

                    e_count += 1;
                    e_curs  += 1;
                    if (e_count == e_nbrcar) {
                      e_count -= 1;
                      e_curs  -= 1;
                    }
                    
                  }
                },
                .DECIMAL => {
                  if (e_count < e_nbrcar and utl.isDigitStr(Fkey.Char) and e_count > 0 or 
                    (std.mem.eql(u8, Fkey.Char, ".") and e_count > 1) or
                    (std.mem.eql(u8, Fkey.Char, "-") and e_count == 0) or
                    (std.mem.eql(u8, Fkey.Char, "+") and e_count == 0)) {

                    if (vfld.scal == 0 and std.mem.eql(u8, Fkey.Char, ".") ) continue;                 

                    if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
                    else  e_FIELD.items[e_count] = Fkey.Char;

                    e_count += 1;
                    e_curs  += 1;
                    if (e_count == e_nbrcar) {
                      e_count -= 1;
                      e_curs  -= 1;
                    }
                    
                  }
                },
                .DATE_ISO => {
                  if (e_count < e_nbrcar) {
                    if (( utl.isDigitStr(Fkey.Char) and e_count <= 3) or
                        ( utl.isDigitStr(Fkey.Char) and e_count == 5 ) or
                        ( utl.isDigitStr(Fkey.Char) and e_count == 6 ) or
                        ( utl.isDigitStr(Fkey.Char) and e_count == 8 ) or
                        ( utl.isDigitStr(Fkey.Char) and e_count == 9 ) or
                        (std.mem.eql(u8, Fkey.Char, "-") and e_count == 4) or
                        (std.mem.eql(u8, Fkey.Char, "-") and e_count == 7) ) {
                    
                      if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
                      else  e_FIELD.items[e_count] = Fkey.Char;

                      e_count += 1;
                      e_curs  += 1;
                      if (e_count == e_nbrcar) {
                        e_count -= 1;
                        e_curs  -= 1;
                      }
                    }
                  }
                },
                .DATE_FR , .DATE_US  => {
                  if (e_count < e_nbrcar ) {
                    if (( utl.isDigitStr(Fkey.Char) and e_count <= 1) or
                        ( utl.isDigitStr(Fkey.Char) and e_count == 3 ) or
                        ( utl.isDigitStr(Fkey.Char) and e_count == 4 ) or
                        ( utl.isDigitStr(Fkey.Char) and e_count >= 6 ) or
                        (std.mem.eql(u8, Fkey.Char, "/") and e_count == 2) or
                        (std.mem.eql(u8, Fkey.Char, "/") and e_count == 5) ) {
                      
                      if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
                      else  e_FIELD.items[e_count] = Fkey.Char;

                      e_count += 1;
                      e_curs  += 1;
                      if (e_count == e_nbrcar) {
                        e_count -= 1;
                        e_curs  -= 1;
                      }
                    }
                  }
                },
                .TELEPHONE=> {
                  if ((e_count < e_nbrcar ) and
                      (utl.isDigitStr(Fkey.Char) or 
                      std.mem.eql(u8, Fkey.Char, "(") or
                      std.mem.eql(u8, Fkey.Char, ")") or
                      std.mem.eql(u8, Fkey.Char, " ") or
                      std.mem.eql(u8, Fkey.Char, "+") or
                      std.mem.eql(u8, Fkey.Char, "-") or
                      std.mem.eql(u8, Fkey.Char, ".") ) ){
                    
                    if (statusCursInsert) insert(Fkey.Char,e_count)
                    else  e_FIELD.items[e_count] = Fkey.Char;

                    e_count += 1;
                    e_curs  += 1;
                    if (e_count == e_nbrcar) {
                      e_count -= 1;
                      e_curs  -= 1;
                    }
                  }
                },
                .MAIL_ISO => {
                  if (e_count < e_nbrcar and isSpace(Fkey.Char) == false and 
                    utl.isMailStr(Fkey.Char)) {
                    
                    if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
                    else  e_FIELD.items[e_count] = Fkey.Char;

                    e_count += 1;
                    e_curs  += 1;
                    if (e_count == e_nbrcar) {
                      e_count -= 1;
                      e_curs  -= 1;
                    }
                    

                  }
                },
                .SWITCH => {
                  if (isSpace(Fkey.Char)) {
                    
                    if (e_switch == false) {
                      e_FIELD.items[e_count] = dds.STRUE;
                      e_switch = true;
                    }
                    else {
                      e_FIELD.items[e_count] = dds.SFALSE;
                      e_switch = false;
                    }
                  }
                },
                .FUNC => {
                  Fkey.Key =kbd.func;
                  break;},
                else => {},
              };
              
          },
          else => {},
          
        }
      }
    }


    return Fkey.Key;
  }

};


// defined Panel
pub const  pnl = struct {

  // define attribut default PANELallocatorPnl
  pub var AtrPanel : dds.ZONATRB = .{
      .styled=[_]u32{@intFromEnum(dds.Style.styleDim),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle),
                    @intFromEnum(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgBlack,
      .foregr = dds.ForegroundColor.fgWhite
  };


  pub var MsgErr : dds.ZONATRB = .{
        .styled=[_]u32{@intFromEnum(dds.Style.notStyle),
                      @intFromEnum(dds.Style.notStyle),
                      @intFromEnum(dds.Style.notStyle),
                      @intFromEnum(dds.Style.notStyle)},
        .backgr = dds.BackgroundColor.bgBlack,
        .foregr = dds.ForegroundColor.fgRed
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

    label: std.ArrayList(lbl.LABEL),

    button: std.ArrayList(btn.BUTTON),

    menu: std.ArrayList(mnu.MENU),

    field: std.ArrayList(fld.FIELD),

    linev: std.ArrayList(lnv.LINE),

    lineh: std.ArrayList(lnh.LINE),

    // double buffer screen
    buf:std.ArrayList(TERMINAL_CHAR),

    idxfld: usize,

    key   : kbd ,     // Func task

    keyField : kbd ,  // enter up down

    actif: bool
  };


  // Init Panel for arrayList exemple Gencurs modlPanel
  pub fn initPanel(vname: [] const u8,
                  vposx: usize, vposy: usize,
                  vlines: usize,
                  vcols: usize,
                  vcadre : dds.CADRE,
                  vtitle: [] const u8 ) PANEL {

    var xpanel = PANEL {
          .name   = vname,
          .posx   = vposx,
          .posy   = vposy,
          .lines  = vlines,
          .cols   = vcols,
          .attribut = AtrPanel,
          .frame = undefined,
          .label  = std.ArrayList(lbl.LABEL).init(dds.allocatorPnl),
          .button = std.ArrayList(btn.BUTTON).init(dds.allocatorPnl),
          .menu   = std.ArrayList(mnu.MENU).init(dds.allocatorPnl),
          .field  = std.ArrayList(fld.FIELD).init(dds.allocatorPnl),
          .linev  = std.ArrayList(lnv.LINE).init(dds.allocatorPnl),
          .lineh  = std.ArrayList(lnh.LINE).init(dds.allocatorPnl),
          .buf    = std.ArrayList(TERMINAL_CHAR).init(dds.allocatorPnl),
          .idxfld = 9999,
          .key    =  kbd.none,
          .keyField = kbd.none,
          .actif  = true,
    };
    // INIT doublebuffer
    var i:usize = (xpanel.lines+1) * (xpanel.cols+1);
    var doublebuffer = TERMINAL_CHAR  { .ch =  " ",
                                        .attribut = xpanel.attribut,
                                        .on = false};

    // init matrix
    while (true) {
        if (i == 0) break ;
        xpanel.buf.append(doublebuffer) catch {
                                    std.debug.print("newPanel err={}\n", .{ErrForms.Invalide_Panel});
                                    _= kbd.getKEY(); 
                                    break ;
                                  };
        i -=1 ;
    }


    // init frame Panel
    xpanel.frame = frm.newFrame(xpanel.name,
                              1 , 1,  // border panel
                              xpanel.lines, xpanel.cols,
                              vcadre, frm.AtrFrame,
                              vtitle, frm.AtrTitle );

    return xpanel;

  }


  // decl New Panel use programe style C commun allocator
  pub  fn newPanelC(vname: [] const u8,
                  vposx: usize, vposy: usize,
                  vlines: usize,
                  vcols: usize,
                  vcadre : dds.CADRE,
                  vtitle: [] const u8 ) *PANEL {

    var device = dds.allocatorPnl.create(PANEL) catch unreachable ;

    device.name   = vname;
    device.posx   = vposx;
    device.posy   = vposy;
    device.lines  = vlines;
    device.cols   = vcols;
    device.attribut = AtrPanel;
    device.frame = undefined;
    device.label  = std.ArrayList(lbl.LABEL).init(dds.allocatorPnl);
    device.button = std.ArrayList(btn.BUTTON).init(dds.allocatorPnl);
    device.menu   = std.ArrayList(mnu.MENU).init(dds.allocatorPnl);
    device.field  = std.ArrayList(fld.FIELD).init(dds.allocatorPnl);
    device.linev  = std.ArrayList(lnv.LINE).init(dds.allocatorPnl);
    device.lineh  = std.ArrayList(lnh.LINE).init(dds.allocatorPnl);
    device.buf    = std.ArrayList(TERMINAL_CHAR).init(dds.allocatorPnl);
    device.idxfld = 9999;
    device.key    =  kbd.none;
    device.keyField = kbd.none;
    device.actif  = true;


    // INIT doublebuffer
    var i:usize = (device.lines+1) * (device.cols+1);
    var doublebuffer = TERMINAL_CHAR  { .ch =  " ",
                                        .attribut = device.attribut,
                                        .on = false};

    // init matrix
    while (true) {
        if (i == 0) break ;
        device.buf.append(doublebuffer) catch {
                                    std.debug.print("newPanel err={}\n", .{ErrForms.Invalide_Panel});
                                    _= kbd.getKEY(); 
                                    break;
                                  };
        i -=1 ;
    }


    // init frame Panel
    device.frame = frm.newFrame(device.name,
                              1 , 1,  // border panel
                              device.lines, device.cols,
                              vcadre, frm.AtrFrame,
                              vtitle, frm.AtrTitle );

    return device;

  }

  pub fn initMatrix(vpnl: *PANEL) void {
    vpnl.buf.deinit();
    vpnl.buf    = std.ArrayList(TERMINAL_CHAR).init(dds.allocatorPnl);

        // INIT doublebuffer
    var i:usize = (vpnl.lines+1) * (vpnl.cols+1);
    var doublebuffer = TERMINAL_CHAR  { .ch =  " ",
                                        .attribut = vpnl.attribut,
                                        .on = false};

    // init matrix
    while (true) {
        if (i == 0) break ;
        vpnl.buf.append(doublebuffer) catch unreachable;
        i -=1 ;
    }
  }


  pub fn freePanel(vpnl: *PANEL) void {
    vpnl.label.clearAndFree();
    vpnl.button.clearAndFree();
    vpnl.field.clearAndFree();
    vpnl.menu.clearAndFree();
    vpnl.lineh.clearAndFree();
    vpnl.linev.clearAndFree();
    vpnl.buf.clearAndFree();
    vpnl.label.deinit();
    vpnl.button.deinit();
    vpnl.field.deinit();
    vpnl.menu.deinit();
    vpnl.lineh.deinit();
    vpnl.linev.deinit();
    vpnl.buf.deinit();
  }


  pub fn getName(vpnl: *PANEL)  [] const u8 {
    return vpnl.name;
  }
  pub fn getPosx(vpnl: *PANEL) usize {
    return vpnl.posx;
  }
  pub fn getPosy(vpnl: *PANEL) usize {
    return vpnl.posy;
  }
  pub fn getCols(vpnl: *PANEL) usize {
    return vpnl.cols;
  }
  pub fn getLines(vpnl: *PANEL) usize {
    return vpnl.lines;
  }
  pub fn getTitle(vpnl: *PANEL)  [] const u8 {
    return vpnl.frame.title;
  }
  pub fn getIdxfld(vpnl: *PANEL) usize {
    return vpnl.idxfld;
  }
  pub fn getActif(vpnl: *PANEL) bool {
    return vpnl.actif;
  }

  pub fn setIdxfld(vpnl: *PANEL , n :usize) void {
    vpnl.idxfld = n ;
  }
  pub fn setActif(vpnl: *PANEL , b :bool) void {
    vpnl.items.actif = b ;
  }


  pub fn displayPanel(vpnl: *PANEL)  void {
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
  pub fn clsPanel( vpnl : *PANEL) void {
    var x :usize = 0;
    var y :usize = 0;
    var n :usize = 0;

    while (x < vpnl.lines) : (x += 1) {
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
  
  // clear Panel
  pub fn clearPanel( vpnl : *PANEL) void {

    vpnl.idxfld =9999;

    vpnl.keyField =kbd.none;

    for (vpnl.field.items, 0..) |_, idx| {
      vpnl.field.items[idx].text =" ";
      vpnl.field.items[idx].zwitch =false;

    }
  }
  // restor -panel  MATRIX to terminal ---> arraylist panel
  pub fn rstPanel( vsrc : *PANEL , vdst : *PANEL) void {
    if (vdst.actif == false)  return ;
    if (vsrc.posx + vsrc.lines > vdst.posx + vdst.lines  )  return ;
    if (vsrc.posy + vsrc.cols  > vdst.posy + vdst.cols  )  return ;
    var x :usize = 0;
    var y :usize = 0;
    var n :usize = 0;
    var npos : usize =  vdst.posx - vsrc.posx;
    
    while (x < vsrc.lines) : (x += 1) {
        n = (vdst.cols * npos) + (vdst.posy - vsrc.posy) ;
        y = 0;
        while (y < vsrc.cols) : (y += 1) {
          term.gotoXY(x + vsrc.posx   , (y + vsrc.posy) );
          term.writeStyled(vdst.buf.items[n].ch,vdst.buf.items[n].attribut);
          n += 1;
        }
      npos += 1;
    }
  }

  /// print PANEL
  pub fn printPanel  (vpnl: *PANEL) void {
    if ( vpnl.actif == false ) return; 

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

    // FIELD
    for (vpnl.field.items) |fldprt| {
      if (fldprt.actif) fld.printField(vpnl, fldprt);
    }

    // BUTTON
    if (vpnl.button.items.len > 0) {

      btn.printButton(vpnl);
    }
    
    // LINE Vertical
    for (vpnl.linev.items) |lnvprt| {
      if (lnvprt.actif) lnv.printLine(vpnl, lnvprt);
    }
        
    // LINE Horizontal
    for (vpnl.lineh.items) |lnhprt| {
      if (lnhprt.actif) lnh.printLine(vpnl, lnhprt);
    }



    displayPanel(vpnl);
  }

  pub fn msgErr(vpnl: *PANEL, info: [] const u8) void {

    var x: usize  = vpnl.lines;
    var n: usize  = vpnl.cols * (x - 2) ;
    var y: usize  = 1 ;


    var msgerr:[]const u8 = utl.concatStr("Info : ", info);

    if (vpnl.cols < (msgerr.len) )  msgerr = utl.subStr(msgerr, 0, vpnl.cols - 2) catch |err| {dsperr.errorForms(err); return;};


    while (y <= (vpnl.cols - 2) ) : (y += 1) {
      term.gotoXY(vpnl.posx + x  - 2  , y + vpnl.posy  );
      term.writeStyled(" ",vpnl.attribut);
    }
    y = 1 ;
    term.gotoXY(vpnl.posx + x  - 2 , y + vpnl.posy   );
    term.writeStyled(msgerr,MsgErr);

    while (true) {
      var e_key = kbd.getKEY();
      switch ( e_key.Key ) {
        .esc => break,
      else =>  {},
      }
    }


    while (y <= (vpnl.cols - 2)) : (y += 1) {
      n += 1;
      term.gotoXY(vpnl.posx + x  - 2, y + vpnl.posy  );
      term.writeStyled(vpnl.buf.items[n].ch,vpnl.buf.items[n].attribut);
    }
    
  }

  /// Check if it is a KEY function
  fn isPanelKey(vpnl:  *PANEL, e_key: kbd) bool {
    for ( vpnl.button.items) |xbtn| {
    if (xbtn.key == e_key ) return true;
    }
    return false;
  }

  /// if it is a KEY function Check
  fn isPanelCtrl( vpnl: *PANEL, e_key: kbd)  bool {
    for ( vpnl.button.items) |xbtn| {
    if ( xbtn.check and xbtn.key == e_key ) return true;
    }
    return false;
  }

  ///search there available field
  fn isNextIO(vpnl: *PANEL, idx : usize ) usize {
    var i : usize = idx + 1;
    while ( i < vpnl.field.items.len) : (i += 1) {
      if (vpnl.field.items[i].actif)
        if (!vpnl.field.items[i].protect ) break ;
    }
    return i;
  }

  ///search there available field
  fn isPriorIO(vpnl: *PANEL, idx : usize) usize {
    var i : usize = idx - 1;
    if ( i < 0) i = 0;
    while ( i > 0 ) : (i -= 1) {
      if (vpnl.field.items[i].actif)
        if (!vpnl.field.items[i].protect ) break ;
    }
    return i;
  }


  pub fn isValide(vpnl: *PANEL) bool {
    if (vpnl.actif == false ) return  false ;


    for (vpnl.field.items, 0..) |f, idx| {
      if ( !f.protect and f.actif) {
        //check tofill and field.len > 0
        if (f.tofill and utl.trimStr(f.text).len == 0 ) {
            vpnl.idxfld = idx;
            return false;
        }
        //check tofill and field.len > 0 and regexLen > 0 execute regex
        if ( f.regex.len > 0 and f.tofill and utl.trimStr(f.text).len > 0) {
            if ( !reg.isMatch(utl.trimStr(f.text) ,f.regex)) {
              vpnl.idxfld = idx;
              return false;
            }
        }
        // function call proctask            
      }
    }
    vpnl.idxfld = 0;
    return true;

  }

  ///------------------------------------------------------
  /// Format management including zones
  /// idxfld == 9999 print panel else position field
  /// keyboard proction keys are returned to the calling procedure
  ///
  /// only the key CtrlH = Aide / Help for field
  ///
  /// Reserved keys for FIELD management
  /// traditionally  UP, DOWN, TAB, STAB, CtrlA,
  /// ENTER, HOME, END, RIGTH, LEFt, BACKSPACE, DELETE, INSERT
  /// FUNC Triggered by ioField function
  /// predefined and customizable REGEX control
  /// CALL to be planned in the future with  call execve job
  /// ATTN to be planned in the future with thread job
  ///------------------------------------------------------
  pub fn ioPanel(vpnl: *PANEL) kbd {
    if (vpnl.actif == false ) return  kbd.none;

    var nField :usize = 0;
    var fld_key : kbd =  kbd.enter;
    var nbrFieldIO : usize = vpnl.field.items.len;


    if ( vpnl.idxfld == 9999) {
        printPanel(vpnl); 
        nField = 0;
    } else {

      switch(vpnl.key ) { 
        .func => nField = vpnl.idxfld,
        .task => {
              nField = vpnl.idxfld;
              switch(vpnl.keyField) {
                .enter => {
                  if ( nField + 1 > nbrFieldIO - 1 ) nField = 0
                  else nField= isNextIO(vpnl,nField);
                  vpnl.idxfld = nField;
                },
                .up  => {
                  if (nField == 0) nField = nbrFieldIO - 1
                  else nField= isPriorIO(vpnl,nField);
                  vpnl.idxfld = nField;
                },
                .down  => {
                  if (nField  + 1 > nbrFieldIO - 1) nField = 0
                  else nField= isNextIO(vpnl,nField);
                  vpnl.idxfld = nField;
                },
                else => nField = vpnl.idxfld,
              }
            },
        else => nField = vpnl.idxfld,    
      }
    }

    vpnl.keyField = kbd.none; 
    

    while (true) {

      if (nbrFieldIO == 0)  {
        var vKey= kbd.getKEY();

        if (isPanelKey(vpnl,vKey.Key)) {
          vpnl.idxfld = 9999;
          return vKey.Key;
        }
        continue ;
      }
      else 
        if ( !vpnl.field.items[nField ].protect and vpnl.field.items[nField ].actif) {

          fld.printField(vpnl,vpnl.field.items[nField ]);
          fld.displayField(vpnl,vpnl.field.items[nField ]);

          fld_key = fld.ioField(vpnl,vpnl.field.items[nField ]);

          fld.printField(vpnl,vpnl.field.items[nField ]);
          fld.displayField(vpnl,vpnl.field.items[nField ]);
        
          vpnl.key = kbd.none;

          // function call procfunc            
          if (fld_key == kbd.func ) {
            vpnl.idxfld = nField;
            vpnl.key = kbd.func;
            return fld_key;
          }
          // function call proctask            
          if (fld_key == kbd.task) {
            vpnl.idxfld = nField;
            vpnl.key = kbd.task;
            return fld_key;
          }


          

          
          // control validity
          if (isPanelKey(vpnl,fld_key )) {
            if (!isPanelCtrl(vpnl,fld_key)){
                vpnl.idxfld = nField ;
                return fld_key;
              }
            else {
              if (isValide(vpnl)) {
                return fld_key;
              }
              else { 
                msgErr(vpnl,"Format invalide");
                nField = vpnl.idxfld ;
                fld_key = kbd.none ;
              }
            }

          }
        }

      switch(fld_key) {
        .enter  => {
          if ( nField + 1 > nbrFieldIO - 1 ) nField = 0
          else nField= isNextIO(vpnl,nField);
          vpnl.idxfld = nField;
        },
        .up  => {
          if (nField == 0) nField = nbrFieldIO - 1
          else nField= isPriorIO(vpnl,nField);
          vpnl.idxfld = nField;
        },
        .down  => {
          if (nField  + 1 > nbrFieldIO - 1) nField = 0
          else nField= isNextIO(vpnl,nField);
          vpnl.idxfld = nField;
        },
        else => {}

      }
    }
  }                  

};
