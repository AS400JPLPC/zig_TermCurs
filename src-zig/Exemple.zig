/// exemple
/// There's still much to do. I'm progressing slowly Thank you for your patience


const std = @import("std");

const dds = @import("dds");

// terminal Fonction
const term = @import("cursed");

// keyboard
const kbd = @import("cursed").kbd;


// error
const dsperr = @import("forms").dsperr;
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
// flied
const fld = @import("forms").fld;


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
                  32,
                  132,
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

  Panel.label.append(lbl.newLabel("Name-1",11,52,
                        "Eric",
                        lbl.AtrLabel)
    ) catch unreachable ;
   //example: option specific
  Panel.label.items[2].attribut.styled[0] = @enumToInt(dds.Style.styleItalic);
  Panel.label.items[2].attribut.styled[1] = @enumToInt(dds.Style.notStyle);


  Panel.field.append(fld.newFieldString("NOM",5,2,
                                        dds.REFTYP.TEXT_FREE,
                                        30,                       // width
                                        "my name",                // text
                                        false,                    // empty
                                        "required",               // error msg
                                        "please enter your name", // help
                                        "",                       // regex
                                        fld.AtrField,             // attribut field
                                        fld.AtrProtect            // attribut protect field
                                        )
    ) catch unreachable ;
  
  Panel.field.append(fld.newFieldString("NOM2",6,2,
                                        dds.REFTYP.TEXT_FREE,
                                        30,                       // width
                                        "my name",                // text
                                        false,                    // empty
                                        "required",               // error msg
                                        "please enter your name", // help
                                        "",                       // regex
                                        fld.AtrField,             // attribut field
                                        fld.AtrProtect            // attribut protect field
                                        )
    ) catch unreachable ;
  


  //-------------------------------------------------
  // button
  // F.. , Sow/hiden, Attribut,
  // Text, Attribut text,
  // Chek value field input
  Panel.button.append(btn.newButton(
                        kbd.F1,
                        true, // show
                        btn.AtrButton,
                        "Help Jean-Pierre",
                        btn.AtrTitle,
                        true //check
                        )
    ) catch unreachable ;

  Panel.button.append(btn.newButton(
                      kbd.F3,
                      true, // show
                      btn.AtrButton,
                      "Exit",
                      btn.AtrTitle,
                      true //check
                      )
    ) catch unreachable ;

  Panel.button.append(btn.newButton(
                        kbd.F7,
                        true, // show
                        btn.AtrButton,
                        "Test menu",
                        btn.AtrTitle,
                        true //check
                        )
    ) catch unreachable ;

  Panel.button.append(btn.newButton(
                        kbd.F8,
                        true, // show
                        btn.AtrButton,
                        "Test Grid",
                        btn.AtrTitle,
                        true //check
                        )
    ) catch unreachable ;

  Panel.button.append(btn.newButton(
                        kbd.F9,
                        true, // show
                        btn.AtrButton,
                        "Test Combo",
                        btn.AtrTitle,
                        true //check
                        )
    ) catch unreachable ;

  Panel.button.append(btn.newButton(
                        kbd.F12,
                        true, // show
                        btn.AtrButton,
                        "ReDisplay",
                        btn.AtrTitle,
                        true //check
                        )
    ) catch unreachable;

  Panel.button.append(btn.newButton(
                        kbd.F23,
                        true, // show
                        btn.AtrButton,
                        "Delete label",
                        btn.AtrTitle,
                        true //check
                        )
    ) catch unreachable;

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
  Panel.label.items[0].attribut.styled[0] = @enumToInt(dds.Style.styleDim);
  Panel.label.items[0].attribut.styled[1] = @enumToInt(dds.Style.styleUnderscore);


  Panel.button.append(btn.newButton(
                        kbd.F12,
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

fn tstCombo( vfld : [] const u8) []const u8 {
  var cellPos:usize = 0;
   
  var Xcombo = grd.initGrid(
                  "Grid01",
                  20, 2,
                  3 ,  // nbr ligne  + header
                  grd.gridStyle,
                  grd.AtrGrid,
                  grd.AtrTitle,
                  grd.AtrCell,
                  dds.CADRE.line1,
                  )  ;

  var Cell = std.ArrayList(grd.CELL).init(allocator);
  Cell.append(grd.newCell("Choix",15,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgGreen)) catch unreachable ;
  grd.setHeaders(&Xcombo, Cell) catch unreachable ;

  grd.addRows(&Xcombo , &.{"---"});
  grd.addRows(&Xcombo , &.{"Famille"});        
  grd.addRows(&Xcombo , &.{"Amis"}); 
  grd.addRows(&Xcombo , &.{"Professionel"});

  if (std.mem.eql(u8,vfld,"---") == true)      cellPos = 0;
  if (std.mem.eql(u8,vfld,"Famille") == true)  cellPos = 1;
  if (std.mem.eql(u8,vfld,"Amis") == true)     cellPos = 2;
  if (std.mem.eql(u8,vfld,"Professionel") == true) cellPos = 3;

  var Gkey :grd.GridSelect = undefined ;

  Gkey =grd.ioCombo(&Xcombo,cellPos);
  //std.debug.print("key:{} \r\n",.{Gkey.Key});
  //if ( Gkey.Key != kbd.esc ) std.debug.print("buf:{s} \r\n",.{Gkey.Buf.items[0]})
  if ( Gkey.Key == kbd.esc )  return "";
  return Gkey.Buf.items[0] ;
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
  term.resizeTerm(pFmt01.lines,pFmt01.cols);
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

        if (grd.countColumns(&pFmt01.grid.items[0]) == 0) {
          var Cell = std.ArrayList(grd.CELL).init(allocator);
          Cell.append(grd.newCell("ID",3,dds.REFTYP.DIGIT,dds.ForegroundColor.fgCyan)) catch unreachable ;
          Cell.append(grd.newCell("Name",15,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgYellow)) catch unreachable ;
          Cell.append(grd.newCell("animal",20,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgWhite)) catch unreachable ;
          Cell.append(grd.newCell("prix",8,dds.REFTYP.DECIMAL,dds.ForegroundColor.fgWhite)) catch unreachable ;
          grd.setCellEditCar(&Cell.items[3],"€");
          Cell.append(grd.newCell("HS",1,dds.REFTYP.SWITCH,dds.ForegroundColor.fgRed)) catch unreachable ;
          grd.setHeaders(&pFmt01.grid.items[0], Cell) catch unreachable ;
          grd.printGridHeader(&pFmt01.grid.items[0]);
        }


          grd.resetRows(&pFmt01.grid.items[0]);

          grd.addRows(&pFmt01.grid.items[0] , &.{"01", "Adam","Aigle","1000,00","1"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"02", "Eve", "poisson","1001,00","1"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"03", "Rouge","Aigle","1002,00","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"04", "Bleu", "poisson","100,00","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"05", "Bleu5", "poisson","100,00","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"06", "Bleu6", "poisson","100,00","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"07", "Bleu7", "poisson","100,00","1"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"08", "Bleu8", "poisson","100,00","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"09", "Bleu9", "poisson","100,00","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"10", "Bleu10", "poisson","100,00","0"});
          grd.addRows(&pFmt01.grid.items[0] , &.{"11", "Bleu11", "poisson","100,00","0"});

          grd.dltRows(&pFmt01.grid.items[0] , 5);
          var Gkey :grd.GridSelect = undefined ;

          Gkey =grd.ioGrid(&pFmt01.grid.items[0]);
          std.debug.print("key:{} \r\n",.{Gkey.Key});
          if ( Gkey.Key != kbd.esc ) std.debug.print("buf:{s} \r\n",.{Gkey.Buf.items[1]});

        },

      .F9 => {
        var vfld : [] const u8 = "Professionel";
        vfld = tstCombo(vfld) ;
        std.debug.print("buf:>{s}< \r\n",.{vfld});
      },

      .F12 => { 
        //var i = fld.getIndex(pFmt01 , "NOMX" ) catch |err| {dsperr.errorForms(err); return;};
        var i = fld.getIndex(pFmt01 , "NOM2" ) catch |err| {dsperr.errorForms(err); return;};
        fld.setProtect(pFmt01,i, true);
        fld.printField(pFmt01,pFmt01.field.items[i]);
        fld.displayField(pFmt01,pFmt01.field.items[i]);
        _= kbd.getKEY();
        fld.setProtect(pFmt01,i, false);
        fld.setErr(pFmt01,i,true);
        fld.setText(pFmt01,i,"123456789012345678901234567890");
        fld.printField(pFmt01,pFmt01.field.items[i]);
        fld.displayField(pFmt01,pFmt01.field.items[i]);
        _= kbd.getKEY();
        fld.setErr(pFmt01,i,false);
        i = lbl.getIndex(pFmt01,"Name-2") catch |err| {dsperr.errorForms(err); return;};
        lbl.updateText(pFmt01,i,"Ma petite Marie");
        _= kbd.getKEY();
        lbl.updateText(pFmt01,i,"Marie");
        _= kbd.getKEY();     
        pnl.printPanel(pFmt01);

      },
      .F23 => {
        var i = fld.getIndex(pFmt01 , "NOM" ) catch |err| {dsperr.errorForms(err); return;};
        fld.dltRows(&pFmt01,i);
        pnl.printPanel(pFmt01);
      },
      else => {},
    }
    if (Tkey.Key == kbd.F3) break; // end work
  }


}