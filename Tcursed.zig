const std = @import("std");
const utf = @import("std").unicode;
const utl = @import("utils");
const os = std.os;
const io = std.io;

const term = @import("cursed");
const assert = std.debug.assert;


const ArenaAllocator = std.heap.ArenaAllocator;
const zig_string = @import("zig_string");
const String = zig_string.String;

fn concat( a: []const u8, b: []const u8) ![]u8 {
    const allocator = std.heap.page_allocator;
    const result = try allocator.alloc(u8, a.len + b.len);
    std.mem.copy(u8, result, a);
    std.mem.copy(u8, result[a.len..], b);
    return result;
}

fn charToConst (vZone:[4]u8 , i: usize) ![]const u8 {
    var string : []const u8 ="";
    switch( i ){
        1 => string = vZone[0..1] ,
        2 => string = vZone[0..2] ,
        3 => string = vZone[0..3] ,
        4 => string = vZone[0..4] ,
        else => string = "",
    }
    return string;

}



pub fn main() !void {
    const stdout = io.getStdOut();
    var arena = ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var myStr = String.init(&arena.allocator());
    defer myStr.deinit();

    try myStr.concat("jpélé种通用的编程语言和工具链");

    //var str : [] u8  = undefined;
    var zone : [4]   u8 = undefined;
    const ArrayList = std.ArrayList;
    const test_allocator = std.testing.allocator;
    var list = ArrayList(u21).init(test_allocator);

    var zoned:[] const u8 = "";

    var raw_term =  try term.enableRawMode();
    defer raw_term.disableRawMode() catch {};

    try stdout.writer().print("Press Ctrl-q to exit... crtl-c clear\n\r", .{});
    try raw_term.flushMode();

    term.offMouse();
    var init_saisie: bool = true;
    while (true) {
        try raw_term.flushMode();
        switch (try term.getKey()) {
            .key => |k| switch (k) {
                .fun => |c| switch (c) {
                    2 =>
                        {
                                term.onMouse();
                        },
                    3 =>
                        {
                                term.offMouse();
                        },
                    else => try stdout.writer().print("Key fun: {d}\n\r", .{c})
                },
                .alt => |c| switch (c) {
                    'a' =>
                        {
                                try stdout.writer().print("Key alt(a): coucou \n\r", .{});
                        },
                    'w' =>
                        {
                                defer list.deinit();
                                list = ArrayList(u21).init(test_allocator);
                                myStr.clear();
                                zoned ="";

                        },
                    else => try stdout.writer().print("Key alt: {u}\n\r", .{c})
                },
                // char can have more than 1 u8, because of unicode
                .char => |c| switch (c) {
                    else => {
                        var string : []const u8 ="";
                        if (init_saisie == true ) {
                            // StringIterator

                            var iter = myStr.iterator();
                            while (iter.next()) |ch| {
                                zone = [_]u8{0} ** 4;
                                var x =utf.utf8Decode(ch) catch unreachable;
                                try list.append(@as(u21,x));

                                var u = utf.utf8Encode(x,&zone) catch unreachable;
                                string = charToConst(zone,u) catch unreachable;
                                zoned = try concat(zoned,string);
                            }



                        }
                        init_saisie = false;
                        zone = [_]u8{0} ** 4;
                        var i = utf.utf8Encode(c,&zone) catch unreachable;
                        string = charToConst(zone,i)  catch unreachable;
                        try myStr.concat(string);
                        try list.append(c);

                        zoned = "";
                        for (list.items) | z | {
                            zone = [_]u8{0} ** 4;
                            i = utf.utf8Encode(z,&zone) catch unreachable;
                            string = charToConst(zone,i)  catch unreachable;
                            zoned = try concat(zoned,string);

                        }

                        try stdout.writer().print("\n\r zoned len => {any}  mysStr len => {any} capacity {any} {s} \n", .{zoned.len,myStr.len() ,myStr.capacity(), myStr.str()});

                        //var pos : usize = 0;
                        //if (myStr.find("a") != null) {
                        //    pos = myStr.find("a").?  ;

                        //std.debug.print("\n\r pos @ {any}\n",.{pos});
                        //pos = myStr.findPos(pos+1,string).?  ;
                        //std.debug.print("\n\r pos @ {d}\n",.{pos});
                        //std.debug.print("\n\r pop @{s}\n",.{myStr.pop()});
                        //}
                        //myStr.normalize(5);
                        //std.debug.print("\n\r normalze 5  str @ {s}\n",.{myStr.str()});
                        //try stdout.writer().print("\n\r mysStr len => {any} capacity {any} {s} \n", .{myStr.len() ,myStr.capacity(), myStr.str()});
                        //try myStr.StringTo(zoned);
                        //myStr.clear();

                        //var optional_str_1 : ?[]u8 = myStr.toOwned() catch unreachable;
                        //var str1: []const u8 = optional_str_1 orelse "";
                        //std.debug.print("\n\rstr1={s}<  len{d}  \n", .{str1, str1.len});
                        //myStr.normalize(4);
                        //std.debug.print("\n\r normalze 4  str @ {s}\n",.{myStr.str()});
                        try myStr.toUpperStr();
                        var wl : usize =0;
                        var zz = try myStr.clone();
                        //zz.normalize(4);
                        string = zz.str();
                        var iterx = utl.iteratS.iterator(string);
                        while (iterx.next()) |_| {
                            //try stdout.writer().print("\n\r iter outils => {s}\n\r",.{ch});
                            wl += 1 ;
                        }
                        try stdout.writer().print("\n\r zoned len => {any} : {d}  mysStr len => {any} capacity {any} {s} \n\r", .{zoned.len, wl, myStr.len() ,myStr.capacity(), myStr.str()});

                        try myStr.toLowerStr();
                            term.titleTerm("TEST 5250");
                            //term.resizeTerm(10,132) ;
                    }
                },
                .ctrl => |c| switch (c) {
                    'q' => break,
                    'c' =>
                        {
                            term.cls();
                            term.gotoXY(1,10);
                            try stdout.writer().print("Press Ctrl-q to exit... crtl-c clear\n\r", .{});
                        },
                    'w' =>
                        {
                        if (term.MouseInfo.x > 0){
                            term.gotoXY(term.MouseInfo.x,term.MouseInfo.y);
                            term.getCursor();
                            try stdout.writer().print("term X:{d}  Y:{d}\n\r", .{term.posCurs.x, term.posCurs.y});
                            }
                        },
                    's' => term.show(),
                    'h' => term.hide(),

                    else => try stdout.writer().print("Key ctrl: {u}\n\r", .{c})
                },
                .pageup   =>  try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.KEY.pageup)}),
                .pagedown =>  try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.KEY.pagedown)}),
                .up =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.KEY.up)});
                    // term.gotoUp(1);
                },
                .down =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.KEY.down)});
                    // term.gotoDown(1);
                },
                .left =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.KEY.left)});
                    // term.gotoLeft(1);
                },
                .right =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.KEY.right)});
                    // term.gotoRight(1);
                },
                .ins =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.KEY.ins)});
                    // term.gotoRight(1);
                },
                .delete =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.KEY.delete)});
                    // term.gotoRight(1);
                },
                .home =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.KEY.home)});
                    // term.gotoRight(1);
                },
                .end =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.KEY.end)});
                    // term.gotoRight(1);
                },
                .tab =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.KEY.tab)});
                    // term.gotoRight(1);
                },
                .backspace =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.KEY.backspace)});
                    // term.gotoRight(1);
                },
                .enter =>  {
                    try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.KEY.enter)});
                    // term.gotoRight(1);
                },
                .mouse => {
                    try stdout.writer().print("Key: {s}\n\r", .{@tagName(term.KEY.mouse)});
                    try stdout.writer().print("X :{d}\n\r", .{term.MouseInfo.x});
                    try stdout.writer().print("Y :{d}\n\r", .{term.MouseInfo.y});
                    switch (term.MouseInfo.action) {
                        term.MouseAction.maPressed => try stdout.writer().print("Button-Pressed\n\r",.{}),
                        term.MouseAction.maReleased => try stdout.writer().print("Button-Released\n\r",.{}),
                        else => {}
                    }
                    switch (term.MouseInfo.button) {
                        term.MouseButton.mbLeft => try stdout.writer().print("Button-mbLeft\n\r",.{}),
                        term.MouseButton.mbMiddle => try stdout.writer().print("Button-mbMiddle\n\r",.{}),
                        term.MouseButton.mbRight => try stdout.writer().print("Button-Right\n\r",.{}),
                        else => {}
                    }
                    switch (term.MouseInfo.scrollDir) {
                        term.ScrollDirection.msUp => try stdout.writer().print("Button-Scroll up\n\r",.{}),
                        term.ScrollDirection.msDown => try stdout.writer().print("Button-Scroll Down\n\r",.{}),
                        else => {}
                    }
                },
                else => continue
            },
            // ex. Pause Imp ...  term not supported yet
            else => {}
        }
    }

    try stdout.writer().print("Bye bye\n\r", .{});
}