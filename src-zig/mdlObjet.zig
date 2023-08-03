const std = @import("std");

const dds = @import("dds");

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
// menu
const mnu = @import("forms").mnu;
// flied
const fld = @import("forms").fld;
// line horizontal
const lnh = @import("forms").lnh;
// line vertival
const lnv = @import("forms").lnv;


// grid
const grd = @import("grid").grd;

// tools utility
const utl = @import("utils");

// tools regex
const reg = @import("match");





var numPanel: usize = undefined;

pub const ErrMain = error{
    main_append_XPANEL_invalide,
    main_run_EnumFunc_invalide,
    main_run_EnumTask_invalide,
    main_loadPanel_allocPrint_invalide,
    main_updatePanel_allocPrint_invalide,
    main_XPANEL_invalide,
};



//=================================================
// description Function
// choix work panel
pub fn qryPanel(vpnl: *std.ArrayList(pnl.PANEL)) usize {
    var cellPos: usize = 0;


    var Xcombo : *grd.GRID =  grd.newGridC(
        "qryPanel",
        1,
        1,
        20,
        grd.gridStyle,
        dds.CADRE.line1,
    );
    defer dds.allocatorPnl.destroy(Xcombo);

    grd.newCell(Xcombo,"ID", 3, dds.REFTYP.UDIGIT, dds.ForegroundColor.fgGreen);
    grd.newCell(Xcombo,"Name", 10, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgYellow);
    grd.newCell(Xcombo,"Title", 15, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
    grd.setHeaders(Xcombo);

    var idx: usize = 0;
    for (vpnl.items) |p| {
        grd.addRows(Xcombo, &.{ utl.usizeToStr(idx), p.name, p.frame.title });
        idx += 1;
    }

    var Gkey: grd.GridSelect = undefined;
    defer Gkey.Buf.deinit();

    while (true) {
        Gkey = grd.ioCombo(Xcombo, cellPos);

        if (Gkey.Key == kbd.enter) {
            grd.freeGrid(Xcombo);
            
            return utl.strToUsize(Gkey.Buf.items[0]) catch unreachable;
        }


        if (Gkey.Key == kbd.esc) {
            grd.freeGrid(Xcombo);
            
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

    numPanel = qryPanel(XPANEL);

    if (numPanel == 999) return;

    term.cls();
    var pFmt01 : *pnl.PANEL = pnl.newPanelC("FRAM01",
                  XPANEL.items[numPanel].posx,
                  XPANEL.items[numPanel].posy,
                  XPANEL.items[numPanel].lines,
                  XPANEL.items[numPanel].cols,
                  XPANEL.items[numPanel].frame.cadre,
                  XPANEL.items[numPanel].frame.title);
                  
                  


    for (XPANEL.items[numPanel].button.items) |p| {
    pFmt01.button.append(p) catch unreachable ;
    }
    for (XPANEL.items[numPanel].label.items) |p| {
    pFmt01.label.append(p) catch unreachable ;
    }
    for (XPANEL.items[numPanel].field.items) |p| {
    pFmt01.field.append(p) catch unreachable ;
    }
    for (XPANEL.items[numPanel].linev.items) |p| {
    pFmt01.linev.append(p) catch unreachable ;
    }
    for (XPANEL.items[numPanel].lineh.items) |p| {
    pFmt01.lineh.append(p) catch unreachable ;
    }
    
    //for (XPANEL.items[numPanel].grid.items) |p| {
    //pFmt01.grid.append(p) catch unreachable ;
    //}

    for (XPANEL.items[numPanel].menu.items) |p| {
    pFmt01.menu.append(p) catch unreachable ;
    }


    pFmt01.menu.append(mnu.newMenu(
                      "Choix",                // name
                      1, 1,                  // posx, posy  
                      dds.CADRE.line1,        // type line fram
                      dds.MNUVH.vertical,     // type menu vertical / horizontal
                      &.{                    // item
                      "Label-Order",
                      "Label-Remove",
                      }
                      )) catch unreachable ;

    pnl.printPanel(pFmt01);

    maxY = pFmt01.cols + pFmt01.posy;
    if (pFmt01.frame.cadre != dds.CADRE.line0) maxY -= 0;
    minY = pFmt01.posy;
    if (pFmt01.frame.cadre != dds.CADRE.line0) minY += 1;

    maxX = pFmt01.lines + pFmt01.posx;
    if (pFmt01.frame.cadre != dds.CADRE.line0) maxX -= 2;
    minX = pFmt01.posx;
    if (pFmt01.frame.cadre != dds.CADRE.line0) minX += 1;

    term.onMouse();
    var Tkey : term.Keyboard = undefined ; // defines the receiving structure of the keyboard
    while (true) {
        term.cursShow();
        Tkey = kbd.getKEY();

        if (Tkey.Key == kbd.mouse)  { forms.dspMouse(pFmt01);  continue;  } // active display Cursor x/y mouse

        switch (Tkey.Key) {
            .F10 =>  {
                XPANEL.items[numPanel].label.clearAndFree();
                XPANEL.items[numPanel].label =std.ArrayList(lbl.LABEL).init(dds.allocatorPnl);
                XPANEL.items[numPanel].label.clearRetainingCapacity(); 
                for (pFmt01.label.items) |p| {
                XPANEL.items[numPanel].label.append(p) catch unreachable ;
                }

                pnl.freePanel(pFmt01);
                defer dds.allocatorPnl.destroy(pFmt01);
                dds.deinitUtils();
                return;
            },
            .F12 => {

                pnl.freePanel(pFmt01);
                defer dds.allocatorPnl.destroy(pFmt01);
                dds.deinitUtils();
                return ; 
            } ,

            // Def Title
            .altT => {
                term.getCursor(); 
                if (term.posCurs.x < minX or term.posCurs.x > maxX or
                term.posCurs.y < minY or term.posCurs.y > maxY ) continue ;
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

            // Order / Remove
            .altW => {
                var nitem  :usize = 0; 
                  nitem  = mnu.ioMenu(pFmt01,pFmt01.menu.items[0],nitem);
                  term.cls();
                  if (nitem == 0) orderLabel(pFmt01);   // Order  Label
                  if (nitem == 1) removeLabel(pFmt01);  // Remove Label
                  term.offMouse();
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

fn writeLabel(vpnl: *pnl.PANEL, Title: bool) void {
    //term.getCursor();
    var e_count: usize = 0;
    var tampon: []const u8 = undefined;
    var text: []const u8 = undefined;
    var e_LABEL = std.ArrayList([]const u8).init(dds.allocatorUtils);
    defer e_LABEL.deinit();
    defer dds.allocatorUtils.destroy(&e_LABEL);

    var e_posx: usize = term.posCurs.x;
    var e_posy: usize = term.posCurs.y;
    var e_curs: usize = e_posy;

    // defines the receiving structure of the keyboard
    var Tkey: term.Keyboard = undefined;

    var i: usize = 0;
    while (i < vpnl.cols) : (i += 1) {
        e_LABEL.append(" ") catch unreachable;
    }
    while (true) {
        forms.dspCursor(vpnl, e_posx, e_curs);

        Tkey = kbd.getKEY();

        //dspMouse(vpnl);  // active display Cursor x/y mouse
        //std.debug.print("Key: {d}  - {d}\n\r",.{term.posCurs.x, term.posCurs.y});
        switch (Tkey.Key) {
            .F12 => return,

		
            .ctrlV => {
                tampon = std.fmt.allocPrint(dds.allocatorStr,"L{d}{d}",.{e_posx,e_posy}) catch unreachable;
                text = utl.trimStr(utl.listToStr(e_LABEL));
              if (Title) {
                vpnl.label.append(lbl.newTitle(
                tampon, e_posx ,e_posy,fld.ToStr(text)
                )) catch unreachable;
              }
              else {
                vpnl.label.append(lbl.newLabel(
                tampon, e_posx ,e_posy,fld.ToStr(text)
                )) catch unreachable;
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
fn orderLabel( vpnl : *pnl.PANEL) void {
  var idx: usize = 0;
  var idy: usize = 0;
  const allocatorOrder= std.heap.page_allocator;
  var newlabel = std.ArrayList(lbl.LABEL).init(allocatorOrder);
  var savlabel = std.ArrayList(lbl.LABEL).init(allocatorOrder);



  var Gkey :grd.GridSelect = undefined ;
  defer Gkey.Buf.clearAndFree();

  for (vpnl.label.items) |p| {
    savlabel.append(p) catch unreachable ;
    }

  var Origine : *grd.GRID =  grd.newGridC(
                  "Origine",
                  2, 2,
                  25,  
                  grd.gridStyle,
                  dds.CADRE.line1,
                  )  ;
  defer dds.allocatorPnl.destroy(Origine);

  var Order : *grd.GRID =  grd.newGridC(
                  "Order",
                  2, 70,
                  25,  
                  grd.gridStyle,
                  dds.CADRE.line1,
                  )  ;
  defer dds.allocatorPnl.destroy(Order);

  grd.newCell(Origine,"col",3,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgGreen);
  grd.newCell(Origine,"name",6,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgYellow);
  grd.newCell(Origine,"text",40,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgGreen);
  grd.setHeaders(Origine) ;

  grd.newCell(Order,"col",3,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgGreen);
  grd.newCell(Order,"name",6,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgYellow);
  grd.newCell(Order,"text",40,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgGreen);
  grd.setHeaders(Order) ;

  while (true) {
    idx = 0 ; 
    grd.resetRows(Origine);
    for (vpnl.label.items) |l| {
      var ridx =  std.fmt.allocPrint(dds.allocatorUtils, "{d}",.{idx}) catch unreachable;

      if ( l.text.len > 40) grd.addRows(Origine , &.{ridx, l.name, l.text[0..39] })
      else  grd.addRows(Origine , &.{ridx, l.name, l.text });

      idx += 1;

    }



    Gkey =grd.ioGridKey(Origine,term.kbd.ctrlV,false);
    if ( Gkey.Key == kbd.esc)   break ;
    if ( Gkey.Key == kbd.ctrlV)   break ;
    if ( Gkey.Key == kbd.enter ) {   
      newlabel.append(vpnl.label.items[std.fmt.parseInt(usize, Gkey.Buf.items[0], 10) catch unreachable ]) catch unreachable;
      var ridy =  std.fmt.allocPrint(dds.allocatorUtils, "{d}",.{idy}) catch unreachable;

      grd.addRows(Order , &.{ridy, Gkey.Buf.items[1], Gkey.Buf.items[2] });
      idy += 1;
      grd.printGridHeader(Order) ;
      grd.printGridRows(Order);
      var ligne : usize = std.fmt.parseInt(usize, Gkey.Buf.items[0], 10) catch unreachable;
      _=vpnl.label.orderedRemove(ligne);
    }
  }

  vpnl.label.clearAndFree();
  vpnl.label =std.ArrayList(lbl.LABEL).init(dds.allocatorPnl);
  vpnl.label.clearRetainingCapacity();
  // restor and exit
  if ( Gkey.Key == kbd.esc ) {
    for (savlabel.items) |p| {
    vpnl.label.append(p) catch unreachable ;
    }
  }
  // new Order and exit
  else { 
    for (newlabel.items) |p| {
    vpnl.label.append(p) catch unreachable ;
    }
  }
  

  grd.freeGrid(Origine);
  grd.freeGrid(Order);
  //Origine =undefined;
  //Order   =undefined;

  newlabel.clearAndFree();
  newlabel.deinit();


  savlabel.clearAndFree();
  savlabel.deinit();

  defer allocatorOrder.destroy(&newlabel);
  defer allocatorOrder.destroy(&savlabel);
  return ;
}


// remove Label
fn removeLabel( vpnl : *pnl.PANEL) void {
  var idx: usize = 0;

  const allocatorRemove= std.heap.page_allocator;
  var savlabel : std.ArrayList(lbl.LABEL) = std.ArrayList(lbl.LABEL).init(allocatorRemove);



  var Gkey :grd.GridSelect = undefined ;
  defer Gkey.Buf.clearAndFree();

  for (vpnl.label.items) |p| {
    savlabel.append(p) catch unreachable ;
    }

  var Origine : *grd.GRID =  grd.newGridC(
                  "Origine",
                  2, 2,
                  25,  
                  grd.gridStyle,
                  dds.CADRE.line1,
                  )  ;
  defer dds.allocatorPnl.destroy(Origine);

  grd.newCell(Origine,"col",3,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgGreen);
  grd.newCell(Origine,"name",6,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgYellow);
  grd.newCell(Origine,"text",40,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgGreen);
  grd.setHeaders(Origine) ;
  

  while (true) {
    idx = 0 ; 
    grd.resetRows(Origine);
    for (vpnl.label.items) |l| {
      var ridx =  std.fmt.allocPrint(dds.allocatorUtils, "{d}",.{idx}) catch unreachable;


      if ( l.text.len > 40) grd.addRows(Origine , &.{ridx, l.name, l.text[0..39] })
      else  grd.addRows(Origine , &.{ridx, l.name, l.text });

      idx += 1;

    }

    Gkey =grd.ioGridKey(Origine,term.kbd.ctrlV,false);
    if ( Gkey.Key == kbd.esc)   break ;
    if ( Gkey.Key == kbd.ctrlV) break ;
    if ( Gkey.Key == kbd.enter ) {
      var ridx : usize = std.fmt.parseInt(usize, Gkey.Buf.items[0], 10) catch unreachable;
      _=vpnl.label.orderedRemove(ridx);
    }
  }


  // restor and exit
  if ( Gkey.Key == kbd.esc ) {
    vpnl.label.clearAndFree();
    vpnl.label =std.ArrayList(lbl.LABEL).init(dds.allocatorPnl);
    vpnl.label.clearRetainingCapacity();

    for (savlabel.items) |p| {
    vpnl.label.append(p) catch unreachable ;
    }
  }


  grd.freeGrid(Origine);
  
  savlabel.clearAndFree();
  savlabel.deinit();
  defer allocatorRemove.destroy(&savlabel);
}