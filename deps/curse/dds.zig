

    // def. standard style
    pub const  Style = enum (u8)  {
        notStyle = 0,      // not styled
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

    // attribut standard
    pub const ZONATRB = struct {
        styled      : [4]u32,
        backgr      : BackgroundColor,
        foregr      : ForegroundColor,

    };


    pub const CADRE = enum {
        line0,
        line1,
        line2
    };

    var name: []const u8 = undefined ;
    var posx: usize = undefined ;
    var posy: usize = undefined ;
    var attribut:ZONATRB = undefined;

    var title: bool = undefined ;

    var crtl: bool = undefined;
    var actif: bool = undefined ;

    var lines: usize = undefined ;
    var cols:  usize = undefined ;
    var index: usize = undefined ;

    var text: []const u8 = undefined ;