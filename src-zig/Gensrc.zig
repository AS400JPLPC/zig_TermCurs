///-----------------------
/// prog mdlGrid 
///-----------------------

const std = @import("std");

/// terminal Fonction
const term = @import("cursed");
// keyboard
const kbd = @import("cursed").kbd;

// error
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

// src def
const def = @import("srcdef");

// management JSON
const mdlFile = @import("mdlFile");

// Description MENU
const wrtMenu = @import("srcMenu").wrtMenu;

// Description FORMULAIRE
const wrtForms = @import("srcForms").wrtForms;



// REFERENCE CONTROL
const deb_Log = @import("logsrc").openFile;   // open  file
const del_Log = @import("logsrc").deleteFile; // delete file
const end_Log = @import("logsrc").closeFile;  // close file
const new_Line = @import("logsrc").newLine;   // new line
const pref      = @import("logsrc").scoped;     // print file 

const allocator = std.heap.page_allocator;


    // PANEL = FORMULAIRE
    // SFLD = GRID 
    // program can display subfile records only by issuing an output operation to the subfile-control record format
    // COMBO = GRID
    // drop-down list of predefined values.
    // MENU = list: behaves like a choice with an index return




var NOBJET = std.ArrayList(def.DEFOBJET).init(allocator);
var NFIELD = std.ArrayList(def.DEFFIELD).init(allocator);
var NLABEL = std.ArrayList(def.DEFLABEL).init(allocator);
var NLINEH = std.ArrayList(def.DEFLINEH).init(allocator);
var NLINEV = std.ArrayList(def.DEFLINEV).init(allocator);
var NBUTTON= std.ArrayList(def.DEFBUTTON).init(allocator);

var NPANEL = std.ArrayList(pnl.PANEL).init(allocator);
var NGRID  = std.ArrayList(grd.GRID ).init(allocator);
var NMENU  = std.ArrayList(mnu.DEFMENU ).init(allocator);


var numPanel: usize = undefined;
var numGrid : usize = undefined;
var numMenu : usize = undefined;

var nopt : usize    = 0;

const choix = enum {
    folder,
    control,
    list,
    linkcombo,
    srcmenu,
    srcforms,
    clean,
    exit
};



const e0 = "─┬─";

const e1 = " │ ";

const e2 = "─┼─";

const e9 = "─┴─";

