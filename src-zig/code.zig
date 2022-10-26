const std = @import("std");
const term = @import("cursed");
const kbd = @import("cursed").kbd;

const dds = @import("dds");
const frm = @import("forms").frm;
const lbl = @import("forms").lbl;
const pnl = @import("forms").pnl;
const btn = @import("forms").btn;
const mnu = @import("forms").mnu;

const output =std.io.getStdOut();



// procedure de définition de label doit être généé automatiquement
const allocator = std.heap.page_allocator;
pub var rcd_label = std.ArrayList(lbl.LABEL).init(allocator);

pub var rcd_label2 = std.ArrayList(lbl.LABEL).init(allocator);

pub fn stockLabel() void{

    rcd_label.append(lbl.newLabel("Name-1",1,1,
                        "Jean-Pierre",
                        lbl.AtrLabel
        )) catch {return;} ;
    //example: option specific
    rcd_label.items[0].attribut.styled[2] = @enumToInt(dds.Style.styleReverse);
    rcd_label.items[0].attribut.styled[3] = @enumToInt(dds.Style.styleBlink);


    rcd_label.append(lbl.newLabel("Name-2",3,1,
                        "Marie",
                        lbl.AtrLabel
        )) catch {return;} ;


     rcd_label.append(lbl.newLabel("Name-3",8,48,
                        "------------------------------",
                        lbl.AtrLabel
        )) catch {return;};

    rcd_label.append(lbl.newLabel("Name-3",9,48,
                        "------------------------------",
                        lbl.AtrLabel
        )) catch {return;};


    rcd_label.append(lbl.newLabel("Name-4",11,50,
                        "Eric",
                        lbl.AtrLabel
        )) catch {return;} ;

    rcd_label.append(lbl.newLabel("Name-5",12,48,
                        "------------------------------",
                        lbl.AtrLabel
        )) catch {return;} ;

    rcd_label.append(lbl.newLabel("Name-6",13,48,
                        "------------------------------",
                        lbl.AtrLabel
        )) catch {return;} ;
    rcd_label.append(lbl.newLabel("Name-6",16,48,
                        "------------------------------",
                        lbl.AtrLabel
        )) catch {return;} ;
    rcd_label.append(lbl.newLabel("Name-6",18,48,
                        "------------------------------",
                        lbl.AtrLabel
        )) catch {return;} ;

    rcd_label.append(lbl.newLabel("Name-6",19,48,
                        "------------------------------",
                        lbl.AtrLabel
        )) catch {return;} ;
}

pub fn stockLabel2() void{

    rcd_label2.append(lbl.newLabel("Name-1",1,2,
                        "Jean-Pierre",
                        lbl.AtrLabel
        )) catch {return;} ;
    //example: option specific
    rcd_label2.items[0].attribut.styled[2] = @enumToInt(dds.Style.styleReverse);
    rcd_label2.items[0].attribut.styled[3] = @enumToInt(dds.Style.styleBlink);


    rcd_label2.append(lbl.newLabel("Name-2",2,2,
                        "Marie",
                        lbl.AtrLabel
        )) catch {return;} ;
}


var rcd_button = std.ArrayList(btn.BUTTON).init(allocator);


pub fn stockButton() void{

    rcd_button.append(btn.newButton(
                        kbd.str(kbd.F1),
                        true, // show
                        btn.AtrButton,
                        "Help Jean-Pierre",
                        btn.AtrTitle,
                        true //check
                        )) catch unreachable ;
}

var rcd_Menu = std.ArrayList(mnu.MENU).init(allocator);


pub fn stockMenu_1() void{

    var item= std.ArrayList([] const u8).init(allocator);

    item.append("Panel ") catch unreachable ;
    item.append("Sav.  ") catch unreachable ;
    item.append("Exit  ") catch unreachable ;

    rcd_Menu.append(mnu.initMenu(
                        "Menu01",
                        1, 1,
                        3,
                        50,
                        mnu.AtrMnu,
                        mnu.AtrBar,
                        mnu.AtrCell,
                        dds.CADRE.line1,
                        dds.MNUVH.horizontal,
                        item,
                        )) catch unreachable ;
}

pub fn stockMenu_2() void{

    var item= std.ArrayList([] const u8).init(allocator);

    item.append("Panel ") catch unreachable ;
    item.append("Sav.  ") catch unreachable ;
    item.append("Exit  ") catch unreachable ;

    rcd_Menu.append(mnu.initMenu(
                        "Menu01",
                        1, 1,
                        10,
                        15,
                        mnu.AtrMnu,
                        mnu.AtrBar,
                        mnu.AtrCell,
                        dds.CADRE.line1,
                        dds.MNUVH.vertical,
                        item,
                        )) catch unreachable ;
}





