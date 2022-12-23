/// exemple
/// There's still much to do. I'm progressing slowly Thank you for your patience


const std = @import("std");

const dds = @import("dds");

// terminal Fonction
const term = @import("cursed");

// keyboard
const kbd = @import("cursed").kbd;

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
// grid
const grd = @import("forms").grd;


const allocator = std.heap.page_allocator;




pub fn Panel_Fmt01() pnl.PANEL {

  //-------------------------------------------------
  // Panel
  // Name Panel, Pos X, Pos Y,
  // nbr Lines, nbr columns
  // Attribut Panel
  // Type frame, Attribut frame
  // Title Panel, Attribut Title
  var Panel = pnl.initPanel("Format01",
                  1, 1,
                  42,
                  152,
                  pnl.AtrPanel,
                  dds.CADRE.line1,
                  frm.AtrFrame,
                  "TITLE",
                  frm.AtrTitle);

  //-------------------------------------------------
  // Label
  // Name , pos X, pos Y,
  // Text , Attribut Text
  Panel.label.append(lbl.newLabel("Name-1",1,1,
                        "Jean-Pierre",
                        lbl.AtrLabel)
    ) catch unreachable ;

  Panel.label.append(lbl.newLabel("Name-2",2,2,
                        "Marie",
                        lbl.AtrLabel)
    ) catch unreachable ;

  Panel.label.append(lbl.newLabel("Name-1",10,1,
                        "Eric",
                        lbl.AtrLabel)
    ) catch unreachable ;


  //-------------------------------------------------
  // button
  // F.. , Sow/hiden, Attribut,
  // Text, Attribut text,
  // Chek value field input
  Panel.button.append(btn.newButton(
                        kbd.str(kbd.F1),
                        true, // show
                        btn.AtrButton,
                        "Help Jean-Pierre",
                        btn.AtrTitle,
                        true //check
                        )
    ) catch unreachable ;

  Panel.button.append(btn.newButton(
                      kbd.str(kbd.F3),
                      true, // show
                      btn.AtrButton,
                      "Exit",
                      btn.AtrTitle,
                      true //check
                      )
    ) catch unreachable ;

  Panel.button.append(btn.newButton(
                        kbd.str(kbd.F7),
                        true, // show
                        btn.AtrButton,
                        "Test menu",
                        btn.AtrTitle,
                        true //check
                        )
    ) catch unreachable ;

  Panel.button.append(btn.newButton(
                        kbd.str(kbd.F8),
                        true, // show
                        btn.AtrButton,
                        "Test Grid",
                        btn.AtrTitle,
                        true //check
                        )
    ) catch unreachable ;

  //-------------------------------------------------
  //the menu is not double buffered it is not a Panel
  // name,
  // posx , posy
  // numbers lines   = numbers Item + 2 for fram ex: 7
  // numbers columns
  // Attribut fram
  // Attribut bar (reverse)
  // Attribut cell
  // item
  Panel.menu.append(mnu.initMenu(
                      "Menu01",
                      1, 1,
                      9,
                      15,
                      mnu.AtrMnu,
                      mnu.AtrBar,
                      mnu.AtrCell,
                      dds.CADRE.line1,
                      dds.MNUVH.vertical,
                      &.{"Open..",
                      "List..",
                      "View..",
                      "Delete",
                      "New..",
                      "Src...",
                      "Exit.."}
                      )) catch unreachable ;



  Panel.grid.append(grd.initGrid(
                  "Grid01",
                  20, 2,
                  7,
                  grd.gridStyle,
                  grd.AtrGrid,
                  grd.AtrTitle,
                  grd.AtrCell,
                  dds.CADRE.line1,
                  )) catch unreachable ;


  return Panel;
}


