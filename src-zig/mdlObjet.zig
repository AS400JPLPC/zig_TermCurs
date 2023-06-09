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

const allocator = std.heap.page_allocator;

var NPANEL = std.ArrayList(pnl.PANEL).init(allocator);
var numPanel: usize = undefined;

pub const ErrMain = error{
    main_append_NPANEL_invalide,
    main_run_EnumFunc_invalide,
    main_run_EnumTask_invalide,
    main_loadPanel_allocPrint_invalide,
    main_updatePanel_allocPrint_invalide,
    main_NPANEL_invalide,
};

const lp01 = enum {
    F_shw,
    F_chk,
    F_txt,
    alt_shw,
    alt_chk,
    alt_txt,
    ctrl_shw,
    ctrl_chk,
    ctrl_txt,
    lnh1,
    lnv1,
    lnv2,
};
// field panel pFmt01
const fp01 = enum(u9) {
    name = 0,
    posx,
    posy,
    lines,
    cols,
    cadre,
    title,
    // field function F01..F24

    F1,
    F1_shw,
    F1_chk,
    F1_txt,
    F2,
    F2_shw,
    F2_chk,
    F2_txt,
    F3,
    F3_shw,
    F3_chk,
    F3_txt,
    F4,
    F4_shw,
    F4_chk,
    F4_txt,
    F5,
    F5_shw,
    F5_chk,
    F5_txt,
    F6,
    F6_shw,
    F6_chk,
    F6_txt,
    F7,
    F7_shw,
    F7_chk,
    F7_txt,
    F8,
    F8_shw,
    F8_chk,
    F8_txt,
    F9,
    F9_shw,
    F9_chk,
    F9_txt,
    F10,
    F10_shw,
    F10_chk,
    F10_txt,
    F11,
    F11_shw,
    F11_chk,
    F11_txt,
    F12,
    F12_shw,
    F12_chk,
    F12_txt,
    F13,
    F13_shw,
    F13_chk,
    F13_txt,
    F14,
    F14_shw,
    F14_chk,
    F14_txt,
    F15,
    F15_shw,
    F15_chk,
    F15_txt,
    F16,
    F16_shw,
    F16_chk,
    F16_txt,
    F17,
    F17_shw,
    F17_chk,
    F17_txt,
    F18,
    F18_shw,
    F18_chk,
    F18_txt,
    F19,
    F19_shw,
    F19_chk,
    F19_txt,
    F20,
    F20_shw,
    F20_chk,
    F20_txt,
    F21,
    F21_shw,
    F21_chk,
    F21_txt,
    F22,
    F22_shw,
    F22_chk,
    F22_txt,
    // field function altA..altZ

    altA,
    altA_shw,
    altA_chk,
    altA_txt,
    altB,
    altB_shw,
    altB_chk,
    altB_txt,
    altC,
    altC_shw,
    altC_chk,
    altC_txt,
    altD,
    altD_shw,
    altD_chk,
    altD_txt,
    altE,
    altE_shw,
    altE_chk,
    altE_txt,
    altF,
    altF_shw,
    altF_chk,
    altF_txt,
    altG,
    altG_shw,
    altG_chk,
    altG_txt,
    altH,
    altH_shw,
    altH_chk,
    altH_txt,
    altI,
    altI_shw,
    altI_chk,
    altI_txt,
    altJ,
    altJ_shw,
    altJ_chk,
    altJ_txt,
    altK,
    altK_shw,
    altK_chk,
    altK_txt,
    altL,
    altL_shw,
    altL_chk,
    altL_txt,
    altM,
    altM_shw,
    altM_chk,
    altM_txt,
    altN,
    altN_shw,
    altN_chk,
    altN_txt,
    altO,
    altO_shw,
    altO_chk,
    altO_txt,
    altP,
    altP_shw,
    altP_chk,
    altP_txt,
    altQ,
    altQ_shw,
    altQ_chk,
    altQ_txt,
    altR,
    altR_shw,
    altR_chk,
    altR_txt,
    altS,
    altS_shw,
    altS_chk,
    altS_txt,
    altT,
    altT_shw,
    altT_chk,
    altT_txt,
    altU,
    altU_shw,
    altU_chk,
    altU_txt,
    altV,
    altV_shw,
    altV_chk,
    altV_txt,
    altW,
    altW_shw,
    altW_chk,
    altW_txt,
    altX,
    altX_shw,
    altX_chk,
    altX_txt,
    altY,
    altY_shw,
    altY_chk,
    altY_txt,
    altZ,
    altZ_shw,
    altZ_chk,
    altZ_txt,

    // field function ctrlA..ctrlZ

    ctrlA,
    ctrlA_shw,
    ctrlA_chk,
    ctrlA_txt,
    ctrlB,
    ctrlB_shw,
    ctrlB_chk,
    ctrlB_txt,
    ctrlC,
    ctrlC_shw,
    ctrlC_chk,
    ctrlC_txt,
    ctrlD,
    ctrlD_shw,
    ctrlD_chk,
    ctrlD_txt,
    ctrlE,
    ctrlE_shw,
    ctrlE_chk,
    ctrlE_txt,
    ctrlF,
    ctrlF_shw,
    ctrlF_chk,
    ctrlF_txt,
    ctrlI_shw,
    ctrlI_chk,
    ctrlI_txt,
    ctrlJ,
    ctrlJ_shw,
    ctrlJ_chk,
    ctrlJ_txt,
    ctrlK,
    ctrlK_shw,
    ctrlK_chk,
    ctrlK_txt,
    ctrlL,
    ctrlL_shw,
    ctrlL_chk,
    ctrlL_txt,
    ctrlM,
    ctrlM_shw,
    ctrlM_chk,
    ctrlM_txt,
    ctrlN,
    ctrlN_shw,
    ctrlN_chk,
    ctrlN_txt,
    ctrlO,
    ctrlO_shw,
    ctrlO_chk,
    ctrlO_txt,
    ctrlP,
    ctrlP_shw,
    ctrlP_chk,
    ctrlP_txt,
    ctrlQ,
    ctrlQ_shw,
    ctrlQ_chk,
    ctrlQ_txt,
    ctrlR,
    ctrlR_shw,
    ctrlR_chk,
    ctrlR_txt,
    ctrlS,
    ctrlS_shw,
    ctrlS_chk,
    ctrlS_txt,
    ctrlT,
    ctrlT_shw,
    ctrlT_chk,
    ctrlT_txt,
    ctrlU,
    ctrlU_shw,
    ctrlU_chk,
    ctrlU_txt,
    ctrlV,
    ctrlV_shw,
    ctrlV_chk,
    ctrlV_txt,
    ctrlW,
    ctrlW_shw,
    ctrlW_chk,
    ctrlW_txt,
    ctrlX,
    ctrlX_shw,
    ctrlX_chk,
    ctrlX_txt,
    ctrlY,
    ctrlY_shw,
    ctrlY_chk,
    ctrlY_txt,
    ctrlZ,
    ctrlZ_shw,
    ctrlZ_chk,
    ctrlZ_txt,
};