pub fn main() !void {


    var console =  try term.enableRawMode();
    defer console.disableRawMode() catch {};
    const stdout = std.io.getStdOut();
    defer rcd_label.deinit();

    stockLabel();

    var index_label: ?usize = null;
    for (rcd_label.items) | xLABEL, idx| {
        if (std.mem.eql(u8, xLABEL.text, "Marie")) {
            index_label = idx;
        }
    }


    stockLabel2();
    stockButton() ;
    var panel = pnl.initPanel("PANEL",
                  1, 1, // x,y
                  30,   // lines
                  132,   // cols
                  pnl.AtrPanel,     // attribut Panel
                  dds.CADRE.line1,  // type de cadre
                  frm.AtrFrame,    // atribut BOX
                  "TITLE",
                  frm.AtrTitle);

        for (rcd_label.items) |xLABEL| {
            panel.label.append(xLABEL) catch {return;} ;
        }

        for (rcd_button.items) |xBUTTON| {
            panel.button.append(xBUTTON) catch {unreachable;} ;
        }



    var panel2 = pnl.initPanel("PANEL2",
                  10,50, // x,y
                  15,   // lines
                  20,   // cols
                  pnl.AtrPanel,     // attribut Panel
                  dds.CADRE.line1,  // type de cadre
                  frm.AtrFrame,    // atribut BOX
                  "PANEL2",
                  frm.AtrTitle);
    for (rcd_label2.items) |xLABEL| {
        panel2.label.append(xLABEL) catch {return;} ;
    }


    term.offMouse();

    pnl.printPanel(panel);



    // get f1..f24 Alt.. crtl..
    var Tkey = kbd.getKEY();
    switch (Tkey.Key) {
            else => {},
        }



    pnl.printPanel(panel2);

    while (true) {

        Tkey = kbd.getKEY();
        switch (Tkey.Key) {
                .F5 => {
                    term.onMouse();
                },
                .F6 => {
                    term.offMouse();
                },
                .F11 => {
                    std.debug.print("F11 \n\r",.{});
                },
                .altA => {
                    std.debug.print("Key .alt: {s}\n\r",.{kbd.str(Tkey.Key)});
                },
                .ctrlA => {
                    std.debug.print("Key .ctrl: {s}\n\r",.{kbd.str(Tkey.Key)});
                },
                .char => {

                    std.debug.print("Key .char: {s}\n\r",.{Tkey.Char});
                },
                .mouse => {
                    try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.kbd.mouse)});
                    try stdout.writer().print("X :{d}\n\r", .{term.MouseInfo.x});
                    try stdout.writer().print("Y :{d}\n\r", .{term.MouseInfo.y});
                    switch (term.MouseInfo.action) {
                        term.MouseAction.maPressed => try stdout.writer().print("Button-Pressed\n\r",.{}),
                        term.MouseAction.maReleased => try stdout.writer().print("Button-Released\n\r",.{}),
                        else => {}
                    }
                    switch (term.MouseInfo.button) {
                        term.MouseButton.mbLeft => try stdout.writer().print("Button-mbLeft\n\r",.{}),
                        term.MouseButton.mbMiddle => try stdout.writer().print("Button-mbMiddle\n\r",.{}),
                        term.MouseButton.mbRight => try stdout.writer().print("Button-Right\n\r",.{}),
                        else => {}
                    }
                    switch (term.MouseInfo.scrollDir) {
                        term.ScrollDirection.msUp => try stdout.writer().print("Button-Scroll up\n\r",.{}),
                        term.ScrollDirection.msDown => try stdout.writer().print("Button-Scroll Down\n\r",.{}),
                        else => {}
                    }
                },
                else => {
                    std.debug.print("?? {}",.{Tkey.Key});
                },
            }

        if (Tkey.Key == kbd.F3) break;

    }

    pnl.rstPanel(panel2,panel);

    Tkey = kbd.getKEY();
    switch (Tkey.Key) {
            else => {},
        }

    pnl.printPanel(panel2);
    stockMenu_2();
    for (rcd_Menu.items) |xMENU| {
            panel2.menu.append(xMENU) catch unreachable ;
        }


    var nitem = mnu.ioMenu(panel2,panel2.menu.items[0],0);
    panel2.menu.items[0].selMenu = nitem;
    std.debug.print("n°item {}",.{panel2.menu.items[0].selMenu});

    Tkey = kbd.getKEY();
    switch (Tkey.Key) {
            else => {},
        }


    try stdout.writer().print("Bye bye\n\r", .{});
}