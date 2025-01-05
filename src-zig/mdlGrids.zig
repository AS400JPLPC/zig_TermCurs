///-----------------------
/// prog mdlGrid 
///-----------------------

const std = @import("std");

/// terminal Fonction
const term = @import("cursed");
// keyboard
const kbd = @import("cursed").kbd;

// error
const msgerr = @import("forms").ErrForms;
const dsperr = @import("forms").dsperr;

// full delete for produc
const forms = @import("forms");

// frame
const frm = @import("forms").frm;
// panel
const pnl = @import("forms").pnl;
// button
const btn = @import("forms").btn;
// label
const lbl = @import("forms").lbl;
// flied
const fld = @import("forms").fld;
// line horizontal
const lnh = @import("forms").lnh;
// line vertival
const lnv = @import("forms").lnv;

// grid
const grd = @import("grid").grd;
// menu
const mnu = @import("menu").mnu;

// tools utility
const utl = @import("utils");

// tools regex
const reg = @import("mvzr");

var numPanel: usize = undefined;
var numGrid : usize = undefined;

pub const ErrMain = error{
    main_append_XPANEL_invalide,
    main_run_FuncGrid_invalide,
    main_run_TaskGrid_invalide,
    main_run_FcellEnum_invalide,
    main_run_TcellEnum_invalide,
    main_loadPanel_allocPrint_invalide,
    main_updatePanel_allocPrint_invalide,
    main_XPANEL_invalide,
};

fn strToUsize(v: []const u8) usize {
    if (v.len == 0) return 0;
    return std.fmt.parseUnsigned(u64, v, 10) catch |err| {
        @panic(@errorName(err));
    };
}

fn usizeToStr(v: usize) []const u8 {
    return std.fmt.allocPrint(utl.allocUtl, "{d}", .{v}) catch |err| {
        @panic(@errorName(err));
    };
}

