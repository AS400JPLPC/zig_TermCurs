const std = @import("std");

const dds = @import("deps/curse/dds.zig");

// terminal Fonction
const term = @import("deps/curse/cursed.zig");
// keyboard
const kbd = @import("deps/curse/cursed.zig").kbd;


// full forms developpeur
const forms = @import("deps/curse/forms.zig");
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
// line horizontal
const lnh = @import("deps/curse/forms.zig").lnh;
// line vertival
const lnv = @import("deps/curse/forms.zig").lnv;

// tools utility
const utl = @import("deps/curse/utils.zig");

// tools regex
const reg = @import("deps/curse/match.zig");

const allocator = std.heap.page_allocator;

/// ---------------------------------------------------
/// Exemple defined Panel Label Field Button Menu Grid
/// ---------------------------------------------------

pub fn Panel_Fmt01() pnl.PANEL {

  //-------------------------------------------------
  // Panel
  // Name Panel, Pos X, Pos Y,
  // nbr Lines, nbr columns
  // Attribut Panel
  // Type frame, Attribut frame
  // Title Panel, Attribut Title
  var Panel = pnl.initPanel("Fmt01",
                  1, 1,
                  32,
                  132,
                  dds.CADRE.line1,
                  "TITLE");

  //-------------------------------------------------
  // Label
  // Name , pos X, pos Y,
  // Text , Attribut Text
  Panel.label.append(lbl.newLabel("free",2,2,"Text-Free...................:")
    ) catch unreachable ;

  Panel.label.append(lbl.newLabel("full",3,2,"Text-Full.....protect.......:")
    ) catch unreachable ;
  
  Panel.label.append(lbl.newLabel("cb01",3,62,"Fonction 01..:")
    ) catch unreachable ;

  Panel.label.append(lbl.newLabel("cb02",4,62,"Fonction 02..:")
    ) catch unreachable ;

  Panel.label.append(lbl.newLabel("alpha",5,2,"Text-Alpha..................:")
    ) catch unreachable ;

  Panel.label.append(lbl.newLabel("alphaupper",6,2,"Text-Alpha-Uppercase........:")
    ) catch unreachable ;

  Panel.label.append(lbl.newLabel("alphanumeric",7,2,"Text-Alpha-Numeric..........:")
    ) catch unreachable ;

  Panel.label.append(lbl.newLabel("alphanumericupper",8,2,"Text-Alpha-Numeric-Upercase.:")
    ) catch unreachable ;

  Panel.label.append(lbl.newLabel("password",10,2,"Text-Password...............:")
    ) catch unreachable ;

  Panel.label.append(lbl.newLabel("yesno",11,2,"Text-Yes or No..............:")
    ) catch unreachable ;

  Panel.label.append(lbl.newLabel("udigit",13,2,"Text-Unsigned.Digit.........:")
    ) catch unreachable ;  

  Panel.label.append(lbl.newLabel("digit",14,2,"Text-signed.Digit...........:")
    ) catch unreachable ; 

  Panel.label.append(lbl.newLabel("udecimal",15,2,"Text-unsigned.Ddecimal......:")
    ) catch unreachable ; 

  Panel.label.append(lbl.newLabel("decimal",16,2,"Text-signed.Ddecimal........:")
    ) catch unreachable ;

  Panel.label.append(lbl.newLabel("dateiso",18,2,"Text-Date-ISO...............:")
    ) catch unreachable ;

  Panel.label.append(lbl.newLabel("datefr",19,2,"Text-Date-FR................:")
    ) catch unreachable;   

  Panel.label.append(lbl.newLabel("dateus",20,2,"Text-Date-US................:")
    ) catch unreachable;

  Panel.label.append(lbl.newLabel("telephone",22,2,"Text-Telephone..US..........:")
    ) catch unreachable;

  Panel.label.append(lbl.newLabel("telephone2",24,2,"Text-Telephone..Standard....:")
    ) catch unreachable;

  Panel.label.append(lbl.newLabel("mail",26,2,"Text-Mail...................:")
    ) catch unreachable; 

  Panel.label.append(lbl.newLabel("switch",28,2,"Text-Switch.................:",)
    ) catch unreachable; 

  Panel.label.append(lbl.newTitle("TITLE",29,70,"Title ex : FACTURE",)
    ) catch unreachable; 

  //example: option specific
  Panel.label.items[1].attribut.styled[0] = @enumToInt(dds.Style.styleItalic);
  Panel.label.items[1].attribut.styled[1] = @enumToInt(dds.Style.notStyle);


 // Field 

    
  Panel.field.append(fld.newFieldTextFree("free",2,32,            // Name , posx posy
                                        30,                       // width
                                        "free",                   // text
                                        true,                     // tofill
                                        "required",               // error msg
                                        "please enter text",      // help
                                        "",                       // regex
                                        )
    ) catch unreachable ;

  Panel.field.append(fld.newFieldTextFull("full",3,32,            // Name , posx posy
                                        30,                       // width
                                        "full",                   // text
                                        true,                     // tofill
                                        "required",               // error msg
                                        "please enter text",      // help
                                        "",                       // regex
                                        )
    ) catch unreachable ;

  fld.setProtect(&Panel,1,true) catch unreachable;

  Panel.field.append(fld.newFieldAlpha("alpha",5,32,              // Name , posx posy
                                        30,                       // width
                                        "abcd",                   // text
                                        true,                     // tofill
                                        "required",               // error msg
                                        "please enter text Alpha",// help
                                        "^[a-zA-Z]{1,}$",         // regex
                                        )
    ) catch unreachable ;

  Panel.field.append(fld.newFieldAlphaUpper("alphaU",6,32,        // Name , posx posy
                                        30,                       // width
                                        "ABCD",                   // text
                                        true,                     // tofill
                                        "required",               // error msg
                                        "please enter text Alpha Uppercase",// help
                                        "",                       // regex
                                        )
    ) catch unreachable ;

  Panel.field.append(fld.newFieldAlphaNumeric("alphaN",7,32,      // Name , posx posy
                                        30,                       // width
                                        "abcd12345",              // text
                                        true,                     // tofill
                                        "required",               // error msg
                                        "please enter text Alpha Numéric",// help
                                        "^[a-zA-Z]{1,1}[a-zA-Z0-9]{0,}",                       // regex
                                        )
    ) catch unreachable ;

  Panel.field.append(fld.newFieldAlphaNumericUpper("alphaNU",8,32, // Name , posx posy
                                        30,                       // width
                                        "ABCD12345",              // text
                                        true,                     // tofill
                                        "required",               // error msg
                                        "please enter text Alpha Numéric",// help
                                        "^[A-Z]{1,1}[A-Z0-9]{0,}",                       // regex
                                        )
    ) catch unreachable ;

  Panel.field.append(fld.newFieldPassword("password",10,32,        // Name , posx posy
                                        30,                       // width
                                        "SECRET",                 // text
                                        true,                     // tofill
                                        "required",               // error msg
                                        "please enter text Alpha Numéric",// help
                                        "",                       // regex
                                        )
    ) catch unreachable ;

  Panel.field.append(fld.newFieldYesNo("yesno",11,32,             // Name , posx posy
                                        "N",                      // text
                                        true,                     // tofill
                                        "required Y or N",        // error msg
                                        "",                       // help default "to validate Y or N "
                                        )
    ) catch unreachable ;

  Panel.field.append(fld.newFieldUDigit("udigit",13,32,           // Name , posx posy
                                        5,                        // width
                                        "00102",                  // text
                                        true,                     // tofill
                                        "Invalide value",         // error msg
                                        "value numeric not signed",// help
                                        "",                       // regex default standard
                                        )
    ) catch unreachable ;

  Panel.field.append(fld.newFieldDigit("digit",14,32,            // Name , posx posy
                                        5,                        // width
                                        "+00102",                 // text
                                        true,                     // tofill
                                        "Invalide value",         // error msg
                                        "value numeric signed",   // help
                                        "",                       // regex default standard
                                        )
    ) catch unreachable ;

  Panel.field.append(fld.newFieldUDecimal("udecimal",15,32,       // Name , posx posy
                                        10,                       // width
                                        2,                        // scal
                                        "001.02",                 // text
                                        true,                     // tofill
                                        "Invalide value",         // error msg
                                        "",                       // help default
                                        "",                       // regex default standard
                                        )
    ) catch unreachable ;

  Panel.field.append(fld.newFieldDecimal("decimal",16,32,         // Name , posx posy
                                        10,                       // width
                                        2,                        // scal
                                        "+001.02",                // text
                                        true,                     // tofill
                                        "Invalide value",         // error msg
                                        "",                       // help default
                                        "",                       // regex default standard
                                        )
    ) catch unreachable ;
  
  Panel.field.append(fld.newFieldDateISO("dateiso",18,32,         // Name , posx posy
                                        "1951-10-12",                       // text
                                        true,                     // tofill
                                        "required",               // error msg
                                        "",                       // help default
                                        )
    ) catch unreachable ;
  
  Panel.field.append(fld.newFieldDateFR("datefr",19,32,           // Name , posx posy
                                        "12/10/1951",             // text
                                        true,                     // tofill
                                        "required",               // error msg
                                        "",                       // help default
                                        )
    ) catch unreachable ;
  
  Panel.field.append(fld.newFieldDateUS("dateus",20,32,           // Name , posx posy
                                        "07/04/1776",             // text
                                        true,                     // tofill
                                        "required",               // error msg
                                        "",                       // help default
                                        )
    ) catch unreachable ;

  Panel.field.append(fld.newFieldTelephone("telephone",22,32,     // Name , posx posy
                                        25,                       // width
                                        "+(001)451 452 453 545",                       // text
                                        true,                     // tofill
                                        "required or invalide",   // error msg
                                        "ex:+(001)456.123.789",   // help
             "^[+]{1,1}[(]([0-9]{3,3})[)]([-. ]?[0-9]{3}){2,4}$",   // regex US default standard
                                        )
    ) catch unreachable ;

  Panel.field.append(fld.newFieldTelephone("telephone2",24,32,     // Name , posx posy
                                        25,                       // width
                                        "+(33)6 01 02 03 04",                       // text
                                        false,                     // tofill
                                        "required or invalide",   // error msg
                                        "ex:+(33)6.12.34.56.78",  // help
"^[+]{1,1}[(]{0,1}[0-9]{1,3}[)]([0-9]{1,3}){1,1}([-. ]?[0-9]{2,3}){2,4}$"   // regex default standard fr
                                        )
    ) catch unreachable ;
  
  Panel.field.append(fld.newFieldMail("mail",26,32,               // Name , posx posy
                                        100,                      // width
                                        "gloups@gmail.com",      // text  error
                                        true,                     // tofill
                                        "required",               // error msg
                                        "",                       // help default
                                        )
    ) catch unreachable ;
  
  Panel.field.append(fld.newFieldSwitch("Switch",28,32,             // Name , posx posy
                                        true,                    // switch
                                        "required",               // error msg
                                        "",                       // help
                                        )
    ) catch unreachable ;

   Panel.field.append(fld.newFieldFunc("cb01",3,76,               // Name , posx posy
                                        20,                       // width
                                        "Amis",                   // text
                                        true,                     // tofill
                                        "comboFn01",              // Process for FUNC 
                                        "required",               // error msg
                                        "select combo",           // help
                                        )
    ) catch unreachable ;

    Panel.field.append(fld.newFieldFunc("cb02",4,76,              // Name , posx posy
                                        20,                       // width
                                        "",                       // text
                                        false,                     // tofill
                                        "comboFn02",              // Process for FUNC 
                                        "required",               // error msg
                                        "select combo",           // help
                                        )
    ) catch unreachable ;


  //-------------------------------------------------
  //the menu is not double buffered it is not a Panel

  Panel.menu.append(mnu.newMenu(
                      "Menu01",               // name
                      2, 2,                   // posx, posy  
                      dds.CADRE.line1,        // type line fram
                      dds.MNUVH.vertical,     // type menu vertical / horizontal
                      &.{"Open..",            // item
                      "List..",
                      "View..",
                      "Delete",
                      "New..",
                      "Src...",
                      "Exit.."}
                      )) catch unreachable ;

  // Grid ---------------------------------------------------------------
  Panel.grid.append(grd.initGrid(
                  "Grid01",                   // Name
                  20, 62,                     // posx, posy
                  7,                          // numbers lines
                  grd.gridStyle,              // separator | or  space
                  dds.CADRE.line1,            // type line  1,2
                  )) catch unreachable ;

  // button--------------------------------------------------
  Panel.button.append(btn.newButton(
                        kbd.F3,                 // function
                        true,                   // show 
                        false,                  // check field
                        "Exit"                  // title
                        )
    ) catch unreachable ;

  Panel.button.append(btn.newButton(
                        kbd.F2,                 // function
                        true,                   // show
                        true,                   // check field
                        "test"                  // title 
                        )
    ) catch unreachable ;

  Panel.button.append(btn.newButton(
                        kbd.F5,                 // function
                        true,                   // show
                        false,                  // check field
                        "Menu"                  // title 
                        )
    ) catch unreachable ;

  Panel.button.append(btn.newButton(
                          kbd.F8,                 // function
                          true,                   // show 
                          false,                  // check control to Field 
                          "Grid"                  // title
                          )
      ) catch unreachable ;

    return Panel;
}


