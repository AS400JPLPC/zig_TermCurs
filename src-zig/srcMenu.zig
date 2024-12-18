///-----------------------
/// prog mdlGrid 
///-----------------------

const std = @import("std");

/// terminal Fonction
const term = @import("cursed");
// keyboard
const kbd = @import("cursed").kbd;
// menu
const mnu = @import("menu").mnu;
// tools utility
const utl = @import("utils");

// src def
const def = @import("srcdef");


// REFERENCE CONTROL
const deb_Log = @import("logsrc").openFile;   // open  file
const del_Log = @import("logsrc").deleteFile; // delete file
const end_Log = @import("logsrc").closeFile;  // close file
const new_Line = @import("logsrc").newLine;   // new line
const pref     = @import("logsrc").scoped;    // print file 

const allocator = std.heap.page_allocator;

var NOBJET = std.ArrayList(def.DEFOBJET).init(allocator);


var numMenu : usize = undefined;


const e0 = "─┬─";

const e1 = " │ ";

const e2 = "─┼─";

const e9 = "─┴─";
// define attribut default LABEL
const atrText : term.ZONATRB = .{
            .styled=[_]u32{@intFromEnum(term.Style.styleDim),
                                        @intFromEnum(term.Style.styleItalic),
                                        @intFromEnum(term.Style.notStyle),
                                        @intFromEnum(term.Style.notStyle)},
            .backgr = term.BackgroundColor.bgBlack,
            .foregr = term.ForegroundColor.fgGreen,
};

fn strToUsize(v: []const u8) usize {
    if (v.len == 0) return 0;
    return std.fmt.parseUnsigned(u64, v, 10) catch |err| {
        @panic(@errorName(err));
    };
}

fn usizeToStr(v: usize) []const u8 {
    return std.fmt.allocPrint(utl.allocUtl, "{d}", .{v}) catch |err| {
        @panic(@errorName(err));
    };
}

fn padingRight(a: []const u8, len: usize) []const u8 {
     var b :[] const u8 = a;
     while ( b.len < len ) {
        b = std.fmt.allocPrint(    utl.allocUtl,"{s} ",.{ b}) catch unreachable;
    }
    return b;    
}

fn padingLeft(a: []const u8, len: usize) []const u8 {
     var b :[] const u8 = a;
     while ( b.len < len ) {
        b = std.fmt.allocPrint(    utl.allocUtl," {s}",.{ b}) catch unreachable;
    }
    return b;    
}


// main----------------------------------


pub fn wrtMenu( NMENU : std.ArrayList(mnu.DEFMENU ) )  void {
     

    var nopt : usize    = 0;
    
    const source = enum {
        mainMenu,
        exit
    };
    
    const MenuSource = mnu.newMenu(
        "Source",                // name
        5, 2,                    // posx, posy
        mnu.CADRE.line1,        // type line fram
        mnu.MNUVH.vertical,        // type menu vertical / horizontal
        &.{
        "MainMenu",
        "Exit",
        }
    ) ;

        
    nopt = mnu.ioMenu(MenuSource,0);        
    if (nopt == @intFromEnum(source.exit ) or nopt == 999 ) { return; }


    const file = std.fs.cwd().createFile(
        "menusrc.zig", .{ .read = true } ) catch unreachable;
    defer file.close();
    const wrt = file.writer();

    wrt.print("//----------------------\n",.{}) catch {};
    wrt.print("//---date text----------\n",.{}) catch {};
    wrt.print("//----------------------\n",.{}) catch {};
    wrt.print("\n\n\nconst std = @import(\"std\");\n",.{}) catch {};

    wrt.print("// terminal Fonction\n",.{}) catch {};
    wrt.print("const term = @import(\"cursed\");\n",.{}) catch {};

    wrt.print("\n// menu Fonction\n",.{}) catch {};
    wrt.print("const mnu = @import(\"menu\").mnu;\n",.{}) catch {};

    
    wrt.print("\nconst allocator = std.heap.page_allocator;\n",.{}) catch {};
    wrt.print("var NMENU  = std.ArrayList(mnu.DEFMENU ).init(allocator);\n",.{}) catch {};

    for( NMENU.items,0..) | m , i | {
        NOBJET.append(def.DEFOBJET {.name = m.name,.index = i, .objtype = def.OBJTYPE.MENU}) catch unreachable;
        }

    for( NOBJET.items) | m | {
    

        if (m.objtype == def.OBJTYPE.MENU)    {

            wrt.print("\n\n\n//----------------------\n",.{}) catch {};
            wrt.print("// Define Global DSPF MENU\n",.{}) catch {};
            wrt.print("//----------------------\n",.{}) catch {};
                        
            wrt.print("const x{s} = enum {{\n", 
                .{NMENU.items[m.index].name}) catch {};
            for(NMENU.items[m.index].xitems) |text| {
                wrt.print("\t\t\t{s},\n", .{text}) catch {};
            }
            wrt.print("\t\t\t}};\n\n", .{}) catch {};

            
            wrt.print("const {s} = mnu.newMenu(\n", 
                .{NMENU.items[m.index].name}) catch {};
            wrt.print("\t\t\t\"{s}\",\n", 
                .{NMENU.items[m.index].name}) catch {};
            wrt.print("\t\t\t{d}, {d},\n",
                 .{ NMENU.items[m.index].posx, NMENU.items[m.index].posy} ) catch {};
            wrt.print("\t\t\tmnu.CADRE.{s},\n", 
                .{ @tagName(NMENU.items[m.index].cadre)}) catch {};
            wrt.print("\t\t\tmnu.MNUVH.{s},\n", 
                .{ @tagName(NMENU.items[m.index].mnuvh)}) catch {};
            wrt.print("\t\t\t&.{{\n", .{}) catch {};
            for(NMENU.items[m.index].xitems) |text| {
                wrt.print("\t\t\t\"{s}\",\n", .{text}) catch {};
            }
            wrt.print("\t\t\t}}\n", .{}) catch {};
            wrt.print("\t\t\t);\n", .{}) catch {};
        }

        
    }

    
    wrt.print("\n\n\n//----------------------------------\n",.{}) catch {};
    wrt.print("// squelette\n",.{}) catch {};
    wrt.print("//----------------------------------\n\n",.{}) catch {};

    wrt.print("pub fn main() !void {{\n",.{}) catch {};
    wrt.print("// init terminal\n",.{}) catch {};
    wrt.print("term.enableRawMode();\n",.{}) catch {};
    wrt.print("defer term.disableRawMode() ;\n\n",.{}) catch {};

    wrt.print("// Initialisation\n",.{}) catch {};
    wrt.print("term.titleTerm(\"MY-TITLE\");\n\n",.{}) catch {};

    wrt.print("term.resizeTerm(44,168);\n",.{}) catch {};
    wrt.print("term.cls();\n\n",.{}) catch {};

    wrt.print("var nopt : usize = 0;\n",.{}) catch {};

    wrt.print("\twhile (true) {{\n",.{}) catch {};
    wrt.print("\tnopt = mnu.ioMenu(mnu??,nopt);\n",.{}) catch {};
    wrt.print("\t\tif (nopt == @intFromEnum(xmnu??.Exit )) break;\n\n",.{}) catch {};
    wrt.print("\t\t//--- ---\n\n",.{}) catch {};
    wrt.print("\t\t}}\n\n",.{}) catch {};
    wrt.print("}}\n\n",.{}) catch {};

}