//=================================================
// description Function
// choix work panel
pub fn qryPanel(vpnl: *std.ArrayList(pnl.PANEL)) usize {
    const cellPos: usize = 0;
    var Gkey: grd.GridSelect = undefined;

    const Xcombo: *grd.GRID = grd.newGridC(
        "qryPanel",
        1,
        1,
        20,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer Gkey.Buf.deinit();
    defer grd.freeGrid(Xcombo);
    defer grd.allocatorGrid.destroy(Xcombo);

    grd.newCell(Xcombo, "ID", 3, grd.REFTYP.UDIGIT, term.ForegroundColor.fgGreen);
    grd.newCell(Xcombo, "Name", 10, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Xcombo, "Title", 15, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.setHeaders(Xcombo);

    for (vpnl.items, 0..) |p, idx| {
        grd.addRows(Xcombo, &.{ usizeToStr(idx), p.name, p.frame.title });
    }


    while (true) {
        Gkey = grd.ioCombo(Xcombo, cellPos);

        if (Gkey.Key == kbd.enter) {
            return strToUsize(Gkey.Buf.items[0]);
        }

        if (Gkey.Key == kbd.esc) {
            return 999;
        }
    }
}


//=================================================
// description Function
// choix work Grid
pub fn qryCellGrid(vpnl : * pnl.PANEL, vgrd: *std.ArrayList(grd.GRID)) usize {
    const cellPos: usize = 0;
    var Gkey: grd.GridSelect = undefined;

    const Xcombo: *grd.GRID = grd.newGridC(
        "qryPanel",
        1,
        1,
        10,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer Gkey.Buf.deinit();
    defer grd.freeGrid(Xcombo);
    defer grd.allocatorGrid.destroy(Xcombo);

    grd.newCell(Xcombo, "ID", 3, grd.REFTYP.UDIGIT, term.ForegroundColor.fgGreen);
    grd.newCell(Xcombo, "Name", 10, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.setHeaders(Xcombo);

    for (vgrd.items, 0..) |p, idx| {
        grd.addRows(Xcombo, &.{ usizeToStr(idx), p.name});
    }

    while (true) {
        Gkey = grd.ioCombo(Xcombo, cellPos);

        if (Gkey.Key == kbd.enter) {
            pnl.rstPanel(grd.GRID,Xcombo, vpnl);
            return strToUsize(Gkey.Buf.items[0]);
        }
        
        if (Gkey.Key == kbd.esc) {
            pnl.rstPanel(grd.GRID,Xcombo, vpnl);
            return 999;
        }
    }
}



pub fn Panel_HELP() *pnl.PANEL {
    var Panel : *pnl.PANEL = pnl.newPanelC("HELP",
                                        1, 1,
                                        6,
                                        100 ,
                                        forms.CADRE.line1,
                                        ""
                                        );

    Panel.button.append(btn.newButton(
                                    kbd.F12,        // function
                                    true,            // show
                                    false,            // check field
                                    "Abord",        // title 
                                    )
                                ) catch unreachable ;
    

    Panel.field.append(fld.newFieldTextFull("HELP1",2,5,90,"",false,
                                "","",
                                "")) catch unreachable ;
    fld.setProtect(Panel,0,true) catch unreachable;

    Panel.field.append(fld.newFieldTextFull("HELP2",3,5,90,"",false,
                                "","",
                                "")) catch unreachable ;
    
    Panel.field.append(fld.newFieldTextFull("HELP3",4,5,90,"",false,
                                "","",
                                "")) catch unreachable ;
                    
    fld.setProtect(Panel,0,true) catch unreachable;
    return Panel;
    }

// end desription Function
//=================================================

var maxY: usize = 0;
var maxX: usize = 0;
var minY: usize = 0;
var minX: usize = 0;
var X: usize = 0;
var Y: usize = 0;

// const allocator = std.heap.page_allocator;

var NGRID : std.ArrayList(grd.GRID) = undefined;

//pub fn main() !void {
pub fn fnPanel(XPANEL: *std.ArrayList(pnl.PANEL), XGRID: *std.ArrayList(grd.GRID)) void {
    term.cls();



    numPanel = qryPanel(XPANEL);

    if (numPanel == 999) return;

    NGRID = std.ArrayList(grd.GRID).init(grd.allocatorGrid);
    for (XGRID.items) |xgrd| { NGRID.append(xgrd) catch unreachable; }
    defer NGRID.clearAndFree();
    defer NGRID.deinit();

    term.cls();
    var pFmt01: *pnl.PANEL = pnl.newPanelC("FRAM01",
        XPANEL.items[numPanel].posx, XPANEL.items[numPanel].posy,
        XPANEL.items[numPanel].lines, XPANEL.items[numPanel].cols,
        XPANEL.items[numPanel].frame.cadre,
        XPANEL.items[numPanel].frame.title);

    for (XPANEL.items[numPanel].button.items) |p| {
        pFmt01.button.append(p)
        catch |err| { @panic(@errorName(err)); };
    }
    for (XPANEL.items[numPanel].label.items) |p| {
        pFmt01.label.append(p)
        catch |err| { @panic(@errorName(err)); };
    }
    for (XPANEL.items[numPanel].field.items, 0..) |p, idx| {
        pFmt01.field.append(p) catch |err| { @panic(@errorName(err)); };
        var vText: [] u8 = undefined ;
        
 
            switch(p.reftyp) {
                forms.REFTYP.TEXT_FREE, forms.REFTYP.TEXT_FULL , forms.REFTYP.ALPHA ,
                forms.REFTYP.ALPHA_UPPER, forms.REFTYP.ALPHA_NUMERIC, forms.REFTYP.ALPHA_NUMERIC_UPPER,
                forms.REFTYP.PASSWORD, forms.REFTYP.YES_NO  =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
                    @memset(vText[0..p.width], '#');
                } ,

                forms.REFTYP.UDIGIT =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
                    @memset(vText[0..p.width], '0');
                    //editcar
                    if (p.edtcar.len > 0) {
                        vText = std.fmt.allocPrint(utl.allocUtl, "{s}{s}", .{vText, p.edtcar }
                        ) catch unreachable;
                    }
                } ,
            
                forms.REFTYP.DIGIT =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width + 1) catch unreachable;
                    @memset(vText[0..p.width], '0');
                    vText = std.fmt.allocPrint(utl.allocUtl, "+{s}", .{vText[0..p.width]})
                            catch unreachable;
                    //editcar
                    if (p.edtcar.len > 0) {
                        vText = std.fmt.allocPrint(utl.allocUtl, "{s}{s}", .{vText, p.edtcar }
                        ) catch unreachable;
                    }
                } ,
            
                forms.REFTYP.UDECIMAL =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width + 1 + p.scal) catch unreachable;
                    @memset(vText[0..(p.width + p.scal)] , '0');
                    vText = std.fmt.allocPrint(utl.allocUtl, "{s}.{s}", .{vText[0..p.width],vText[0..p.scal]})
                            catch unreachable;
                    //editcar
                    if (p.edtcar.len > 0) {
                        vText = std.fmt.allocPrint(utl.allocUtl, "{s}{s}", .{vText, p.edtcar }
                        ) catch unreachable;
                    }
                } ,
            
                forms.REFTYP.DECIMAL =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width + 2 + p.scal) catch unreachable;
                    @memset(vText[0..(p.width + p.scal)], '0');
                    vText = std.fmt.allocPrint(utl.allocUtl, "+{s}.{s}", .{vText[0..p.width],vText[0..p.scal]})
                            catch unreachable;
                //editcar
                    if (p.edtcar.len > 0) {
                        vText = std.fmt.allocPrint(utl.allocUtl, "{s}{s}", .{vText, p.edtcar }
                        ) catch unreachable;
                    }
                } ,
            
                forms.REFTYP.DATE_ISO =>    vText = std.fmt.allocPrint(utl.allocUtl, "YYYY-MM-DD", .{})
                                                catch unreachable,
                forms.REFTYP.DATE_FR  =>    vText = std.fmt.allocPrint(utl.allocUtl, "DD/MM/YYYY", .{})
                                                catch unreachable,

                forms.REFTYP.DATE_US  =>    vText = std.fmt.allocPrint(utl.allocUtl, "MM/DD/YYYY", .{})
                                                catch unreachable,

                forms.REFTYP.TELEPHONE =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
                    @memset(vText[0..p.width], '*');
                } ,

                forms.REFTYP.MAIL_ISO  =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
                    @memset(vText[0..p.width], '@');
                } ,
                forms.REFTYP.SWITCH   =>    vText = std.fmt.allocPrint(utl.allocUtl, "{s}", .{forms.CTRUE})
                                                catch unreachable,

                forms.REFTYP.FUNC  =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
                    @memset(vText[0..p.width], 'F');
                } ,

            }
            fld.setText(pFmt01,    idx, vText) catch |err| { @panic(@errorName(err)); };

    }


    for (XPANEL.items[numPanel].linev.items) |p| {
        pFmt01.linev.append(p)
        catch |err| { @panic(@errorName(err)); };
    }
    for (XPANEL.items[numPanel].lineh.items) |p| {
        pFmt01.lineh.append(p)
        catch |err| { @panic(@errorName(err)); };
    }


    var mChoix = mnu.newMenu("Choix", // name
            1, 1, // posx, posy
            mnu.CADRE.line1, // type line fram
            mnu.MNUVH.vertical, // type menu vertical / horizontal
            &.{ // item
            "C-G..View",
            "Cell-View",
            "Cell-Order",
            "Cell-Remove",
            }
        );
  
    pnl.printPanel(pFmt01);

    maxY = pFmt01.cols + pFmt01.posy;
    if (pFmt01.frame.cadre != forms.CADRE.line0) maxY -= 0;
    
    minY = pFmt01.posy;
    if (pFmt01.frame.cadre != forms.CADRE.line0) minY += 1;

    maxX = pFmt01.lines + pFmt01.posx;
    if (pFmt01.frame.cadre != forms.CADRE.line0) maxX -= 2;
    
    minX = pFmt01.posx;
    if (pFmt01.frame.cadre != forms.CADRE.line0) minX += 1;

    term.onMouse();
    var Tkey: term.Keyboard = undefined; // defines the receiving structure of the keyboard

    while (true) {
        term.cursShow();
        Tkey = kbd.getKEY();

        if (Tkey.Key == kbd.mouse) {
            forms.dspMouse(pFmt01);
            continue;
        } // active display Cursor x/y mouse

        switch (Tkey.Key) {
            .F1     => {
                const pFmtH01 = Panel_HELP();
                fld.setText(pFmtH01,0,"F11 ENRG  F12 Abort  Alt-G add-Grid  Alt-C add-Cell")
                    catch unreachable;
                fld.setText(pFmtH01,1,"name -> :Combo C Grid G")
                    catch unreachable;
                fld.setText(pFmtH01,2,"Alt-R remove Grid   Alt-O order Grid  AltW Outils ")
                    catch unreachable;

                _= pnl.ioPanel(pFmtH01);
                pnl.rstPanel(pnl.PANEL,pFmtH01,pFmt01);
                term.gotoXY(1,1);
                continue;
            },
            .F11 => {
                XGRID.clearRetainingCapacity();
                for (NGRID.items, 0..) |xgrd,idx| {
                    grd.resetRows(&NGRID.items[idx]);
                    
                    XGRID.append( grd.initGrid(
                            xgrd.name,
                            xgrd.posx,
                            xgrd.posy,
                            xgrd.pageRows,
                            xgrd.separator,
                            xgrd.cadre)
                         ) catch unreachable;
                    for (xgrd.cell.items, 0..) |p,id| {
                        grd.newCell(&XGRID.items[idx], p.text, p.long, p.reftyp, p.atrCell.foregr);
                        grd.setCellEditCar(&XGRID.items[idx].cell.items[id], p.edtcar);
                    }
                }
                pnl.freePanel(pFmt01);
                defer forms.allocatorForms.destroy(pFmt01);
                return;
            },
            .F12 => {
                pnl.freePanel(pFmt01);
                defer forms.allocatorForms.destroy(pFmt01);
                return;
            },


            // def grid
            .altG => {
                term.getCursor();
                
                if (term.posCurs.x < minX or term.posCurs.x > maxX or
                    term.posCurs.y < minY or term.posCurs.y > maxY) continue;

                term.writeStyled("?", pFmt01.attribut);
                term.gotoXY(term.posCurs.x , term.posCurs.y );
                term.getCursor();
                term.offMouse();
                writeDefGrid(pFmt01);
                term.cls();
                pnl.printPanel(pFmt01);
                term.onMouse();
            },

            // def field
            .altC => {
                numGrid = qryCellGrid(pFmt01, &NGRID);

                if (numGrid != 999) {
                    term.offMouse();
                    writeDefCell(&NGRID,numGrid);
                }
                term.cls();
                pnl.printPanel(pFmt01);
                term.onMouse();
            },

            // order Grid
            .altO => {
                orderGrid(&NGRID );                    // order Grid
                term.cls();
                pnl.printPanel(pFmt01);
                term.onMouse();
            },
            // Order / Remove
            .altW => {
                numGrid = qryCellGrid(pFmt01, &NGRID);
                term.cursHide();
                if (numGrid != 999) {
                    var nitem: usize = 0;
                    nitem = mnu.ioMenu( mChoix, nitem);
                    term.offMouse();
                    pnl.rstPanel(mnu.MENU,&mChoix,pFmt01);
                    term.onMouse();
                    if (nitem == 0) viewGrid(pFmt01,NGRID,numGrid );    // view  Grid
                    if (nitem == 1) viewCell(pFmt01,NGRID,numGrid );    // view  Cell
                    if (nitem == 2) orderCell(NGRID,numGrid );          // order Cell
                    if (nitem == 3) removeCell(NGRID,numGrid );         // order Cell
                 }
                term.cls();
                pnl.printPanel(pFmt01);
                term.onMouse();
                term.cursShow();
            },
            

            // Remove
            .altR => {
                    removeGrid(&NGRID);   // Remove Grid

                    term.cls();
                    pnl.printPanel(pFmt01);
                    term.onMouse();
            },
            else => {},
        }
    }
}


