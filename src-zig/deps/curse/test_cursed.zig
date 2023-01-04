
test "testcursed" {
//pub fn main() !void {
    const defAtrLabel : dds.ZONATRB = .{
    .styled=[_]u32{@enumToInt(dds.Style.styleBright),
                   @enumToInt(dds.Style.styleItalic),
                   @enumToInt(dds.Style.notStyle),
                   @enumToInt(dds.Style.notStyle)},
    .backgr = dds.BackgroundColor.bgBlack,
    .foregr = dds.ForegroundColor.fgGreen,
    };
    enableRawMode() ;
    defer disableRawMode() ;

    writeStyled("bonjour \n\r",defAtrLabel );
    writeStyled("appuyez sur une touche du clavier:\n\r",defAtrLabel );
    onMouse();
    flushIO();

    while (true ) {
        const Tkey = kbd.getKEY();
    //std.debug.print("F.. {} \n\r",.{Tkey.Key});
    
        switch (Tkey.Key) {
                    .F16    => std.debug.print("F.. {} \n\r",.{Tkey.Key}),
                    .altB   => std.debug.print("Alt. {} \n\r",.{Tkey.Key}),
                    .ctrlG  => std.debug.print("Ctrl. {} \n\r",.{Tkey.Key}),
                    .mouse  => {
                        std.debug.print("Ctrl. {} \n\r",.{Tkey.Key});
                        std.debug.print("Key: {s}\n\r", .{@tagName(kbd.mouse)});
                        std.debug.print("X :{d}\n\r", .{MouseInfo.x});
                        std.debug.print("Y :{d}\n\r", .{MouseInfo.y});
                    switch (MouseInfo.action) {
                        MouseAction.maPressed => std.debug.print("Button-Pressed\n\r",.{}),
                        MouseAction.maReleased => std.debug.print("Button-Released\n\r",.{}),
                        else => {}
                    }
                    switch (MouseInfo.button) {
                        MouseButton.mbLeft => std.debug.print("Button-mbLeft\n\r",.{}),
                        MouseButton.mbMiddle => std.debug.print("Button-mbMiddle\n\r",.{}),
                        MouseButton.mbRight => std.debug.print("Button-Right\n\r",.{}),
                        else => {}
                    }
                    switch (MouseInfo.scrollDir) {
                        ScrollDirection.msUp => std.debug.print("Button-Scroll up\n\r",.{}),
                        ScrollDirection.msDown => std.debug.print("Button-Scroll Down\n\r",.{}),
                        else => {}
                    }
                    },
                    .char  =>  std.debug.print("Char. {s}\n\r",.{Tkey.Char }),


                    else => {},
                    //else    => std.debug.print("F.. {} \n\r",.{Tkey.Key}),
                }

        if (Tkey.Key == kbd.F20) break;
    }

}