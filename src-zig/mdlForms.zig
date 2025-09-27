///-----------------------
/// prog Forms
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
var numGrid : usize = undefined;
var NGRID : std.ArrayList(grd.GRID) = .empty;

pub const ErrMain = error{
    main_append_XPANEL_invalide,
    main_run_EnumFunc_invalide,
    main_run_EnumTask_invalide,
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
    return std.fmt.allocPrint(mem.allocUtl, "{d}", .{v}) catch |err| {
        @panic(@errorName(err));
    };
}

// specifique for mdlForms not pub
fn setName(vpnl: *pnl.PANEL , n: usize, val:[] const u8) forms.ErrForms ! void {
    if ( n < vpnl.field.items.len) vpnl.field.items[n].name = val
    else return forms.ErrForms.fld_setName_Index_invalide;
}

fn setRefType(vpnl: *pnl.PANEL , n: usize, val:forms.REFTYP) forms.ErrForms ! void {
    if ( n < vpnl.field.items.len) vpnl.field.items[n].reftyp = val
    else return forms.ErrForms.fld_setRefType_Index_invalide;
}


fn setWidth(vpnl: *pnl.PANEL , n: usize, val:usize) forms.ErrForms ! void {
    if ( n < vpnl.field.items.len) vpnl.field.items[n].width = val
    else return forms.ErrForms.fld_setWidth_Index_invalide;
}