// forms field
const fp02 = enum {
    fname,
    fposx,
    fposy,
    flines,
    fstyle,
    fcadre,
};


fn Panel_defGrid(nposx: usize) *pnl.PANEL {


    var Panel: *pnl.PANEL = pnl.newPanelC("FRAM02", nposx ,2,9, 42, forms.CADRE.line1, "Def.field");

    Panel.button.append(btn.newButton(
        kbd.F9, // function
        true, // show
        true, // check field
        "Enrg", // title
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.button.append(btn.newButton(
        kbd.F12, // function
        true, // show
        false, // check field
        "Return", // title
    )) catch |err| { @panic(@errorName(err)); }; 

    Panel.label.append(lbl.newLabel(@tagName(fp02.fname)  ,2,2, "name.....:") ) catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(fp02.fposx)  ,3,2, "posX.....:") ) catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(fp02.fposy)  ,4,2, "posy.....:") ) catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(fp02.flines) ,5,2, "lines....:") ) catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(fp02.fstyle) ,6,2, "style....:") ) catch unreachable ;
    Panel.label.append(lbl.newLabel(@tagName(fp02.fcadre) ,7,2, "cadre....:") ) catch unreachable ;

    Panel.field.append(fld.newFieldAlphaNumeric(@tagName(fp02.fname),2,12,10,"",true,
                            "required","please enter :text [a-zA-Z]{1,1} [A-z0-9]",
                            "^[CG]{1,1}[a-zA-Z0-9]{0,}$")) catch unreachable ;
    fld.setTask(Panel,@intFromEnum(fp02.fname),"TaskName") catch unreachable ;

    Panel.field.append(fld.newFieldUDigit(@tagName(fp02.fposx),3,12,2,"",false,
                            "","please enter Pos X 1...",
                            "^[1-9]{1,1}?[0-9]{0,}$")) catch unreachable ;
    fld.setProtect(Panel,@intFromEnum(fp02.fposx),true) catch unreachable ;

    Panel.field.append(fld.newFieldUDigit(@tagName(fp02.fposy),4,12,3,"",false,
                            "","please enter Pos y 1...",
                            "^[1-9]{1,1}?[0-9]{0,}$")) catch unreachable ;
    fld.setProtect(Panel,@intFromEnum(fp02.fposy),true) catch unreachable ;

    Panel.field.append(fld.newFieldUDigit(@tagName(fp02.flines),5,12,2,"",true,
                            "required","please enter Lines 1...",
                            "^[1-9]{1,1}?[0-9]{0,}$")) catch unreachable ;
    fld.setTask(Panel,@intFromEnum(fp02.flines),"TaskLines") catch unreachable ;

    Panel.field.append(fld.newFieldFunc(@tagName(fp02.fstyle),6,12,1,"",false,"FuncStyle",
                            "required","please enter gridStyle = | gridnoStyles = ' '",
                            )) catch unreachable ;
    fld.setTask(Panel,@intFromEnum(fp02.fstyle),"TaskStyle") catch unreachable ;

    Panel.field.append(fld.newFieldFunc(@tagName(fp02.fcadre),7,12,1,"",true,"FuncCadre",
                            "required","please choose the type of frame")) catch unreachable ;
    fld.setTask(Panel,@intFromEnum(fp02.fcadre),"TaskCadre") catch unreachable ; 

    return Panel;
  }




//=================================================
// description Function