pub const FPANEL = struct { name: []const u8, posx: usize, posy: usize, lines: usize, cols: usize, cadre: dds.CADRE, title: []const u8, button: std.ArrayList(btn.BUTTON) };

pub fn Panel_Fmt01() pnl.PANEL {
    var Panel = pnl.initPanel("FRAM01", 1, 1, 42, 158, dds.CADRE.line1, "Def.Objet");

    Panel.menu.append(mnu.newMenu("cadre", // name
        8, 12, // posx, posy
        dds.CADRE.line1, // type line fram
        dds.MNUVH.vertical, // type menu vertical / horizontal
        &.{ // item
        "Noline",
        "Line 1",
        "Line 2",
    })) catch unreachable;
    return Panel;
}

// function special for developpeur
// activat onMouse
// pose X/Y = clik mouse
fn dspMouse(vpnl: *pnl.PANEL) void {
    const AtrDebug: dds.ZONATRB = .{
        .styled = [_]u32{ @enumToInt(dds.Style.notStyle), @enumToInt(dds.Style.notStyle), @enumToInt(dds.Style.notStyle), @enumToInt(dds.Style.notStyle) },
        .backgr = dds.BackgroundColor.bgBlack,
        .foregr = dds.ForegroundColor.fgRed,
    };

    var msg = std.fmt.allocPrint(allocator, "{d:0>2}{s}{d:0>3}", .{ term.MouseInfo.x, "/", term.MouseInfo.y }) catch unreachable;
    term.gotoXY(vpnl.posx + vpnl.lines - 1, (vpnl.posy + vpnl.cols - 1) - 7);
    term.writeStyled(msg, AtrDebug);
    term.gotoXY(term.MouseInfo.x, term.MouseInfo.y);
}

