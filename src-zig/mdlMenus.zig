///-----------------------
/// prog mdlMenu 
///-----------------------

const std = @import("std");


/// terminal Fonction
const term = @import("cursed");
// keyboard
const kbd = @import("cursed").kbd;

// allocator
const mem = @import("alloc");

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
var numMenu : usize = undefined;


pub const ErrMain = error{
    // main_append_XPANEL_invalide,
    main_run_FuncGrid_invalide,
    main_run_TaskGrid_invalide,
    main_run_FcellEnum_invalide,
    main_run_TcellEnum_invalide,
};


    pub fn initMenuDef(
        vname: []const u8,
        vposx: usize,
        vposy: usize,
        vcadre: mnu.CADRE,
        vmnuvh: mnu.MNUVH,
        vxitems : [][] const u8    ) 
        mnu.DEFMENU{
            const xmenu = mnu.DEFMENU{
            .name = vname,
            .posx = vposx,
            .posy = vposy,
            .cadre = vcadre,
            .mnuvh = vmnuvh,
            .xitems = vxitems
            };
        return xmenu;
    }


fn strToUsize(v: []const u8) usize {
    if (v.len == 0) return 0;
    return std.fmt.parseUnsigned(u64, v, 10) catch |err| {
        @panic(@errorName(err));
    };
}