//=================================================
// description Function
// choix work panel
pub fn qryPanel(vpnl: *std.ArrayList(pnl.PANEL)) usize {
    const cellPos: usize = 0;

    const Xcombo: *grd.GRID = grd.newGridC(
        "qryPanel",
        1,
        1,
        20,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer mem.allocTui.destroy(Xcombo);

    grd.newCell(Xcombo, "ID", 3, grd.REFTYP.UDIGIT, term.ForegroundColor.fgGreen);
    grd.newCell(Xcombo, "Name", 10, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Xcombo, "Title", 15, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.setHeaders(Xcombo);

    for (vpnl.items, 0..) |p, idx| {
        grd.addRows(Xcombo, &.{ usizeToStr(idx), p.name, p.frame.title });
    }

    var Gkey: grd.GridSelect = undefined;
    defer Gkey.Buf.deinit(mem.allocTui);

    while (true) {
        Gkey = grd.ioCombo(Xcombo, cellPos);

        if (Gkey.Key == kbd.enter) {
            grd.freeGrid(Xcombo);

            return strToUsize(Gkey.Buf.items[0]);
        }

        if (Gkey.Key == kbd.esc) {
            grd.freeGrid(Xcombo);

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

    
    Panel.field.append(mem.allocTui,fld.newFieldTextFull("HELP3",4,5,90,"",false,
                                "","",
                                "")) catch unreachable ;
    fld.setProtect(Panel,2,true) catch unreachable;
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

//pub fn main() !void {
pub fn fnPanel(XPANEL: *std.ArrayList(pnl.PANEL), XGRID: *std.ArrayList(grd.GRID)) void {
    term.cls();

    numPanel = qryPanel(XPANEL);

    NGRID = std.ArrayList(grd.GRID).initCapacity(mem.allocTui,0) catch unreachable;
    for (XGRID.items) |xgrd| { NGRID.append(mem.allocTui,xgrd) catch unreachable; }
    defer NGRID.clearRetainingCapacity();


    if (numPanel == 999) return;

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
                forms.REFTYP.TEXT_FREE, forms.REFTYP.TEXT_FULL ,    forms.REFTYP.ALPHA ,
                forms.REFTYP.ALPHA_UPPER,    forms.REFTYP.ALPHA_NUMERIC, forms.REFTYP.ALPHA_NUMERIC_UPPER,
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


    var mChoix = mnu.newMenu("Choix", // name
            1, 1, // posx, posy
            mnu.CADRE.line1, // type line fram
            mnu.MNUVH.vertical, // type menu vertical / horizontal
            &.{ // item
            "Label-Order",
            "Label-Remove",
            "field-Order",
            "field-Remove",
            "Horizontal-Order",
            "Horizontal-Remove",
            "Vertical-Order",
            "Vertical-Remove"
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
                fld.setText(pFmtH01,0,"F11 ENRG   F12 Abort   Alt-T Title   Alt-L label ")
                    catch unreachable;
                fld.setText(pFmtH01,1,"Alt-F Field (new)   Alt-U Field(update)")
                    catch unreachable;
                fld.setText(pFmtH01,2,"Line Alt-H Horizontal   Alt-V Vertical   Alt-W Outils  Alt-G Grid")
                    catch unreachable;

                _= pnl.ioPanel(pFmtH01);
                pnl.rstPanel(pnl.PANEL,pFmtH01,pFmt01);
                term.gotoXY(1,1);
                continue;
            },
            .F11 => {
                XPANEL.items[numPanel].label.clearAndFree(mem.allocTui);
                XPANEL.items[numPanel].label = std.ArrayList(lbl.LABEL).initCapacity(mem.allocTui,0) catch unreachable;
                XPANEL.items[numPanel].label.clearRetainingCapacity();
                for (pFmt01.label.items) |p| {
                    XPANEL.items[numPanel].label.append(mem.allocTui,p)
                        catch |err| { @panic(@errorName(err)); };
                }

                XPANEL.items[numPanel].field.clearAndFree(mem.allocTui);
                XPANEL.items[numPanel].field = std.ArrayList(fld.FIELD).initCapacity(mem.allocTui,0) catch unreachable;
                XPANEL.items[numPanel].field.clearRetainingCapacity();
                for (pFmt01.field.items) |p| {
                    XPANEL.items[numPanel].field.append(mem.allocTui,p) 
                        catch |err| { @panic(@errorName(err)); };
                }

                XPANEL.items[numPanel].lineh.clearAndFree(mem.allocTui);
                XPANEL.items[numPanel].lineh = std.ArrayList(lnh.LINEH).initCapacity(mem.allocTui,0) catch unreachable;
                XPANEL.items[numPanel].lineh.clearRetainingCapacity();
                for (pFmt01.lineh.items) |p| {
                    XPANEL.items[numPanel].lineh.append(mem.allocTui,p) 
                        catch |err| { @panic(@errorName(err)); };
                }

                XPANEL.items[numPanel].linev.clearAndFree(mem.allocTui);
                XPANEL.items[numPanel].linev = std.ArrayList(lnv.LINEV).initCapacity(mem.allocTui,0) catch unreachable;
                XPANEL.items[numPanel].linev.clearRetainingCapacity();
                for (pFmt01.linev.items) |p| {
                    XPANEL.items[numPanel].linev.append(mem.allocTui,p) 
                        catch |err| { @panic(@errorName(err)); };
                }
                pnl.freePanel(pFmt01);
                defer mem.allocTui.destroy(pFmt01);
                pnl.freePanel(pFmtH01);
                defer mem.allocTui.destroy(pFmtH01);
                term.deinitTerm();
                mem.deinitUtl();
                return;
            },
            .F12 => {
                pnl.freePanel(pFmt01);
                defer mem.allocTui.destroy(pFmt01);
                pnl.freePanel(pFmtH01);
                defer mem.allocTui.destroy(pFmtH01);
                term.deinitTerm();
                mem.deinitUtl();
                return;
            },

            // Def Title
            .altT => {
                term.getCursor();
                
                if (term.posCurs.x < minX or term.posCurs.x > maxX or
                    term.posCurs.y < minY or term.posCurs.y > maxY) continue;
                
                term.offMouse();
                writeLabel(pFmt01, true);
                pnl.printPanel(pFmt01);
                term.onMouse();
            },

            // def label
            .altL => {
                term.getCursor();
                
                if (term.posCurs.x < minX or term.posCurs.x > maxX or
                    term.posCurs.y < minY or term.posCurs.y > maxY) continue;
                
                term.offMouse();
                writeLabel(pFmt01, false);
                pnl.printPanel(pFmt01);
                term.onMouse();
            },

            // def field
            .altF => {
                term.getCursor();
                
                if (term.posCurs.x < minX or term.posCurs.x > maxX or
                    term.posCurs.y < minY or term.posCurs.y > maxY) continue;

                term.writeStyled("?", pFmt01.attribut);
                term.gotoXY(term.posCurs.x , term.posCurs.y );
                term.getCursor();
                term.offMouse();
                writefield(pFmt01);
                term.cls();
                pnl.printPanel(pFmt01);
                term.onMouse();
            },
            
            // display GRID
            .altG => {
                numGrid = qryCellGrid(pFmt01,&NGRID);

                if (numGrid != 999) {
                    term.offMouse();
                    term.cursHide();
                    viewGrid(pFmt01,NGRID,numGrid);
                    term.gotoXY(1,1);
                    term.cursShow();
                }
                term.onMouse();
            },
            // update field
            .altU => {
                term.getCursor();
                
                if (term.posCurs.x < minX or term.posCurs.x > maxX or
                    term.posCurs.y < minY or term.posCurs.y > maxY) continue;
                
                for (pFmt01.field.items, 0..) |p, nI| {
                    if (p.posx == ((term.posCurs.x - pFmt01.posx) + 1)  and
                    p.posy == ((term.posCurs.y - pFmt01.posy ) + 1 )) {
                        term.writeStyled("?", pFmt01.attribut);
                        term.gotoXY(term.posCurs.x , term.posCurs.y );
                        term.getCursor();
                        term.offMouse();
                        updateField(pFmt01, nI, p);
                        break;
                    }
                }
                term.cls();
                pnl.printPanel(pFmt01);
                term.onMouse();
            },

            // def line Horizontal
            .altH => {
                term.getCursor();
                
                if (term.posCurs.x < minX or term.posCurs.x > maxX or
                    term.posCurs.y < minY or term.posCurs.y > maxY) continue;

                term.writeStyled("?", pFmt01.attribut);
                term.gotoXY(term.posCurs.x, term.posCurs.y );
                term.getCursor();
                term.offMouse();
                writeHorizontal(pFmt01);
                term.cls();
                pnl.printPanel(pFmt01);
                term.onMouse();
            },

            // def line Vertical
            .altV => {
                term.getCursor();
                
                if (term.posCurs.x < minX or term.posCurs.x > maxX or
                    term.posCurs.y < minY or term.posCurs.y > maxY) continue;

                term.writeStyled("?", pFmt01.attribut);
                term.gotoXY(term.posCurs.x, term.posCurs.y );
                term.getCursor();
                term.offMouse();
                writeVertical(pFmt01);
                term.cls();
                pnl.printPanel(pFmt01);
                term.onMouse();
            },
            // Order / Remove
            .altW => {
                var nitem: usize = 0;
                nitem = mnu.ioMenu(mChoix, nitem);
                term.offMouse();
                pnl.rstPanel(mnu.MENU,&mChoix,pFmt01);
                term.onMouse();

                if (nitem == 0) orderLabel(pFmt01);    // Order  Label

                if (nitem == 1) removeLabel(pFmt01);   // Remove Labely

                if (nitem == 2) orderField(pFmt01);    // order field

                if (nitem == 3) removeField(pFmt01);   // Remove field

                if (nitem == 4) orderHorizontal(pFmt01);    // order Line Horizontal

                if (nitem == 5) removeHorizontal(pFmt01);   // Remove Line vertical

                if (nitem == 6) orderVertical(pFmt01);    // order Line Horizontal

                if (nitem == 7) removeVertical(pFmt01);   // Remove Line vertical
                    
                term.cls();
                pnl.printPanel(pFmt01);
                term.onMouse();
            },
            else => {},
        }
    }
}

//------------------------------------------------------------------
// definition label

fn writeLabel(vpnl: *pnl.PANEL, vtitle: bool) void {
    //term.getCursor();
    var e_count: usize = 0;
    var tampon: []const u8 = undefined;
    var text: []const u8 = undefined;
    var e_LABEL = std.ArrayList([]const u8).initCapacity(mem.allocTui,0) catch unreachable;
    defer e_LABEL.deinit(mem.allocTui);
    defer mem.allocTui.destroy(&e_LABEL);

    var e_posx: usize = term.posCurs.x;
    var e_posy: usize = term.posCurs.y;
    var e_curs: usize = e_posy;

    // defines the receiving structure of the keyboard
    var Tkey: term.Keyboard = undefined;
    const pFmtH01 = Panel_HELP();

    var i: usize = 0;
    while (i < vpnl.cols) : (i += 1) {
        e_LABEL.append(mem.allocTui," ") catch |err| {
            @panic(@errorName(err));
        };
    }
    while (true) {
        forms.dspCursor(vpnl, e_posx, e_curs,"Label/Title");

        Tkey = kbd.getKEY();

        //forms.dspMouse(vpnl);  // active display Cursor x/y mouse
        //std.debug.print("Key: {d}  - {d}\n\r",.{term.posCurs.x, term.posCurs.y});
        switch (Tkey.Key) {
            .F1     => {
                fld.setText(pFmtH01,0,"F12 Abort  ctrl-V") catch unreachable;
                _= pnl.ioPanel(pFmtH01);
                pnl.rstPanel(pnl.PANEL,pFmtH01,vpnl);
                term.gotoXY(1,1);
                continue;
            },
            
            .F12 => return,

            .ctrlV => {
                e_posx -= vpnl.posx ; e_posy -= vpnl.posy;
                tampon = std.fmt.allocPrint(mem.allocTui, "L{d}{d}", .{e_posx + 1, e_posy + 1 })
                    catch |err| { @panic(@errorName(err)); };
                
                text = utl.trimStr(utl.listToStr(e_LABEL));
                if (vtitle == true ) {
                    vpnl.label.append(mem.allocTui,lbl.newTitle(tampon, e_posx + 1, e_posy + 1 , fld.ToStr(text)))
                    catch |err| { @panic(@errorName(err)); };
                } else {
                    vpnl.label.append(mem.allocTui,lbl.newLabel(tampon, e_posx + 1, e_posy + 1 , fld.ToStr(text))) 
                       catch |err| { @panic(@errorName(err)); };
                }
                return;
            },
            .home => {
                e_count = 0;
                e_curs = e_posy;
            },
            .end => {
                tampon = utl.listToStr(e_LABEL);
                e_count = utl.trimStr(tampon).len - 1;
                e_curs = e_posy + utl.trimStr(tampon).len - 1;
            },
            .right, .tab => {
                if (e_curs < (vpnl.cols + vpnl.posy) - 1) {
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
                if (e_curs < (vpnl.cols + vpnl.posy) - 1) {
                    if (vtitle) {
                        term.writeStyled(Tkey.Char, lbl.AtrTitle);
                        e_LABEL.items[e_count] = Tkey.Char;
                    } else {
                        term.writeStyled(Tkey.Char, lbl.AtrLabel);
                        e_LABEL.items[e_count] = Tkey.Char;
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

// Order label
fn orderLabel(vpnl: *pnl.PANEL) void {
    var idy: usize = 0;
    var newlabel = std.ArrayList(lbl.LABEL).initCapacity(mem.allocTui,0) catch unreachable;
    var savlabel = std.ArrayList(lbl.LABEL).initCapacity(mem.allocTui,0) catch unreachable;

    var Gkey: grd.GridSelect = undefined;
    defer Gkey.Buf.clearAndFree(mem.allocTui);

    for (vpnl.label.items) |p| {
        savlabel.append(mem.allocTui,p)
        catch |err| { @panic(@errorName(err)); };        
    }

    const Origine: *grd.GRID = grd.newGridC(
        "Origine",
        2,
        2,
        25,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer mem.allocTui.destroy(Origine);

    const Order: *grd.GRID = grd.newGridC(
        "Order",
        2,
        70,
        25,
        grd.gridStyle,
        grd.CADRE.line1,
    );

    defer mem.allocTui.destroy(Order);


    grd.newCell(Origine, "col", 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "name", 6, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Origine, "text", 40, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.setHeaders(Origine);

    grd.newCell(Order, "col", 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Order, "name", 6, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Order, "text", 40, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.setHeaders(Order);

    while (true) {
        grd.resetRows(Origine);
        for (vpnl.label.items, 0..) |l, idx| {
            const ridx = usizeToStr(idx);

            if (l.text.len > 40) grd.addRows(Origine, &.{ ridx, l.name, l.text[0..39] })
            else grd.addRows(Origine, &.{ ridx, l.name, l.text });
        }

        Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
        if (Gkey.Key == kbd.esc) break;
        if (Gkey.Key == kbd.ctrlV) break;
        if (Gkey.Key == kbd.enter) {
            newlabel.append(mem.allocTui,vpnl.label.items[strToUsize(Gkey.Buf.items[0])])
                catch |err| { @panic(@errorName(err)); };
            
            const ridy = usizeToStr(idy);

            grd.addRows(Order, &.{ ridy, Gkey.Buf.items[1], Gkey.Buf.items[2] });
            idy += 1;
            grd.printGridHeader(Order);
            grd.printGridRows(Order);
            const ligne: usize = strToUsize(Gkey.Buf.items[0]);

            _ = vpnl.label.orderedRemove(ligne);
        }
    }

    vpnl.label.clearAndFree(mem.allocTui);
    vpnl.label = std.ArrayList(lbl.LABEL).initCapacity(mem.allocTui,0) catch unreachable;
    vpnl.label.clearRetainingCapacity();
    // restor and exit
    if (Gkey.Key == kbd.esc) {
        for (savlabel.items) |p| {
            vpnl.label.append(mem.allocTui,p)
                        catch |err| { @panic(@errorName(err)); };
        }
    }
    // new Order and exit CTRL-V
    else {
        for (newlabel.items) |p| {
            vpnl.label.append(mem.allocTui,p)   
                        catch |err| { @panic(@errorName(err)); };
                 }
    }

    grd.freeGrid(Origine);
    grd.freeGrid(Order);

    newlabel.clearAndFree(mem.allocTui);
    newlabel.deinit(mem.allocTui);

    savlabel.clearAndFree(mem.allocTui);
    savlabel.deinit(mem.allocTui);
}

// remove Label
fn removeLabel(vpnl: *pnl.PANEL) void {
    var savlabel: std.ArrayList(lbl.LABEL) = std.ArrayList(lbl.LABEL).initCapacity(mem.allocTui,0) catch unreachable;
    var Gkey: grd.GridSelect = undefined;
    defer Gkey.Buf.clearAndFree(mem.allocTui);

    for (vpnl.label.items) |p| {
        savlabel.append(mem.allocTui,p)  
            catch |err| { @panic(@errorName(err)); };
    }

    const Origine: *grd.GRID = grd.newGridC(
        "Origine",
        2,
        2,
        25,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer mem.allocTui.destroy(Origine);

    grd.newCell(Origine, "col", 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "name", 6, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Origine, "text", 40, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.setHeaders(Origine);

    while (true) {
        grd.resetRows(Origine);
        for (vpnl.label.items, 0..) |l, idx| {
            const ridx =  usizeToStr(idx);
 
            if (l.text.len > 40) grd.addRows(Origine, &.{ ridx, l.name, l.text[0..39] })
            else grd.addRows(Origine, &.{ ridx, l.name, l.text });
        }

        Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
        if (Gkey.Key == kbd.esc) break;
        if (Gkey.Key == kbd.ctrlV) break;
        if (Gkey.Key == kbd.enter) {
            const ligne: usize = strToUsize(Gkey.Buf.items[0]);

            _ = vpnl.label.orderedRemove(ligne);
        }
    }

    // restor and exit
    if (Gkey.Key == kbd.esc) {
        vpnl.label.clearAndFree(mem.allocTui);
        vpnl.label = std.ArrayList(lbl.LABEL).initCapacity(mem.allocTui,0) catch unreachable;
        vpnl.label.clearRetainingCapacity();

        for (savlabel.items) |p| {
            vpnl.label.append(mem.allocTui,p) 
             catch |err| { @panic(@errorName(err)); };
        }
    }

    grd.freeGrid(Origine);

    savlabel.clearAndFree(mem.allocTui);
    savlabel.deinit(mem.allocTui);
}
  
//==========================================
// FIELD Management
//==========================================

// forms field
const fp02 = enum {
    fname,
    fposx,
    fposy,
    ftype,
    fwidth,
    fscal,
    frequi,
    fprotect,
    fedtcar,
    ferrmsg,
    fhelp,
    ffunc,
    ftask,
    fcall,
    ftcall,
    fpcall,
};

//  string return enum
fn strToEnum(comptime EnumTag: type, vtext: []const u8) EnumTag {
    inline for (@typeInfo(EnumTag).@"enum".fields) |f| {
        if (std.mem.eql(u8, f.name, vtext)) return @field(EnumTag, f.name);
    }

    var buffer: [128]u8 = [_]u8{0} ** 128;
    const result = std.fmt.bufPrintZ(buffer[0..], "invalid Text {s} for strToEnum ", .{vtext}) catch unreachable;
    @panic(result);
}

// panel for field
fn Panel_Fmt02(nposx: usize) *pnl.PANEL {
    var Panel: *pnl.PANEL = pnl.newPanelC("FRAM01", nposx, 2, 13, 62, forms.CADRE.line1, "Def.field");

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

    
    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fname), 2, 2, "name.....:")) 
    catch |err| { @panic(@errorName(err)); }; 
    
    Panel.field.append(mem.allocTui,fld.newFieldAlphaNumeric(@tagName(fp02.fname), 2, // posx
        2 + Panel.label.items[@intFromEnum(fp02.fname)].text.len, //posy
        15, // len
        "", // text
        true, // required
        "required help ctrl-h", // Msg err
        "please enter text 1car Letter  other alphanumeric", // help
        "^[a-zA-Z]{1}[a-zA-Z0-9]{0,}$" // regex
    )) catch |err| { @panic(@errorName(err)); }; 

    fld.setTask(Panel, @intFromEnum(fp02.fname), "TaskName") 
    catch |err| { @panic(@errorName(err)); }; 


    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fposx), 3, 2, "PosX.:"))
    catch |err| { @panic(@errorName(err)); }; 

    Panel.field.append(mem.allocTui,fld.newFieldUDigit(@tagName(fp02.fposx), 3, // posx
        2 + Panel.label.items[@intFromEnum(fp02.fposx)].text.len, //posy
        2, // len
        "", // text
        false, // required
        "", // Msg err default
        "", // help default
        "" // regex default
    )) catch |err| { @panic(@errorName(err)); }; 

    fld.setProtect(Panel, @intFromEnum(fp02.fposx), true)
    catch |err| { @panic(@errorName(err)); }; 


    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fposy), 3, 12, "PosY.:"))
    catch |err| { @panic(@errorName(err)); };     

    Panel.field.append(mem.allocTui,fld.newFieldUDigit(@tagName(fp02.fposy), 3, // posx
        12 + Panel.label.items[@intFromEnum(fp02.fposy)].text.len, //posy
        3, // len
        "", // text
        false, // required
        "", // Msg err default
        "", // help default
        "" // regex default
    )) catch |err| { @panic(@errorName(err)); }; 

    fld.setProtect(Panel, @intFromEnum(fp02.fposy), true) 
        catch |err| { @panic(@errorName(err)); }; 
        

    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.ftype), 3, 32, "Type.:"))
        catch |err| { @panic(@errorName(err)); }; 
        
    Panel.field.append(mem.allocTui,fld.newFieldFunc(
        @tagName(fp02.ftype),
        3, // posx
        32 + Panel.label.items[@intFromEnum(fp02.ftype)].text.len, //posy
        19, // len
        "", // text
        true, // required
        "funcType", // function
        "Reference type required", // Msg err
        "Refence field", // help
    )) catch |err| {
        @panic(@errorName(err));
    };
    fld.setTask(Panel, @intFromEnum(fp02.ftype), "TaskType")
        catch |err| { @panic(@errorName(err)); }; 

        
    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fwidth), 4, 2, "Width.:"))
        catch |err| { @panic(@errorName(err)); }; 
        
    Panel.field.append(mem.allocTui,fld.newFieldUDigit(@tagName(fp02.fwidth), 4, // posx
        2 + Panel.label.items[@intFromEnum(fp02.fwidth)].text.len, //posy
        3, // len
        "", // text
        true, // required
        "Len field required or too long", // Msg err
        "len field", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); }; 

    fld.setTask(Panel, @intFromEnum(fp02.fwidth), "TaskWidth") 
        catch |err| { @panic(@errorName(err)); }; 
        

    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fscal), 4, 20, "Scal.:"))
        catch |err| { @panic(@errorName(err)); }; 
        
    Panel.field.append(mem.allocTui,fld.newFieldUDigit(@tagName(fp02.fscal), 4, // posx
        20 + Panel.label.items[@intFromEnum(fp02.fscal)].text.len, //posy
        3, // len
        "", // text
        true, // required
        "Len Scal field required or too long", // Msg err
        "len Scal field", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); }; 

    fld.setTask(Panel, @intFromEnum(fp02.fscal), "TaskScal")
        catch |err| { @panic(@errorName(err)); }; 
        
    
    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.frequi), 4, 32, "Required.:"))
        catch |err| { @panic(@errorName(err)); }; 
        
    Panel.field.append(mem.allocTui,fld.newFieldSwitch(@tagName(fp02.frequi), 4, // posx
        32 + Panel.label.items[@intFromEnum(fp02.frequi)].text.len, //posy
        false, // required
        "field required True or False", // Msg err
        " field value required True or False" // Text
    )) catch |err| { @panic(@errorName(err)); }; 


    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fprotect), 5, 2, "Protect.:"))
        catch |err| { @panic(@errorName(err)); }; 

    Panel.field.append(mem.allocTui,fld.newFieldSwitch(@tagName(fp02.fprotect), 5, // posx
        2 + Panel.label.items[@intFromEnum(fp02.fprotect)].text.len, //posy
        false, // required
        "field Protect required True or False", // Msg err
        " field Protect required True or False" // Text
    )) catch |err| { @panic(@errorName(err)); }; 

    
    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fedtcar), 5, 20, "Edit Car.:"))
        catch |err| { @panic(@errorName(err)); }; 
        
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp02.fedtcar), 5, // posx
        20 + Panel.label.items[@intFromEnum(fp02.fedtcar)].text.len, //posy
        1, // len
        "", // text
        false, // required
        "", // Msg err
        "please enter text ex:$ € % £", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); }; 
 
        fld.setTask(Panel, @intFromEnum(fp02.fscal), "TaskEdtcar")
        catch |err| { @panic(@errorName(err)); };
 
    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.ferrmsg), 6, 2, "Err Msg.:")) 
        catch |err| { @panic(@errorName(err)); }; 
        
    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp02.ferrmsg), 6, // posx
        2 + Panel.label.items[@intFromEnum(fp02.ferrmsg)].text.len, //posy
        50, // len
        "", // text
        false, // required
        "required Help", // Msg err
        "please enter text  message error", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); }; 
        
    fld.setTask(Panel, @intFromEnum(fp02.ferrmsg), "TaskErrmsg") 
        catch |err| { @panic(@errorName(err)); }; 


    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fhelp), 7, 2, "Help.:")) 
        catch |err| { @panic(@errorName(err)); }; 

    Panel.field.append(mem.allocTui,fld.newFieldTextFull(@tagName(fp02.fhelp), 7, // posx
        2 + Panel.label.items[@intFromEnum(fp02.fhelp)].text.len, //posy
        50, // len
        "", // text
        true, // required
        "required Help", // Msg err
        "please enter text  Help", // help
        "" // regex
    )) catch |err| { @panic(@errorName(err)); }; 

    
    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.ffunc), 8, 2, "Function.:"))
        catch |err| { @panic(@errorName(err)); }; 

    Panel.field.append(mem.allocTui,fld.newFieldAlphaNumeric(@tagName(fp02.ffunc), 8, // posx
        2 + Panel.label.items[@intFromEnum(fp02.ffunc)].text.len, //posy
        15, // len
        "", // text
        false, // required
        "required Function", // Msg err
        "please enter Name Function  Combo", // help
        "^[C]{1}[a-zA-Z0-9]{1,}$" // regex
    )) catch |err| { @panic(@errorName(err)); }; 

    fld.setTask(Panel, @intFromEnum(fp02.ffunc), "TaskFunc") catch |err| {
        @panic(@errorName(err));
    };


    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.ftask), 9, 2, "Task.:")) 
        catch |err| { @panic(@errorName(err)); }; 
        
    Panel.field.append(mem.allocTui,fld.newFieldAlphaNumeric(@tagName(fp02.ftask), 9, // posx
        2 + Panel.label.items[@intFromEnum(fp02.ftask)].text.len, //posy
        15, // len
        "", // text
        false, // required
        "err Task", // Msg err
        "please enter Name Task T.....", // help
        "^[T]{1}[a-zA-Z0-9]{1,}$" // regex
    )) catch |err| { @panic(@errorName(err)); }; 

    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fcall), 10, 2, "Exec.:"))
                catch |err| { @panic(@errorName(err)); }; 
        
    Panel.field.append(mem.allocTui,fld.newFieldAlphaNumeric(@tagName(fp02.fcall), 10, // posx
        2 + Panel.label.items[@intFromEnum(fp02.fcall)].text.len, //posy
        15, // len
        "", // text
        false, // required
        "Value invalid", // Msg err
        "please enter Name Exec <Program>", // help
        "^[A-Z]{1}[a-zA-Z0-9]{1,}$" // regex
    )) catch |err| { @panic(@errorName(err)); };
    
    fld.setTask(Panel, @intFromEnum(fp02.fcall), "TaskCall") catch |err| {
        @panic(@errorName(err));
    };

    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.ftcall), 10, 30, "Type.:")) 
        catch |err| { @panic(@errorName(err)); }; 

    Panel.field.append(mem.allocTui,fld.newFieldFunc(@tagName(fp02.ftcall), 10, // posx
        32 + Panel.label.items[@intFromEnum(fp02.ftcall)].text.len, //posy
        10, // len
        "", // text
        false, // required
        "funcCall", // function
        "enter type call", // Msg err
        "Type call", // help
    )) catch |err| { @panic(@errorName(err)); };

    fld.setTask(Panel, @intFromEnum(fp02.ftcall), "TaskTcall") catch |err| {
        @panic(@errorName(err));
    };

    Panel.label.append(mem.allocTui,lbl.newLabel(@tagName(fp02.fpcall), 10, 50, "Parm.:"))
        catch |err| { @panic(@errorName(err)); };
        
    Panel.field.append(mem.allocTui,fld.newFieldSwitch(@tagName(fp02.fpcall), 10, // posx
        52 + Panel.label.items[@intFromEnum(fp02.fpcall)].text.len, //posy
        false, // required
        "", // Msg err
        " field value required True or False" // Text
    )) catch |err| { @panic(@errorName(err)); }; 

    fld.setTask(Panel, @intFromEnum(fp02.fpcall), "TaskPcall") catch |err| {
        @panic(@errorName(err));
    };

    return Panel;
}