pub fn Panel_Fmt02() pnl.PANEL {

  var Panel = pnl.initPanel("Fmt02",
                  10,50, // x,y
                  10,    // lines
                  30,    // cols
                  pnl.AtrPanel,     // attribut Panel
                  dds.CADRE.line1,  // type de cadre
                  frm.AtrFrame,     // atribut BOX
                  "Panel-Info",
                  frm.AtrTitle);

  Panel.label.append(lbl.newLabel("Info",5,2,
                        "Demo: Displaying a Window",
                        lbl.AtrLabel
        )) catch unreachable ;
  //example: option specific
  Panel.label.items[0].attribut.styled[2] = @enumToInt(dds.Style.styleReverse);
  Panel.label.items[0].attribut.styled[3] = @enumToInt(dds.Style.styleBlink);


  Panel.button.append(btn.newButton(
                        kbd.str(kbd.F12),
                        true, // show
                        btn.AtrButton,
                        "Return",
                        btn.AtrTitle,
                        true //check
                        )
    ) catch unreachable ;





  return Panel;
}

fn setID( lineID : usize ) usize {
  lineID += 1 ;
  return lineID;
}

pub fn main() !void {

  // open terminal and config and offMouse , cursHide->(cursor hide)
  term.enableRawMode();
  defer term.disableRawMode() ;

  // define Panel
  var pFmt01 = Panel_Fmt01();
  var pFmt02 = Panel_Fmt02();

  // defines the receiving structure of the keyboard
  var Tkey : term.Keyboard = undefined ;

  // work Panel-01
  pnl.printPanel(pFmt01);
  while (true) {

    Tkey = kbd.getKEY();
    switch (Tkey.Key) {
      .F1 => {
          // work panel -02
          pnl.printPanel(pFmt02);
          while (true) {
            Tkey = kbd.getKEY();
              switch (Tkey.Key) {
                .F12 => pnl.rstPanel(pFmt02,pFmt01),
                else => {},
              }
            if (Tkey.Key == kbd.F12) { Tkey.Key = kbd.none; break; }
          }
        },

      .F7 => {
          var nitem = mnu.ioMenu(pFmt01,pFmt01.menu.items[0],0);
          pFmt01.menu.items[0].selMenu = nitem;
          mnu.rstPanel(pFmt01.menu.items[0], pFmt01);
          std.debug.print("n°item {}",.{pFmt01.menu.items[0].selMenu});
         
        },

      .F8 => {

        if (grd.counColumns(&pFmt01.grid.items[0]) == 0) {
          var Cell = std.ArrayList(grd.CELL).init(allocator);
          Cell.append(grd.newCell("ID",3,dds.REFTYP.DIGIT,dds.ForegroundColor.fgGreen)) catch unreachable ;
          Cell.append(grd.newCell("Name",15,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgYellow)) catch unreachable ;
          Cell.append(grd.newCell("animal",20,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgWhite)) catch unreachable ;
          //Cell.append(grd.newCell("prix",8,dds.REFTYP.DECIMAL,dds.ForegroundColor.fgWhite)) catch unreachable ;
          // setCellEditCar(g_prix,"€")
          Cell.append(grd.newCell("HS",1,dds.REFTYP.SWITCH,dds.ForegroundColor.fgWhite)) catch unreachable ;
          grd.setHeaders(&pFmt01.grid.items[0], Cell) catch unreachable ;
          grd.printGridHeader(&pFmt01.grid.items[0]);
        }


          grd.resetRows(&pFmt01.grid.items[0]);
          //std.debug.print("len haeder:{}",.{grd.getLenHeaders(&panel.grid.items[0])});
          grd.addRows(&pFmt01.grid.items[0] , &.{"01", "Adam","Aigle","1"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"02", "Eve", "poisson","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"03", "Rouge","Aigle","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"04", "Bleu", "poisson","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"05", "Bleu5", "poisson","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"06", "Bleu6", "poisson","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"07", "Bleu7", "poisson","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"08", "Bleu8", "poisson","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"09", "Bleu9", "poisson","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"10", "Bleu10", "poisson","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"11", "Bleu11", "poisson","0"});

          grd.dltRows(&pFmt01.grid.items[0] , 5);
          var Gkey :grd.GridSelect = undefined ;

          Gkey =grd.ioGrid(&pFmt01.grid.items[0]);
          std.debug.print("key:{} \r\n",.{Gkey.Key});
          if ( Gkey.Key != kbd.esc ) std.debug.print("buf:{s} \r\n",.{Gkey.Buf.items[1]});

        },
      else => {},
    }
    if (Tkey.Key == kbd.F3) break; // end work
  }

}