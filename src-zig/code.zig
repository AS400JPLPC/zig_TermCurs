const std = @import("std");
const term = @import("cursed");

const dds = @import("dds");
const frm = @import("forms").frm;
const lbl = @import("forms").lbl;
const pnl = @import("forms").pnl;

const output =std.io.getStdOut();



// procedure de définition de label doit être généé automatiquement
const allocator = std.heap.page_allocator;
pub var rcd_label = std.ArrayList(lbl.LABEL).init(allocator);

pub fn stockLabel() void{

    rcd_label.append(lbl.newLabel("Name-1",1,2,
                        "Jean-Pierre",
                        lbl.AtrLabel
        )) catch {return;} ;
    //example: option specific
    rcd_label.items[0].attribut.styled[2] = @enumToInt(dds.Style.styleReverse);
    rcd_label.items[0].attribut.styled[3] = @enumToInt(dds.Style.styleBlink);


    rcd_label.append(lbl.newLabel("Name-2",2,2,
                        "Marie",
                        lbl.AtrLabel
        )) catch {return;} ;
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

    // for control
    const AtrPanelx : dds.ZONATRB = .{
      .styled=[_]u32{@enumToInt(dds.Style.styleDim),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle),
                    @enumToInt(dds.Style.notStyle)},
      .backgr = dds.BackgroundColor.bgCyan,
      .foregr = dds.ForegroundColor.fgWhite
    };


    var panel = pnl.initPanel("PANEL",
                  1, 1, // x,y
                  30,   // lines
                  132,   // cols
                  AtrPanelx,     // attribut Panel
                  dds.CADRE.line1,  // type de cadre
                  frm.AtrFrame,    // atribut BOX
                  "TITLE",
                  frm.AtrTitle);
    for (rcd_label.items) |xLABEL| {
        panel.label.append(xLABEL) catch {return;} ;
    }


    var panel2 = pnl.initPanel("PANEL2",
                  10,50, // x,y
                  10,   // lines
                  20,   // cols
                  pnl.AtrPanel,     // attribut Panel
                  dds.CADRE.line1,  // type de cadre
                  frm.AtrFrame,    // atribut BOX
                  "PANEL2",
                  frm.AtrTitle);
    for (rcd_label.items) |xLABEL| {
        panel2.label.append(xLABEL) catch {return;} ;
    }


    term.offMouse();

    pnl.printPanel(panel);
    // get f1..f24 Alt.. crtl..
    while (true) {
        switch (try term.getFunc()) {
                .key  => break ,
                .none => continue ,
            }
    }



    pnl.printPanel(panel2);

    while (true) {
        switch (try term.getFunc()) {
                .key  => break ,
                .none => continue ,
            }
    }

    pnl.rstPanel(panel,panel);

    switch (try term.getKey()) {
            else => {},
        }


    try stdout.writer().print("Bye bye\n\r", .{});
}