//---------------------------------------------------------------------------

//=================================================
// description Function
// choix Type Field
fn funcType(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    var pos: usize = 0;

    const Xcombo: *grd.GRID = grd.newGridC(
        "qryPanel",
        vpnl.posx + 1,
        vpnl.posy + 1,
        7,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer mem.allocTui.destroy(Xcombo);
    grd.newCell(Xcombo, "Ref.Type", 19, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.setHeaders(Xcombo);
    grd.addRows(Xcombo, &.{"TEXT_FREE"}); // Free
    grd.addRows(Xcombo, &.{"TEXT_FULL"}); // Letter Digit Char-special
    grd.addRows(Xcombo, &.{"ALPHA"}); // Letter
    grd.addRows(Xcombo, &.{"ALPHA_UPPER"}); // Letter
    grd.addRows(Xcombo, &.{"ALPHA_NUMERIC"}); // Letter Digit espace -
    grd.addRows(Xcombo, &.{"ALPHA_NUMERIC_UPPER"}); // Letter Digit espace -
    grd.addRows(Xcombo, &.{"PASSWORD"}); // Letter Digit and normaliz char-special
    grd.addRows(Xcombo, &.{"YES_NO"}); // 'y' or 'Y' / 'o' or 'O'
    grd.addRows(Xcombo, &.{"UDIGIT"}); // Digit unsigned
    grd.addRows(Xcombo, &.{"DIGIT"}); // Digit signed
    grd.addRows(Xcombo, &.{"UDECIMAL"}); // Decimal unsigned
    grd.addRows(Xcombo, &.{"DECIMAL"}); // Decimal signed
    grd.addRows(Xcombo, &.{"DATE_ISO"}); // YYYY/MM/DD
    grd.addRows(Xcombo, &.{"DATE_FR"}); // DD/MM/YYYY
    grd.addRows(Xcombo, &.{"DATE_US"}); // MM/DD/YYYY
    grd.addRows(Xcombo, &.{"TELEPHONE"}); // (+123) 6 00 01 00 02
    grd.addRows(Xcombo, &.{"MAIL_ISO"}); // normalize regex
    grd.addRows(Xcombo, &.{"SWITCH"}); // CTRUE CFALSE
    grd.addRows(Xcombo, &.{"FUNC"}); // call Function

    if (std.mem.eql(u8, vfld.text, "TEXT_FREE")) pos = 0;
    if (std.mem.eql(u8, vfld.text, "TEXT_FULL")) pos = 1;
    if (std.mem.eql(u8, vfld.text, "ALPHA")) pos = 2;
    if (std.mem.eql(u8, vfld.text, "ALPHA_UPPER")) pos = 3;
    if (std.mem.eql(u8, vfld.text, "ALPHA_NUMERIC")) pos = 4;
    if (std.mem.eql(u8, vfld.text, "ALPHA_NUMERIC_UPPER")) pos = 5;
    if (std.mem.eql(u8, vfld.text, "PASSWORD")) pos = 6;
    if (std.mem.eql(u8, vfld.text, "YES_NO")) pos = 7;
    if (std.mem.eql(u8, vfld.text, "UDIGIT")) pos = 8;
    if (std.mem.eql(u8, vfld.text, "DIGIT")) pos = 9;
    if (std.mem.eql(u8, vfld.text, "UDECIMAL")) pos = 10;
    if (std.mem.eql(u8, vfld.text, "DECIMAL")) pos = 11;
    if (std.mem.eql(u8, vfld.text, "DATE_ISO")) pos = 12;
    if (std.mem.eql(u8, vfld.text, "DATE_FR")) pos = 13;
    if (std.mem.eql(u8, vfld.text, "DATE_US")) pos = 14;
    if (std.mem.eql(u8, vfld.text, "TELEPHONE")) pos = 15;
    if (std.mem.eql(u8, vfld.text, "MAIL_ISO")) pos = 16;
    if (std.mem.eql(u8, vfld.text, "SWITCH")) pos = 17;
    if (std.mem.eql(u8, vfld.text, "FUNC")) pos = 18;

    var Gkey: grd.GridSelect = undefined;
    defer Gkey.Buf.deinit(mem.allocTui);

    while (true) {
        Gkey = grd.ioCombo(Xcombo, pos);

        if (Gkey.Key == kbd.enter) {
            pnl.rstPanel(grd.GRID,Xcombo, vpnl);
            grd.freeGrid(Xcombo);
            fld.setText(vpnl, @intFromEnum(fp02.ftype), Gkey.Buf.items[0]) 
                catch |err| { @panic(@errorName(err)); }; 
            return;
        }

        if (Gkey.Key == kbd.esc) {
            pnl.rstPanel(grd.GRID,Xcombo, vpnl);
            grd.freeGrid(Xcombo);
            return;
        }
    }
}

fn funcCall(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    var pos: usize = 0;

    const Xcombo: *grd.GRID = grd.newGridC(
        "qryPanel",
        vpnl.posx + 1,
        vpnl.posy + 1,
        4,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer mem.allocTui.destroy(Xcombo);
    grd.newCell(Xcombo, "Ref.Type", 19, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.setHeaders(Xcombo);
    grd.addRows(Xcombo, &.{""}); // Free
    grd.addRows(Xcombo, &.{"SH"}); // batch
    grd.addRows(Xcombo, &.{"APPTERM"}); // Letter Digit Char-special

    if (std.mem.eql(u8, vfld.text, "")) pos = 0;
    if (std.mem.eql(u8, vfld.text, "SH")) pos = 1;
    if (std.mem.eql(u8, vfld.text, "APPTERM")) pos = 2;

    var Gkey: grd.GridSelect = undefined;
    defer Gkey.Buf.deinit(mem.allocTui);

    while (true) {
        Gkey = grd.ioCombo(Xcombo, pos);

        if (Gkey.Key == kbd.enter) {
            pnl.rstPanel(grd.GRID,Xcombo, vpnl);
            grd.freeGrid(Xcombo);
            fld.setText(vpnl, @intFromEnum(fp02.ftcall), Gkey.Buf.items[0]) 
                catch |err| { @panic(@errorName(err)); }; 
            return;
        }

        if (Gkey.Key == kbd.esc) {
            pnl.rstPanel(grd.GRID,Xcombo, vpnl);
            grd.freeGrid(Xcombo);
            return;
        }
    }
}

var callFunc: FuncEnum = undefined;
//=================================================
// description Function
/// run emun Function ex: combo
pub const FuncEnum = enum {
    funcType,
    funcCall,
    none,

    pub fn run(self: FuncEnum, vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
        switch (self) {
            .funcType => funcType(vpnl, vfld),
            .funcCall => funcCall(vpnl, vfld),
            else => dsperr.errorForms(vpnl, ErrMain.main_run_EnumFunc_invalide),
        }
    }

    fn searchFn(vtext: []const u8) FuncEnum {
        inline for (@typeInfo(FuncEnum).@"enum".fields) |f| {
            if (std.mem.eql(u8, f.name, vtext)) return @as(FuncEnum, @enumFromInt(f.value));
        }
        return FuncEnum.none;
    }
};
//---------------------------------------------------------------------------
//=================================================
// description Function
// test exist Name for add or change name

fn TaskName(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    for (vpnl.field.items) |f| {
        if (std.mem.eql(u8, f.name, vfld.text)) {
            term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
            term.writeStyled(vfld.text,pnl.FldErr);
            pnl.msgErr(vpnl, "Already existing invalide Name field");
            vpnl.keyField = kbd.task;
            return;
        }
    }
}

fn TaskType(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    const vReftype = strToEnum(forms.REFTYP, vfld.text);

    for (vpnl.field.items, 0..) |f, idx| {
        if (std.mem.eql(u8, f.name, @tagName(fp02.fscal))) {
            vpnl.field.items[idx].text = "";
            vpnl.field.items[idx].protect = true;
        }

        if (std.mem.eql(u8, f.name, @tagName(fp02.fedtcar))) {
            vpnl.field.items[idx].text = "";
            vpnl.field.items[idx].protect = true;
        }
        if (std.mem.eql(u8, f.name, @tagName(fp02.fwidth))) {
            vpnl.field.items[idx].protect = false;
        }
    }



    
    for (vpnl.field.items, 0..) |f, idx| {
        
        if (vReftype == forms.REFTYP.DECIMAL or
            vReftype == forms.REFTYP.UDECIMAL) {
            if (std.mem.eql(u8, f.name, @tagName(fp02.fscal))) {
                vpnl.field.items[idx].protect = false;
            }
        }
        if (vReftype == forms.REFTYP.DIGIT or
            vReftype == forms.REFTYP.UDIGIT or
            vReftype == forms.REFTYP.DECIMAL or
            vReftype == forms.REFTYP.UDECIMAL)
        {
            if (std.mem.eql(u8, f.name, @tagName(fp02.fedtcar))) {
                vpnl.field.items[idx].protect = false;
            }
        }
    }


    if (vReftype == forms.REFTYP.DATE_ISO or
        vReftype == forms.REFTYP.DATE_FR or
        vReftype == forms.REFTYP.DATE_US)
    {
        for (vpnl.field.items, 0..) |f, idx| {
            if (std.mem.eql(u8, f.name, @tagName(fp02.fwidth))) {
                vpnl.field.items[idx].text = "10";
                vpnl.field.items[idx].protect = true;
            }
        }
    }

    if (vReftype == forms.REFTYP.YES_NO or vReftype == forms.REFTYP.SWITCH) {
        for (vpnl.field.items, 0..) |f, idx| {
            if (std.mem.eql(u8, f.name, @tagName(fp02.fwidth))) {
                vpnl.field.items[idx].text = "1";
                vpnl.field.items[idx].protect = true;
            }
        }
    }
}

fn TaskWidth(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    const val = strToUsize(vfld.text);

    if (val + vfld.posx >= vpnl.cols) {
        const msg = std.fmt.allocPrint(mem.allocUtl,
            "{d} the length of the zone is excessive", .{val})
            catch |err| { @panic(@errorName(err)); };
        defer mem.allocUtl.free(msg);
        term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
        term.writeStyled(vfld.text,pnl.FldErr);
        pnl.msgErr(vpnl, msg);

        vpnl.keyField = kbd.task;
    }
}

fn TaskScal(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    if (std.mem.eql(u8, vfld.text, "UDECIMAL") or std.mem.eql(u8, vfld.text, "DECIMAL")) {
        var width = strToUsize(fld.getText(vpnl, @intFromEnum(fp02.fwidth)) catch unreachable) ;
        if (std.mem.eql(u8, vfld.text, "DECIMAL")) width += 1;

        const vscal = strToUsize(vfld.text);

    
        if (vscal + width + vfld.posx >= vpnl.cols) {
            const msg = std.fmt.allocPrint(mem.allocUtl,
                "{d} the Scal of the zone is excessive", .{vscal}) 
                catch |err| { @panic(@errorName(err)); }; 
                
            defer mem.allocUtl.free(msg);
            term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
            term.writeStyled(vfld.text,pnl.FldErr);
            pnl.msgErr(vpnl, msg);

            vpnl.keyField = kbd.task;
        }
    } else vfld.text = "";
}


fn TaskEdtcar(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    if ( ! std.mem.eql(u8, vfld.text,"")) {
        
        var width = strToUsize(fld.getText(vpnl, @intFromEnum(fp02.fwidth))  catch unreachable) ;
        const vtype = fld.getText(vpnl, @intFromEnum(fp02.ftype))  catch unreachable ;
    
        if (std.mem.eql(u8, vtype, "DIGIT") or std.mem.eql(u8, vtype, "DECIMAL"))  width += 1;

        const scal = strToUsize(fld.getText(vpnl, @intFromEnum(fp02.fscal))  catch unreachable);

        if (width + scal + vfld.posx >= vpnl.cols) {
            const msg = std.fmt.allocPrint(mem.allocUtl,
                "the length of the zone is excessive", .{})
                catch |err| { @panic(@errorName(err)); };            
            defer mem.allocUtl.free(msg);
            term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
            term.writeStyled(vfld.text,pnl.FldErr);
            pnl.msgErr(vpnl, msg);

            vpnl.keyField = kbd.task;
        }
    }
}

fn TaskErrmsg(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    if (!vfld.zwitch and std.mem.eql(u8, "", vfld.text)) {
        pnl.msgErr(vpnl, "the error message text is invalid");
        term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
        term.writeStyled(vfld.text,pnl.FldErr);
        vpnl.keyField = kbd.task;
    }

}

fn TaskFunc(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    if (std.mem.eql(u8, vfld.text, "FUNC")) {
        if (std.mem.eql(u8, "", vfld.procfunc)) {
            pnl.msgErr(vpnl, "the function name is invalid");
            term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
            term.writeStyled(vfld.text,pnl.FldErr);
            vpnl.keyField = kbd.task;
        }
    }

}

fn TaskCall(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    const ztext = std.mem.trim(u8, vfld.text," ");
    var i : usize = 0 ;
    if (std.mem.eql(u8, ztext, "")) {
        i = fld.getIndex(vpnl,@tagName(fp02.ftcall)) catch unreachable;
        fld.setText(vpnl,i,"") catch unreachable;
        fld.printField(vpnl, vpnl.field.items[i]);
        fld.displayField(vpnl, vpnl.field.items[i]);
        i = fld.getIndex(vpnl,@tagName(fp02.fpcall)) catch unreachable;
        fld.setSwitch(vpnl,i,false) catch unreachable;
        fld.printField(vpnl, vpnl.field.items[i]);
        fld.displayField(vpnl, vpnl.field.items[i]);
    }
}


fn TaskTcall(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    var i : usize = fld.getIndex(vpnl,@tagName(fp02.fcall)) catch unreachable;

    var  ztext = fld.getText(vpnl,i) catch unreachable;
    ztext = std.mem.trim(u8, ztext," ");
    if (std.mem.eql(u8, ztext,"")) {
        vfld.text ="";
        fld.printField(vpnl, vpnl.field.items[i]);
        fld.displayField(vpnl, vpnl.field.items[i]);
        i = fld.getIndex(vpnl,@tagName(fp02.fpcall)) catch unreachable;
        fld.setSwitch(vpnl,i,false) catch unreachable;
        fld.printField(vpnl, vpnl.field.items[i]);
        fld.displayField(vpnl, vpnl.field.items[i]);

        
    }
    else {
        i = fld.getIndex(vpnl,@tagName(fp02.ftcall)) catch unreachable;
        ztext = fld.getText(vpnl,i) catch unreachable;
        ztext = std.mem.trim(u8, ztext," ");
        if (std.mem.eql(u8, "", ztext)) {
            pnl.msgErr(vpnl, "the function Type is invalid");
            vpnl.keyField = kbd.task;
        }
    }
}

fn TaskPcall(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    var i : usize = fld.getIndex(vpnl,@tagName(fp02.fcall)) catch unreachable;

    var  ztext = fld.getText(vpnl,i) catch unreachable;
    ztext = std.mem.trim(u8, ztext," ");
    if (std.mem.eql(u8, ztext,"")) {
        i = fld.getIndex(vpnl,@tagName(fp02.fpcall)) catch unreachable;
        vfld.zwitch = false;
        vfld.text =forms.CFALSE;
        fld.printField(vpnl, vpnl.field.items[i]);
        fld.displayField(vpnl, vpnl.field.items[i]);
    }

}

var callTask: TaskEnum = undefined;
//=================================================
// description Function
// run emun Function ex: combo
pub const TaskEnum = enum {
    TaskName,
    TaskType,
    TaskWidth,
    TaskScal,
    TaskEdtcar,
    TaskErrmsg,
    TaskFunc,
    TaskCall,
    TaskTcall,
    TaskPcall,
    none,

    pub fn run(self: TaskEnum, vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
        switch (self) {
            .TaskName    => TaskName(vpnl, vfld),
            .TaskType    => TaskType(vpnl, vfld),
            .TaskWidth    => TaskWidth(vpnl, vfld),
            .TaskScal    => TaskScal(vpnl, vfld),
            .TaskEdtcar    => TaskEdtcar(vpnl, vfld),
            .TaskErrmsg => TaskErrmsg(vpnl, vfld),
            .TaskFunc    => TaskFunc(vpnl, vfld),
            .TaskCall    => TaskCall(vpnl, vfld),
            .TaskTcall    => TaskTcall(vpnl, vfld),
            .TaskPcall    => TaskPcall(vpnl, vfld),

            else => dsperr.errorForms(vpnl, ErrMain.main_run_EnumTask_invalide),
        }
    }
    fn searchFn(vtext: []const u8) TaskEnum {
        inline for (@typeInfo(TaskEnum).@"enum".fields) |f| {
            if (std.mem.eql(u8, f.name, vtext)) return @as(TaskEnum, @enumFromInt(f.value));
        }
        return TaskEnum.none;
    }
};
//---------------------------------------------------------------------------

pub fn writefield(vpnl: *pnl.PANEL) void {
    term.getCursor();
    
    var v_posx: usize = term.posCurs.x;
    const v_posy: usize = term.posCurs.y;
    const e_posx : usize = (v_posx - vpnl.posx) + 1 ; const e_posy : usize= ( v_posy - vpnl.posy) + 1;
    if (v_posx < 15) v_posx = 15 else v_posx = 2;

    // Init format panel
    var pFmt02 = Panel_Fmt02(v_posx);

    v_posx = term.posCurs.x;
    // init zone field
    fld.setText(pFmt02, @intFromEnum(fp02.fposx), std.fmt.allocPrint(mem.allocUtl, "{d}", .{e_posx})
        catch unreachable) catch unreachable;
    fld.setText(pFmt02, @intFromEnum(fp02.fposy), std.fmt.allocPrint(mem.allocUtl, "{d}", .{e_posy})
        catch unreachable) catch unreachable;

    // init struct key
    var Tkey: term.Keyboard = undefined; // defines the receiving structure of the keyboard
    var idx: usize = 0;
    var vReftyp: forms.REFTYP = undefined;
    var vText: []u8 = undefined;
    var vlen: usize = 0;
    var vText2: []u8 = undefined;
    while (true) {
        //Tkey = kbd.getKEY();

        forms.dspCursor(vpnl, v_posx, v_posy,"Field");
        Tkey.Key = pnl.ioPanel(pFmt02);
        switch (Tkey.Key) {
            // call function combo
            .func => {
                callFunc = FuncEnum.searchFn(pFmt02.field.items[pFmt02.idxfld].procfunc);
                callFunc.run(pFmt02, &pFmt02.field.items[pFmt02.idxfld]);
            },
            // call proc control chek value
            .task => {
                callTask = TaskEnum.searchFn(pFmt02.field.items[pFmt02.idxfld].proctask);
                callTask.run(pFmt02, &pFmt02.field.items[pFmt02.idxfld]);
            },
            // write field to panel
            .F9 => {
                vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
                vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                
                vReftyp = strToEnum(forms.REFTYP, pFmt02.field.items[@intFromEnum(fp02.ftype)].text);
                @memset(vText[0..vlen], '#');

                switch (vReftyp) {
                    forms.REFTYP.TEXT_FREE => {
                        vpnl.field.append(mem.allocTui,fld.newFieldTextFree(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                             strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                             strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                             strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                             "",
                             pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                             pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                             pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, "")
                        )
                        catch |err| { @panic(@errorName(err)); };

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };
                        
                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.TEXT_FULL => {
                        vpnl.field.append(mem.allocTui,fld.newFieldTextFull(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, ""))
                            catch |err| { @panic(@errorName(err)); };

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                        catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.ALPHA => {
                        vpnl.field.append(mem.allocTui,fld.newFieldAlpha(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                            "")
                        ) catch |err| { @panic(@errorName(err)); };

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.ALPHA_UPPER => {
                        vpnl.field.append(mem.allocTui,fld.newFieldAlphaUpper(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                            "")
                        ) catch |err| { @panic(@errorName(err)); };

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.ALPHA_NUMERIC => {
                        vpnl.field.append(mem.allocTui,fld.newFieldAlphaNumeric(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, "")
                        ) catch |err| {    @panic(@errorName(err));};


                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,  
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.ALPHA_NUMERIC_UPPER => {
                        vpnl.field.append(mem.allocTui,fld.newFieldAlphaNumericUpper(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                             strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "", pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                            "")) catch |err| {
                            @panic(@errorName(err));
                        };

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                        catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,  
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.PASSWORD => {
                        vpnl.field.append(mem.allocTui,fld.newFieldPassword(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, ""))
                            catch |err| { @panic(@errorName(err)); };

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.YES_NO => {
                        vpnl.field.append(mem.allocTui,fld.newFieldYesNo(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                        )) 
                        catch |err| { @panic(@errorName(err)); };

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.UDIGIT => {
                        vpnl.field.append(mem.allocTui,fld.newFieldUDigit(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                            "")
                        ) catch |err| { @panic(@errorName(err)); };

                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
                        vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText[0..vlen], '0');

                        // editcar
                        if (pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text.len > 0) {
                            vText = std.fmt.allocPrint(mem.allocUtl, "{s}{s}", .{
                                vText, pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text })
                                 catch |err| { @panic(@errorName(err)); };
                        }
                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };
                        
                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.DIGIT => {
                        vpnl.field.append(mem.allocTui,
                        fld.newFieldDigit(pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "", pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                            ""))
                            catch |err| { @panic(@errorName(err)); };

                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
                        vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText[0..vlen], '0');

                        vText = std.fmt.allocPrint(mem.allocUtl, "+{s}", .{vText})
                                catch |err| { @panic(@errorName(err)); };
                        //editcar
                        if (pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text.len > 0) {
                            vText = std.fmt.allocPrint(mem.allocUtl, "{s}{s}", .{
                                vText, pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text }
                            ) catch |err| { @panic(@errorName(err)); };
                        }

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.UDECIMAL => {
                        vpnl.field.append(mem.allocTui,fld.newFieldUDecimal(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fscal)].text),
                            "", pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, ""))
                            catch |err| { @panic(@errorName(err)); };

                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
                        vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText[0..vlen], '0');
                        
                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fscal)].text);
                        vText2 = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText2[0..vlen], '0');
                        
                        vText = std.fmt.allocPrint(mem.allocUtl, "{s},{s}", .{ vText, vText2 })
                            catch |err| { @panic(@errorName(err)); };

                        // editcar

                        if (pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text.len > 0) {
                            vText = std.fmt.allocPrint(mem.allocUtl, "{s}{s}", .{
                                vText, pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text })
                            catch |err| { @panic(@errorName(err)); };
                        }

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.DECIMAL => {
                        vpnl.field.append(mem.allocTui,fld.newFieldDecimal(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fscal)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                            "")) 
                            catch |err| { @panic(@errorName(err)); };

                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
                        vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText[0..vlen], '0');
                        
                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fscal)].text);
                        vText2 = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText2[0..vlen], '0');
                        
                        vText = std.fmt.allocPrint(mem.allocUtl, "+{s},{s}", .{ vText, vText2 })
                            catch unreachable;

                        // editcar
                        if (pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text.len > 0) {
                            vText = std.fmt.allocPrint(mem.allocUtl, "{s}{s}", .{
                                vText, pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text })
                            catch |err| { @panic(@errorName(err)); };
                        }

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.DATE_ISO => {
                        vpnl.field.append(mem.allocTui,fld.newFieldDateISO(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                        ))
                            catch |err| { @panic(@errorName(err)); };

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            "YYYY/MM/DD",
                        ) catch |err| { @panic(@errorName(err)); };
                    },
                    forms.REFTYP.DATE_FR => {
                        vpnl.field.append(mem.allocTui,fld.newFieldDateFR(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                        )) 
                            catch |err| { @panic(@errorName(err)); };
                            
                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            "DD/MM/YYYY",
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.DATE_US => {
                        vpnl.field.append(mem.allocTui,fld.newFieldDateUS(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                        )) 
                            catch |err| { @panic(@errorName(err)); };
                            
                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            "MM/DD/YYYY",
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.TELEPHONE => {
                        vpnl.field.append(mem.allocTui,fld.newFieldTelephone(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, ""))
                            catch |err| { @panic(@errorName(err)); };

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };
                        
                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
                        vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText[0..vlen], '*');
                        
                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.MAIL_ISO => {
                        vpnl.field.append(mem.allocTui,fld.newFieldMail(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                        )) 
                            catch |err| { @panic(@errorName(err)); };

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
                        vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText[0..vlen], '@');
                        
                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.SWITCH => {
                        vpnl.field.append(mem.allocTui,fld.newFieldSwitch(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text))
                            catch |err| { @panic(@errorName(err)); };

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        
                        fld.setText(
                            vpnl,
                            idx,
                            forms.CTRUE,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.FUNC => {
                        vpnl.field.append(mem.allocTui,fld.newFieldFunc(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ffunc)].text,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text))
                            catch |err| { @panic(@errorName(err)); };

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };
                        @memset(vText[0..vlen], 'F');
                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    }
                }
                idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                    catch |err| { @panic(@errorName(err)); };
                    
                fld.setEdtcar(vpnl, idx, pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text)
                    catch |err| { @panic(@errorName(err)); };

                    
                fld.setTask(vpnl, idx, pFmt02.field.items[@intFromEnum(fp02.ftask)].text)
                    catch |err| { @panic(@errorName(err)); };
                    
                fld.setCall(vpnl, idx, pFmt02.field.items[@intFromEnum(fp02.fcall)].text)
                    catch |err| { @panic(@errorName(err)); };

                fld.setTypeCall(vpnl, idx, pFmt02.field.items[@intFromEnum(fp02.ftcall)].text)
                    catch |err| { @panic(@errorName(err)); };

                fld.setParmCall(vpnl, idx, pFmt02.field.items[@intFromEnum(fp02.fpcall)].zwitch)
                    catch |err| { @panic(@errorName(err)); };
                
                fld.setProtect(vpnl, idx, pFmt02.field.items[@intFromEnum(fp02.fprotect)].zwitch)
                    catch |err| { @panic(@errorName(err)); };
                    
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

//---------------------------------------------------------------------------

pub fn updateField(vpnl : *pnl.PANEL, nI: usize,vfld: fld.FIELD) void {
    term.getCursor();
    var v_posx: usize = term.posCurs.x;
    const v_posy: usize = term.posCurs.y;
    const e_posx : usize = (v_posx - vpnl.posx) + 1 ; const e_posy : usize= ( v_posy - vpnl.posy) + 1;
    if (v_posx < 15) v_posx = 15 else v_posx = 2;

    // Init format panel
    var pFmt02 = Panel_Fmt02(v_posx);

    v_posx = term.posCurs.x;
    // init zone field
    fld.setText(pFmt02, @intFromEnum(fp02.fposx), std.fmt.allocPrint(mem.allocUtl, "{d}", .{e_posx})
        catch unreachable) catch unreachable;

    fld.setProtect(pFmt02, @intFromEnum(fp02.fposx),true) catch unreachable;

    fld.setText(pFmt02, @intFromEnum(fp02.fposy), std.fmt.allocPrint(mem.allocUtl, "{d}", .{e_posy})
        catch unreachable) catch unreachable;

    fld.setProtect(pFmt02, @intFromEnum(fp02.fposy), true) catch unreachable;

    fld.setText(pFmt02, @intFromEnum(fp02.fname),
                vfld.name)
            catch unreachable;



    fld.setText(pFmt02, @intFromEnum(fp02.ftype),@tagName(vfld.reftyp))
            catch unreachable;

    fld.setText(pFmt02, @intFromEnum(fp02.fwidth),
                usizeToStr(vfld.width))
            catch unreachable;

    fld.setText(pFmt02, @intFromEnum(fp02.fscal),
                usizeToStr(vfld.scal))
            catch unreachable;

    fld.setSwitch(pFmt02,@intFromEnum(fp02.frequi),vfld.requier)
            catch unreachable;


    fld.setText(pFmt02, @intFromEnum(fp02.ferrmsg),
                vfld.errmsg)
            catch unreachable;

    fld.setText(pFmt02, @intFromEnum(fp02.fhelp),
                vfld.help)
            catch unreachable;

    fld.setText(pFmt02, @intFromEnum(fp02.fedtcar),
                vfld.edtcar)
            catch unreachable;

    fld.setText(pFmt02, @intFromEnum(fp02.ffunc),
                vfld.procfunc)
            catch unreachable;

    fld.setText(pFmt02, @intFromEnum(fp02.ftask),
                vfld.proctask)
            catch unreachable;
    fld.setText(pFmt02, @intFromEnum(fp02.fcall),
                vfld.progcall)
            catch unreachable;

    fld.setText(pFmt02, @intFromEnum(fp02.ftcall),
                vfld.typecall)
            catch unreachable;

    fld.setSwitch(pFmt02,@intFromEnum(fp02.fpcall),vfld.parmcall) catch unreachable;



    fld.setSwitch(pFmt02,@intFromEnum(fp02.fprotect),vfld.protect) catch unreachable;

    // init struct key
    var Tkey: term.Keyboard = undefined; // defines the receiving structure of the keyboard
    var idx: usize = 0;
    var vReftyp: forms.REFTYP = undefined;
    var vText: []u8 = undefined;
    var vlen: usize = 0;
    var vText2: []u8 = undefined;
    while (true) {
        //Tkey = kbd.getKEY();
        // FIELD
        forms.dspCursor(pFmt02, v_posx, v_posy,"Field");
        Tkey.Key = pnl.ioPanel(pFmt02);
        switch (Tkey.Key) {
            // call function combo
            .func => {
                callFunc = FuncEnum.searchFn(pFmt02.field.items[pFmt02.idxfld].procfunc);
                callFunc.run(pFmt02, &pFmt02.field.items[pFmt02.idxfld]);
            },
            // call proc control chek value
            .task => {
                callTask = TaskEnum.searchFn(pFmt02.field.items[pFmt02.idxfld].proctask);
                callTask.run(pFmt02, &pFmt02.field.items[pFmt02.idxfld]);
            },
            // write field to panel
            .F9 => {
                vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
                vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                
                vReftyp = strToEnum(forms.REFTYP, pFmt02.field.items[@intFromEnum(fp02.ftype)].text);
                @memset(vText[0..vlen], '#');

                switch (vReftyp) {
                    forms.REFTYP.TEXT_FREE => {
                        vpnl.field.items[nI] = fld.newFieldTextFree(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                             strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                             strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                             strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                             "",
                             pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                             pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                             pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, ""
                        ) ;
                    
                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };
                        
                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.TEXT_FULL => {
                        vpnl.field.items[nI] = fld.newFieldTextFull(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, ""
                        );

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                        catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.ALPHA => {
                        vpnl.field.items[nI] = fld.newFieldAlpha(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                            ""
                        ); 

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.ALPHA_UPPER => {
                        vpnl.field.items[nI] = fld.newFieldAlphaUpper(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                            ""
                        );

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.ALPHA_NUMERIC => {
                        vpnl.field.items[nI] = fld.newFieldAlphaNumeric(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, ""
                            );


                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,  
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.ALPHA_NUMERIC_UPPER => {
                        vpnl.field.items[nI] = fld.newFieldAlphaNumericUpper(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                             strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "", pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                            ""
                        );

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                        catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,  
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.PASSWORD => {
                        vpnl.field.items[nI] = fld.newFieldPassword(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, ""
                        );

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.YES_NO => {
                        vpnl.field.items[nI] = fld.newFieldYesNo(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                        );

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.UDIGIT => {
                        vpnl.field.items[nI] = fld.newFieldUDigit(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                            ""
                        );

                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
                        vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText[0..vlen], '0');

                        // editcar
                        if (pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text.len > 0) {
                            vText = std.fmt.allocPrint(mem.allocUtl, "{s}{s}", .{
                                vText, pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text })
                                 catch |err| { @panic(@errorName(err)); };
                        }
                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };
                        
                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        )    catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.DIGIT => {
                        vpnl.field.items[nI] = fld.newFieldDigit(pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "", pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                            ""
                        );

                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
                        vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText[0..vlen], '0');

                        vText = std.fmt.allocPrint(mem.allocUtl, "+{s}", .{vText})
                                catch |err| { @panic(@errorName(err)); };
                        //editcar
                        if (pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text.len > 0) {
                            vText = std.fmt.allocPrint(mem.allocUtl, "{s}{s}", .{
                                vText, pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text }
                            ) catch |err| { @panic(@errorName(err)); };
                        }

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.UDECIMAL => {
                        vpnl.field.items[nI] = fld.newFieldUDecimal(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fscal)].text),
                            "", pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, ""
                        );

                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
                        vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText[0..vlen], '0');
                        
                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fscal)].text);
                        vText2 = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText2[0..vlen], '0');
                        
                        vText = std.fmt.allocPrint(mem.allocUtl, "{s},{s}", .{ vText, vText2 })
                            catch |err| { @panic(@errorName(err)); };

                        // editcar

                        if (pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text.len > 0) {
                            vText = std.fmt.allocPrint(mem.allocUtl, "{s}{s}", .{
                                vText, pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text })
                            catch |err| { @panic(@errorName(err)); };
                        }

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.DECIMAL => {
                        vpnl.field.items[nI] = fld.newFieldDecimal(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fscal)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                            ""
                        );

                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
                        vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText[0..vlen], '0');
                        
                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fscal)].text);
                        vText2 = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText2[0..vlen], '0');
                        
                        vText = std.fmt.allocPrint(mem.allocUtl, "+{s},{s}", .{ vText, vText2 })
                            catch unreachable;

                        // editcar
                        if (pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text.len > 0) {
                            vText = std.fmt.allocPrint(mem.allocUtl, "{s}{s}", .{
                                vText, pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text })
                            catch |err| { @panic(@errorName(err)); };
                        }

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.DATE_ISO => {
                        vpnl.field.items[nI] = fld.newFieldDateISO(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                        );

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            "YYYY/MM/DD",
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.DATE_FR => {
                        vpnl.field.items[nI] = fld.newFieldDateFR(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                        );
                            
                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            "DD/MM/YYYY",
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.DATE_US => {
                        vpnl.field.items[nI] = fld.newFieldDateUS(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                        );

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        fld.setText(
                            vpnl,
                            idx,
                            "MM/DD/YYYY",
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.TELEPHONE => {
                        vpnl.field.items[nI] = fld.newFieldTelephone(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, ""
                        );

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };
                        
                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
                        vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText[0..vlen], '*');
                        
                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.MAIL_ISO => {
                        vpnl.field.items[nI] = fld.newFieldMail(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
                        );

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
                        vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
                        @memset(vText[0..vlen], '@');
                        
                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.SWITCH => {
                        vpnl.field.items[nI] = fld.newFieldSwitch(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text
                        );

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };

                        
                        fld.setText(
                            vpnl,
                            idx,
                            forms.CTRUE,
                        ) catch |err| { @panic(@errorName(err)); };
                    },

                    forms.REFTYP.FUNC => {
                        vpnl.field.items[nI] = fld.newFieldFunc(
                            pFmt02.field.items[@intFromEnum(fp02.fname)].text,
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
                            strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
                            "",
                            pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
                            pFmt02.field.items[@intFromEnum(fp02.ffunc)].text,
                            pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
                            pFmt02.field.items[@intFromEnum(fp02.fhelp)].text
                        );

                        idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
                            catch |err| { @panic(@errorName(err)); };
                        @memset(vText[0..vlen], 'F');
                        fld.setText(
                            vpnl,
                            idx,
                            vText,
                        ) catch |err| { @panic(@errorName(err)); };
                    }
                }
                
                fld.setEdtcar(vpnl, nI,    pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text)
                    catch |err| { @panic(@errorName(err)); };
                    
                fld.setTask(vpnl, nI, pFmt02.field.items[@intFromEnum(fp02.ftask)].text)
                    catch |err| { @panic(@errorName(err)); };
                    
                fld.setCall(vpnl, nI, pFmt02.field.items[@intFromEnum(fp02.fcall)].text)
                    catch |err| { @panic(@errorName(err)); };

                fld.setTypeCall(vpnl, nI, pFmt02.field.items[@intFromEnum(fp02.ftcall)].text)
                    catch |err| { @panic(@errorName(err)); };

                fld.setParmCall(vpnl, nI, pFmt02.field.items[@intFromEnum(fp02.fpcall)].zwitch)
                    catch |err| { @panic(@errorName(err)); };
                
                fld.setProtect(vpnl, nI, pFmt02.field.items[@intFromEnum(fp02.fprotect)].zwitch)
                    catch |err| { @panic(@errorName(err)); };
                
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




// Order field
pub fn orderField(vpnl: *pnl.PANEL) void {
    var idxligne: usize = 0;
    var newfield = std.ArrayList(fld.FIELD).initCapacity(mem.allocTui,0) catch unreachable;
    var savfield = std.ArrayList(fld.FIELD).initCapacity(mem.allocTui,0) catch unreachable;

    var Gkey: grd.GridSelect = undefined;
    defer Gkey.Buf.clearAndFree(mem.allocTui);

    for (vpnl.field.items) |p| {
        savfield.append(mem.allocTui,p) 
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
    defer mem.allocTui.destroy(Origine);

    const Order: *grd.GRID = grd.newGridC(
        "Order",
        2,
        70,
        32,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer mem.allocTui.destroy(Order);

    grd.newCell(Origine, "col", 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "name", 6, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Origine, "reftype", 20, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "X", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "Y", 3, grd.REFTYP.UDIGIT, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "width", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "scal", 3, grd.REFTYP.UDIGIT, term.ForegroundColor.fgGreen);
    grd.setHeaders(Origine);

    grd.newCell(Order, "col", 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Order, "name", 6, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Order, "reftype", 20, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Order, "X", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgCyan);
    grd.newCell(Order, "Y", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgCyan);
    grd.newCell(Order, "width", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgGreen);
    grd.newCell(Order, "scal", 3, grd.REFTYP.UDIGIT, term.ForegroundColor.fgGreen);
    grd.setHeaders(Order);

    while (true) {
        grd.resetRows(Origine);
        for (vpnl.field.items, 0..) |f, idx| {
            const ridx = usizeToStr(idx);
            
            const posx = usizeToStr(f.posx) ;
            const posy = usizeToStr(f.posy) ;
            const width= usizeToStr(f.width) ;
            const scal = usizeToStr(f.scal) ;

            grd.addRows(Origine, &.{ ridx, f.name, @tagName(f.reftyp), posx , posy, width,scal });
        }

        Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
        if (Gkey.Key == kbd.esc) break;
        if (Gkey.Key == kbd.ctrlV) break;
        if (Gkey.Key == kbd.enter) {
            newfield.append(mem.allocTui,vpnl.field.items[ strToUsize(Gkey.Buf.items[0])])
                catch |err| { @panic(@errorName(err)); };

            const ridn =usizeToStr(idxligne);
 
            grd.addRows(Order, &.{ ridn, Gkey.Buf.items[1], Gkey.Buf.items[2],
                Gkey.Buf.items[3], Gkey.Buf.items[4], Gkey.Buf.items[5], Gkey.Buf.items[6] });
            idxligne += 1;
            grd.printGridHeader(Order);
            grd.printGridRows(Order);
            const ligne: usize = strToUsize(Gkey.Buf.items[0]);

            _ = vpnl.field.orderedRemove(ligne);
        }
    }

    vpnl.field.clearAndFree(mem.allocTui);
    vpnl.field = std.ArrayList(fld.FIELD).initCapacity(mem.allocTui,0) catch unreachable;
    vpnl.field.clearRetainingCapacity();
    // restor and exit
    if (Gkey.Key == kbd.esc) {
        for (savfield.items) |p| {
            vpnl.field.append(mem.allocTui,p) catch |err| { @panic(@errorName(err)); };
        }
    }
    // new Order and exit
    else {
        for (newfield.items) |p| {
            vpnl.field.append(mem.allocTui,p) catch |err| { @panic(@errorName(err)); };
        }
    }

    grd.freeGrid(Origine);
    grd.freeGrid(Order);

    newfield.clearAndFree(mem.allocTui);
    newfield.deinit(mem.allocTui);

    savfield.clearAndFree(mem.allocTui);
    savfield.deinit(mem.allocTui);
}
// remove Field
fn removeField(vpnl: *pnl.PANEL) void {
    var savfield: std.ArrayList(fld.FIELD) = std.ArrayList(fld.FIELD).initCapacity(mem.allocTui,0) catch unreachable;

    var Gkey: grd.GridSelect = undefined;
    defer Gkey.Buf.clearAndFree(mem.allocTui);

    for (vpnl.field.items) |p| {
        savfield.append(mem.allocTui,p)  
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
    defer mem.allocTui.destroy(Origine);

    grd.newCell(Origine, "col", 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "name", 6, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.newCell(Origine, "reftype", 20, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "X", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "Y", 3, grd.REFTYP.UDIGIT, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "width", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "scal", 3, grd.REFTYP.UDIGIT, term.ForegroundColor.fgGreen);
    grd.setHeaders(Origine);

    while (true) {
        grd.resetRows(Origine);
        for (vpnl.field.items, 0..) |f, idx| {
            const ridx = usizeToStr(idx);
            
            const posx = usizeToStr(f.posx) ;
            const posy = usizeToStr(f.posy) ;
            const width= usizeToStr(f.width) ;
            const scal = usizeToStr(f.scal) ;
            grd.addRows(Origine, &.{ ridx, f.name, @tagName(f.reftyp), posx , posy, width, scal });
        }

        Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
        if (Gkey.Key == kbd.esc) break;
        if (Gkey.Key == kbd.ctrlV) break;
        if (Gkey.Key == kbd.enter) {
            const ligne: usize = strToUsize(Gkey.Buf.items[0]);

            _ = vpnl.field.orderedRemove(ligne);
        }
    }

    // restor and exit
    if (Gkey.Key == kbd.esc) {
        vpnl.field.clearAndFree(mem.allocTui);
        vpnl.field = std.ArrayList(fld.FIELD).initCapacity(mem.allocTui,0) catch unreachable;
        vpnl.field.clearRetainingCapacity();

        for (savfield.items) |p| {
            vpnl.field.append(mem.allocTui,p) 
             catch |err| { @panic(@errorName(err)); };
        }
    }

    grd.freeGrid(Origine);

    savfield.clearAndFree(mem.allocTui);
    savfield.deinit(mem.allocTui);
}

//------------------------------------------------------------------
// definition line horizontal

fn writeHorizontal(vpnl: *pnl.PANEL) void {
    
    //term.getCursor();
    var e_count: usize = 0;
    var tampon: []const u8 = undefined;
    var e_LineH = std.ArrayList([]const u8).initCapacity(mem.allocTui,0) catch unreachable;
    defer e_LineH.deinit(mem.allocTui);
    defer mem.allocTui.destroy(&e_LineH);

    const e_posx: usize = term.posCurs.x ;
    const e_posy: usize = term.posCurs.y ;
    var   e_curs: usize = e_posy;

    // defines the receiving structure of the keyboard
    var Tkey: term.Keyboard = undefined;
    const pFmtH01 = Panel_HELP();

    var litem: usize = 0; // type line cadre menu
 
    var mDefline = mnu.newMenu("DefLine", // name
            1, 1, // posx, posy
            mnu.CADRE.line1, // type line fram
            mnu.MNUVH.vertical, // type menu vertical / horizontal
            &.{ // item
            "Line 1",
            "LLine 2",
            }
        );


    while (true) {
        forms.dspCursor(vpnl, e_posx, e_curs,"Line Horiz.");

        Tkey = kbd.getKEY();

        //dspMouse(vpnl);  // active display Cursor x/y mouse
        //std.debug.print("Key: {d}  - {d}\n\r",.{term.posCurs.x, term.posCurs.y});
        switch (Tkey.Key) {
            .F1     => {
                fld.setText(pFmtH01,0,"F12 Abort ctrl-V  ctr-l Line ") catch unreachable;
                fld.setText(pFmtH01,1,"" ) catch unreachable;
                _= pnl.ioPanel(pFmtH01);
                pnl.rstPanel(pnl.PANEL,pFmtH01,vpnl);
                term.gotoXY(1,1);
                continue;
            },
            
            .F12 => return,
            .ctrlL => {
                litem = 0;
                litem = mnu.ioMenu(mDefline, litem);
                pnl.rstPanel(mnu.MENU,&mDefline,vpnl);
     
            },
            .ctrlV => {
                tampon = std.fmt.allocPrint(mem.allocUtl, "H{d}{d}", .{ e_posx, e_posy })
                    catch |err| { @panic(@errorName(err)); };
                vpnl.lineh.append(mem.allocTui,lnh.newLine(tampon, e_posx, e_posy, e_count,@enumFromInt(litem))) 
                    catch |err| { @panic(@errorName(err)); };
                return;
            },
            .right, .tab => {
                if (e_curs < (vpnl.cols + vpnl.posy) - 1) {
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
            else => {},
        }
    }
}

// Order horizontal
fn orderHorizontal(vpnl: *pnl.PANEL) void {
    var idy: usize = 0;
    var newline = std.ArrayList(lnh.LINEH).initCapacity(mem.allocTui,0) catch unreachable;
    var savline = std.ArrayList(lnh.LINEH).initCapacity(mem.allocTui,0) catch unreachable;

    var Gkey: grd.GridSelect = undefined;
    defer Gkey.Buf.clearAndFree(mem.allocTui);

    for (vpnl.lineh.items) |p| {
        savline.append(mem.allocTui,p)
        catch |err| { @panic(@errorName(err)); };        
    }

    const Origine: *grd.GRID = grd.newGridC(
        "Origine",
        2,
        2,
        25,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer mem.allocTui.destroy(Origine);

    const Order: *grd.GRID = grd.newGridC(
        "Order",
        2,
        70,
        25,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer mem.allocTui.destroy(Order);

    grd.newCell(Origine, "col", 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "name", 6, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.setHeaders(Origine);

    grd.newCell(Order, "col", 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Order, "name", 6, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.setHeaders(Order);

    while (true) {
        grd.resetRows(Origine);
        for (vpnl.lineh.items, 0..) |l, idx| {
            const ridx = usizeToStr(idx);

            grd.addRows(Origine, &.{ ridx, l.name});
        }

        Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
        if (Gkey.Key == kbd.esc) break;
        if (Gkey.Key == kbd.ctrlV) break;
        if (Gkey.Key == kbd.enter) {
            newline.append(mem.allocTui,vpnl.lineh.items[strToUsize(Gkey.Buf.items[0])])
                catch |err| { @panic(@errorName(err)); };
            
            const ridy = usizeToStr(idy);

            grd.addRows(Order, &.{ ridy, Gkey.Buf.items[1]});
            idy += 1;
            grd.printGridHeader(Order);
            grd.printGridRows(Order);
            const ligne: usize = strToUsize(Gkey.Buf.items[0]);

            _ = vpnl.lineh.orderedRemove(ligne);
        }
    }

    vpnl.lineh.clearAndFree(mem.allocTui);
    vpnl.lineh = std.ArrayList(lnh.LINEH).initCapacity(mem.allocTui,0) catch unreachable;
    vpnl.lineh.clearRetainingCapacity();
    // restor and exit
    if (Gkey.Key == kbd.esc) {
        for (savline.items) |p| {
            vpnl.lineh.append(mem.allocTui,p)
                        catch |err| { @panic(@errorName(err)); };
        }
    }
    // new Order and exit CTRL-V
    else {
        for (newline.items) |p| {
            vpnl.lineh.append(mem.allocTui,p)   
                        catch |err| { @panic(@errorName(err)); };
                 }
    }

    grd.freeGrid(Origine);
    grd.freeGrid(Order);

    newline.clearAndFree(mem.allocTui);
    newline.deinit(mem.allocTui);

    savline.clearAndFree(mem.allocTui);
    savline.deinit(mem.allocTui);
}

// remove Horizontal
fn removeHorizontal(vpnl: *pnl.PANEL) void {
    var savline = std.ArrayList(lnh.LINEH).initCapacity(mem.allocTui,0) catch unreachable;

    var Gkey: grd.GridSelect = undefined;
    defer Gkey.Buf.clearAndFree(mem.allocTui);

    for (vpnl.lineh.items) |p| {
        savline.append(mem.allocTui,p)  
            catch |err| { @panic(@errorName(err)); };
    }

    const Origine: *grd.GRID = grd.newGridC(
        "Origine",
        2,
        2,
        25,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer mem.allocTui.destroy(Origine);

    grd.newCell(Origine, "col", 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "name", 6, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.setHeaders(Origine);

    while (true) {
        grd.resetRows(Origine);
        for (vpnl.lineh.items, 0..) |l, idx| {
            const ridx =  usizeToStr(idx);
 
            grd.addRows(Origine, &.{ ridx, l.name});
        }

        Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
        if (Gkey.Key == kbd.esc) break;
        if (Gkey.Key == kbd.ctrlV) break;
        if (Gkey.Key == kbd.enter) {
            const ligne: usize = strToUsize(Gkey.Buf.items[0]);

            _ = vpnl.lineh.orderedRemove(ligne);
        }
    }

    // restor and exit
    if (Gkey.Key == kbd.esc) {
        vpnl.lineh.clearAndFree(mem.allocTui);
        vpnl.lineh = std.ArrayList(lnh.LINEH).initCapacity(mem.allocTui,0) catch unreachable;
        vpnl.lineh.clearRetainingCapacity();

        for (savline.items) |p| {
            vpnl.lineh.append(mem.allocTui,p) 
             catch |err| { @panic(@errorName(err)); };
        }
    }

    grd.freeGrid(Origine);

    savline.clearAndFree(mem.allocTui);
    savline.deinit(mem.allocTui);

}


//------------------------------------------------------------------
// definition line horizontal

fn writeVertical(vpnl: *pnl.PANEL) void {
    
    //term.getCursor();
    var e_count: usize = 0;
    var tampon: []const u8 = undefined;
    var e_LineV = std.ArrayList([]const u8).initCapacity(mem.allocTui,0) catch unreachable;
    defer e_LineV.deinit(mem.allocTui);
    defer mem.allocTui.destroy(&e_LineV);

    const e_posx: usize = term.posCurs.x ;
    const e_posy: usize = term.posCurs.y ;
    var   e_curs: usize = e_posx;

    // defines the receiving structure of the keyboard
    var Tkey: term.Keyboard = undefined;
    const pFmtH01 = Panel_HELP();

    var litem: usize = 0; // type line cadre menu
 
    var mDefline = mnu.newMenu("DefLine", // name
            1, 1, // posx, posy
            mnu.CADRE.line1, // type line fram
            mnu.MNUVH.vertical, // type menu vertical / horizontal
            &.{ // item
            "Line 1",
            "LLine 2",
            }
        );

    while (true) {
        forms.dspCursor(vpnl, e_curs, term.posCurs.y ,"Line Vertical.");
        Tkey = kbd.getKEY();

        //dspMouse(vpnl);  // active display Cursor x/y mouse
        //std.debug.print("Key: {d}  - {d}\n\r",.{term.posCurs.x, term.posCurs.y});
        switch (Tkey.Key) {
            .F1     => {
                fld.setText(pFmtH01,0,"F12 Abort ctrl-V  ctr-l Line ") catch unreachable;
                fld.setText(pFmtH01,1,"" ) catch unreachable;
                _= pnl.ioPanel(pFmtH01);
                pnl.rstPanel(pnl.PANEL,pFmtH01,vpnl);
                term.gotoXY(1,1);
                continue;
            },
            
            .F12 => return,
            .ctrlL => {
                litem = 0;
                litem = mnu.ioMenu(mDefline, litem);
                pnl.rstPanel(mnu.MENU,&mDefline,vpnl);
     
            },
            .ctrlV => {
                tampon = std.fmt.allocPrint(mem.allocUtl, "V{d}{d}", .{ e_posx, e_posy })
                    catch |err| { @panic(@errorName(err)); };
                
                vpnl.linev.append(mem.allocTui,lnv.newLine(tampon, e_posx, e_posy, e_count,@enumFromInt(litem))) 
                    catch |err| { @panic(@errorName(err)); };
                return;
            },
            .down => {
                if (e_curs < (vpnl.cols + vpnl.posx) - 1) {
                    e_count += 1;
                    e_curs += 1;
                }
            },
            .up => {
                if (e_curs > e_posx) {
                    e_count -= 1;
                    e_curs -= 1;
                }
            },
            else => {},
        }
    }
}


// Order horizontal
fn orderVertical(vpnl: *pnl.PANEL) void {
    var idy: usize = 0;
    var newline = std.ArrayList(lnv.LINEV).initCapacity(mem.allocTui,0) catch unreachable;
    var savline = std.ArrayList(lnv.LINEV).initCapacity(mem.allocTui,0) catch unreachable;


    var Gkey: grd.GridSelect = undefined;
    defer Gkey.Buf.clearAndFree(mem.allocTui);

    for (vpnl.linev.items) |p| {
        savline.append(mem.allocTui,p)
        catch |err| { @panic(@errorName(err)); };        
    }

    const Origine: *grd.GRID = grd.newGridC(
        "Origine",
        2,
        2,
        25,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer mem.allocTui.destroy(Origine);

    const Order: *grd.GRID = grd.newGridC(
        "Order",
        2,
        70,
        25,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer mem.allocTui.destroy(Order);

    grd.newCell(Origine, "col", 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "name", 6, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.setHeaders(Origine);

    grd.newCell(Order, "col", 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Order, "name", 6, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.setHeaders(Order);

    while (true) {
        grd.resetRows(Origine);
        for (vpnl.linev.items, 0..) |l, idx| {
            const ridx = usizeToStr(idx);

            grd.addRows(Origine, &.{ ridx, l.name});
        }

        Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
        if (Gkey.Key == kbd.esc) break;
        if (Gkey.Key == kbd.ctrlV) break;
        if (Gkey.Key == kbd.enter) {
            newline.append(mem.allocTui,vpnl.linev.items[strToUsize(Gkey.Buf.items[0])])
                catch |err| { @panic(@errorName(err)); };
            
            const ridy = usizeToStr(idy);

            grd.addRows(Order, &.{ ridy, Gkey.Buf.items[1]});
            idy += 1;
            grd.printGridHeader(Order);
            grd.printGridRows(Order);
            const ligne: usize = strToUsize(Gkey.Buf.items[0]);

            _ = vpnl.linev.orderedRemove(ligne);
        }
    }

    vpnl.linev.clearAndFree(mem.allocTui);
    vpnl.linev = std.ArrayList(lnv.LINEV).initCapacity(mem.allocTui,0) catch unreachable;
    vpnl.linev.clearRetainingCapacity();
    // restor and exit
    if (Gkey.Key == kbd.esc) {
        for (savline.items) |p| {
            vpnl.linev.append(mem.allocTui,p)
                        catch |err| { @panic(@errorName(err)); };
        }
    }
    // new Order and exit CTRL-V
    else {
        for (newline.items) |p| {
            vpnl.linev.append(mem.allocTui,p)   
                        catch |err| { @panic(@errorName(err)); };
                 }
    }

    grd.freeGrid(Origine);
    grd.freeGrid(Order);

    newline.clearAndFree(mem.allocTui);
    newline.deinit(mem.allocTui);

    savline.clearAndFree(mem.allocTui);
    savline.deinit(mem.allocTui);
}

// remove Horizontal
fn removeVertical(vpnl: *pnl.PANEL) void {
    var savline: std.ArrayList(lnv.LINEV) = std.ArrayList(lnv.LINEV).initCapacity(mem.allocTui,0) catch unreachable;

    var Gkey: grd.GridSelect = undefined;
    defer Gkey.Buf.clearAndFree(mem.allocTui);

    for (vpnl.linev.items) |p| {
        savline.append(mem.allocTui,p)  
            catch |err| { @panic(@errorName(err)); };
    }

    const Origine: *grd.GRID = grd.newGridC(
        "Origine",
        2,
        2,
        25,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer mem.allocTui.destroy(Origine);

    grd.newCell(Origine, "col", 3, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "name", 6, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.setHeaders(Origine);

    while (true) {
        grd.resetRows(Origine);
        for (vpnl.linev.items, 0..) |l, idx| {
            const ridx =  usizeToStr(idx);
 
            grd.addRows(Origine, &.{ ridx, l.name});
        }

        Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
        if (Gkey.Key == kbd.esc) break;
        if (Gkey.Key == kbd.ctrlV) break;
        if (Gkey.Key == kbd.enter) {
            const ligne: usize = strToUsize(Gkey.Buf.items[0]);

            _ = vpnl.linev.orderedRemove(ligne);
        }
    }

    // restor and exit
    if (Gkey.Key == kbd.esc) {
        vpnl.linev.clearAndFree(mem.allocTui);
        vpnl.linev = std.ArrayList(lnv.LINEV).initCapacity(mem.allocTui,0) catch unreachable;
        vpnl.linev.clearRetainingCapacity();

        for (savline.items) |p| {
            vpnl.linev.append(mem.allocTui,p) 
             catch |err| { @panic(@errorName(err)); };
        }
    }

    grd.freeGrid(Origine);

    savline.clearAndFree(mem.allocTui);
    savline.deinit(mem.allocTui);
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
    defer Gkey.Buf.deinit(mem.allocTui);
    defer grd.freeGrid(Xcombo);
    defer mem.allocTui.destroy(Xcombo);

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
    defer Gkey.Buf.deinit(mem.allocTui);
    defer grd.freeGrid(Xcombo);
    defer mem.allocTui.destroy(Xcombo);

    for (vgrd.items[numGrid].cell.items, 0..) |p, idx| {
    grd.newCell(Xcombo, p.text, p.long, p.reftyp, p.atrCell.foregr);
    grd.setCellEditCar(&Xcombo.cell.items[idx], p.edtcar);
    }
    grd.setHeaders(Xcombo);

    var vlist = std.ArrayList([] const u8).initCapacity(mem.allocTui,0) catch unreachable;
    defer vlist.clearAndFree(mem.allocTui);
    
    for (vgrd.items[gridNum].cell.items) |p|  {
        var vText: []u8= std.heap.page_allocator.alloc(u8, p.long) catch unreachable;
        if(!std.mem.eql(u8,"SWITCH",@tagName(p.reftyp))) @memset(vText[0..p.long], '#')
        else vText = std.fmt.allocPrint(mem.allocTui, "{s}",.{"true"}) catch  unreachable;
        vlist.append(mem.allocTui,vText) catch unreachable;
    }
    for (0..vgrd.items[gridNum].pageRows) |_| {
        Xcombo.data.append(mem.allocData, .{ .buf = vlist }) catch |err| {
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
        if (Gkey.Key == kbd.enter) {
            break;
        }
    }
}