fn usizeToStr(v: usize) []const u8 {
    return std.fmt.allocPrint(mem.allocUtl, "{d}", .{v}) catch |err| {
        @panic(@errorName(err));
    };
}


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
    defer Gkey.Buf.deinit(mem.allocTui);
    defer grd.freeGrid(Xcombo);
    defer mem.allocTui.destroy(Xcombo);

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
pub fn qryCellMenu(vpnl : * pnl.PANEL, vmnu: *std.ArrayList(mnu.DEFMENU), posx: usize) usize {
    const cellPos: usize = 0;
    var Gkey: grd.GridSelect = undefined;

    const Xcombo: *grd.GRID = grd.newGridC(
        "qryPanel",
        1 + posx,
        1,
        10,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer Gkey.Buf.deinit(mem.allocTui);
    defer grd.freeGrid(Xcombo);
    defer mem.allocTui.destroy(Xcombo);

    grd.newCell(Xcombo, "ID", 3, grd.REFTYP.UDIGIT, term.ForegroundColor.fgGreen);
    grd.newCell(Xcombo, "Name", 10, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.setHeaders(Xcombo);

    for (vmnu.items, 0..) |p, idx| {
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

//=================================================
// end desription Function
// display Help
//=================================================
pub fn Panel_HELP() *pnl.PANEL {
    var Panel : *pnl.PANEL = pnl.newPanelC("HELP",
                                        1, 1,
                                        5,
                                        100 ,
                                        forms.CADRE.line1,
                                        ""
                                        );

    Panel.button.append(mem.allocTui,btn.newButton(
                                    kbd.F12,        // function
                                    true,            // show
                                    false,            // check field
                                    "Abord",        // title 
                                    )
                                ) catch unreachable ;
    

    Panel.field.append(mem.allocTui,fld.newFieldTextFull("HELP1",2,5,90,"",false,
                                "","",
                                "")) catch unreachable ;
    fld.setProtect(Panel,0,true) catch unreachable;

    Panel.field.append(mem.allocTui,fld.newFieldTextFull("HELP2",3,5,90,"",false,
                                "","",
                                "")) catch unreachable ;
    fld.setProtect(Panel,1,true) catch unreachable;
    return Panel;
    }

//=================================================

var maxY: usize = 0;
var maxX: usize = 0;
var minY: usize = 0;
var minX: usize = 0;
var X: usize = 0;
var Y: usize = 0;


var NGRID : std.ArrayList(grd.GRID) = undefined;
var NMENU : std.ArrayList(mnu.DEFMENU) = undefined;

pub fn fnPanel( XPANEL: *std.ArrayList(pnl.PANEL),
                XGRID: *std.ArrayList(grd.GRID),
                XMENU: *std.ArrayList(mnu.DEFMENU)) void {
    term.cls();



    numPanel = qryPanel(XPANEL);

    if (numPanel == 999) return;

    NGRID = std.ArrayList(grd.GRID).initCapacity(mem.allocTui,0) catch unreachable;
    for (XGRID.items) |xgrd| { NGRID.append(mem.allocTui,xgrd) catch unreachable; }
    defer NGRID.clearRetainingCapacity();


    NMENU = std.ArrayList(mnu.DEFMENU).initCapacity(mem.allocTui,0) catch unreachable;
    for (XMENU.items) |xmenu| { NMENU.append(mem.allocTui,xmenu) catch unreachable; }
    defer NMENU.clearRetainingCapacity();
 
    term.cls();
    var pFmt01: *pnl.PANEL = pnl.newPanelC("FRAM01",
        XPANEL.items[numPanel].posx, XPANEL.items[numPanel].posy,
        XPANEL.items[numPanel].lines, XPANEL.items[numPanel].cols,
        XPANEL.items[numPanel].frame.cadre,
        XPANEL.items[numPanel].frame.title);

    for (XPANEL.items[numPanel].button.items) |p| {
        pFmt01.button.append(mem.allocTui,p)
        catch |err| { @panic(@errorName(err)); };
    }
    for (XPANEL.items[numPanel].label.items) |p| {
        pFmt01.label.append(mem.allocTui,p)
        catch |err| { @panic(@errorName(err)); };
    }
    for (XPANEL.items[numPanel].field.items, 0..) |p, idx| {
        pFmt01.field.append(mem.allocTui,p) catch |err| { @panic(@errorName(err)); };
        var vText: [] u8 = undefined ;
        

             switch(p.reftyp) {
                forms.REFTYP.TEXT_FREE, forms.REFTYP.TEXT_FULL ,
                forms.REFTYP.ALPHA , forms.REFTYP.ALPHA_UPPER, forms.REFTYP.ALPHA_LOWER,
                forms.REFTYP.ALPHA_NUMERIC, forms.REFTYP.ALPHA_NUMERIC_UPPER, forms.REFTYP.ALPHA_NUMERIC_LOWER,
                forms.REFTYP.PASSWORD, forms.REFTYP.YES_NO  =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
                    @memset(vText[0..p.width], '#');
                } ,

                forms.REFTYP.UDIGIT =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
                    @memset(vText[0..p.width], '0');
                    //editcar
                    if (p.edtcar.len > 0) {
                        vText = std.fmt.allocPrint(mem.allocUtl, "{s}{s}", .{vText, p.edtcar }
                        ) catch unreachable;
                    }
                } ,
            
                forms.REFTYP.DIGIT =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width + 1) catch unreachable;
                    @memset(vText[0..p.width], '0');
                    vText = std.fmt.allocPrint(mem.allocUtl, "+{s}", .{vText[0..p.width]})
                            catch unreachable;
                    //editcar
                    if (p.edtcar.len > 0) {
                        vText = std.fmt.allocPrint(mem.allocUtl, "{s}{s}", .{vText, p.edtcar }
                        ) catch unreachable;
                    }
                } ,
            
                forms.REFTYP.UDECIMAL =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width + 1 + p.scal) catch unreachable;
                    @memset(vText[0..(p.width + p.scal)] , '0');
                    vText = std.fmt.allocPrint(mem.allocUtl, "{s}.{s}", .{vText[0..p.width],vText[0..p.scal]})
                            catch unreachable;
                    //editcar
                    if (p.edtcar.len > 0) {
                        vText = std.fmt.allocPrint(mem.allocUtl, "{s}{s}", .{vText, p.edtcar }
                        ) catch unreachable;
                    }
                } ,
            
                forms.REFTYP.DECIMAL =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width + 2 + p.scal) catch unreachable;
                    @memset(vText[0..(p.width + p.scal)], '0');
                    vText = std.fmt.allocPrint(mem.allocUtl, "+{s}.{s}", .{vText[0..p.width],vText[0..p.scal]})
                            catch unreachable;
                //editcar
                    if (p.edtcar.len > 0) {
                        vText = std.fmt.allocPrint(mem.allocUtl, "{s}{s}", .{vText, p.edtcar }
                        ) catch unreachable;
                    }
                } ,
            
                forms.REFTYP.DATE_ISO =>    vText = std.fmt.allocPrint(mem.allocUtl, "YYYY-MM-DD", .{})
                                                catch unreachable,
                forms.REFTYP.DATE_FR  =>    vText = std.fmt.allocPrint(mem.allocUtl, "DD/MM/YYYY", .{})
                                                catch unreachable,

                forms.REFTYP.DATE_US  =>    vText = std.fmt.allocPrint(mem.allocUtl, "MM/DD/YYYY", .{})
                                                catch unreachable,

                forms.REFTYP.TELEPHONE =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
                    @memset(vText[0..p.width], '*');
                } ,

                forms.REFTYP.MAIL_ISO  =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
                    @memset(vText[0..p.width], '@');
                } ,
                forms.REFTYP.SWITCH   =>    vText = std.fmt.allocPrint(mem.allocUtl, "{s}", .{forms.CTRUE})
                                                catch unreachable,

                forms.REFTYP.FUNC  =>{
                    vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
                    @memset(vText[0..p.width], 'F');
                } ,

            }
            fld.setText(pFmt01,    idx, vText) catch |err| { @panic(@errorName(err)); };

    }


    for (XPANEL.items[numPanel].linev.items) |p| {
        pFmt01.linev.append(mem.allocTui,p)
        catch |err| { @panic(@errorName(err)); };
    }
    for (XPANEL.items[numPanel].lineh.items) |p| {
        pFmt01.lineh.append(mem.allocTui,p)
        catch |err| { @panic(@errorName(err)); };
    }

  
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
    const pFmtH01 = Panel_HELP();
    while (true) {
        term.cursShow();
        Tkey = kbd.getKEY();

        if (Tkey.Key == kbd.mouse) {
            forms.dspMouse(pFmt01);
            continue;
        } // active display Cursor x/y mouse

        switch (Tkey.Key) {
            .F1     => {
                fld.setText(pFmtH01,0,"F11 ENRG  F12 Abort  Alt-M add-Menu Alt-D remove Alt-C add-Cell")
                    catch unreachable;
                fld.setText(pFmtH01,1,"AltV view  Alt-H/L fixed menu high/low Alt-R refresh")
                    catch unreachable;

                _= pnl.ioPanel(pFmtH01);
                pnl.rstPanel(pnl.PANEL,pFmtH01,pFmt01);
                term.gotoXY(1,1);
                continue;
            },
            .F11 => {
                XMENU.clearRetainingCapacity();
                for (NMENU.items) |xmnu| {
                    for (xmnu.xitems) |text | {
                        if (text.len > 0) {
                            XMENU.append(mem.allocTui,
                                initMenuDef(
                                    xmnu.name,
                                    xmnu.posx,
                                    xmnu.posy,
                                    xmnu.cadre,
                                    xmnu.mnuvh,
                                    xmnu.xitems
                                )
                            ) catch unreachable;
                        }
                        break;
                    }
                }
                pnl.freePanel(pFmt01);
                defer mem.allocTui.destroy(pFmt01);
                defer NMENU.clearRetainingCapacity();
                defer NGRID.clearRetainingCapacity();
                return;
            },
            .F12 => {
                pnl.freePanel(pFmt01);
                defer mem.allocTui.destroy(pFmt01);
                return;
            },


            // def Menu
            .altM => {
                term.getCursor();
                
                if (term.posCurs.x < minX or term.posCurs.x > maxX or
                    term.posCurs.y < minY or term.posCurs.y > maxY) continue;

                term.writeStyled("?", pFmt01.attribut);
                term.gotoXY(term.posCurs.x , term.posCurs.y );
                term.getCursor();
                term.offMouse();
                writeDefMenu(pFmt01);
                term.cls();
                pnl.printPanel(pFmt01);
                term.onMouse();
            },

            // def field
            .altC => {
                numMenu = qryCellMenu(pFmt01, &NMENU,0);

                if (numMenu != 999) {
                    term.offMouse();
                    writeDefCell(&NMENU,numMenu);
                    term.cls();
                    pnl.printPanel(pFmt01);
                    term.onMouse();
                }
            },


            // view 
            .altV => {
                numMenu = qryCellMenu(pFmt01, &NMENU,0);

                if (numMenu != 999) {
                    term.offMouse();
                    viewMenu(pFmt01,NMENU,numMenu );
                    term.cls();
                    pnl.printPanel(pFmt01);
                    term.onMouse();
                }    
            },


            // remove
            .altD => {
                    removeMenu(&NMENU);
                    term.cls();
                    pnl.printPanel(pFmt01);
                    term.onMouse();
            },
            
            // view high
            .altH => {
                numMenu = qryCellMenu(pFmt01, &NMENU,0);

                if (numMenu != 999) {
                    term.offMouse();
                    const Menudisplay = mnu.newMenu(
                                    NMENU.items[numMenu].name,            // name
                                    NMENU.items[numMenu].posx,            // posx
                                    NMENU.items[numMenu].posy,            // posy
                                    NMENU.items[numMenu].cadre,            // type line fram
                                    NMENU.items[numMenu].mnuvh,            // type menu vertical / horizontal
                                    NMENU.items[numMenu].xitems,            // Item const 
                                    ) ;
                    _= mnu.ioMenu(Menudisplay,0);
                    term.gotoXY(1,1);
                    term.onMouse();
                }
            },
            // view low
            .altL => {
                numMenu = qryCellMenu(pFmt01, &NMENU,20);

                if (numMenu != 999) {
                    term.offMouse();
                    const Menudisplay = mnu.newMenu(
                                    NMENU.items[numMenu].name,            // name
                                    NMENU.items[numMenu].posx,            // posx
                                    NMENU.items[numMenu].posy,            // posy
                                    NMENU.items[numMenu].cadre,            // type line fram
                                    NMENU.items[numMenu].mnuvh,            // type menu vertical / horizontal
                                    NMENU.items[numMenu].xitems,            // Item const 
                                    ) ;
                    _= mnu.ioMenu(Menudisplay,0);
                    term.gotoXY(1,1);
                    term.onMouse();
                }
            },
        
            // clear
            .altR => {
                    term.cls();
                    pnl.printPanel(pFmt01);
                    term.onMouse();
            },
            else => {},
        }
    }
}

