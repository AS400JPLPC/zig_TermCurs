test "testforms" {
  term.enableRawMode();
  defer term.disableRawMode() ;

  const xlabel = lbl.newLabel("Name- 1",1,1,
                      "Jean-Pierre",
                      lbl.AtrLabel );
  //term.writeStyled(xlabel.text,xlabel.attribut);

  const xbutton = btn.newButton(
                      kbd.str(kbd.F1),
                      true, // show
                      btn.AtrButton,
                      "Help Jean-Pierre",
                      btn.AtrTitle,
                      true  ); // check

  var panel = pnl.initPanel("panel-0", 1 , 1 ,30 ,50, pnl.AtrPanel,dds.CADRE.line1,frm.AtrFrame,"TITRE",frm.AtrTitle);

  panel.label.append(xlabel) catch {return;} ;
  panel.button.append(xbutton) catch {return;} ;
  pnl.printPanel(panel);

  panel.grid.append(grd.initGrid(
                "Grid01",
                20, 2,
                7,
                grd.gridStyle,
                grd.AtrGrid,
                grd.AtrTitle,
                grd.AtrCell,
                dds.CADRE.line1,
                )) catch unreachable ;

  var Cell = std.ArrayList(grd.CELL).init(allocator);
  Cell.append(grd.newCell("ID",3,dds.REFTYP.DIGIT,dds.ForegroundColor.fgGreen)) catch unreachable ;
  Cell.append(grd.newCell("Name",15,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgYellow)) catch unreachable ;
  Cell.append(grd.newCell("animal",20,dds.REFTYP.TEXT_FREE,dds.ForegroundColor.fgWhite)) catch unreachable ;
  //Cell.append(grd.newCell("prix",8,dds.REFTYP.DECIMAL,dds.ForegroundColor.fgWhite)) catch unreachable ;
  // setCellEditCar(g_prix,"€")
  Cell.append(grd.newCell("HS",1,dds.REFTYP.SWITCH,dds.ForegroundColor.fgWhite)) catch unreachable ;
  grd.setHeaders(&panel.grid.items[0], Cell) catch unreachable ;
  grd.printGridHeader(&panel.grid.items[0]);
  //std.debug.print("len haeder:{}",.{grd.getLenHeaders(&panel.grid.items[0])});
  
  grd.addRows(&panel.grid.items[0] , &.{"01", "Adam","Aigle","1"});
  grd.addRows(&panel.grid.items[0] , &.{"02", "eve", "poisson","0"});
  
  grd.addRows(&panel.grid.items[0] , &.{"03", "Rouge","Aigle","0"});
  grd.addRows(&panel.grid.items[0] , &.{"04", "Bleu", "poisson","0"});
  grd.addRows(&panel.grid.items[0] , &.{"05", "Bleu5", "poisson","0"});
  grd.addRows(&panel.grid.items[0] , &.{"06", "Bleu6", "poisson","0"});
  grd.addRows(&panel.grid.items[0] , &.{"07", "Bleu7", "poisson","0"});
  grd.addRows(&panel.grid.items[0] , &.{"08", "Bleu8", "poisson","0"});
  grd.addRows(&panel.grid.items[0] , &.{"09", "Bleu9", "poisson","0"});
  grd.addRows(&panel.grid.items[0] , &.{"10", "Bleu10", "poisson","0"});
  grd.addRows(&panel.grid.items[0] , &.{"11", "Bleu11", "poisson","0"});

  var Gkey :grd.GridSelect = undefined ;

  Gkey =grd.ioGrid(&panel.grid.items[0]);
  std.debug.print("key:{} \r\n",.{Gkey.Key});
  if ( Gkey.Key != kbd.esc ) std.debug.print("buf:{s} \r\n",.{Gkey.Buf.items[1]});

}
