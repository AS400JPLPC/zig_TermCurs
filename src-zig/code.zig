const std = @import("std");
const stl = @import("style");
const lbl = @import("label");


const output =std.io.getStdOut();



// procedure de définition de label doit être généé automatiquement
const allocator = std.heap.page_allocator;
pub var rcd_label = std.ArrayList(lbl.LABEL).init(allocator);

pub fn stockLabel() void{

    rcd_label.append(lbl.flabel ("Name",1,1,
                        "Jean-Pierre",
                        lbl.defAtrLabel,
                        true,
        ))catch {return;} ;
    //example: option specific
    rcd_label.items[0].attribut.styled[2] = @enumToInt(stl.Style.styleReverse);
    rcd_label.items[0].attribut.styled[3] = @enumToInt(stl.Style.styleBlink);


    rcd_label.append(lbl.flabel ("Name",1,1,
                        "Marie",
                        lbl.defAtrLabel,
                        true,
        ))catch {return;} ;
}




pub fn main() !void {

    defer rcd_label.deinit();

    stockLabel();

    var index_label: ?usize = null;
    for (rcd_label.items) | xLABEL, idx| {
        if (std.mem.eql(u8, xLABEL.text, "Marie")) {
            index_label = idx;
        }
    }

    if (index_label) |i| {
    std.debug.print("LABEL Name: {s}  x:{d} y:{d} \n sytled:{d} \n backgr:{d} \n foregr:{d} \n text:{s}\n  title:{} \n actif:{}\n", .{
    rcd_label.items[i].name,    rcd_label.items[i].posx,    rcd_label.items[i].posy,
    rcd_label.items[i].attribut.styled,
    rcd_label.items[i].attribut.backgr,
    rcd_label.items[i].attribut.foregr,
    rcd_label.items[i].text,
    rcd_label.items[i].title,   rcd_label.items[i].actif
    });
    } else {
    std.debug.print("LABEL not found\n", .{});
    }

    stl.writeStyled("bonjour \n",lbl.defAtrLabel );

    stl.writeStyled("------------------ \n",lbl.defAtrLabel );
    for (rcd_label.items) |xLABEL| {
          stl.writeStyled(xLABEL.text,xLABEL.attribut);
          //only fo test
          output.writer().print("\n", .{}) catch {return;} ;
          stl.writeStyled("------------------ \n",lbl.defAtrLabel );
        }

}