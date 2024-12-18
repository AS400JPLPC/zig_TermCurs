pub    const OBJTYPE = enum { PANEL, SFLD ,COMBO , MENU };
    
pub    const DEFOBJET = struct {
        name:  []const u8,
        index: usize,
        objtype: OBJTYPE,
    };
pub    const DEFFIELD = struct {
        panel: []const u8,
        npnl: usize,
        field: []const u8,
        index: usize,
        func:  []const u8,
        fgrid: []const u8,
        task:  []const u8,
        call:  []const u8,
    };

pub    const DEFLABEL = struct {
        panel: []const u8,
        npnl: usize,
        label: []const u8,
        index: usize,
    };

pub    const DEFLINEH = struct {
        panel: []const u8,
        npnl: usize,
        line: []const u8,
        index: usize,
    };

pub    const DEFLINEV = struct {
        panel: []const u8,
        npnl: usize,
        line: []const u8,
        index: usize,
    };
    
pub    const DEFBUTTON = struct {
        panel: []const u8,
        npnl: usize,    
        button: []const u8,
        index: usize,
        title:   []const u8,
        
    };    