// combo-------------------------------------
fn comboFn01( vpnl : *pnl.PANEL , vfld :* fld.FIELD) void {
  var cellPos:usize = 0;

  var Xcombo = grd.initGrid(
                  "Combo01",
                  4, 76,
                  4 ,  
                  grd.gridStyle,
                  dds.CADRE.line1,
                  )  ;

  var Cell = std.ArrayList(grd.CELL).init(allocator);
  defer Cell.deinit();
  Cell.append(grd.newCell("Choix",15,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgGreen)) catch unreachable ;
  grd.setHeaders(&Xcombo, Cell) ;

  grd.addRows(&Xcombo , &.{"---"});
  grd.addRows(&Xcombo , &.{"Famille"});        
  grd.addRows(&Xcombo , &.{"Amis"}); 
  grd.addRows(&Xcombo , &.{"Professionel"});
  grd.addRows(&Xcombo , &.{"Docteur"});

  if (std.mem.eql(u8,vfld.text,"---") == true)      cellPos = 0;
  if (std.mem.eql(u8,vfld.text,"Famille") == true)  cellPos = 1;
  if (std.mem.eql(u8,vfld.text,"Amis") == true)     cellPos = 2;
  if (std.mem.eql(u8,vfld.text,"Professionel") == true) cellPos = 3;
  if (std.mem.eql(u8,vfld.text,"Docteur") == true) cellPos = 4;

  var Gkey :grd.GridSelect = undefined ;

  Gkey =grd.ioCombo(&Xcombo,cellPos);
  grd.rstPanel(&Xcombo, vpnl);


  grd.resetGrid(&Xcombo);
  Cell.clearAndFree();
  Xcombo.buf.clearAndFree();



  if ( Gkey.Key == kbd.esc )   return ; 
  vfld.text = Gkey.Buf.items[0];
  return ;
}