//=====================================================
// display definition frame menu
//=====================================================

// forms field
const fp02 = enum {
    fname,
    fposx,
    fposy,
    fcadre,
    fsens
};


fn Panel_defMenu(nposx: usize) *pnl.PANEL {


    var Panel: *pnl.PANEL = pnl.newPanelC("FRAM02", nposx ,2,9, 42, forms.CADRE.line1, "Def.field");

    Panel.button.append(mem.allocTui,btn.newButton(
        kbd.F9, // function
        true, // show
        true, // check field
        "Enrg", // title
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.button.append(mem.allocTui,btn.newButton(
        kbd.F12, // function
        true, // show
        false, // check field
        "Return", // title
    )) catch |err| { @panic(@errorName(err)); }; 

    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fname)  ,2,2, "name.....:") ) catch unreachable ;
    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fposx)  ,3,2, "posX.....:") ) catch unreachable ;
    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fposy)  ,4,2, "posy.....:") ) catch unreachable ;
    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fcadre) ,5,2, "cadre....:") ) catch unreachable ;
    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fsens)  ,6,2, "sens.....:") ) catch unreachable ;

    Panel.field.append(mem.allocTui,fld.newFieldAlphaNumeric(@tagName(fp02.fname),2,12,10,"",true,
                            "required","please enter :text [a-zA-Z]{1,1} [A-z0-9]",
                            "^[a-zA-Z]{1,1}[a-zA-Z0-9]{0,}$")) catch unreachable ;
    fld.setTask(Panel,@intFromEnum(fp02.fname),"TaskName") catch unreachable ;

    Panel.field.append(mem.allocTui,fld.newFieldUDigit(@tagName(fp02.fposx),3,12,2,"",false,
                            "","please enter Pos X 1...",
                            "^[1-9]{1,1}?[0-9]{0,}$")) catch unreachable ;
    fld.setProtect(Panel,@intFromEnum(fp02.fposx),true) catch unreachable ;

    Panel.field.append(mem.allocTui,fld.newFieldUDigit(@tagName(fp02.fposy),4,12,3,"",false,
                            "","please enter Pos y 1...",
                            "^[1-9]{1,1}?[0-9]{0,}$")) catch unreachable ;
    fld.setProtect(Panel,@intFromEnum(fp02.fposy),true) catch unreachable ;

    Panel.field.append(mem.allocTui,fld.newFieldFunc(@tagName(fp02.fcadre),5,12,5,"",true,"FuncCadre",
                            "required","please enter line1 line2")) catch unreachable ;
    fld.setTask(Panel,@intFromEnum(fp02.fcadre),"TaskCadre") catch unreachable ; 

    Panel.field.append(mem.allocTui,fld.newFieldFunc(@tagName(fp02.fsens),6,12,10,"",false,"FuncSens",
                            "required","please enter horizontal verticale ",
                            )) catch unreachable ;
    fld.setTask(Panel,@intFromEnum(fp02.fsens),"TaskSens") catch unreachable ;
    return Panel;
  }




