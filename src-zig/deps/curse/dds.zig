
const std = @import("std");


//en sortie de programme ou de session
var arenaField = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  //defer arena.deinit();
pub var  allocatorField = arenaField.allocator();
pub fn deinitField() void {
    arenaField.deinit();
    arenaField = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    allocatorField = arenaField.allocator();
}


//en sortie de programme ou de session
var arenaGrid= std.heap.ArenaAllocator.init(std.heap.page_allocator);
  //defer arena.deinit();
pub var  allocatorGrid = arenaGrid.allocator();
pub fn deinitGrid() void {
    arenaGrid.deinit();
    arenaGrid = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    allocatorGrid = arenaGrid.allocator();
}


// display utilisatation forms 
var arenaPrint = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  //defer arena.deinit();
var  allocatorPrint = arenaPrint.allocator();
pub fn deinitPrint() void {
    arenaPrint.deinit();
    arenaPrint = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    allocatorPrint = arenaPrint.allocator();
}








pub const  Style = enum (u8)  {
    notStyle = 0,      // not styled
    styleBold = 1,     // bold text
    styleDim,          // dim text
    styleItalic,       // italic (or reverse on terminals not supporting)
    styleUnderscore,   // underscored text
    styleBlink,        // blinking/bold text
    styleBlinkRapid,   // rapid blinking/bold text (not widely supported)
    styleReverse,      // reverse
    styleHidden,       // hidden text
    styleCrossed       // strikethrough
};


pub const  typeCursor = enum (u8)  {
    cDefault,
    cBlink,
    cSteady,
    cBlinkUnderline,
    cSteadyUnderline,
    cBlinkBar,
    cSteadyBar
};

// def standard color fgd dull color  fg higth color
pub const  ForegroundColor = enum (u8) {// terminal's foreground colors
    fgdBlack = 30,         // black
    fgdRed ,               // red
    fgdGreen,              // green
    fgdYellow,             // yellow
    fgdBlue,               // blue
    fgdMagenta,            // magenta
    fgdCyan,               // cyan
    fgdWhite,              // white
    fgBlack = 90,        // black
    fgRed ,               // red
    fgGreen,              // green
    fgYellow,             // yellow
    fgBlue,               // blue
    fgMagenta,            // magenta
    fgCyan,               // cyan
    fgWhite      ,        // white
};

pub const  BackgroundColor = enum (u8)  { // terminal's background colors
    bgBlack = 40,         // black
    bgRed ,               // red
    bgGreen,              // green
    bgYellow,             // yellow
    bgBlue,               // blue
    bgMagenta,            // magenta
    bgCyan  = 106 ,       // cyan
    bgWhite = 47,         // white
};



// attribut standard
pub const ZONATRB = struct {
    styled      : [4]u32,
    backgr      : BackgroundColor,
    foregr      : ForegroundColor

};


pub const CADRE = enum  {
    line0,
    line1,
    line2
};


pub const LINE = enum {
    line1 ,
    line2
};

pub const MNUVH = enum {
vertical ,
horizontal
};


pub const REFTYP = enum {
    TEXT_FREE,            // Free
    TEXT_FULL,            // Letter Digit Char-special
    ALPHA,                // Letter
    ALPHA_UPPER,          // Letter
    ALPHA_NUMERIC,        // Letter Digit espace -
    ALPHA_NUMERIC_UPPER,  // Letter Digit espace -
    PASSWORD,             // Letter Digit and normaliz char-special
    YES_NO,               // 'y' or 'Y' / 'o' or 'O'
    UDIGIT,               // Digit unsigned
    DIGIT,                // Digit signed 
    UDECIMAL,             // Decimal unsigned
    DECIMAL,              // Decimal signed
    DATE_ISO,             // YYYY/MM/DD
    DATE_FR,              // DD/MM/YYYY
    DATE_US,              // MM/DD/YYYY
    TELEPHONE,            // (+123) 6 00 01 00 02 
    MAIL_ISO,             // normalize regex
    SWITCH,               // CTRUE CFALSE
    FUNC,                 // call Function
    FCALL                 // call program
};


pub const ALIGNS = enum {
    left ,
    rigth
    };


pub const CMP = enum {
    LT,
    EQ,
    GT
};


// display grid
pub const CTRUE  = "✔";
pub const CFALSE = " ";
// input   field
pub const STRUE  = "✔";
pub const SFALSE = "◉";