fn comboFn02( vpnl : *pnl.PANEL , vfld :* fld.FIELD) void {
  var cellPos:usize = 0;
  
  var Xcombo = grd.initGrid(
                  "Combo02",
                  5, 76,
                  4 ,  
                  grd.gridStyle,
                  dds.CADRE.line1,
                  )  ;


  var Cell = std.ArrayList(grd.CELL).init(allocator);
  Cell.append(grd.newCell("Choix",15,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgGreen)) catch unreachable ;
  grd.setHeaders(&Xcombo, Cell) ;

  grd.addRows(&Xcombo , &.{"---"});
  grd.addRows(&Xcombo , &.{"Informaticien"});        
  grd.addRows(&Xcombo , &.{"sportif"}); 

  if (std.mem.eql(u8,vfld.text,"---") == true)      cellPos = 0;
  if (std.mem.eql(u8,vfld.text,"Informaticien") == true)  cellPos = 1;
  if (std.mem.eql(u8,vfld.text,"sportif") == true)     cellPos = 2;


  var Gkey :grd.GridSelect = undefined ;

  Gkey =grd.ioCombo(&Xcombo,cellPos);
  grd.rstPanel(&Xcombo, vpnl);


  grd.resetGrid(&Xcombo);
  Cell.clearAndFree();
  Xcombo.buf.clearAndFree();

  if ( Gkey.Key == kbd.esc )  return ;
  vfld.text = Gkey.Buf.items[0];
  return ;
}