//=================================================
// Description Function
// Func: Think of it as a choice like a fixed combo

var callFuncMenu: FuncMenu = undefined;
// description Function
// choix Cadre
fn FuncCadre( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {

    var pos:usize = 0;

    var mCadre = mnu.newMenu(
                            "cadre",                // name
                            vpnl.posx + 1, 20,        // posx, posy
                            mnu.CADRE.line1,        // type line fram
                            mnu.MNUVH.vertical,        // type menu vertical / horizontal
                            &.{                        // item
                            "line1",
                            "line2",
                            });
    var nitem    :usize = 0;
    if (std.mem.eql(u8, vfld.text, "line1")) pos = 0;
    if (std.mem.eql(u8, vfld.text, "line2")) pos = 1;
    while (true) {
        nitem    = mnu.ioMenu(mCadre,pos);
        if (nitem != 9999) break;
    }

    vfld.text = std.fmt.allocPrint(mem.allocUtl,"{s}",
                        .{@tagName(@as(mnu.CADRE,@enumFromInt(nitem + 1)))}) catch unreachable;

    pnl.rstPanel(mnu.MENU,&mCadre,vpnl);
}

// choix Sens Orientation
fn FuncSens( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {

    var pos:usize = 0;

    var mCadre = mnu.newMenu(
                            "Style",                // name
                            vpnl.posx + 1, 20,        // posx, posy
                            mnu.CADRE.line1,        // type line frame
                            mnu.MNUVH.vertical,        // type menu vertical / horizontal
                            &.{                        // item
                            "verticale",
                            "horizontal",
                            });
    var nitem    :usize = 0;
    if (std.mem.eql(u8, vfld.text, " ")) pos = 0;
    if (std.mem.eql(u8, vfld.text, "verticale"))  pos = 0;
    if (std.mem.eql(u8, vfld.text, "horizontal")) pos = 1;

    while (true) {
        nitem    = mnu.ioMenu(mCadre,pos);
        if (nitem != 9999) break;
    }
    vfld.text = std.fmt.allocPrint(mem.allocUtl,"{s}",
                        .{@tagName(@as(mnu.MNUVH,@enumFromInt(nitem    )))}) catch unreachable;

     pnl.rstPanel(mnu.MENU,&mCadre,vpnl);
}
//-------------------------
// exec funtion
//-------------------------
pub const FuncMenu = enum {
    FuncSens,
    FuncCadre,
    none,

    pub fn run(self: FuncMenu , vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
        switch (self) {
            .FuncSens  => FuncSens(vpnl, vfld),
            .FuncCadre => FuncCadre(vpnl, vfld),
            else => dsperr.errorForms(vpnl, ErrMain.main_run_FuncGrid_invalide),
        }
    }

    fn searchFn(vtext: []const u8) FuncMenu {
        inline for (@typeInfo(FuncMenu).@"enum".fields) |f| {
            if (std.mem.eql(u8, f.name, vtext)) return @as(FuncMenu, @enumFromInt(f.value));
        }
        return FuncMenu.none;
    }
};

//=================================================
// description Function
// Task: Performs complex checks, automatically upon input output,
// but can be used as a control flow before validating the form.

fn TaskName(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    for (NMENU.items) |f| {
        if (std.mem.eql(u8, f.name, vfld.text)) {
            pnl.msgErr(vpnl, "Already existing invalide Name");
            vpnl.keyField = kbd.task;
            return;
        }
    }
}

fn TaskCadre( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {
    
    if (std.mem.eql(u8, vfld.text,""))  {
        pnl.msgErr(vpnl, "Cadre is invalide");
        vpnl.keyField = kbd.task;
        }
}


fn TaskSens( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {
    
    if (std.mem.eql(u8, vfld.text,"")) {
        pnl.msgErr(vpnl, "Sense is invalide");
        vpnl.keyField = kbd.task;
        }
}


var callTaskMenu: TaskMenu = undefined;
//=================================================
// description Function
// exec Task

pub const TaskMenu= enum {
    TaskName,
    TaskCadre,
    TaskSens,
    none,

    pub fn run(self: TaskMenu, vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
        switch (self) {
            .TaskName    => TaskName(vpnl, vfld),
            .TaskCadre    => TaskCadre(vpnl,vfld),
            .TaskSens    => TaskSens(vpnl,vfld),
            else => dsperr.errorForms(vpnl, ErrMain.main_run_TaskGrid_invalide),
        }
    }
    fn searchFn(vtext: []const u8) TaskMenu {
        inline for (@typeInfo(TaskMenu).@"enum".fields) |f| {
            if (std.mem.eql(u8, f.name, vtext)) return @as(TaskMenu, @enumFromInt(f.value));
        }
        return TaskMenu.none;
    }
};
//---------------------------------------------------------------------------

pub fn writeDefMenu(vpnl: *pnl.PANEL) void {
    term.getCursor();
    const v_posx: usize = term.posCurs.x;
    const v_posy: usize = term.posCurs.y;

    // Init format panel
    var v_pos :usize = 0;
    if (v_posx >= 20 ) v_pos = 2 else v_pos = 22 ;
    var pFmt02 = Panel_defMenu(v_pos);
    pFmt02.field.items[@intFromEnum(fp02.fposx)].text = usizeToStr(v_posx);
    pFmt02.field.items[@intFromEnum(fp02.fposy)].text = usizeToStr(v_posy);
    
    // init struct key
    var Tkey: term.Keyboard = undefined; 

    while (true) {

        forms.dspCursor(vpnl, v_posx, v_posy,"Def. Menu");
        Tkey.Key = pnl.ioPanel(pFmt02);
        switch (Tkey.Key) {
            // call function combo
            .func => {
                callFuncMenu = FuncMenu.searchFn(pFmt02.field.items[pFmt02.idxfld].procfunc);
                callFuncMenu.run(pFmt02, &pFmt02.field.items[pFmt02.idxfld]);
            },
            // call proc control chek value
            .task => {
                callTaskMenu = TaskMenu.searchFn(pFmt02.field.items[pFmt02.idxfld].proctask);
                callTaskMenu.run(pFmt02, &pFmt02.field.items[pFmt02.idxfld]);
            },
            // write field to panel
            .F9 => {
                // control 
                for (pFmt02.field.items, 0.. ) |f , idx | {
                    if (f.proctask.len > 0) {
                        pFmt02.idxfld =  idx;
                        pFmt02.keyField = kbd.none;
                        callTaskMenu  = TaskMenu.searchFn(f.proctask);
                        callTaskMenu.run(pFmt02, &pFmt02.field.items[pFmt02.idxfld]);
                        if (pFmt02.keyField == kbd.task) break;
                    }
                }
                if (pFmt02.keyField == kbd.task) continue;
                const vitems : [][]const u8 = mem.allocTui.alloc([]const u8, 1) catch unreachable;
                const bl : []const u8 = "";
                vitems[0] = bl;
                NMENU.append(mem.allocTui, initMenuDef(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToEnum(mnu.CADRE,pFmt02.field.items[@intFromEnum(fp02.fcadre)].text),
                            strToEnum(mnu.MNUVH,pFmt02.field.items[@intFromEnum(fp02.fsens)].text),
                            vitems
                        )) catch unreachable;

                pnl.freePanel(pFmt02);
                defer mem.allocTui.destroy(pFmt02);
                return;
            },

            // exit panel field
            .F12 => {
                pnl.freePanel(pFmt02);
                defer mem.allocTui.destroy(pFmt02);
                return;
            },
            else => {},
        }
    }
}
//==========================================
// CELL Management
// defining menu options
//==========================================

// forms field
const fp03 = enum {
    ftext1,
    ftext2,
    ftext3,
    ftext4,
    ftext5,
    ftext6,
    ftext7,
    ftext8,
    ftext9,
    ftext10,
    ftext11,
    ftext12,
    ftext13,
    ftext14,
    ftext15,
    ftext16,
    ftext17,
    ftext18,
    ftext19,
    ftext20,
    ftext21,
    ftext22,
    ftext23,
    ftext24,
    ftext25,
    ftext26,
};
// panel for field
fn Panel_Fmt03() *pnl.PANEL {
    var Panel: *pnl.PANEL = pnl.newPanelC("FRAM03", 2, 2 , 30, 82, forms.CADRE.line1, "Def.Menu");
    
    Panel.button.append(mem.allocTui,btn.newButton(
        kbd.F9, // function
        true, // show
        true, // check field
        "Enrg", // title
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.button.append(mem.allocTui,btn.newButton(
        kbd.F12, // function
        true, // show
        false, // check field
        "Return", // title
    )) catch |err| { @panic(@errorName(err)); }; 
    
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext1),
        2, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext2),
        3, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext3),
        4, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext4),
        5, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext5),
        6, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext6),
        7, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext7),
        8, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext8),
        9, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext9),
        10, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext10),
        11, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext11),
        12, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext12),
        13, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext13),
        14, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext14),
        15, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext15),
        16, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext16),
        17, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext17),
        18, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext18),
        19, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext19),
        20, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext20),
        21, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext21),
        22, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext22),
        23, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext23),
        24, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext24),
        25, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext25),
        26, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp03.ftext26),
        27, 2 ,
        80, // len
        "", // text
        false, // required
        "required help ctrl-h", // Msg err
        "please enter text 1 car Letter  other alphanumeric", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); };


    return Panel;
}