var callFuncGrid: FuncGrid = undefined;
// description Function
// choix Cadre
fn FuncCadre( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {

    var pos:usize = 1;

    var mCadre = mnu.newMenu(
                            "cadre",                // name
                            vpnl.posx + 1, 20,        // posx, posy
                            mnu.CADRE.line1,        // type line fram
                            mnu.MNUVH.vertical,        // type menu vertical / horizontal
                            &.{                        // item
                            "Noline",
                            "Line 1",
                            "Line 2",
                            });
    var nitem    :usize = 0;
    if (std.mem.eql(u8, vfld.text, "0")) pos = 0;
    if (std.mem.eql(u8, vfld.text, "1")) pos = 1;
    if (std.mem.eql(u8, vfld.text, "2")) pos = 2;
    while (true) {
        nitem    = mnu.ioMenu(mCadre,pos);
        if (nitem != 9999) break;
    }

    vfld.text = std.fmt.allocPrint(forms.allocatorForms,"{d}",.{nitem}) catch unreachable; 
    pnl.rstPanel(mnu.MENU,&mCadre,vpnl);
}
// description Function
// choix Style
fn FuncStyle( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {

    var pos:usize = 1;

    var mCadre = mnu.newMenu(
                            "Style",                // name
                            vpnl.posx + 1, 20,        // posx, posy
                            mnu.CADRE.line1,        // type line frame
                            mnu.MNUVH.vertical,        // type menu vertical / horizontal
                            &.{                        // item
                            "gridStyle2",
                            "gridStyle",
                            });
    var nitem    :usize = 0;
    if (std.mem.eql(u8, vfld.text, " ")) pos = 0;
    if (std.mem.eql(u8, vfld.text, grd.gridStyle)) pos = 1;
    while (true) {
        nitem    = mnu.ioMenu(mCadre,pos);
        if (nitem != 9999) break;
    }

    if (nitem == 1 ) vfld.text = std.fmt.allocPrint(forms.allocatorForms,"{s}",.{grd.gridStyle}) catch unreachable
    else vfld.text = std.fmt.allocPrint(forms.allocatorForms,"║",.{}) catch unreachable; 
    pnl.rstPanel(mnu.MENU,&mCadre,vpnl);
}
//=================================================
// description Function
/// run emun Function ex: combo
pub const FuncGrid = enum {
    FuncStyle,
    FuncCadre,
    none,

    pub fn run(self: FuncGrid , vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
        switch (self) {
            .FuncStyle => FuncStyle(vpnl, vfld),
            .FuncCadre => FuncCadre(vpnl, vfld),
            else => dsperr.errorForms(vpnl, ErrMain.main_run_FuncGrid_invalide),
        }
    }

    fn searchFn(vtext: []const u8) FuncGrid {
        inline for (@typeInfo(FuncGrid).@"enum".fields) |f| {
            if (std.mem.eql(u8, f.name, vtext)) return @as(FuncGrid, @enumFromInt(f.value));
        }
        return FuncGrid.none;
    }
};

//=================================================
// description Function
// test exist Name for add or change name

fn TaskName(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    for (NGRID.items) |f| {
        if (std.mem.eql(u8, f.name, vfld.text)) {
            pnl.msgErr(vpnl, "Already existing invalide Name");
            vpnl.keyField = kbd.task;
            return;
        }
    }
}


fn TaskLines( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {
        const termSize = term.getSize() ;
        const lines =    utl.strToUsize(vfld.text);
        const posx    =    utl.strToUsize(fld.getText(vpnl,@intFromEnum(fp02.fposx)) catch unreachable) ;
        
        if (termSize.height < lines or lines == 0 or termSize.height < lines + posx - 1 ) {
            const msg = std.fmt.allocPrint(
            grd.allocatorGrid,"The number of rows Invalide",
            .{}) catch unreachable;
            defer grd.allocatorGrid.free(msg);
            pnl.msgErr(vpnl, msg);
            vpnl.keyField = kbd.task;
        }
}


fn TaskStyle( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {
    
    if (std.mem.eql(u8, vfld.text,"")) {
        const msg = std.fmt.allocPrint(grd.allocatorGrid,
            "Style is invalide",.{}) catch unreachable;
        defer grd.allocatorGrid.free(msg);
        pnl.msgErr(vpnl, msg);
        vpnl.keyField = kbd.task;
        }
}

fn TaskCadre( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {
    const cadre =    utl.strToUsize(vfld.text);
    
    if (cadre == 0 ) {
        const msg = std.fmt.allocPrint(grd.allocatorGrid,
            "Cadre is invalide",.{}) catch unreachable;
        defer grd.allocatorGrid.free(msg);
        pnl.msgErr(vpnl, msg);
        vpnl.keyField = kbd.task;
        }
}


var callTaskGrid: TaskGrid = undefined;
//=================================================
// description Function
/// run emun Function ex: combo
pub const TaskGrid= enum {
    TaskName,
    TaskLines,
    TaskStyle,
    TaskCadre,
    none,

    pub fn run(self: TaskGrid, vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
        switch (self) {
            .TaskName    => TaskName(vpnl, vfld),
            .TaskLines    => TaskLines(vpnl,vfld),
            .TaskStyle    => TaskStyle(vpnl,vfld),
            .TaskCadre    => TaskCadre(vpnl,vfld),
            else => dsperr.errorForms(vpnl, ErrMain.main_run_TaskGrid_invalide),
        }
    }
    fn searchFn(vtext: []const u8) TaskGrid {
        inline for (@typeInfo(TaskGrid).@"enum".fields) |f| {
            if (std.mem.eql(u8, f.name, vtext)) return @as(TaskGrid, @enumFromInt(f.value));
        }
        return TaskGrid.none;
    }
};
//---------------------------------------------------------------------------

pub fn writeDefGrid(vpnl: *pnl.PANEL) void {
    term.getCursor();
    const v_posx: usize = term.posCurs.x;
    const v_posy: usize = term.posCurs.y;

    // Init format panel
    var v_pos :usize = 0;
    if (v_posx >= 20 ) v_pos = 2 else v_pos = 22 ;
    var pFmt02 = Panel_defGrid(v_pos);
    pFmt02.field.items[@intFromEnum(fp02.fposx)].text = usizeToStr(v_posx);
    pFmt02.field.items[@intFromEnum(fp02.fposy)].text = usizeToStr(v_posy);
    
    // init struct key
    var Tkey: term.Keyboard = undefined; // defines the receiving structure of the keyboard
    const idx: usize = 0;
    _ = idx;
    var vlen: usize = 0;
    

    while (true) {
        //Tkey = kbd.getKEY();

        forms.dspCursor(vpnl, v_posx, v_posy,"Field");
        Tkey.Key = pnl.ioPanel(pFmt02);
        switch (Tkey.Key) {
            // call function combo
            .func => {
                callFuncGrid = FuncGrid.searchFn(pFmt02.field.items[pFmt02.idxfld].procfunc);
                callFuncGrid.run(pFmt02, &pFmt02.field.items[pFmt02.idxfld]);
            },
            // call proc control chek value
            .task => {
                callTaskGrid = TaskGrid.searchFn(pFmt02.field.items[pFmt02.idxfld].proctask);
                callTaskGrid.run(pFmt02, &pFmt02.field.items[pFmt02.idxfld]);
            },
            // write field to panel
            .F9 => {
                vlen = pFmt02.field.items[@intFromEnum(fp02.fname)].text.len;
            
                NGRID.append( grd.initGrid(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.flines)].text),
                            pFmt02.field.items[@intFromEnum(fp02.fstyle)].text,
                            @enumFromInt(strToUsize(pFmt02.field.items[@intFromEnum(fp02.fcadre)].text))
                         )) catch unreachable;

        
        
                pnl.freePanel(pFmt02);
                defer forms.allocatorForms.destroy(pFmt02);
                return;
            },

            // exit panel field
            .F12 => {
                pnl.freePanel(pFmt02);
                defer forms.allocatorForms.destroy(pFmt02);
                return;
            },
            else => {},
        }
    }
}
//==========================================
// CELL Management
//==========================================

// forms field
const fp03 = enum {
    ftext,
    fwidth,
    ftype,
    fedtcar,
    fatrcell
    

};
// panel for field
fn Panel_Fmt03(nposx: usize) *pnl.PANEL {
    var Panel: *pnl.PANEL = pnl.newPanelC("FRAM03", nposx, 2, 13, 62, forms.CADRE.line1, "Def.field");

    Panel.button.append(btn.newButton(
        kbd.F9, // function
        true, // show
        true, // check field
        "Enrg", // title
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.button.append(btn.newButton(
        kbd.F12, // function
        true, // show
        false, // check field
        "Return", // title
    )) catch |err| { @panic(@errorName(err)); }; 
    
    Panel.label.append(lbl.newLabel(@tagName(fp03.ftext), 2, 2, "Text.....:")) 
    catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(fld.newFieldTextFull(@tagName(fp03.ftext), 2, // posx
        2 + Panel.label.items[@intFromEnum(fp03.ftext)].text.len, //posy
        20, // len
        "", // text
        true, // required
        "required help ctrl-h", // Msg err
        "please enter text 1car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };

    fld.setTask(Panel, @intFromEnum(fp03.ftext), "TcellText") 
    catch |err| { @panic(@errorName(err)); }; 


    Panel.label.append(lbl.newLabel(@tagName(fp03.fwidth), 3, 2, "Width....:"))
        catch |err| { @panic(@errorName(err)); }; 
        
    Panel.field.append(fld.newFieldUDigit(@tagName(fp03.fwidth), 3, // posx
        2 + Panel.label.items[@intFromEnum(fp03.fwidth)].text.len, //posy
        3, // len
        "", // text
        true, // required
        "Len field required or too long", // Msg err
        "len field", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); }; 

    fld.setTask(Panel, @intFromEnum(fp03.fwidth), "TcellWidth") 
        catch |err| { @panic(@errorName(err)); }; 


    Panel.label.append(lbl.newLabel(@tagName(fp03.ftype), 3, 32, "Type.:"))
        catch |err| { @panic(@errorName(err)); }; 
        
    Panel.field.append(fld.newFieldFunc(
        @tagName(fp03.ftype),
        3, // posx
        32 + Panel.label.items[@intFromEnum(fp03.ftype)].text.len, //posy
        19, // len
        "", // text
        true, // required
        "FcellType", // function
        "Reference type required", // Msg err
        "Refence field", // help
    )) catch |err| {
        @panic(@errorName(err));
    };
    fld.setTask(Panel, @intFromEnum(fp03.ftype), "TcellType")
        catch |err| { @panic(@errorName(err)); };


    Panel.label.append(lbl.newLabel(@tagName(fp03.fedtcar), 4, 2, "Edit Car.:"))
        catch |err| { @panic(@errorName(err)); }; 
        
    Panel.field.append(fld.newFieldTextFull(@tagName(fp03.fedtcar), 4, // posx
        2 + Panel.label.items[@intFromEnum(fp03.fedtcar)].text.len, //posy
        1, // len
        "", // text
        false, // required
        "", // Msg err
        "please enter text ex:$ € % £", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); }; 
 

    Panel.label.append(lbl.newLabel(@tagName(fp03.fatrcell), 5, 2, "Color...:"))
        catch |err| { @panic(@errorName(err)); }; 
        
    Panel.field.append(fld.newFieldFunc(
        @tagName(fp03.fatrcell),
        5, // posx
        2 + Panel.label.items[@intFromEnum(fp03.fatrcell)].text.len, //posy
        19, // len
        "", // text
        true, // required
        "FcellAtr", // function
        "Reference type required", // Msg err
        "Refence field", // help
    )) catch |err| {
        @panic(@errorName(err));
    };
    fld.setTask(Panel, @intFromEnum(fp03.fatrcell), "TcellAtr")
        catch |err| { @panic(@errorName(err)); };

    return Panel;
}

//---------------------------------------------------------------------------
//  string return enum
fn strToEnum(comptime EnumTag: type, vtext: []const u8) EnumTag {
    inline for (@typeInfo(EnumTag).@"enum".fields) |f| {
        if (std.mem.eql(u8, f.name, vtext)) return @field(EnumTag, f.name);
    }

    var buffer: [128]u8 = [_]u8{0} ** 128;
    const result = std.fmt.bufPrintZ(buffer[0..], "invalid Text {s} for strToEnum ", .{vtext}) catch unreachable;
    @panic(result);
}
//=================================================
// description Function
// choix Type Field
fn FcellType(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    var pos: usize = 0;
    var Gkey: grd.GridSelect = undefined;
    const Xcombo: *grd.GRID = grd.newGridC(
        "qryPanel",
        vpnl.posx + 2,
        vpnl.posy + 32,
        6,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer Gkey.Buf.deinit();
    defer grd.freeGrid(Xcombo);
    defer grd.allocatorGrid.destroy(Xcombo);
    
    grd.newCell(Xcombo, "Ref.Type", 19, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.setHeaders(Xcombo);
    grd.addRows(Xcombo, &.{"TEXT_FREE"}); // Free
    grd.addRows(Xcombo, &.{"UDIGIT"}); // Digit unsigned
    grd.addRows(Xcombo, &.{"DIGIT"}); // Digit signed
    grd.addRows(Xcombo, &.{"UDECIMAL"}); // Decimal unsigned
    grd.addRows(Xcombo, &.{"DECIMAL"}); // Decimal signed

    if (std.mem.eql(u8, vfld.text, "TEXT_FREE")) pos = 0;
    if (std.mem.eql(u8, vfld.text, "UDIGIT"))    pos = 1;
    if (std.mem.eql(u8, vfld.text, "DIGIT"))     pos = 2;
    if (std.mem.eql(u8, vfld.text, "UDECIMAL"))  pos = 3;
    if (std.mem.eql(u8, vfld.text, "DECIMAL"))   pos = 4;

    while (true) {
        Gkey = grd.ioCombo(Xcombo, pos);

        if (Gkey.Key == kbd.enter) {
            pnl.rstPanel(grd.GRID,Xcombo, vpnl);
            fld.setText(vpnl, @intFromEnum(fp03.ftype), Gkey.Buf.items[0]) 
                catch |err| { @panic(@errorName(err)); }; 
            return;
        }

        if (Gkey.Key == kbd.esc) {
            pnl.rstPanel(grd.GRID,Xcombo, vpnl);
            return;
        }
    }
}

//=================================================
// description Function
// choix Type Field
fn FcellAtr(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    var pos: usize = 2;
    var Gkey: grd.GridSelect = undefined;
    
    var vtext :[]const u8 = undefined;
    const Xcombo: *grd.GRID = grd.newGridC(
        "qryPanel",
        vpnl.posx ,
        vpnl.posy ,
        9,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer Gkey.Buf.deinit();
    defer grd.freeGrid(Xcombo);
    defer grd.allocatorGrid.destroy(Xcombo);
    
    grd.newCell(Xcombo, "Color-Text", 10, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.setHeaders(Xcombo);
    grd.addRows(Xcombo, &.{"Black"});
    grd.addRows(Xcombo, &.{"Red"});
    grd.addRows(Xcombo, &.{"Green"});
    grd.addRows(Xcombo, &.{"Yellow"});
    grd.addRows(Xcombo, &.{"Blue"});
    grd.addRows(Xcombo, &.{"Magenta"});
    grd.addRows(Xcombo, &.{"Cyan"});
    grd.addRows(Xcombo, &.{"White"});


    if (std.mem.eql(u8, vfld.text, "fgBlack"))   pos = 0;
    if (std.mem.eql(u8, vfld.text, "fgRed"))     pos = 1;
    if (std.mem.eql(u8, vfld.text, "fgGreen"))   pos = 2;
    if (std.mem.eql(u8, vfld.text, "fgYellow"))  pos = 3;
    if (std.mem.eql(u8, vfld.text, "fgBlue"))    pos = 4;
    if (std.mem.eql(u8, vfld.text, "fgMagenta")) pos = 5;
    if (std.mem.eql(u8, vfld.text, "fgCyan"))    pos = 6;
    if (std.mem.eql(u8, vfld.text, "fgWhite"))   pos = 7;


    while (true) {
        Gkey = grd.ioCombo(Xcombo, pos);

        if (Gkey.Key == kbd.enter) {
            vtext = std.fmt.allocPrint(grd.allocatorGrid,"fg{s}",.{Gkey.Buf.items[0]}) catch unreachable;
            fld.setText(vpnl, @intFromEnum(fp03.fatrcell),    vtext) 
                catch |err| { @panic(@errorName(err)); };
            
            pnl.rstPanel(grd.GRID,Xcombo, vpnl);
            return;
        }

        if (Gkey.Key == kbd.esc) {
            pnl.rstPanel(grd.GRID,Xcombo, vpnl);
            return;
        }
    }
}

var callFcell: FcellEnum = undefined;
//=================================================
// description Function
/// run emun Function ex: combo
pub const FcellEnum = enum {
    FcellType,
    FcellAtr,
    none,

    pub fn run(self: FcellEnum, vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
        switch (self) {
            .FcellType => FcellType(vpnl, vfld),
            .FcellAtr  => FcellAtr(vpnl, vfld),
            else => dsperr.errorForms(vpnl, ErrMain.main_run_FcellEnum_invalide),
        }
    }

    fn searchFn(vtext: []const u8) FcellEnum {
        inline for (@typeInfo(FcellEnum).@"enum".fields) |f| {
            if (std.mem.eql(u8, f.name, vtext)) return @as(FcellEnum, @enumFromInt(f.value));
        }
        return FcellEnum.none;
    }
};
//---------------------------------------------------------------------------
//=================================================
// description Function
// test exist Name for add or change name

fn TcellText(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
        if (std.mem.eql(u8, vfld.text , "")) {
            pnl.msgErr(vpnl, "Already existing invalide Text field");
            vpnl.keyField = kbd.task;
            return;
        }
}

fn TcellWidth(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    const val = strToUsize(vfld.text);

    if (val == 0) {
        const msg = std.fmt.allocPrint(utl.allocUtl,
            "{d} the length of the zone is invalid", .{val})
            catch |err| { @panic(@errorName(err)); };
        pnl.msgErr(vpnl, msg);

        vpnl.keyField = kbd.task;
    }
}
fn TcellType(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    const vReftype = strToEnum(forms.REFTYP, vfld.text);

    for (vpnl.field.items, 0..) |f, idx| {
        if (std.mem.eql(u8, f.name, @tagName(fp03.fedtcar))) {
            vpnl.field.items[idx].text = "";
            vpnl.field.items[idx].protect = true;
        }
        if (std.mem.eql(u8, f.name, @tagName(fp03.fwidth))) {
                vpnl.field.items[idx].protect = false;
        }
    }



    
    for (vpnl.field.items, 0..) |f, idx| {
        
        if (vReftype == forms.REFTYP.DIGIT or
            vReftype == forms.REFTYP.UDIGIT or
            vReftype == forms.REFTYP.DECIMAL or
            vReftype == forms.REFTYP.UDECIMAL)
        {
            if (std.mem.eql(u8, f.name, @tagName(fp03.fedtcar))) {
                vpnl.field.items[idx].protect = false;
            }
        }
    }


    if (vReftype == forms.REFTYP.DATE_ISO or
        vReftype == forms.REFTYP.DATE_FR or
        vReftype == forms.REFTYP.DATE_US)
    {
        for (vpnl.field.items, 0..) |f, idx| {
            if (std.mem.eql(u8, f.name, @tagName(fp03.fwidth))) {
                vpnl.field.items[idx].text = "10";
                vpnl.field.items[idx].protect = true;
            }
        }
    }

    if (vReftype == forms.REFTYP.YES_NO or vReftype == forms.REFTYP.SWITCH) {
        for (vpnl.field.items, 0..) |f, idx| {
            if (std.mem.eql(u8, f.name, @tagName(fp03.fwidth))) {
                vpnl.field.items[idx].text = "1";
                vpnl.field.items[idx].protect = true;
            }
        }
    }
}
fn TcellAtr(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {

        if (std.mem.eql(u8, vfld.text,"")) {
            const msg = std.fmt.allocPrint(utl.allocUtl,
                "the error message Color is invalid", .{})
                catch |err| { @panic(@errorName(err)); };            
            pnl.msgErr(vpnl, msg);

            vpnl.keyField = kbd.task;
        }
}
var callTcell: TcellEnum = undefined;
//=================================================
// description Function
// run emun Function ex: combo
pub const TcellEnum = enum {
    TcellText,
    TcellType,
    TcellWidth,
    TcellAtr,
    none,

    pub fn run(self: TcellEnum, vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
        switch (self) {
            .TcellText    => TcellText(vpnl, vfld),
            .TcellType    => TcellType(vpnl, vfld),
            .TcellWidth    => TcellWidth(vpnl, vfld),
            .TcellAtr    => TcellAtr(vpnl, vfld),

            else => dsperr.errorForms(vpnl, ErrMain.main_run_TcellEnum_invalide),
        }
    }
    fn searchFn(vtext: []const u8) TcellEnum {
        inline for (@typeInfo(TcellEnum).@"enum".fields) |f| {
            if (std.mem.eql(u8, f.name, vtext)) return @as(TcellEnum, @enumFromInt(f.value));
        }
        return TcellEnum.none;
    }
};
//---------------------------------------------------------------------------
pub fn writeDefCell(vGrid: *std.ArrayList(grd.GRID) , gridNum : usize) void {
    term.getCursor();
    var v_posx: usize = term.posCurs.x;

    if (v_posx >= 20) v_posx = 2 else v_posx = 22;

    // Init format panel
    var pFmt03 = Panel_Fmt03(v_posx);
    // init zone field

    // init struct key
    var Tkey: term.Keyboard = undefined; // defines the receiving structure of the keyboard
    var vlen: usize = 0;
    while (true) {
        //Tkey = kbd.getKEY();

        Tkey.Key = pnl.ioPanel(pFmt03);
        switch (Tkey.Key) {
            // call function combo
            .func => {
                callFcell = FcellEnum.searchFn(pFmt03.field.items[pFmt03.idxfld].procfunc);
                callFcell.run(pFmt03, &pFmt03.field.items[pFmt03.idxfld]);
            },
            // call proc control chek value
            .task => {
                callTcell = TcellEnum.searchFn(pFmt03.field.items[pFmt03.idxfld].proctask);
                callTcell.run(pFmt03, &pFmt03.field.items[pFmt03.idxfld]);
            },
            // write field to panel
            .F9 => {
    
                grd.newCell(
                    &vGrid.items[gridNum],
                    pFmt03.field.items[@intFromEnum(fp03.ftext)].text,
                    strToUsize(pFmt03.field.items[@intFromEnum(fp03.fwidth)].text),
                    strToEnum(grd.REFTYP, pFmt03.field.items[@intFromEnum(fp03.ftype)].text),
                    strToEnum(term.ForegroundColor, pFmt03.field.items[@intFromEnum(fp03.fatrcell)].text)
                );
                vlen = vGrid.items[gridNum].cell.items.len - 1;
                grd.setCellEditCar(&vGrid.items[gridNum].cell.items[vlen],
                                    pFmt03.field.items[@intFromEnum(fp03.fedtcar)].text);
                pnl.freePanel(pFmt03);
                defer forms.allocatorForms.destroy(pFmt03);
                return;
            },

            // exit panel field
            .F12 => {
                pnl.freePanel(pFmt03);
                defer forms.allocatorForms.destroy(pFmt03);
                return;
            },
            else => {},
        }
    }
}
//=================================================
// description Function
// view GRID
pub fn viewGrid(vpnl: *pnl.PANEL ,vgrd: std.ArrayList(grd.GRID), gridNum: usize) void {

    if (vgrd.items[gridNum].cell.items.len == 0 ) return;
    const cellPos: usize = 0;
    var Gkey: grd.GridSelect = undefined;

    const Xcombo: *grd.GRID = grd.newGridC(
        vgrd.items[gridNum].name,
        vgrd.items[gridNum].posx,
        vgrd.items[gridNum].posy,
        vgrd.items[gridNum].pageRows,
        vgrd.items[gridNum].separator,
        vgrd.items[gridNum].cadre,
    );
    defer Gkey.Buf.deinit();
    defer grd.freeGrid(Xcombo);
    defer grd.allocatorGrid.destroy(Xcombo);

    for (vgrd.items[numGrid].cell.items, 0..) |p, idx| {
    grd.newCell(Xcombo, p.text, p.long, p.reftyp, p.atrCell.foregr);
    grd.setCellEditCar(&Xcombo.cell.items[idx], p.edtcar);
    }
    grd.setHeaders(Xcombo);

    const vlist = std.ArrayList([] const u8);
    var m = vlist.init(grd.allocatorGrid);
    for (vgrd.items[gridNum].cell.items) |p|  {
        var vText: []u8= std.heap.page_allocator.alloc(u8, p.long) catch unreachable;
        @memset(vText[0..p.long], '#');
        m.append(vText) catch unreachable;
    }
    for (0..vgrd.items[gridNum].pageRows) |_| {
        Xcombo.data.append(grd.allocatorArgData, .{ .buf = m }) catch |err| {
            @panic(@errorName(err));
        };
    }
    grd.setPageGrid(Xcombo);

    while (true) {
        Gkey = grd.ioCombo(Xcombo, cellPos);

        if (Gkey.Key == kbd.esc) {
            pnl.rstPanel(grd.GRID,Xcombo, vpnl);
            break;
        }
    }
}
// remove Grid
fn removeGrid(vgrid: *std.ArrayList(grd.GRID)) void {
    var savgrid: std.ArrayList(grd.GRID) = std.ArrayList(grd.GRID).init(grd.allocatorGrid);

    var Gkey: grd.GridSelect = undefined;

    
    for (vgrid.items) |p| {
        savgrid.append(p)  
            catch |err| { @panic(@errorName(err)); };
    }

    const Origine: *grd.GRID = grd.newGridC(
        "Origine",
        2,
        2,
        32,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer Gkey.Buf.clearAndFree();
    defer grd.freeGrid(Origine);
    defer grd.allocatorGrid.destroy(Origine);


    grd.newCell(Origine, "index", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgWhite);
    grd.newCell(Origine, "name", 10, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Origine, "X", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "Y", 3, grd.REFTYP.UDIGIT, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "width", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgGreen);
    grd.setHeaders(Origine);

    while (true) {
        grd.resetRows(Origine);
        for (vgrid.items, 0..) |g, idx| {
            const ridx = usizeToStr(idx);
            
            const posx = usizeToStr(g.posx) ;
            const posy = usizeToStr(g.posy) ;
            const lines= usizeToStr(g.lines) ;
            grd.addRows(Origine, &.{ ridx, g.name, posx , posy, lines});
        }

        Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
        if (Gkey.Key == kbd.esc) break;
        if (Gkey.Key == kbd.ctrlV) break;
        if (Gkey.Key == kbd.enter) {
            const ligne: usize = strToUsize(Gkey.Buf.items[0]);

            _ = vgrid.orderedRemove(ligne);
        }
    }

    // restor and exit
    if (Gkey.Key == kbd.esc) {
        vgrid.clearAndFree();
        vgrid.clearRetainingCapacity();

        for (savgrid.items) |p| {
            vgrid.append(p) 
             catch |err| { @panic(@errorName(err)); };
        }
    }

    savgrid.clearAndFree();
    savgrid.deinit();
}

// order GRID
pub fn orderGrid(vgrd: *std.ArrayList(grd.GRID)) void {

    if (vgrd.items.len == 0 ) return;


    var newgrid: std.ArrayList(grd.GRID) = std.ArrayList(grd.GRID).init(grd.allocatorGrid);
    var savgrid: std.ArrayList(grd.GRID) = std.ArrayList(grd.GRID).init(grd.allocatorGrid);


    
    for (vgrd.items) |p| {
        savgrid.append(p)  
            catch |err| { @panic(@errorName(err)); };
    }


    
    var idxligne: usize = 0;
    var Gkey: grd.GridSelect = undefined;

    const Origine: *grd.GRID = grd.newGridC(
        "Origine",
        2,
        2,
        20,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer Gkey.Buf.deinit();
    defer grd.freeGrid(Origine);
    defer grd.allocatorGrid.destroy(Origine);
    grd.newCell(Origine, "index", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgWhite);
    grd.newCell(Origine, "Name"  , 20, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.setHeaders(Origine);



    const Order: *grd.GRID = grd.newGridC(
        "Order",
        2,
        50,
        20,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer grd.freeGrid(Order);
    defer grd.allocatorGrid.destroy(Order);
    grd.newCell(Order, "Col"   , 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Order, "Name"  , 20, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.setHeaders(Order);

    while (true) {
        grd.resetRows(Origine);

        grd.resetRows(Origine);
        for (vgrd.items, 0..) |g, idx| {
            const ridx = usizeToStr(idx);
            grd.addRows(Origine, &.{ ridx, g.name});
        }

        Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
        if (Gkey.Key == kbd.esc) break;
        if (Gkey.Key == kbd.ctrlV) break;
        if (Gkey.Key == kbd.enter) {
            newgrid.append(vgrd.items[ strToUsize(Gkey.Buf.items[0])])
                catch |err| { @panic(@errorName(err)); };
            const ridn =usizeToStr(idxligne);
            grd.addRows(Order, &.{ ridn, Gkey.Buf.items[1]});
            idxligne += 1;
            grd.printGridHeader(Order);
            grd.printGridRows(Order);
            const ligne: usize = strToUsize(Gkey.Buf.items[0]);
            _ = vgrd.orderedRemove(ligne);
        }
    }

    vgrd.clearAndFree();
    vgrd.clearRetainingCapacity();
    // restor and exit
    if (Gkey.Key == kbd.esc) {
        for (savgrid.items) |p| {
            vgrd.append(p) catch |err| { @panic(@errorName(err)); };
        }
    }
    // new Order and exit
    else {
        for (newgrid.items) |p| {
            vgrd.append(p) catch |err| { @panic(@errorName(err)); };
        }
    }
    newgrid.clearAndFree();
    newgrid.deinit();

    savgrid.clearAndFree();
    savgrid.deinit();
}

// view Cell
pub fn viewCell(vpnl: *pnl.PANEL ,vgrd: std.ArrayList(grd.GRID), gridNum: usize) void {

    if (vgrd.items[gridNum].cell.items.len == 0 ) return;
    const cellPos: usize = 0;
    var Gkey: grd.GridSelect = undefined;

    const Xcombo: *grd.GRID = grd.newGridC(
        "Xcombo",
        2,
        2,
        20,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer Gkey.Buf.deinit();
    defer grd.freeGrid(Xcombo);
    defer grd.allocatorGrid.destroy(Xcombo);

    grd.newCell(Xcombo, "Name"  , 20, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Xcombo, "len"   , 3,  grd.REFTYP.UDIGIT,     term.ForegroundColor.fgGreen);
    grd.newCell(Xcombo, "Type"  , 20, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Xcombo, "pos"   , 3,  grd.REFTYP.UDIGIT,    term.ForegroundColor.fgGreen);
    grd.newCell(Xcombo, "Edtcar", 1,  grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgWhite);
    grd.newCell(Xcombo, "Color" , 10, grd.REFTYP.TEXT_FREE,    term.ForegroundColor.fgGreen);
    

    for (vgrd.items[gridNum].cell.items) |p|  {
    grd.addRows(Xcombo, &.{ p.text,usizeToStr(p.long), @tagName(p.reftyp),
                            usizeToStr(p.posy),p.edtcar,@tagName(p.atrCell.foregr)});
    }

    grd.setHeaders(Xcombo);
    while (true) {
        Gkey = grd.ioCombo(Xcombo, cellPos);

        if (Gkey.Key == kbd.esc) {
            pnl.rstPanel(grd.GRID,Xcombo, vpnl);
            break;
        }
    }
}

// order GRID
pub fn orderCell(vgrd: std.ArrayList(grd.GRID), gridNum: usize) void {

    if (vgrd.items[gridNum].cell.items.len == 0 ) return;


    var newcell: std.ArrayList(grd.CELL) = std.ArrayList(grd.CELL).init(grd.allocatorGrid);
    var savcell: std.ArrayList(grd.CELL) = std.ArrayList(grd.CELL).init(grd.allocatorGrid);


    
    for (vgrd.items[gridNum].cell.items) |p|  {
        savcell.append(p)
        catch |err| { @panic(@errorName(err)); };
    }


    
    var idxligne: usize = 0;
    var Gkey: grd.GridSelect = undefined;

    const Origine: *grd.GRID = grd.newGridC(
        "Origine",
        2,
        2,
        20,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer Gkey.Buf.deinit();
    defer grd.freeGrid(Origine);
    defer grd.allocatorGrid.destroy(Origine);

    grd.newCell(Origine, "col"  , 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Origine, "Name"  , 20, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Origine, "len"   , 3,  grd.REFTYP.UDIGIT,     term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "Type"  , 20, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Origine, "pos"   , 3,  grd.REFTYP.UDIGIT,    term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "Edtcar", 1,  grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgWhite);
    grd.newCell(Origine, "Color" , 10, grd.REFTYP.TEXT_FREE,    term.ForegroundColor.fgGreen);
    grd.setHeaders(Origine);



    const Order: *grd.GRID = grd.newGridC(
        "Order",
        2,
        80,
        20,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer grd.freeGrid(Order);
    defer grd.allocatorGrid.destroy(Order);
    grd.newCell(Order, "Col"   , 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Order, "Name"  , 20, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Order, "len"   , 3,  grd.REFTYP.UDIGIT,     term.ForegroundColor.fgGreen);
    grd.newCell(Order, "Type"  , 20, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Order, "pos"   , 3,  grd.REFTYP.UDIGIT,    term.ForegroundColor.fgGreen);
    grd.newCell(Order, "Edtcar", 1,  grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgWhite);
    grd.newCell(Order, "Color" , 10, grd.REFTYP.TEXT_FREE,    term.ForegroundColor.fgGreen);
    grd.setHeaders(Order);

    while (true) {
        grd.resetRows(Origine);

        for (vgrd.items[gridNum].cell.items, 0..) |p,idx|  {
            grd.addRows(Origine, &.{usizeToStr(idx),
                     p.text,usizeToStr(p.long), @tagName(p.reftyp),
                    usizeToStr(p.posy),p.edtcar,@tagName(p.atrCell.foregr)});
        }

        Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
        if (Gkey.Key == kbd.esc) break;
        if (Gkey.Key == kbd.ctrlV) break;
        if (Gkey.Key == kbd.enter) {
            newcell.append(vgrd.items[gridNum].cell.items[ strToUsize(Gkey.Buf.items[0])])
                catch |err| { @panic(@errorName(err)); };
            const ridn =usizeToStr(idxligne);
            grd.addRows(Order, &.{ ridn, Gkey.Buf.items[1], Gkey.Buf.items[2],
                Gkey.Buf.items[3], ridn, Gkey.Buf.items[5], Gkey.Buf.items[6] });
            idxligne += 1;
            grd.printGridHeader(Order);
            grd.printGridRows(Order);
            const ligne: usize = strToUsize(Gkey.Buf.items[0]);
            _ = vgrd.items[gridNum].cell.orderedRemove(ligne);
        }
    }

    vgrd.items[gridNum].cell.clearAndFree();
    vgrd.items[gridNum].cell.clearRetainingCapacity();
    // restor and exit
    if (Gkey.Key == kbd.esc) {
        for (savcell.items) |p| {
            vgrd.items[gridNum].cell.append(p) catch |err| { @panic(@errorName(err)); };
        }
    }
    // new Order and exit
    else {
        for (newcell.items,0..) |_,idx| {
            newcell.items[idx].posy= idx;
        }
        for (newcell.items) |p| {
            vgrd.items[gridNum].cell.append(p) catch |err| { @panic(@errorName(err)); };
        }
    }
    newcell.clearAndFree();
    newcell.deinit();

    savcell.clearAndFree();
    savcell.deinit();
}


// order GRID
pub fn removeCell(vgrd: std.ArrayList(grd.GRID), gridNum: usize) void {

    if (vgrd.items[gridNum].cell.items.len == 0 ) return;

    var savcell: std.ArrayList(grd.CELL) = std.ArrayList(grd.CELL).init(grd.allocatorGrid);

    for (vgrd.items[gridNum].cell.items) |p|  {
        savcell.append(p)
        catch |err| { @panic(@errorName(err)); };
    }



    var Gkey: grd.GridSelect = undefined;

    const Origine: *grd.GRID = grd.newGridC(
        "Xcombo",
        2,
        2,
        20,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer Gkey.Buf.deinit();
    defer grd.freeGrid(Origine);
    defer grd.allocatorGrid.destroy(Origine);

    grd.newCell(Origine, "Col"   , 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Origine, "Name"  , 20, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Origine, "len"   , 3,  grd.REFTYP.UDIGIT,     term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "Type"  , 20, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Origine, "pos"   , 3,  grd.REFTYP.UDIGIT,    term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "Edtcar", 1,  grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgWhite);
    grd.newCell(Origine, "Color" , 10, grd.REFTYP.TEXT_FREE,    term.ForegroundColor.fgGreen);
    grd.setHeaders(Origine);


    while (true) {
        grd.resetRows(Origine);

        for (vgrd.items[gridNum].cell.items, 0..) |p,idx|  {
            grd.addRows(Origine, &.{usizeToStr(idx),
                     p.text,usizeToStr(p.long), @tagName(p.reftyp),
                    usizeToStr(p.posy),p.edtcar,@tagName(p.atrCell.foregr)});
        }

        Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
        if (Gkey.Key == kbd.esc) break;
        if (Gkey.Key == kbd.ctrlV) break;
        if (Gkey.Key == kbd.enter) {
            const ligne: usize = strToUsize(Gkey.Buf.items[0]);
            _ = vgrd.items[gridNum].cell.orderedRemove(ligne);
        }
    }

    // restor and exit
    if (Gkey.Key == kbd.esc) {
        vgrd.items[gridNum].cell.clearAndFree();
        vgrd.items[gridNum].cell.clearRetainingCapacity();
        for (savcell.items) |p| {
            vgrd.items[gridNum].cell.append(p) catch |err| { @panic(@errorName(err)); };
        }
    }
    // new Order and exit
    else {
        
        for (0..vgrd.items[gridNum].cell.items.len ) |idx| {
            vgrd.items[gridNum].cell.items[idx].posy= idx;
        }
    }

    savcell.clearAndFree();
    savcell.deinit();
}