fn dspCursor(vpnl: *pnl.PANEL, x_posx: usize, x_posy: usize) void {
    const AtrDebug: dds.ZONATRB = .{
        .styled = [_]u32{ @enumToInt(dds.Style.notStyle), @enumToInt(dds.Style.notStyle), @enumToInt(dds.Style.notStyle), @enumToInt(dds.Style.notStyle) },
        .backgr = dds.BackgroundColor.bgBlack,
        .foregr = dds.ForegroundColor.fgRed,
    };

    var msg = std.fmt.allocPrint(allocator, "{d:0>2}{s}{d:0>3}", .{ x_posx, "/", x_posy }) catch unreachable;
    term.gotoXY(vpnl.posx + vpnl.lines - 1, (vpnl.posy + vpnl.cols - 1) - 7);
    term.writeStyled(msg, AtrDebug);
    term.gotoXY(x_posx, x_posy);
}

//=================================================
// description Function
// choix work panel
pub fn qryPanel(vpnl: std.ArrayList(pnl.PANEL), frompnl: *pnl.PANEL) usize {
    var cellPos: usize = 0;
    var Xcombo = grd.initGrid(
        "qryPanel",
        1,
        1,
        20,
        grd.gridStyle,
        dds.CADRE.line1,
    );

    var Cell = std.ArrayList(grd.CELL).init(allocator);
    Cell.append(grd.newCell("ID", 3, dds.REFTYP.UDIGIT, dds.ForegroundColor.fgGreen)) catch unreachable;
    Cell.append(grd.newCell("Name", 10, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgYellow)) catch unreachable;
    Cell.append(grd.newCell("Title", 15, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen)) catch unreachable;
    grd.setHeaders(&Xcombo, Cell);

    var idx: usize = 0;
    for (vpnl.items) |p| {
        grd.addRows(&Xcombo, &.{ utl.usizeToStr(idx) catch unreachable, p.name, p.frame.title });
        idx += 1;
    }

    var Gkey: grd.GridSelect = undefined;
    while (true) {
        Gkey = grd.ioCombo(&Xcombo, cellPos);
        if (Gkey.Key == kbd.enter) {
            grd.rstPanel(&Xcombo, frompnl);
            return utl.strToUsize(Gkey.Buf.items[0]) catch unreachable;
        }
        if (Gkey.Key == kbd.esc) {
            grd.rstPanel(&Xcombo, frompnl);
            return 999;
        }
    }
}

// end desription Function
//=================================================

var maxY: usize = 0;
var maxX: usize = 0;
var minY: usize = 0;
var minX: usize = 0;
var X: usize = 0;
var Y: usize = 0;

//pub fn main() !void {
pub fn fnPanel(XPANEL: *std.ArrayList(pnl.PANEL)) !void {
    term.cls();
    var pFmt01 = Panel_Fmt01();
    // defines the receiving structure of the keyboard
    var Tkey: term.Keyboard = undefined;

    pnl.clearPanel(&pFmt01);
    // testing
    //loadPanel(&pFmt01, &pFmt01);
    NPANEL.clearRetainingCapacity();
    for (XPANEL.items) |p| {
        NPANEL.append(p) catch dsperr.errorForms(ErrMain.main_run_EnumTask_invalide);
    }

    numPanel = qryPanel(NPANEL, &pFmt01);

    if (numPanel == 999) return;

    pFmt01 = NPANEL.items[numPanel];

    pnl.printPanel(&pFmt01);

    maxY = pFmt01.cols + pFmt01.posy;
    if (pFmt01.frame.cadre != dds.CADRE.line0) maxY -= 0;
    minY = pFmt01.posy;
    if (pFmt01.frame.cadre != dds.CADRE.line0) minY += 1;

    maxX = pFmt01.lines + pFmt01.posx;
    if (pFmt01.frame.cadre != dds.CADRE.line0) maxX -= 2;
    minX = pFmt01.posx;
    if (pFmt01.frame.cadre != dds.CADRE.line0) minX += 1;

    term.onMouse();
    //term.cursShow();
    while (true) {
        term.cursShow();
        Tkey = kbd.getKEY();
        if (Tkey.Key == kbd.mouse)  { dspMouse(&pFmt01);  continue;  } // active display Cursor x/y mouse

        switch (Tkey.Key) {
            .F10 =>  {
                XPANEL.items[numPanel].label = pFmt01.label; 
                return;
            },
            .F12 =>  return,
            .altT => {
                term.getCursor(); 
                if (term.posCurs.x < minX or term.posCurs.x > maxX or
                term.posCurs.y < minY or term.posCurs.y > maxY ) continue ;
                term.offMouse();
                writeLabel(&pFmt01, true);
                pnl.printPanel(&pFmt01);
                term.onMouse();
            },
            .altL => {
                term.getCursor();
                if (term.posCurs.x < minX or term.posCurs.x > maxX or
                    term.posCurs.y < minY or term.posCurs.y > maxY) continue;
                term.offMouse();
                writeLabel(&pFmt01, false);
                pnl.printPanel(&pFmt01);
                term.onMouse();
            },

            else => {},
        }
    }
}

