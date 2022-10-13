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

    var i : usize = 1 ;
    while ( i <= 40) : ( i += 1) {
        output.writer().print("12345678901234567890123456789012345678901234567890\n\r", .{}) catch {return;} ;
    }

    var panel = pnl.initPanel("PANEL0",
                  5, 3, // x,y
                  10,   // lines
                  20,   // cols
                  pnl.AtrPanel,     // attribut Panel
                  dds.CADRE.line1,  // type de cadre
                  frm.AtrFrame,    // atribut BOX
                  "TITLE-Pnl0",
                  frm.AtrTitle);
    for (rcd_label.items) |xLABEL| {
        panel.label.append(xLABEL) catch {return;} ;
    }


    var panel2 = pnl.initPanel("PANEL2",
                  15, 30, // x,y
                  10,   // lines
                  20,   // cols
                  pnl.AtrPanel,     // attribut Panel
                  dds.CADRE.line1,  // type de cadre
                  frm.AtrFrame,    // atribut BOX
                  "TITLE-Pnl0",
                  frm.AtrTitle);
    for (rcd_label.items) |xLABEL| {
        panel2.label.append(xLABEL) catch {return;} ;
    }

    pnl.printPanel(panel);
    switch (try term.getKey()) {
        else => {}
        }

    pnl.clsPanel(panel);

    pnl.printPanel(panel2);

    switch (try term.getKey()) {
        else => {}
        }


    try stdout.writer().print("Bye bye\n\r", .{});
}