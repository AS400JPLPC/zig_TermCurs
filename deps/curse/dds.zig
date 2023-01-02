// def. standard style
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

// def standard color fgd dull color  fg higth color
pub const  ForegroundColor = enum (u8) {// terminal's foreground colors
    fgdBlack = 30,          // black
    fgdRed ,               // red
    fgdGreen,              // green
    fgdYellow,             // yellow
    fgdBlue,               // blue
    fgdMagenta,            // magenta
    fgdCyan,               // cyan
    fgdWhite,              // white
    fgBlack = 90,         // black
    fgRed ,               // red
    fgGreen,              // green
    fgYellow,             // yellow
    fgBlue,               // blue
    fgMagenta,            // magenta
    fgCyan,               // cyan
    fgWhite               // white
 };

pub const  BackgroundColor = enum (u8)  { // terminal's background colors
    bgBlack = 40,          // black
    fgRed,                // red
    bgGreen,              // green
    bgYellow,             // yellow
    bgBlue,               // blue
    bgMagenta,            // magenta
    bgCyan,               // cyan
    bgWhite               // white
};



// attribut standard
pub const ZONATRB = struct {
    styled      : [4]u32,
    backgr      : BackgroundColor,
    foregr      : ForegroundColor

};


pub const CADRE = enum {
    line0,
    line1,
    line2
};

pub const MNUVH = enum {
vertical ,
horizontal
};


pub const REFTYP = enum {
    TEXT_FREE,
    ALPHA,
    ALPHA_UPPER,
    ALPHA_NUMERIC,
    ALPHA_NUMERIC_UPPER,
    TEXT_FULL,
    PASSWORD,
    DIGIT,
    DIGIT_SIGNED,
    DECIMAL,
    DECIMAL_SIGNED,
    DATE_ISO,
    DATE_FR,
    DATE_US,
    TELEPHONE,
    MAIL_ISO,
    YES_NO,
    SWITCH,
    FPROC,
    FCALL
};

pub const ALIGNS = enum {
    left ,
    rigth
    };
pub const CTRUE = "✓";
pub const CFALSE = " ";