//------------------------------------------------------------------
// definition label

fn writeLabel(vpnl: *pnl.PANEL, Title: bool) void {
    //term.getCursor();
    var e_count: usize = 0;
    var tampon: []const u8 = undefined;
    var e_LABEL = std.ArrayList([]const u8).init(allocator);
    var e_posx: usize = term.posCurs.x;
    var e_posy: usize = term.posCurs.y;
    var e_curs: usize = e_posy;

    // defines the receiving structure of the keyboard
    var Lkey: term.Keyboard = undefined;
    var i: usize = 0;
    while (i < vpnl.cols) : (i += 1) {
        e_LABEL.append(" ") catch unreachable;
    }
    while (true) {
        dspCursor(vpnl, e_posx, e_curs);

        Lkey = kbd.getKEY();

        //dspMouse(vpnl);  // active display Cursor x/y mouse
        //std.debug.print("Key: {d}  - {d}\n\r",.{term.posCurs.x, term.posCurs.y});
        switch (Lkey.Key) {
            .F2 => {
                term.gotoXY(e_posx, e_posy);
                tampon = utl.listToStr(e_LABEL);
                if (Title) term.writeStyled(utl.trimStr(tampon), lbl.AtrTitle) 
                else term.writeStyled(utl.trimStr(tampon), lbl.AtrLabel);
            },
            .F12 => return,

		
            .ctrlV => {
                tampon = std.fmt.allocPrint(allocator,"L{d}{d}",.{e_posx,e_posy}) catch unreachable;
              if (Title) {
                vpnl.label.append(lbl.newTitle(
                tampon, e_posx ,e_posy,utl.trimStr(utl.listToStr(e_LABEL))) ) catch unreachable;
              }
              else {
                vpnl.label.append(lbl.newLabel(
                tampon, e_posx ,e_posy,utl.trimStr(utl.listToStr(e_LABEL))) ) catch unreachable;
              }
              return ;
            },
            .home => {
                e_count = 0;
                e_curs  = e_posy;
            },
            .end => {
                tampon = utl.listToStr(e_LABEL);
                e_count = utl.trimStr(tampon).len - 1;
                e_curs = e_posy + utl.trimStr(tampon).len - 1;
            },
            .right, .tab => {
                if (e_curs < (vpnl.cols + vpnl.posy) - 1 ) {
                    e_count += 1;
                    e_curs += 1;
                }
            },
            .left, .stab => {
                if (e_curs > e_posy) {
                    e_count -= 1;
                    e_curs -= 1;
                }
            },
            .char => {
                if (e_curs < (vpnl.cols + vpnl.posy) - 1 ) {
                  if (Title) {
                      term.writeStyled(Lkey.Char, lbl.AtrTitle);
                      e_LABEL.items[e_count] = Lkey.Char;
                  } else {
                      term.writeStyled(Lkey.Char, lbl.AtrLabel);
                      e_LABEL.items[e_count] = Lkey.Char;
                  }
                  if (e_count < vpnl.cols) {
                      e_count += 1;
                      e_curs += 1;
                  }
                }
            },
            else => {},
        }
    }
}