/// run emun Function ex: combo
pub const FnEnum = enum {
  comboFn01,
  comboFn02,
  none,

  pub fn run(self: FnEnum, vpnl : *pnl.PANEL, vfld: *fld.FIELD ) void  {
      switch (self) {
          .comboFn01 => comboFn01(vpnl,vfld),
          .comboFn02 => comboFn02(vpnl,vfld),
          else => dsperr.errorForms( error.main_function_Enum_invalide),
      }
  }

  fn searchFn ( vtext: [] const u8 ) FnEnum {
    var i   :usize = 0;
    var max :usize = @enumToInt(FnEnum.none) ;
      while( i < max ) : (i += 1) {
        if ( std.mem.eql(u8, @tagName(@intToEnum(FnEnum,i)), vtext)) return @intToEnum(FnEnum,i);
      }
      return FnEnum.none;

    }
};
var callFunc: FnEnum = undefined;


//test ---------- pas de sortie output

test "test" {
  var infox : []const u8 = "";
  infox = utl.concatStr("Info : ", infox );
  std.debug.print("{s}",.{infox});
}



// main----------------------------------
pub fn main() !void {

  // open terminal and config and offMouse , cursHide->(cursor hide)
  term.enableRawMode();
  defer term.disableRawMode() ;
  

  // define Panel
  var pFmt01 = Panel_Fmt01();

  
  // defines the receiving structure of the keyboard
  var Tkey : term.Keyboard = undefined ;

  // work Panel-01
  term.resizeTerm(pFmt01.lines,pFmt01.cols);

  //pnl.printPanel(&pFmt01);
  //forms.mydebeug(561, "stop");
  //Tkey.Key = kbd.F2;

  while (true) {
    

    // Tkey = kbd.getKEY();

    Tkey.Key = pnl.ioPanel(&pFmt01);
    
    dds.deinitUtils();

    switch (Tkey.Key) {

      .func => {
        callFunc = FnEnum.searchFn(pFmt01.field.items[pFmt01.idxfld].procfunc); // User clicks "increment"
        callFunc.run(&pFmt01, &pFmt01.field.items[pFmt01.idxfld]);
      },

      .F2 => {
          // test control chek field
          pnl.msgErr(&pFmt01,"le test de la saisie est OK");
        },
      .F5 => {
          var nitem = mnu.ioMenu(&pFmt01,pFmt01.menu.items[0],0);
          mnu.rstPanel(&pFmt01.menu.items[0], &pFmt01);
          std.debug.print("n°item {}",.{nitem});
        },
      .F8 => {

        var Gkey :grd.GridSelect = undefined ;

        if (grd.countColumns(&pFmt01.grid.items[0]) == 0) {
          var Cell = std.ArrayList(grd.CELL).init(allocator);
          Cell.append(grd.newCell("ID",2,dds.REFTYP.UDIGIT,dds.ForegroundColor.fgCyan)) catch unreachable ;
          Cell.append(grd.newCell("Name",15,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgYellow)) catch unreachable ;
          Cell.append(grd.newCell("animal",20,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgWhite)) catch unreachable ;
          Cell.append(grd.newCell("prix",10,dds.REFTYP.DECIMAL,dds.ForegroundColor.fgWhite)) catch unreachable ;
          grd.setCellEditCar(&Cell.items[3],"€");
          Cell.append(grd.newCell("HS",1,dds.REFTYP.SWITCH,dds.ForegroundColor.fgRed)) catch unreachable ;
          Cell.append(grd.newCell("Password",10,dds.REFTYP.PASSWORD,dds.ForegroundColor.fgGreen)) catch unreachable ;
          grd.setHeaders(&pFmt01.grid.items[0], Cell);
          grd.printGridHeader(&pFmt01.grid.items[0]);
          Cell.clearAndFree();
        }


        grd.resetRows(&pFmt01.grid.items[0]);

        grd.addRows(&pFmt01.grid.items[0] , &.{"1", "Adam","Aigle","+1000.00","1","tictac"});
        grd.addRows(&pFmt01.grid.items[0] , &.{"2", "Eve", "poisson","-1001.00","1","tictac2"});
        grd.addRows(&pFmt01.grid.items[0] , &.{"3", "Rouge","Aigle","1002.00","0","tictac3"});
        grd.addRows(&pFmt01.grid.items[0] , &.{"4", "Bleu", "poisson","100.00","0","tictac"});
        grd.addRows(&pFmt01.grid.items[0] , &.{"5", "Bleu5", "poisson","100.00","0","tictac"});
        grd.addRows(&pFmt01.grid.items[0] , &.{"6", "Bleu6", "poisson","100.00","0","tictac"});
        grd.addRows(&pFmt01.grid.items[0] , &.{"7", "Bleu7", "poisson","100.00","1","tictac"});
        grd.addRows(&pFmt01.grid.items[0] , &.{"8", "Bleu8", "poisson","100.00","0","tictac"});
        grd.addRows(&pFmt01.grid.items[0] , &.{"9", "Bleu9", "poisson","100.00","0","tictac"});
        grd.addRows(&pFmt01.grid.items[0] , &.{"10", "Bleu10", "poisson","100.00","0","tictac"});
        grd.addRows(&pFmt01.grid.items[0] , &.{"11", "Bleu11", "poisson","100.00","0","tictac"});

        //grd.dltRows(&pFmt01.grid.items[0] , 5) catch |err| {dsperr.errorForms(err); return;};


        Gkey =grd.ioGrid(&pFmt01.grid.items[0],true);

        if ( Gkey.Key == kbd.enter and pFmt01.idxfld == 0) {
          fld.setText(&pFmt01,0,Gkey.Buf.items[2]) catch |err| {dsperr.errorForms(err); return;};
        }

        if (Gkey.Key  == kbd.pageDown) {
        grd.resetRows(&pFmt01.grid.items[0]);
        grd.addRows(&pFmt01.grid.items[0] , &.{"12", "Bleu12", "Aigle","100,00","0"});
        grd.addRows(&pFmt01.grid.items[0] , &.{"13", "Bleu13", "poisson","100,00","0"});
        grd.addRows(&pFmt01.grid.items[0] , &.{"14", "Bleu14", "Vache","100,00","0"});
        // test display pageDown
        Gkey =grd.ioGrid(&pFmt01.grid.items[0],true);
          if (Gkey.Key  == kbd.pageUp) {
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
            // test display pageUp
            Gkey =grd.ioGrid(&pFmt01.grid.items[0],false);
          }
        }
        grd.rstPanel(&pFmt01.grid.items[0], &pFmt01);
        //grd.resetGrid(&pFmt01.grid.items[0]);
        //Cell.clearAndFree();
        //pFmt01.grid.items[0].buf.deinit();
      },
      .F23 => {     
        pnl.printPanel(&pFmt01);
      },
      else => {},
    }
    if (Tkey.Key == kbd.F3) break; // end work
  }


}