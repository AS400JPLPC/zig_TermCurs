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

    rcd_label.append(lbl.newLabel("Name-1",1,1,
                        "Jean-Pierre",
                        lbl.AtrLabel,
        )) catch {return;} ;
    //example: option specific
    rcd_label.items[0].attribut.styled[2] = @enumToInt(dds.Style.styleReverse);
    rcd_label.items[0].attribut.styled[3] = @enumToInt(dds.Style.styleBlink);


    rcd_label.append(lbl.newLabel("Name-2",2,1,
                        "Marie",
                        lbl.AtrLabel,
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

    if (index_label) |i| {
    std.debug.print("LABEL Name: {s}  x:{d} y:{d} \n\r sytled:{d} \n\r backgr:{d} \n\r foregr:{d} \n\r text:{s}\n\r  title:{} \n\r actif:{}\n\r", .{
    rcd_label.items[i].name,    rcd_label.items[i].posx,    rcd_label.items[i].posy,
    rcd_label.items[i].attribut.styled,
    rcd_label.items[i].attribut.backgr,
    rcd_label.items[i].attribut.foregr,
    rcd_label.items[i].text,
    rcd_label.items[i].title,   rcd_label.items[i].actif
    });
    } else {
    std.debug.print("LABEL not found\n\r", .{});
    }

    term.writeStyled("bonjour \n\r",lbl.AtrLabel );

    term.writeStyled("------------------ \n",lbl.AtrLabel );
    for (rcd_label.items) |xLABEL| {
          term.writeStyled(xLABEL.text,xLABEL.attribut);
          //only fo test
          output.writer().print("\n\r", .{}) catch {return;} ;
          term.writeStyled("------------------ \n\r",lbl.AtrLabel );
        }

    var panel = pnl.initPanel("PANEL0",
                  10, 20, // x,y
                  10,   // lines
                  20,   // cols
                  pnl.AtrPanel,     // attribut Panel
                  dds.CADRE.line1,  // type de cadre
                  frm.AtrFrame,    // atribut BOX
                  "TITLE",
                  frm.AtrTitle);
    for (rcd_label.items) |xLABEL| {
        panel.label.append(xLABEL) catch {return;} ;
    }

    pnl.printPanel(panel);

    term.flushIO();
    switch (try term.getKey()) {
        else => {}
        }
    try stdout.writer().print("Bye bye\n\r", .{});
}