//---------------------------------------------------------------------------
pub fn writeDefCell(vMenu: *std.ArrayList(mnu.DEFMENU) , menuNum : usize) void {
    term.getCursor();


    // Init format panel
    const pFmt03 = Panel_Fmt03();
    // init zone field
    for (vMenu.items[menuNum].xitems, 0..) |text , idx| {
        if (text.len > 0) {
                pFmt03.field.items[idx].text = text;
        }
    }
    // init struct key
    var Tkey: term.Keyboard = undefined; 

        while (true) {

        Tkey.Key = pnl.ioPanel(pFmt03);
        switch (Tkey.Key) {
            // write field to panel
            .F9 => {
                    var fxx : usize = @intFromEnum(fp03.ftext1);
                    var nTst : usize = 0;
                    while ( fxx <= @intFromEnum(fp03.ftext26)) :( fxx += 1 ) {
                        if (pFmt03.field.items[fxx].text.len == 0) nTst += 1;
                    }
                         
                    if (nTst == 26) {
                        pnl.msgErr(pFmt03, "No definition, INVALID record");
                    }
                    else {
                        var xmenu =  std.ArrayList([]const u8).initCapacity(mem.allocTui,0) catch unreachable;
                        fxx  = @intFromEnum(fp03.ftext1);
                        nTst = 0;
                        while ( fxx <= @intFromEnum(fp03.ftext26)) :( fxx += 1 ) {
                            if (pFmt03.field.items[fxx].text.len > 0) {
                                nTst += 1;
                                xmenu.append(mem.allocTui,pFmt03.field.items[fxx].text) catch unreachable;
                            }
                        }
                        var menu : [] []const u8 = undefined;
                        if ( nTst > 0) {
                            menu = mem.allocTui.alloc([]const u8, nTst) catch unreachable;
                            for (xmenu.items, 0.. ) |txt,idx | {
                                menu[idx] = txt; 
                            }
                            vMenu.items[menuNum].xitems = menu;
                        } 
                        else {
                            menu = mem.allocTui.alloc([]const u8, 1) catch unreachable;
                            
                            const bl : []const u8 = "";
                            menu[0] = bl;
                        }
                        vMenu.items[menuNum].xitems = menu;
                    
                        pnl.freePanel(pFmt03);
                        defer mem.allocTui.destroy(pFmt03);
                        return;
                    }
            },

            // exit panel field Menu
            .F12 => {
                pnl.freePanel(pFmt03);
                defer mem.allocTui.destroy(pFmt03);
                return;
            },
            else => {},
        }
    }
}
//=================================================
// description Function
// view Menu
pub fn viewMenu(vpnl: *pnl.PANEL ,vmnu: std.ArrayList(mnu.DEFMENU), menuNum: usize) void {

        var Menudisplay = mnu.newMenu(
                        vmnu.items[menuNum].name,            // name
                        vmnu.items[menuNum].posx,            // posx
                        vmnu.items[menuNum].posy,            // posy
                        vmnu.items[menuNum].cadre,            // type line fram
                        vmnu.items[menuNum].mnuvh,            // type menu vertical / horizontal
                        vmnu.items[menuNum].xitems,            // Item const 
                        ) ;
        _= mnu.ioMenu(Menudisplay,0);
        pnl.rstPanel(mnu.MENU,&Menudisplay,vpnl);

}
// remove MenuGrid
fn removeMenu(vmenu: *std.ArrayList(mnu.DEFMENU)) void {
    var savgrid: std.ArrayList(mnu.DEFMENU) = std.ArrayList(mnu.DEFMENU).initCapacity(mem.allocTui,0) catch unreachable;

    var Gkey: grd.GridSelect = undefined;

    
    for (vmenu.items) |p| {
        savgrid.append(mem.allocTui,p)  
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
    defer Gkey.Buf.clearAndFree(mem.allocTui);
    defer grd.freeGrid(Origine);
    defer mem.allocTui.destroy(Origine);


    grd.newCell(Origine, "index", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgWhite);
    grd.newCell(Origine, "name", 10, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Origine, "X", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "Y", 3, grd.REFTYP.UDIGIT, term.ForegroundColor.fgGreen);
    grd.setHeaders(Origine);

    while (true) {
        grd.resetRows(Origine);
        for (vmenu.items, 0..) |g, idx| {
            const ridx = usizeToStr(idx);
            
            const posx = usizeToStr(g.posx) ;
            const posy = usizeToStr(g.posy) ;
            grd.addRows(Origine, &.{ ridx, g.name, posx , posy});
        }

        Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
        if (Gkey.Key == kbd.esc) break;
        if (Gkey.Key == kbd.ctrlV) break;
        if (Gkey.Key == kbd.enter) {
            const ligne: usize = strToUsize(Gkey.Buf.items[0]);

            _ = vmenu.orderedRemove(ligne);
        }
    }

    // restor and exit
    if (Gkey.Key == kbd.esc) {
        vmenu.clearAndFree(mem.allocTui);
        vmenu.clearRetainingCapacity();

        for (savgrid.items) |p| {
            vmenu.append(mem.allocTui,p) 
             catch |err| { @panic(@errorName(err)); };
        }
    }

    savgrid.clearAndFree(mem.allocTui);
    savgrid.deinit(mem.allocTui);
}
