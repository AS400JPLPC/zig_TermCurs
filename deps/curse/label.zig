const std = @import("std");
const stl= @import("style.zig");


// ---- LABEL-------------------
// define attribut default LABEL
pub const defAtrLabel : stl.ZONATRB = .{
    .styled=[_]i32{@enumToInt(stl.Style.styleBright),
                   @enumToInt(stl.Style.styleItalic),
                   @enumToInt(stl.Style.notstyle),
                   @enumToInt(stl.Style.notstyle)},
    .backgr = stl.BackgroundColor.bgBlack,
    .backBright = false,
    .foregr = stl.ForegroundColor.fgGreen,
    .foreBright = true
};

// define attribut default TITLE
pub const defAtrTitle : stl.ZONATRB = .{
    .styled=[_]i32{@enumToInt(stl.Style.styleBright),
                   @enumToInt(stl.Style.notstyle),
                   @enumToInt(stl.Style.notstyle),
                   @enumToInt(stl.Style.notstyle)},
    .backgr = stl.BackgroundColor.bgBlack,
    .backBright = false,
    .foregr = stl.ForegroundColor.fgCyan,
    .foreBright = true
};


// empty shell Label
pub const LABEL = struct {
    name: []const u8 ,
    posx: usize ,
    posy: usize ,
    attribut:stl.ZONATRB,
    text: []const u8  ,
    title: bool ,
    actif: bool
};



pub fn flabel(name: []const u8,posx:usize,posy:usize,
              text: []const u8,
              attribut : stl.ZONATRB,
              actif:bool) LABEL {

        const xlabel = LABEL{
            .name = name,
            .posx = posx ,
            .posy = posy,
            .attribut = attribut,
            .text = text,
            .title = false,
            .actif = actif,
        };

        return xlabel;
}
pub fn ftile(name: []const u8,posx:usize,posy:usize,
              text: []const u8,
              attribut : stl.ZONATRB,
              actif:bool) LABEL {

        const xlabel = LABEL{
            .name = name,
            .posx = posx ,
            .posy = posy,
            .attribut = attribut,
            .text = text,
            .title = true,
            .actif = actif,
        };

        return xlabel;
}

