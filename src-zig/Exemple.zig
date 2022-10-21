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



const allocator = std.heap.page_allocator;




pub fn Panel_Fmt01() pnl.PANEL {


  // Panel
  // Name Panel, Pos X, Pos Y,
  // nbr Lines, nbr columns
  // Attribut Panel
  // Type frame, Attribut frame
  // Title Panel, Attribut Title
  var Panel = pnl.initPanel("Format01",
                  1, 1,
                  30,
                  132,
                  pnl.AtrPanel,
                  dds.CADRE.line1,
                  frm.AtrFrame,
                  "TITLE",
                  frm.AtrTitle);


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

  return Panel;
}


pub fn Panel_Fmt02() pnl.PANEL {

  var Panel = pnl.initPanel("Fmt02",
                  10,50, // x,y
                  10,   // lines
                  30,   // cols
                  pnl.AtrPanel,     // attribut Panel
                  dds.CADRE.line1,  // type de cadre
                  frm.AtrFrame,    // atribut BOX
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


pub fn main() !void {

  // open terminal and config and offMouse , cursHide->(cursor hide)
  var console =  try term.enableRawMode();
  defer console.disableRawMode() catch {};

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
      else => {},
    }

    if (Tkey.Key == kbd.F3) break; // end work
  }

}