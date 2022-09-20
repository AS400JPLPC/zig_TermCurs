const std = @import("std");
const output =std.io.getStdOut();


// attribut standard
pub const ZONATRB = struct {
    styled      : [4]i32,
    backgr      : BackgroundColor,
    backBright  : bool,
    foregr      : ForegroundColor,
    foreBright  : bool,
};



// def. standard style
pub const  Style = enum (u8)  {
    notstyle = 0,      // not styled
    styleBright = 1,   // bright text
    styleDim,          // dim text
    styleItalic,       // italic (or reverse on terminals not supporting)
    styleUnderscore,   // underscored text
    styleBlink,        // blinking/bold text
    styleBlinkRapid,   // rapid blinking/bold text (not widely supported)
    styleReverse,      // reverse
    styleHidden,       // hidden text
    styleStrikethrough // strikethrough
};

// def standard color
pub const  ForegroundColor = enum (u8) {// terminal's foreground colors
    fgBlack = 30,         // black
    fgRed,                // red
    fgGreen,              // green
    fgYellow,             // yellow
    fgBlue,               // blue
    fgMagenta,            // magenta
    fgCyan,               // cyan
    fgWhite,              // white
    fgDefault             // default terminal foreground color
};

pub const  BackgroundColor = enum (u8)  { // terminal's background colors
    bgBlack = 40,         // black
    bgRed,                // red
    bgGreen,              // green
    bgYellow,             // yellow
    bgBlue,               // blue
    bgMagenta,            // magenta
    bgCyan,               // cyan
    bgWhite,              // white
    bgDefault             // default terminal background color
};

pub fn resetStyle() void {
    // Reset the terminal style.
    output.writer().print("\x1b[0m", .{}) catch {return;} ;

}

// Sets the terminal style.
pub fn setStyle(style:[4]i32 ) void {
    for (style) |v| {
        if (v != 0) {
         output.writer().print("\x1b[{d}m", .{v}) catch {return;} ;
        }
    }
}

// Sets the terminal's foreground color.
pub fn  setForegroundColor(attribut : ZONATRB) void {
    output.writer().print("\x1b[{d}m", .{@enumToInt(attribut.foregr)}) catch {return;} ;
}

// Sets the terminal's Background color.
pub fn  setBackgroundColor(attribut : ZONATRB) void {
    output.writer().print("\x1b[{d}m", .{@enumToInt(attribut.backgr)})  catch {return;} ;
}

// write text and attribut
pub fn writeStyled(text: []const u8 , attribut : ZONATRB ) void {
    setForegroundColor(attribut);
    setBackgroundColor(attribut);
    setStyle(attribut.styled);
    output.writer().print("{s}", .{text}) catch {return;} ;
    resetStyle();
}