// define attribut default LABEL
const atrText : term.ZONATRB = .{
            .styled=[_]u32{@intFromEnum(term.Style.styleDim),
                                        @intFromEnum(term.Style.styleItalic),
                                        @intFromEnum(term.Style.notStyle),
                                        @intFromEnum(term.Style.notStyle)},
            .backgr = term.BackgroundColor.bgBlack,
            .foregr = term.ForegroundColor.fgGreen,
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

fn padingRight(a: []const u8, len: usize) []const u8 {
     var b :[] const u8 = a;
     while ( b.len < len ) {
        b = std.fmt.allocPrint(    utl.allocUtl,"{s} ",.{ b}) catch unreachable;
    }
    return b;    
}

fn padingLeft(a: []const u8, len: usize) []const u8 {
     var b :[] const u8 = a;
     while ( b.len < len ) {
        b = std.fmt.allocPrint(    utl.allocUtl," {s}",.{ b}) catch unreachable;
    }
    return b;    
}


// main----------------------------------

pub fn main() !void {
    //term.offscrool();
    // open terminal and config and offMouse , cursHide->(cursor hide)
    term.enableRawMode();
    defer term.disableRawMode() ;

    // Initialisation
    term.titleTerm("DESIGNER");


    term.resizeTerm(44,168);
    const termSize = term.getSize();


    fld.MouseDsp = true ; // active display cursor x/y mouse

    const base : *pnl.PANEL = pnl.newPanelC("base",
                    1, 1,
                    termSize.height,
                    termSize.width ,
                    forms.CADRE.line1,
                    "") ;
    //-------------------------------------------------
    //the menu is not double buffered it is not a Panel

    const MenuPrincipal = mnu.newMenu(
                    "Screen",                // name
                    2, 2,                    // posx, posy
                    mnu.CADRE.line1,        // type line fram
                    mnu.MNUVH.vertical,        // type menu vertical / horizontal
                    &.{
                    "Folder",
                    "Control",
                    "List",
                    "Link-Combo",
                    "SrcMenu",
                    "SrcForms",
                    "Clear *all",
                    "Exit...",
                    }
                    ) ;

        pnl.printPanel(base);
    while (true) {

        pnl.printPanel(base);
        term.deinitTerm();
        utl.deinitUtl();


        nopt = mnu.ioMenu(MenuPrincipal,0);

        if (nopt == @intFromEnum(choix.exit )) { break; }
        if (nopt == @intFromEnum(choix.control )) controlRef(NOBJET, NFIELD) ;
        if (nopt == @intFromEnum(choix.list )) listRef(NOBJET, NFIELD, NLABEL, NLINEH, NLINEV, NBUTTON) ;
        
        if (nopt == @intFromEnum(choix.srcmenu ) and NMENU.items.len > 0) wrtMenu(NMENU) ;
        
        if (nopt == @intFromEnum(choix.srcforms ) and NPANEL.items.len > 0)
         wrtForms(NPANEL,NGRID,NMENU,NOBJET,NFIELD,NLABEL,NLINEH,NLINEV,NBUTTON) ;

         
        if (nopt == @intFromEnum(choix.linkcombo )) linkCombo(base, &NFIELD) ;
        if (nopt == @intFromEnum(choix.folder)) { 
            try mdlFile.wrkJson(&NPANEL, &NGRID, &NMENU, false) ;// use mdlRjson  
            if (NPANEL.items.len > 0) {
                for( NPANEL.items,0..) | p , i | {
                    NOBJET.append(def.DEFOBJET {.name = p.name, .index = i, .objtype = def.OBJTYPE.PANEL})
                         catch unreachable;
                    
                    for( p.field.items,0..) | f , x | {
                    NFIELD.append(def.DEFFIELD {.panel = p.name, .npnl = i , .field = f.name, .index = x,
                    .func = f.procfunc , .fgrid ="",
                    .task = f.proctask , .call =f.typecall}) catch unreachable;
                    }
                    
                    for( p.label.items,0..) | l , y | {
                    NLABEL.append(def.DEFLABEL {.panel = p.name, .npnl = i , .label = l.name, .index = y
                    }) catch unreachable;
                    }
                    
                    for( p.lineh.items,0..) | h , y | {
                    NLINEH.append(def.DEFLINEH {.panel = p.name, .npnl = i , .line = h.name, .index = y
                    }) catch unreachable;
                    }
                    
                    for( p.linev.items,0..) | v , y | {
                    NLINEV.append(def.DEFLINEV {.panel = p.name, .npnl = i , .line = v.name, .index = y
                    }) catch unreachable;
                    }
                                        
                    for( p.button.items,0..) | b , y | {
                    NBUTTON.append(def.DEFBUTTON {.panel = p.name, .npnl = i ,
                         .button = b.name, .index = y, .title = b.title
                    }) catch unreachable;
                    }
                }
            }    
            for( NMENU.items,0..) | m , i | {
                NOBJET.append(def.DEFOBJET {.name = m.name,.index = i, .objtype = def.OBJTYPE.MENU})
                     catch unreachable;
                }
            for( NGRID.items,0..) | m , i | {
                if (m.name[0] == 'C')
                      NOBJET.append(def.DEFOBJET {.name = m.name,.index = i, .objtype = def.OBJTYPE.COMBO})
                           catch unreachable
                else
                      NOBJET.append(def.DEFOBJET {.name = m.name,.index = i, .objtype = def.OBJTYPE.SFLD})
                           catch unreachable;
            }
            
        }
        // clean allocator *all
        if (nopt == @intFromEnum(choix.clean)) {
            utl.deinitUtl();
            grd.deinitGrid();
            
            if (NPANEL.items.len > 0) {
                NPANEL.clearRetainingCapacity();
            }
            if (NGRID.items.len > 0) {
                NGRID.clearRetainingCapacity();
            }
            if (NMENU.items.len > 0) {
                NMENU.clearRetainingCapacity();
            }
            if (NOBJET.items.len > 0) {
                NOBJET.clearRetainingCapacity();
            }
            if (NFIELD.items.len > 0) {
                NFIELD.clearRetainingCapacity();
            }
            if (NLABEL.items.len > 0) {
                NLABEL.clearRetainingCapacity();
            }
            if (NLINEH.items.len > 0) {
                NLINEH.clearRetainingCapacity();
            }
            if (NLINEV.items.len > 0) {
                NLINEV.clearRetainingCapacity();
            }
        
            if (NBUTTON.items.len > 0) {
                NBUTTON.clearRetainingCapacity();
            }
        }
    
    }
    term.disableRawMode();
}

//---------------------------------
// choix panel
//---------------------------------
fn qryCellGrid(vpnl : *pnl.PANEL, vobjet: *std.ArrayList(def.DEFOBJET )) usize {
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

    for (vobjet.items) |p| {
        if (p.objtype ==  def.OBJTYPE.PANEL  ){
        grd.addRows(Xcombo, &.{ usizeToStr(p.index), p.name});
        }
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

// affectation GRID
pub fn linkCombo(vpnl :*pnl.PANEL, xfield: *std.ArrayList(def.DEFFIELD) ) void {
    const numOBJET = qryCellGrid(vpnl, &NOBJET);
    var ftext : [] const u8 = undefined;

    if (numOBJET == 999) return;

    
    var savObjet: std.ArrayList(def.DEFFIELD) = std.ArrayList(def.DEFFIELD).init(utl.allocUtl);

    for (NFIELD.items) |p| {
        savObjet.append(p)  
        catch |err| { @panic(@errorName(err)); };
    }

    var Gkey: grd.GridSelect = undefined;
    const Origine: *grd.GRID = grd.newGridC(
        "Origine",
        2,
        2,
        20,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer Gkey.Buf.clearAndFree();
    defer grd.freeGrid(Origine);
    defer grd.allocatorGrid.destroy(Origine);


    grd.newCell(Origine, "Key", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgWhite);
    grd.newCell(Origine, "name", 10, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "field", 3, grd.REFTYP.TEXT_FREE , term.ForegroundColor.fgYellow);
    grd.newCell(Origine, "index", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "Func", 15, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "COMBO", 15, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.setHeaders(Origine);

    while (true) {
        grd.resetRows(Origine);
        for (NFIELD.items) |g| {
            if (! std.mem.eql(u8, g.func , "")) {
            
                const ridx = usizeToStr(numOBJET);
            

                const index = usizeToStr(g.index) ;
                grd.addRows(Origine, &.{ ridx, g.panel, g.field , index, g.func, g.fgrid });
            }
        }
        Gkey = grd.ioGridKey(Origine,term.kbd.ctrlV, false);
        if (Gkey.Key == kbd.esc) break;
        if (Gkey.Key == kbd.ctrlV) break;        
        if (Gkey.Key == kbd.enter) {
            ftext = addCombo(vpnl);
            
            for (NFIELD.items , 0..) | f , idx | {
                if ( strToUsize(Gkey.Buf.items[0]) == f.npnl and strToUsize(Gkey.Buf.items[3]) == f.index ) {
                     xfield.items[idx].fgrid = ftext;
                     NPANEL.items[f.npnl].field.items[f.index].procfunc = ftext;
                }
            }
        }
    }

    if (Gkey.Key == kbd.esc) {
        NFIELD.clearRetainingCapacity();

        for (savObjet.items) |p| {
            NFIELD.append(p) 
             catch |err| { @panic(@errorName(err)); };
        }
    }
    savObjet.clearAndFree();
    savObjet.deinit();
    term.cls();
}

pub fn addCombo(vpnl :*pnl.PANEL ) [] const u8 {

    var Gkey: grd.GridSelect = undefined;
    const Origine: *grd.GRID = grd.newGridC(
        "Origine",
        2,
        70,
        20,
        grd.gridStyle,
        grd.CADRE.line1,
    );
    defer Gkey.Buf.clearAndFree();
    defer grd.freeGrid(Origine);
    defer grd.allocatorGrid.destroy(Origine);

    grd.newCell(Origine, "name", 10, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "index", 3, grd.REFTYP.UDIGIT , term.ForegroundColor.fgGreen);
    grd.newCell(Origine, "Func", 15, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.setHeaders(Origine);

    for (NOBJET.items) |g| {
            if ( g.objtype == def.OBJTYPE.COMBO) {
                const index = usizeToStr(g.index) ;
                grd.addRows(Origine, &.{ g.name, index, "COMBO"});
            }
        }
    while (true) {

        Gkey = grd.ioGrid(Origine,false);
        if (Gkey.Key == kbd.enter) {
            pnl.rstPanel(grd.GRID,Origine, vpnl);
            return Gkey.Buf.items[0];
        }
    
        if (Gkey.Key == kbd.esc) {
            pnl.rstPanel(grd.GRID,Origine, vpnl);
            return "";
        }
    }    
}

fn controlRef(xobjet: std.ArrayList(def.DEFOBJET), xfield: std.ArrayList(def.DEFFIELD)) void {

    del_Log("ref_control.txt");
    deb_Log("ref_control.txt");


        for( xobjet.items) | m | {
            const name = padingRight(m.name ,10);
            pref(.NOBJET).objet("Name {s} \t Index {d} \t  type {}"
                , .{name , m.index , m.objtype});
        }

    new_Line();
    new_Line();
    for( xobjet.items) |m | {
        if ( m.objtype == def.OBJTYPE.PANEL) {
            const name = padingRight(m.name ,10);
            pref(.NOBJET).objet("Name {s} \t Index {d} \t  type {}"
            , .{name , m.index , m.objtype});
        
        new_Line();
        
        pref(.NFIELD).ligne(
            "┌───────────{s}────{s}───────────────{s}─────{s}───────────────{s}───────────────{s}───────────────{s}────────────────┐"
                ,.{e0, e0, e0, e0, e0, e0, e0});
        pref(.NFIELD).ligne(
            "│ Name      {s}Npnl{s}field          {s}Index{s}func           {s}grid           {s}task           {s}call            │"
                ,.{e1, e1, e1, e1, e1, e1, e1});
        pref(.NFIELD).ligne(
            "├───────────{s}────{s}───────────────{s}─────{s}───────────────{s}───────────────{s}───────────────{s}────────────────┤"
                ,.{e2, e2, e2, e2, e2, e2, e2});
        
        for( xfield.items) | f | {
            if (std.mem.eql(u8 ,m.name, f.panel)) {
                if ( ! std.mem.eql(u8 ,f.func ,"") or ! std.mem.eql(u8 ,f.task ,"") or ! std.mem.eql(u8 ,f.call ,"")){
                const panel = padingRight(f.panel ,10);
                const npnl  = padingLeft(usizeToStr(f.npnl),4);
                const field = padingRight(f.field ,15);
                const index = padingLeft(usizeToStr(f.index),5);
                const func  = padingRight(f.func  ,15);
                const fgrid = padingRight(f.fgrid ,15);
                const task  = padingRight(f.task  ,15);
                const call  = padingRight(f.call  ,15);
                
                pref(.NFIELD).ligne(
                "│ {s}{s}{s}{s}{s}{s}{s}{s}{s}{s}{s}{s}{s}{s}{s} │"
                ,.{panel, e1, npnl, e1, field, e1, index, e1, func, e1, fgrid, e1, task, e1, call});
                }
            }
        }
        pref(.NFIELD).ligne(
                "└───────────{s}────{s}───────────────{s}─────{s}───────────────{s}───────────────{s}───────────────{s}────────────────┘"
                ,.{e9, e9, e9, e9, e9, e9, e9});
        
        new_Line();
        var ok = true;
        for( xfield.items) | e | {
            if (std.mem.eql(u8 ,m.name, e.panel)) { 
                if ( ! std.mem.eql(u8 ,e.func ,"") and std.mem.eql(u8 ,e.fgrid,"") 
                                                    or !std.mem.eql(u8 ,e.func , e.fgrid)) {
                if ( ok) {
                pref(.NFIELD).ligne(
                "┌────────────────{s}─────{s}───────────────{s}───────────────{s}────────────────────────────┐"
                ,.{e0, e0, e0, e0});
            
                pref(.NFIELD).ligne(
                "│ field          {s}Index{s}func           {s}grid           {s}                            │"
                ,.{e1, e1, e1, e1});
            
                pref(.NFIELD).ligne(
                "├────────────────{s}─────{s}───────────────{s}───────────────{s}────────────────────────────┤"
                ,.{e2, e2, e2, e2});
            
                ok =false;
                }
                    const field = padingRight(e.field ,15);
                    const index = padingLeft(usizeToStr(e.index),5);
                    const func  = padingRight(e.func  ,15);
                    const fgrid = padingRight(e.fgrid ,15);
                    pref(.NFIELD).ligne(
                    "│ {s}{s}{s}{s}{s}{s}{s}{s}ERROR combo ≠ Func          │"
                    ,.{field, e1, index, e1, func, e1, fgrid, e1});
                }
            }
        }
        if ( !ok) {
                        
                pref(.NFIELD).ligne(
                "└────────────────{s}─────{s}───────────────{s}───────────────{s}────────────────────────────┘"
                ,.{e9, e9, e9, e9});
            }
        }
    }
    end_Log();
    utl.deinitUtl();
}



fn listRef(xobjet: std.ArrayList(def.DEFOBJET), xfield: std.ArrayList(def.DEFFIELD),
             xlabel: std.ArrayList(def.DEFLABEL)
             , xlineh: std.ArrayList(def.DEFLINEH), xlinev: std.ArrayList(def.DEFLINEV)
             , xbutton: std.ArrayList(def.DEFBUTTON)) void {

    del_Log("ref_list.txt");
    deb_Log("ref_list.txt");

        for( xobjet.items) | m | {
            const name = padingRight(m.name ,10);
            pref(.NOBJET).objet("Name {s} \t Index {d} \t  type {}"
                , .{name , m.index , m.objtype});
        }

    new_Line();
    new_Line();

    for( xobjet.items) |m | {
    if ( m.objtype == def.OBJTYPE.PANEL) {
        const name = padingRight(m.name ,10);
        pref(.NOBJET).objet("Name {s} \t Index {d} \t  type {}"
            , .{name , m.index , m.objtype});
        
        
        //=========================================================================
        // Field
        //=========================================================================
    
        new_Line();
        
        pref(.NFIELD).ligne(
                "┌───────────{s}────{s}───────────────{s}─────{s}───────────────{s}───────────────{s}───────────────{s}────────────────┐"
                ,.{e0, e0, e0, e0, e0, e0, e0});
        pref(.NFIELD).ligne(
                "│ Name      {s}Npnl{s}field          {s}Index{s}func           {s}grid           {s}task           {s}call            │"
                ,.{e1, e1, e1, e1, e1, e1, e1});
        pref(.NFIELD).ligne(
                "├───────────{s}────{s}───────────────{s}─────{s}───────────────{s}───────────────{s}───────────────{s}────────────────┤"
                ,.{e2, e2, e2, e2, e2, e2, e2});
        
        for( xfield.items) | f | {
            if (std.mem.eql(u8 ,m.name, f.panel)) {
                if ( ! std.mem.eql(u8 ,f.func ,"") or ! std.mem.eql(u8 ,f.task ,"") or ! std.mem.eql(u8 ,f.call ,"")){
                const panel = padingRight(f.panel ,10);
                const npnl  = padingLeft(usizeToStr(f.npnl),4);
                const field = padingRight(f.field ,15);
                const index = padingLeft(usizeToStr(f.index),5);
                const func  = padingRight(f.func  ,15);
                const fgrid = padingRight(f.fgrid ,15);
                const task  = padingRight(f.task  ,15);
                const call  = padingRight(f.call  ,15);
                
                pref(.NFIELD).ligne(
                "│ {s}{s}{s}{s}{s}{s}{s}{s}{s}{s}{s}{s}{s}{s}{s} │"
                ,.{panel, e1, npnl, e1, field, e1, index, e1, func, e1, fgrid, e1, task, e1, call});
                }
            }
        }
        pref(.NFIELD).ligne(
                "└───────────{s}────{s}───────────────{s}─────{s}───────────────{s}───────────────{s}───────────────{s}────────────────┘"
                ,.{e9, e9, e9, e9, e9, e9, e9});
        
        
        
        //=========================================================================
        // Label
        //=========================================================================

        new_Line();
        pref(.NLABEL).ligne(
                "┌───────────{s}────{s}───────────────{s}──────┐"
                ,.{e0, e0, e0});
        pref(.NLABEL).ligne(
                "│ Name      {s}Npnl{s}label          {s}Index │"
                ,.{e1, e1, e1});
        pref(.NLABEL).ligne(
                "├───────────{s}────{s}───────────────{s}──────┤"
                ,.{e2, e2, e2});
        
        for( xlabel.items) | l | {
            if (std.mem.eql(u8 ,m.name, l.panel)) {
                const panel = padingRight(l.panel ,10);
                const npnl   = padingLeft(usizeToStr(l.npnl),4);
                const label = padingRight(l.label ,15);
                const index = padingLeft(usizeToStr(l.index),5);
                
                pref(.NLABEL).ligne(
                "│ {s}{s}{s}{s}{s}{s}{s} │"
                ,.{panel, e1, npnl, e1, label, e1, index});
            }
        }
        pref(.NLABEL).ligne(
                "└───────────{s}────{s}───────────────{s}──────┘"
                ,.{e9, e9, e9});

        
        //=========================================================================
        // Line horizontal
        //=========================================================================

        new_Line();
        pref(.NLINEH).ligne(
                "┌───────────{s}────{s}───────────────{s}──────┐"
                ,.{e0, e0, e0});
        pref(.NLINEH).ligne(
                "│ Name      {s}Npnl{s}line Horizontal{s}Index │"
                ,.{e1, e1, e1});
        pref(.NLINEH).ligne(
                "├───────────{s}────{s}───────────────{s}──────┤"
                ,.{e2, e2, e2});
        
        for( xlineh.items) | h | {
            if (std.mem.eql(u8 ,m.name, h.panel)) {
                const panel = padingRight(h.panel ,10);
                const npnl   = padingLeft(usizeToStr(h.npnl),4);
                const line  = padingRight(h.line ,15);
                const index = padingLeft(usizeToStr(h.index),5);
                
                pref(.NLINEH).ligne(
                "│ {s}{s}{s}{s}{s}{s}{s} │"
                ,.{panel, e1, npnl, e1, line, e1, index});
            }
        }
        pref(.NLINEH).ligne(
                "└───────────{s}────{s}───────────────{s}──────┘"
                ,.{e9, e9, e9});

        
        //=========================================================================
        // Line vertical
        //=========================================================================

        new_Line();
        pref(.NLINEV).ligne(
                "┌───────────{s}────{s}───────────────{s}──────┐"
                ,.{e0, e0, e0});
        pref(.NLINEV).ligne(
                "│ Name      {s}Npnl{s}line vertical  {s}Index │"
                ,.{e1, e1, e1});
        pref(.NLINEV).ligne(
                "├───────────{s}────{s}───────────────{s}──────┤"
                ,.{e2, e2, e2});
        
        for( xlinev.items) | v | {
            if (std.mem.eql(u8 ,m.name, v.panel)) {
                const panel = padingRight(v.panel ,10);
                const npnl   = padingLeft(usizeToStr(v.npnl),4);
                const line  = padingRight(v.line ,15);
                const index = padingLeft(usizeToStr(v.index),5);
                
                pref(.NLINEV).ligne(
                "│ {s}{s}{s}{s}{s}{s}{s} │"
                ,.{panel, e1, npnl, e1, line, e1, index});
            }
        }
        pref(.NLINEV).ligne(
                "└───────────{s}────{s}───────────────{s}──────┘"
                ,.{e9, e9, e9});
        
    
    
    
        
        //=========================================================================
        // Button
        //=========================================================================
        new_Line();
        pref(.NBUTTON).ligne(
                "┌───────────{s}────{s}───────────────{s}─────{s}────────────────┐"
                ,.{e0, e0, e0, e0});
        pref(.NBUTTON).ligne(
                "│ Name      {s}Npnl{s}Button         {s}Index{s}Title           │"
                ,.{e1, e1, e1, e1});
        pref(.NBUTTON).ligne(
                "├───────────{s}────{s}───────────────{s}─────{s}────────────────┤"
                ,.{e2, e2, e2, e2});
        
        for( xbutton.items) | b | {
            if (std.mem.eql(u8 ,m.name, b.panel)) {
                const panel = padingRight(b.panel ,10);
                const npnl   = padingLeft(usizeToStr(b.npnl),4);
                const button = padingRight(b.button ,15);
                const index = padingLeft(usizeToStr(b.index),5);
                const title = padingRight(b.title ,15);
                
                pref(.NBUTTON).ligne(
                "│ {s}{s}{s}{s}{s}{s}{s}{s}{s} │"
                ,.{panel, e1, npnl, e1, button, e1, index, e1, title});
            }
        }
        pref(.NBUTTON).ligne(
                "└───────────{s}────{s}───────────────{s}─────{s}────────────────┘"
                ,.{e9, e9, e9, e9});
    }
    }
    end_Log();
    utl.deinitUtl();

}
