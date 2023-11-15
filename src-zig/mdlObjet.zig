const std = @import("std");
const dds = @import("dds");

/// terminal Fonction
const term = @import("cursed");
// keyboard
const kbd = @import("cursed").kbd;

// error
const msgerr = @import("forms").ErrForms;
const dsperr = @import("forms").dsperr;

// full delete for produc
const forms = @import("forms");

// frame
const frm = @import("forms").frm;
// panel
const pnl = @import("forms").pnl;
// button
const btn = @import("forms").btn;
// label
const lbl = @import("forms").lbl;
// menu
const mnu = @import("forms").mnu;
// flied
const fld = @import("forms").fld;
// line horizontal
const lnh = @import("forms").lnh;
// line vertival
const lnv = @import("forms").lnv;

// grid
const grd = @import("grid").grd;

// tools utility
const utl = @import("utils");

// tools regex
const reg = @import("match");

var numPanel: usize = undefined;

pub const ErrMain = error{
	main_append_XPANEL_invalide,
	main_run_EnumFunc_invalide,
	main_run_EnumTask_invalide,
	main_loadPanel_allocPrint_invalide,
	main_updatePanel_allocPrint_invalide,
	main_XPANEL_invalide,
};

fn strToUsize(v: []const u8) usize {
	if (v.len == 0) return 0;
	return std.fmt.parseUnsigned(u64, v, 10) catch |err| {
		@panic(@errorName(err));
	};
}

fn usizeToStr(v: usize) []const u8 {
	return std.fmt.allocPrint(dds.allocatorUtils, "{d}", .{v}) catch |err| {
		@panic(@errorName(err));
	};
}

//=================================================
// description Function
// choix work panel
pub fn qryPanel(vpnl: *std.ArrayList(pnl.PANEL)) usize {
	var cellPos: usize = 0;

	var Xcombo: *grd.GRID = grd.newGridC(
		"qryPanel",
		1,
		1,
		20,
		grd.gridStyle,
		dds.CADRE.line1,
	);
	defer dds.allocatorPnl.destroy(Xcombo);

	grd.newCell(Xcombo, "ID", 3, dds.REFTYP.UDIGIT, dds.ForegroundColor.fgGreen);
	grd.newCell(Xcombo, "Name", 10, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgYellow);
	grd.newCell(Xcombo, "Title", 15, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
	grd.setHeaders(Xcombo);

	for (vpnl.items, 0..) |p, idx| {
		grd.addRows(Xcombo, &.{ usizeToStr(idx), p.name, p.frame.title });
	}

	var Gkey: grd.GridSelect = undefined;
	defer Gkey.Buf.deinit();

	while (true) {
		Gkey = grd.ioCombo(Xcombo, cellPos);

		if (Gkey.Key == kbd.enter) {
			grd.freeGrid(Xcombo);

			return strToUsize(Gkey.Buf.items[0]);
		}

		if (Gkey.Key == kbd.esc) {
			grd.freeGrid(Xcombo);

			return 999;
		}
	}
}


pub fn Panel_HELP() *pnl.PANEL {
	var Panel : *pnl.PANEL = pnl.newPanelC("HELP",
										1, 1,
										4,
										100 ,
										dds.CADRE.line1,
										""
										);

	Panel.button.append(btn.newButton(
									kbd.F12,		// function
									true,			// show
									false,			// check field
									"Abord",		// title 
									)
								) catch unreachable ;
	

	Panel.field.append(fld.newFieldTextFull("HELP",2,5,90,"",false,
								"","",
								"")) catch unreachable ;
	fld.setProtect(Panel,0,true) catch unreachable;
	return Panel;
	}

// end desription Function
//=================================================

var maxY: usize = 0;
var maxX: usize = 0;
var minY: usize = 0;
var minX: usize = 0;
var X: usize = 0;
var Y: usize = 0;


//pub fn main() !void {
pub fn fnPanel(XPANEL: *std.ArrayList(pnl.PANEL)) void {
	term.cls();

	numPanel = qryPanel(XPANEL);

	if (numPanel == 999) return;

	term.cls();
	var pFmt01: *pnl.PANEL = pnl.newPanelC("FRAM01",
		XPANEL.items[numPanel].posx, XPANEL.items[numPanel].posy,
		XPANEL.items[numPanel].lines, XPANEL.items[numPanel].cols,
		XPANEL.items[numPanel].frame.cadre,
		XPANEL.items[numPanel].frame.title);

	for (XPANEL.items[numPanel].button.items) |p| {
		pFmt01.button.append(p)
		catch |err| { @panic(@errorName(err)); };
	}
	for (XPANEL.items[numPanel].label.items) |p| {
		pFmt01.label.append(p)
		catch |err| { @panic(@errorName(err)); };
	}
	for (XPANEL.items[numPanel].field.items, 0..) |p, idx| {
		pFmt01.field.append(p) catch |err| { @panic(@errorName(err)); };
		var vText: [] u8 = undefined ;
		
 
			switch(p.reftyp) {
				dds.REFTYP.TEXT_FREE, dds.REFTYP.TEXT_FULL ,	dds.REFTYP.ALPHA ,
				dds.REFTYP.ALPHA_UPPER,	dds.REFTYP.ALPHA_NUMERIC, dds.REFTYP.ALPHA_NUMERIC_UPPER,
				dds.REFTYP.PASSWORD, dds.REFTYP.YES_NO  =>{
					vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
					@memset(vText[0..p.width], '#');
				} ,

				dds.REFTYP.UDIGIT =>{
					vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
					@memset(vText[0..p.width], '0');
					//editcar
					if (p.edtcar.len > 0) {
						vText = std.fmt.allocPrint(dds.allocatorUtils, "{s}{s}", .{vText, p.edtcar }
						) catch unreachable;
					}
				} ,
			
				dds.REFTYP.DIGIT =>{
					vText = std.heap.page_allocator.alloc(u8, p.width + 1) catch unreachable;
					@memset(vText[0..p.width], '0');
					vText = std.fmt.allocPrint(dds.allocatorUtils, "+{s}", .{vText[0..p.width]})
							catch unreachable;
					//editcar
					if (p.edtcar.len > 0) {
						vText = std.fmt.allocPrint(dds.allocatorUtils, "{s}{s}", .{vText, p.edtcar }
						) catch unreachable;
					}
				} ,
			
				dds.REFTYP.UDECIMAL =>{
					vText = std.heap.page_allocator.alloc(u8, p.width + 1 + p.scal) catch unreachable;
					@memset(vText[0..(p.width + p.scal)] , '0');
					vText = std.fmt.allocPrint(dds.allocatorUtils, "{s}.{s}", .{vText[0..p.width],vText[0..p.scal]})
							catch unreachable;
					//editcar
					if (p.edtcar.len > 0) {
						vText = std.fmt.allocPrint(dds.allocatorUtils, "{s}{s}", .{vText, p.edtcar }
						) catch unreachable;
					}
				} ,
			
				dds.REFTYP.DECIMAL =>{
					vText = std.heap.page_allocator.alloc(u8, p.width + 2 + p.scal) catch unreachable;
					@memset(vText[0..(p.width + p.scal)], '0');
					vText = std.fmt.allocPrint(dds.allocatorUtils, "+{s}.{s}", .{vText[0..p.width],vText[0..p.scal]})
							catch unreachable;
				//editcar
					if (p.edtcar.len > 0) {
						vText = std.fmt.allocPrint(dds.allocatorUtils, "{s}{s}", .{vText, p.edtcar }
						) catch unreachable;
					}
				} ,
			
				dds.REFTYP.DATE_ISO =>	vText = std.fmt.allocPrint(dds.allocatorUtils, "YYYY-MM-DD", .{})
												catch unreachable,
				dds.REFTYP.DATE_FR  =>	vText = std.fmt.allocPrint(dds.allocatorUtils, "DD/MM/YYYY", .{})
												catch unreachable,

				dds.REFTYP.DATE_US  =>	vText = std.fmt.allocPrint(dds.allocatorUtils, "MM/DD/YYYY", .{})
												catch unreachable,

				dds.REFTYP.TELEPHONE =>{
					vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
					@memset(vText[0..p.width], '*');
				} ,

				dds.REFTYP.MAIL_ISO  =>{
					vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
					@memset(vText[0..p.width], '@');
				} ,
				dds.REFTYP.SWITCH   =>	vText = std.fmt.allocPrint(dds.allocatorUtils, "{s}", .{dds.CTRUE})
												catch unreachable,

				dds.REFTYP.FUNC  =>{
					vText = std.heap.page_allocator.alloc(u8, p.width) catch unreachable;
					@memset(vText[0..p.width], 'F');
				} ,

			}
			fld.setText(pFmt01,	idx, vText) catch |err| { @panic(@errorName(err)); };

	}

	
	for (XPANEL.items[numPanel].linev.items) |p| {
		pFmt01.linev.append(p)
		catch |err| { @panic(@errorName(err)); };
	}
	for (XPANEL.items[numPanel].lineh.items) |p| {
		pFmt01.lineh.append(p)
		catch |err| { @panic(@errorName(err)); };
	}

	for (XPANEL.items[numPanel].menu.items) |p| {
		pFmt01.menu.append(p)
		catch |err| { @panic(@errorName(err)); };
	}

	pFmt01.menu.append(mnu.newMenu("Choix", // name
			1, 1, // posx, posy
			dds.CADRE.line1, // type line fram
			dds.MNUVH.vertical, // type menu vertical / horizontal
			&.{ // item
			"Label-Order",
			"Label-Remove",
			"field-Order",
			"field-Remove",
			}
		)
	) catch |err| { @panic(@errorName(err)); };
 
 
	pnl.printPanel(pFmt01);

	maxY = pFmt01.cols + pFmt01.posy;
	if (pFmt01.frame.cadre != dds.CADRE.line0) maxY -= 0;
	
	minY = pFmt01.posy;
	if (pFmt01.frame.cadre != dds.CADRE.line0) minY += 1;

	maxX = pFmt01.lines + pFmt01.posx;
	if (pFmt01.frame.cadre != dds.CADRE.line0) maxX -= 2;
	
	minX = pFmt01.posx;
	if (pFmt01.frame.cadre != dds.CADRE.line0) minX += 1;

	term.onMouse();
	var Tkey: term.Keyboard = undefined; // defines the receiving structure of the keyboard
	var pFmtH01 = Panel_HELP();
	while (true) {
		term.cursShow();
		Tkey = kbd.getKEY();

		if (Tkey.Key == kbd.mouse) {
			forms.dspMouse(pFmt01);
			continue;
		} // active display Cursor x/y mouse

		switch (Tkey.Key) {
			.F1	 => {
				fld.setText(pFmtH01,0,"F11 ENRG  F12 Abort  Alt-T Title Alt-L label Alt-F Field AltW Outils")
					catch unreachable;
				_= pnl.ioPanel(pFmtH01);
				pnl.rstPanel(pFmtH01,pFmt01);
				term.gotoXY(1,1);
				continue;
			},
			.F11 => {
				XPANEL.items[numPanel].label.clearAndFree();
				XPANEL.items[numPanel].label = std.ArrayList(lbl.LABEL).init(dds.allocatorPnl);
				XPANEL.items[numPanel].label.clearRetainingCapacity();
				for (pFmt01.label.items) |p| {
					XPANEL.items[numPanel].label.append(p)
						catch |err| { @panic(@errorName(err)); };
				}

				XPANEL.items[numPanel].field.clearAndFree();
				XPANEL.items[numPanel].field = std.ArrayList(fld.FIELD).init(dds.allocatorPnl);
				XPANEL.items[numPanel].field.clearRetainingCapacity();
				for (pFmt01.field.items) |p| {
					XPANEL.items[numPanel].field.append(p) 
						catch |err| { @panic(@errorName(err)); };
				}

				pnl.freePanel(pFmt01);
				defer dds.allocatorPnl.destroy(pFmt01);
				dds.deinitUtils();
				return;
			},
			.F12 => {
				pnl.freePanel(pFmt01);
				defer dds.allocatorPnl.destroy(pFmt01);
				dds.deinitUtils();
				return;
			},

			// Def Title
			.altT => {
				term.getCursor();
				
				if (term.posCurs.x < minX or term.posCurs.x > maxX or
					term.posCurs.y < minY or term.posCurs.y > maxY) continue;
				
				term.offMouse();
				writeLabel(pFmt01, true);
				pnl.printPanel(pFmt01);
				term.onMouse();
			},

			// def label
			.altL => {
				term.getCursor();
				
				if (term.posCurs.x < minX or term.posCurs.x > maxX or
					term.posCurs.y < minY or term.posCurs.y > maxY) continue;
				
				term.offMouse();
				writeLabel(pFmt01, false);
				pnl.printPanel(pFmt01);
				term.onMouse();
			},

			// def field
			.altF => {
				term.getCursor();
				
				if (term.posCurs.x < minX or term.posCurs.x > maxX or
					term.posCurs.y < minY or term.posCurs.y > maxY) continue;

				term.writeStyled("?", pFmt01.attribut);
				term.gotoXY(term.posCurs.x, term.posCurs.y);
				term.getCursor();
				term.offMouse();
				writefield(pFmt01);
				term.cls();
				pnl.printPanel(pFmt01);
				term.onMouse();
			},
			// Order / Remove
			.altW => {
				var nitem: usize = 0;
				nitem = mnu.ioMenu(pFmt01, pFmt01.menu.items[0], nitem);

				if (nitem == 0) orderLabel(pFmt01);	// Order  Label

				if (nitem == 1) removeLabel(pFmt01);   // Remove Label

				if (nitem == 2) orderField(pFmt01);	// order field

				if (nitem == 3) removeField(pFmt01);   // Remove field

				term.offMouse();
				term.cls();
				pnl.printPanel(pFmt01);
				term.onMouse();
			},
			else => {},
		}
	}
}

//------------------------------------------------------------------
// definition label

fn writeLabel(vpnl: *pnl.PANEL, vtitle: bool) void {
	//term.getCursor();
	var e_count: usize = 0;
	var tampon: []const u8 = undefined;
	var text: []const u8 = undefined;
	var e_LABEL = std.ArrayList([]const u8).init(dds.allocatorUtils);
	defer e_LABEL.deinit();
	defer dds.allocatorUtils.destroy(&e_LABEL);

	var e_posx: usize = term.posCurs.x;
	var e_posy: usize = term.posCurs.y;
	var e_curs: usize = e_posy;

	// defines the receiving structure of the keyboard
	var Tkey: term.Keyboard = undefined;
	var pFmtH01 = Panel_HELP();

	var i: usize = 0;
	while (i < vpnl.cols) : (i += 1) {
		e_LABEL.append(" ") catch |err| {
			@panic(@errorName(err));
		};
	}
	while (true) {
		forms.dspCursor(vpnl, e_posx, e_curs,"Label/Title");

		Tkey = kbd.getKEY();

		//dspMouse(vpnl);  // active display Cursor x/y mouse
		//std.debug.print("Key: {d}  - {d}\n\r",.{term.posCurs.x, term.posCurs.y});
		switch (Tkey.Key) {
			.F1	 => {
				fld.setText(pFmtH01,0,"F12 Abort  ctrl-V") catch unreachable;
				_= pnl.ioPanel(pFmtH01);
				pnl.rstPanel(pFmtH01,vpnl);
				term.gotoXY(1,1);
				continue;
			},
			
			.F12 => return,

			.ctrlV => {
				tampon = std.fmt.allocPrint(dds.allocatorStr, "L{d}{d}", .{ e_posx, e_posy })
					catch |err| { @panic(@errorName(err)); };
				
				text = utl.trimStr(utl.listToStr(e_LABEL));
				if (vtitle == true ) {
					vpnl.label.append(lbl.newTitle(tampon, e_posx, e_posy, fld.ToStr(text)))
					catch |err| { @panic(@errorName(err)); };
				} else {
					vpnl.label.append(lbl.newLabel(tampon, e_posx, e_posy, fld.ToStr(text))) 
					   catch |err| { @panic(@errorName(err)); };
				}
				return;
			},
			.home => {
				e_count = 0;
				e_curs = e_posy;
			},
			.end => {
				tampon = utl.listToStr(e_LABEL);
				e_count = utl.trimStr(tampon).len - 1;
				e_curs = e_posy + utl.trimStr(tampon).len - 1;
			},
			.right, .tab => {
				if (e_curs < (vpnl.cols + vpnl.posy) - 1) {
					e_count += 1;
					e_curs += 1;
				}
			},
			.left, .stab => {
				if (e_curs > e_posy) {
					e_count -= 1;
					e_curs -= 1;
				}
			},
			.char => {
				if (e_curs < (vpnl.cols + vpnl.posy) - 1) {
					if (vtitle) {
						term.writeStyled(Tkey.Char, lbl.AtrTitle);
						e_LABEL.items[e_count] = Tkey.Char;
					} else {
						term.writeStyled(Tkey.Char, lbl.AtrLabel);
						e_LABEL.items[e_count] = Tkey.Char;
					}
					if (e_count < vpnl.cols) {
						e_count += 1;
						e_curs += 1;
					}
				}
			},
			else => {},
		}
	}
}

// Order label
fn orderLabel(vpnl: *pnl.PANEL) void {
	var idy: usize = 0;
	const allocatorOrder = std.heap.page_allocator;
	var newlabel = std.ArrayList(lbl.LABEL).init(allocatorOrder);
	var savlabel = std.ArrayList(lbl.LABEL).init(allocatorOrder);

	var Gkey: grd.GridSelect = undefined;
	defer Gkey.Buf.clearAndFree();

	for (vpnl.label.items) |p| {
		savlabel.append(p)
		catch |err| { @panic(@errorName(err)); };		
	}

	var Origine: *grd.GRID = grd.newGridC(
		"Origine",
		2,
		2,
		25,
		grd.gridStyle,
		dds.CADRE.line1,
	);
	defer dds.allocatorPnl.destroy(Origine);

	var Order: *grd.GRID = grd.newGridC(
		"Order",
		2,
		70,
		25,
		grd.gridStyle,
		dds.CADRE.line1,
	);
	defer dds.allocatorPnl.destroy(Order);

	grd.newCell(Origine, "col", 3, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
	grd.newCell(Origine, "name", 6, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgYellow);
	grd.newCell(Origine, "text", 40, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
	grd.setHeaders(Origine);

	grd.newCell(Order, "col", 3, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
	grd.newCell(Order, "name", 6, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgYellow);
	grd.newCell(Order, "text", 40, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
	grd.setHeaders(Order);

	while (true) {
		grd.resetRows(Origine);
		for (vpnl.label.items, 0..) |l, idx| {
			var ridx = usizeToStr(idx);

			if (l.text.len > 40) grd.addRows(Origine, &.{ ridx, l.name, l.text[0..39] })
			else grd.addRows(Origine, &.{ ridx, l.name, l.text });
		}

		Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
		if (Gkey.Key == kbd.esc) break;
		if (Gkey.Key == kbd.ctrlV) break;
		if (Gkey.Key == kbd.enter) {
			newlabel.append(vpnl.label.items[strToUsize(Gkey.Buf.items[0])])
				catch |err| { @panic(@errorName(err)); };
			
			var ridy = usizeToStr(idy);

			grd.addRows(Order, &.{ ridy, Gkey.Buf.items[1], Gkey.Buf.items[2] });
			idy += 1;
			grd.printGridHeader(Order);
			grd.printGridRows(Order);
			var ligne: usize = strToUsize(Gkey.Buf.items[0]);

			_ = vpnl.label.orderedRemove(ligne);
		}
	}

	vpnl.label.clearAndFree();
	vpnl.label = std.ArrayList(lbl.LABEL).init(dds.allocatorPnl);
	vpnl.label.clearRetainingCapacity();
	// restor and exit
	if (Gkey.Key == kbd.esc) {
		for (savlabel.items) |p| {
			vpnl.label.append(p)
						catch |err| { @panic(@errorName(err)); };
		}
	}
	// new Order and exit CTRL-V
	else {
		for (newlabel.items) |p| {
			vpnl.label.append(p)   
						catch |err| { @panic(@errorName(err)); };
				 }
	}

	grd.freeGrid(Origine);
	grd.freeGrid(Order);

	newlabel.clearAndFree();
	newlabel.deinit();

	savlabel.clearAndFree();
	savlabel.deinit();

	return;
}

// remove Label
fn removeLabel(vpnl: *pnl.PANEL) void {
	const allocatorRemove = std.heap.page_allocator;
	var savlabel: std.ArrayList(lbl.LABEL) = std.ArrayList(lbl.LABEL).init(allocatorRemove);

	var Gkey: grd.GridSelect = undefined;
	defer Gkey.Buf.clearAndFree();

	for (vpnl.label.items) |p| {
		savlabel.append(p)  
			catch |err| { @panic(@errorName(err)); };
	}

	var Origine: *grd.GRID = grd.newGridC(
		"Origine",
		2,
		2,
		25,
		grd.gridStyle,
		dds.CADRE.line1,
	);
	defer dds.allocatorPnl.destroy(Origine);

	grd.newCell(Origine, "col", 3, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
	grd.newCell(Origine, "name", 6, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgYellow);
	grd.newCell(Origine, "text", 40, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
	grd.setHeaders(Origine);

	while (true) {
		grd.resetRows(Origine);
		for (vpnl.label.items, 0..) |l, idx| {
			var ridx =  usizeToStr(idx);
 
			if (l.text.len > 40) grd.addRows(Origine, &.{ ridx, l.name, l.text[0..39] })
			else grd.addRows(Origine, &.{ ridx, l.name, l.text });
		}

		Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
		if (Gkey.Key == kbd.esc) break;
		if (Gkey.Key == kbd.ctrlV) break;
		if (Gkey.Key == kbd.enter) {
			var ligne: usize = strToUsize(Gkey.Buf.items[0]);

			_ = vpnl.label.orderedRemove(ligne);
		}
	}

	// restor and exit
	if (Gkey.Key == kbd.esc) {
		vpnl.label.clearAndFree();
		vpnl.label = std.ArrayList(lbl.LABEL).init(dds.allocatorPnl);
		vpnl.label.clearRetainingCapacity();

		for (savlabel.items) |p| {
			vpnl.label.append(p) 
			 catch |err| { @panic(@errorName(err)); };
		}
	}

	grd.freeGrid(Origine);

	savlabel.clearAndFree();
	savlabel.deinit();
}

//==========================================
// FIELD Management
//==========================================

// forms field
const fp02 = enum {
	fname,
	fposx,
	fposy,
	ftype,
	fwidth,
	fscal,
	frequi,
	fprotect,
	fedtcar,
	ferrmsg,
	fhelp,
	ffunc,
	ftask,
};

//  string return enum
fn strToEnum(comptime EnumTag: type, vtext: []const u8) EnumTag {
	inline for (@typeInfo(EnumTag).Enum.fields) |f| {
		if (std.mem.eql(u8, f.name, vtext)) return @field(EnumTag, f.name);
	}

	var buffer: [128]u8 = [_]u8{0} ** 128;
	var result = std.fmt.bufPrintZ(buffer[0..], "invalid Text {s} for strToEnum ", .{vtext}) catch unreachable;
	@panic(result);
}

// panel for field
fn Panel_Fmt02(nposx: usize) *pnl.PANEL {
	var Panel: *pnl.PANEL = pnl.newPanelC("FRAM01", nposx, 2, 12, 62, dds.CADRE.line1, "Def.field");

	Panel.button.append(btn.newButton(
		kbd.F9, // function
		true, // show
		true, // check field
		"Enrg", // title
	)) catch |err| { @panic(@errorName(err)); };
	
	Panel.button.append(btn.newButton(
		kbd.F12, // function
		true, // show
		false, // check field
		"Return", // title
	)) catch |err| { @panic(@errorName(err)); }; 

	
	Panel.label.append(lbl.newLabel(@tagName(fp02.fname), 2, 2, "name.....:")) 
	catch |err| { @panic(@errorName(err)); }; 
	
	Panel.field.append(fld.newFieldAlphaNumeric(@tagName(fp02.fname), 2, // posx
		2 + Panel.label.items[@intFromEnum(fp02.fname)].text.len, //posy
		15, // len
		"", // text
		true, // required
		"required help ctrl-h", // Msg err
		"please enter text 1car Letter  other alphanumeric", // help
		"(^[a-zA-Z]{1,1}[a-zA-Z0-9]{1,})$" // regex
	)) catch |err| { @panic(@errorName(err)); }; 

	fld.setTask(Panel, @intFromEnum(fp02.fname), "TaskName") 
	catch |err| { @panic(@errorName(err)); }; 


	Panel.label.append(lbl.newLabel(@tagName(fp02.fposx), 3, 2, "PosX.:"))
	catch |err| { @panic(@errorName(err)); }; 

	Panel.field.append(fld.newFieldUDigit(@tagName(fp02.fposx), 3, // posx
		2 + Panel.label.items[@intFromEnum(fp02.fposx)].text.len, //posy
		2, // len
		"", // text
		false, // required
		"", // Msg err default
		"", // help default
		"" // regex default
	)) catch |err| { @panic(@errorName(err)); }; 

	fld.setProtect(Panel, @intFromEnum(fp02.fposx), true)
	catch |err| { @panic(@errorName(err)); }; 


	Panel.label.append(lbl.newLabel(@tagName(fp02.fposy), 3, 12, "PosY.:"))
	catch |err| { @panic(@errorName(err)); };	 

	Panel.field.append(fld.newFieldUDigit(@tagName(fp02.fposy), 3, // posx
		12 + Panel.label.items[@intFromEnum(fp02.fposy)].text.len, //posy
		3, // len
		"", // text
		false, // required
		"", // Msg err default
		"", // help default
		"" // regex default
	)) catch |err| { @panic(@errorName(err)); }; 

	fld.setProtect(Panel, @intFromEnum(fp02.fposy), true) 
		catch |err| { @panic(@errorName(err)); }; 
		

	Panel.label.append(lbl.newLabel(@tagName(fp02.ftype), 3, 32, "Type.:"))
		catch |err| { @panic(@errorName(err)); }; 
		
	Panel.field.append(fld.newFieldFunc(
		@tagName(fp02.ftype),
		3, // posx
		32 + Panel.label.items[@intFromEnum(fp02.ftype)].text.len, //posy
		19, // len
		"", // text
		true, // required
		"funcType", // function
		"Reference type required", // Msg err
		"Refence field", // help
	)) catch |err| {
		@panic(@errorName(err));
	};
	fld.setTask(Panel, @intFromEnum(fp02.ftype), "TaskType")
		catch |err| { @panic(@errorName(err)); }; 

		
	Panel.label.append(lbl.newLabel(@tagName(fp02.fwidth), 4, 2, "Width.:"))
		catch |err| { @panic(@errorName(err)); }; 
		
	Panel.field.append(fld.newFieldUDigit(@tagName(fp02.fwidth), 4, // posx
		2 + Panel.label.items[@intFromEnum(fp02.fwidth)].text.len, //posy
		3, // len
		"", // text
		true, // required
		"Len field required or too long", // Msg err
		"len field", // help
		"" // regex
	)) catch |err| { @panic(@errorName(err)); }; 

	fld.setTask(Panel, @intFromEnum(fp02.fwidth), "TaskWidth") 
		catch |err| { @panic(@errorName(err)); }; 
		

	Panel.label.append(lbl.newLabel(@tagName(fp02.fscal), 4, 20, "Scal.:"))
		catch |err| { @panic(@errorName(err)); }; 
		
	Panel.field.append(fld.newFieldUDigit(@tagName(fp02.fscal), 4, // posx
		20 + Panel.label.items[@intFromEnum(fp02.fscal)].text.len, //posy
		3, // len
		"", // text
		true, // required
		"Len Scal field required or too long", // Msg err
		"len Scal field", // help
		"" // regex
	)) catch |err| { @panic(@errorName(err)); }; 

	fld.setTask(Panel, @intFromEnum(fp02.fscal), "TaskScal")
		catch |err| { @panic(@errorName(err)); }; 
		
	
	Panel.label.append(lbl.newLabel(@tagName(fp02.frequi), 4, 32, "Required.:"))
		catch |err| { @panic(@errorName(err)); }; 
		
	Panel.field.append(fld.newFieldSwitch(@tagName(fp02.frequi), 4, // posx
		32 + Panel.label.items[@intFromEnum(fp02.frequi)].text.len, //posy
		false, // required
		"field required True or False", // Msg err
		" field value required True or False" // Text
	)) catch |err| { @panic(@errorName(err)); }; 


	Panel.label.append(lbl.newLabel(@tagName(fp02.fprotect), 5, 2, "Protect.:"))
		catch |err| { @panic(@errorName(err)); }; 

	Panel.field.append(fld.newFieldSwitch(@tagName(fp02.fprotect), 5, // posx
		2 + Panel.label.items[@intFromEnum(fp02.fprotect)].text.len, //posy
		false, // required
		"field Protect required True or False", // Msg err
		" field Protect required True or False" // Text
	)) catch |err| { @panic(@errorName(err)); }; 

	
	Panel.label.append(lbl.newLabel(@tagName(fp02.fedtcar), 5, 20, "Edit Car.:"))
		catch |err| { @panic(@errorName(err)); }; 
		
	Panel.field.append(fld.newFieldTextFull(@tagName(fp02.fedtcar), 5, // posx
		20 + Panel.label.items[@intFromEnum(fp02.fedtcar)].text.len, //posy
		1, // len
		"", // text
		false, // required
		"", // Msg err
		"please enter text ex:$ € % £", // help
		"" // regex
	)) catch |err| { @panic(@errorName(err)); }; 
 
		fld.setTask(Panel, @intFromEnum(fp02.fscal), "TaskEdtcar")
		catch |err| { @panic(@errorName(err)); };
 
	Panel.label.append(lbl.newLabel(@tagName(fp02.ferrmsg), 6, 2, "Err Msg.:")) 
		catch |err| { @panic(@errorName(err)); }; 
		
	Panel.field.append(fld.newFieldTextFull(@tagName(fp02.ferrmsg), 6, // posx
		2 + Panel.label.items[@intFromEnum(fp02.ferrmsg)].text.len, //posy
		50, // len
		"", // text
		false, // required
		"required Help", // Msg err
		"please enter text  message error", // help
		"" // regex
	)) catch |err| { @panic(@errorName(err)); }; 
		
	fld.setTask(Panel, @intFromEnum(fp02.ferrmsg), "TaskErrmsg") 
		catch |err| { @panic(@errorName(err)); }; 


	Panel.label.append(lbl.newLabel(@tagName(fp02.fhelp), 7, 2, "Help.:")) 
		catch |err| { @panic(@errorName(err)); }; 

	Panel.field.append(fld.newFieldTextFull(@tagName(fp02.fhelp), 7, // posx
		2 + Panel.label.items[@intFromEnum(fp02.fhelp)].text.len, //posy
		50, // len
		"", // text
		true, // required
		"required Help", // Msg err
		"please enter text  Help", // help
		"" // regex
	)) catch |err| { @panic(@errorName(err)); }; 

	
	Panel.label.append(lbl.newLabel(@tagName(fp02.ffunc), 8, 2, "Function.:"))
		catch |err| { @panic(@errorName(err)); }; 

	Panel.field.append(fld.newFieldAlphaNumeric(@tagName(fp02.ffunc), 8, // posx
		2 + Panel.label.items[@intFromEnum(fp02.ffunc)].text.len, //posy
		15, // len
		"", // text
		false, // required
		"required Function", // Msg err
		"please enter Name Function  F.....", // help
		"(^[F]{1,1}[a-zA-Z0-9]{1,})$" // regex
	)) catch |err| { @panic(@errorName(err)); }; 

	fld.setTask(Panel, @intFromEnum(fp02.ffunc), "TaskFunc") catch |err| {
		@panic(@errorName(err));
	};


	Panel.label.append(lbl.newLabel(@tagName(fp02.ftask), 9, 2, "Task.:")) 
		catch |err| { @panic(@errorName(err)); }; 
		
	Panel.field.append(fld.newFieldAlphaNumeric(@tagName(fp02.ftask), 9, // posx
		2 + Panel.label.items[@intFromEnum(fp02.ftask)].text.len, //posy
		15, // len
		"", // text
		false, // required
		"err Task", // Msg err
		"please enter Name Task T.....", // help
		"(^[T]{1,1}[a-zA-Z0-9]{1,})$" // regex1
	)) catch |err| { @panic(@errorName(err)); }; 

	return Panel;
}

//---------------------------------------------------------------------------

//=================================================
// description Function
// choix Cadre
fn funcType(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
	var pos: usize = 0;

	var Xcombo: *grd.GRID = grd.newGridC(
		"qryPanel",
		vpnl.posx + 1,
		vpnl.posy + 1,
		7,
		grd.gridStyle,
		dds.CADRE.line1,
	);
	defer dds.allocatorPnl.destroy(Xcombo);
	grd.newCell(Xcombo, "Ref.Type", 19, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
	grd.setHeaders(Xcombo);
	grd.addRows(Xcombo, &.{"TEXT_FREE"}); // Free
	grd.addRows(Xcombo, &.{"TEXT_FULL"}); // Letter Digit Char-special
	grd.addRows(Xcombo, &.{"ALPHA"}); // Letter
	grd.addRows(Xcombo, &.{"ALPHA_UPPER"}); // Letter
	grd.addRows(Xcombo, &.{"ALPHA_NUMERIC"}); // Letter Digit espace -
	grd.addRows(Xcombo, &.{"ALPHA_NUMERIC_UPPER"}); // Letter Digit espace -
	grd.addRows(Xcombo, &.{"PASSWORD"}); // Letter Digit and normaliz char-special
	grd.addRows(Xcombo, &.{"YES_NO"}); // 'y' or 'Y' / 'o' or 'O'
	grd.addRows(Xcombo, &.{"UDIGIT"}); // Digit unsigned
	grd.addRows(Xcombo, &.{"DIGIT"}); // Digit signed
	grd.addRows(Xcombo, &.{"UDECIMAL"}); // Decimal unsigned
	grd.addRows(Xcombo, &.{"DECIMAL"}); // Decimal signed
	grd.addRows(Xcombo, &.{"DATE_ISO"}); // YYYY/MM/DD
	grd.addRows(Xcombo, &.{"DATE_FR"}); // DD/MM/YYYY
	grd.addRows(Xcombo, &.{"DATE_US"}); // MM/DD/YYYY
	grd.addRows(Xcombo, &.{"TELEPHONE"}); // (+123) 6 00 01 00 02
	grd.addRows(Xcombo, &.{"MAIL_ISO"}); // normalize regex
	grd.addRows(Xcombo, &.{"SWITCH"}); // CTRUE CFALSE
	grd.addRows(Xcombo, &.{"FUNC"}); // call Function

	if (std.mem.eql(u8, vfld.text, "TEXT_FREE")) pos = 0;
	if (std.mem.eql(u8, vfld.text, "TEXT_FULL")) pos = 1;
	if (std.mem.eql(u8, vfld.text, "ALPHA")) pos = 2;
	if (std.mem.eql(u8, vfld.text, "ALPHA_UPPER")) pos = 3;
	if (std.mem.eql(u8, vfld.text, "ALPHA_NUMERIC")) pos = 4;
	if (std.mem.eql(u8, vfld.text, "ALPHA_NUMERIC_UPPER")) pos = 5;
	if (std.mem.eql(u8, vfld.text, "PASSWORD")) pos = 6;
	if (std.mem.eql(u8, vfld.text, "YES_NO")) pos = 7;
	if (std.mem.eql(u8, vfld.text, "UDIGIT")) pos = 8;
	if (std.mem.eql(u8, vfld.text, "UDECIMAL")) pos = 9;
	if (std.mem.eql(u8, vfld.text, "DECIMAL")) pos = 10;
	if (std.mem.eql(u8, vfld.text, "DATE_ISO")) pos = 11;
	if (std.mem.eql(u8, vfld.text, "DATE_FR")) pos = 12;
	if (std.mem.eql(u8, vfld.text, "DATE_US")) pos = 13;
	if (std.mem.eql(u8, vfld.text, "TELEPHONE")) pos = 14;
	if (std.mem.eql(u8, vfld.text, "MAIL_ISO")) pos = 15;
	if (std.mem.eql(u8, vfld.text, "SWITCH")) pos = 16;
	if (std.mem.eql(u8, vfld.text, "FUNC")) pos = 17;

	var Gkey: grd.GridSelect = undefined;
	defer Gkey.Buf.deinit();

	while (true) {
		Gkey = grd.ioCombo(Xcombo, pos);

		if (Gkey.Key == kbd.enter) {
			grd.rstPanel(Xcombo, vpnl);
			grd.freeGrid(Xcombo);
			fld.setText(vpnl, @intFromEnum(fp02.ftype), Gkey.Buf.items[0]) 
				catch |err| { @panic(@errorName(err)); }; 
			return;
		}

		if (Gkey.Key == kbd.esc) {
			grd.rstPanel(Xcombo, vpnl);
			grd.freeGrid(Xcombo);
			return;
		}
	}
}

var callFunc: FuncEnum = undefined;
//=================================================
// description Function
/// run emun Function ex: combo
pub const FuncEnum = enum {
	funcType,
	none,

	pub fn run(self: FuncEnum, vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
		switch (self) {
			.funcType => funcType(vpnl, vfld),
			else => dsperr.errorForms(vpnl, ErrMain.main_run_EnumFunc_invalide),
		}
	}

	fn searchFn(vtext: []const u8) FuncEnum {
		var max: usize = @typeInfo(FuncEnum).Enum.fields.len;

		inline for (@typeInfo(FuncEnum).Enum.fields) |f| {
			if (std.mem.eql(u8, f.name, vtext)) return @as(FuncEnum, @enumFromInt(f.value));
		}
		return @as(FuncEnum, @enumFromInt(max));
	}
};
//---------------------------------------------------------------------------
//=================================================
// description Function
// test exist Name for add or change name

fn TaskName(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
	for (vpnl.field.items) |f| {
		if (std.mem.eql(u8, f.name, vfld.text)) {
			pnl.msgErr(vpnl, "Already existing invalide Name field");
			vpnl.keyField = kbd.task;
			return;
		}
	}
	return;
}

fn TaskType(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
	var vReftype = strToEnum(dds.REFTYP, vfld.text);

	for (vpnl.field.items, 0..) |f, idx| {
		if (std.mem.eql(u8, f.name, @tagName(fp02.fscal))) {
			vpnl.field.items[idx].text = "";
			vpnl.field.items[idx].protect = true;
		}

		if (std.mem.eql(u8, f.name, @tagName(fp02.fedtcar))) {
			vpnl.field.items[idx].text = "";
			vpnl.field.items[idx].protect = true;
		}
	}



	
	for (vpnl.field.items, 0..) |f, idx| {
		
		if (vReftype == dds.REFTYP.DECIMAL or
			vReftype == dds.REFTYP.UDECIMAL) {
			if (std.mem.eql(u8, f.name, @tagName(fp02.fscal))) {
				vpnl.field.items[idx].protect = false;
			}
		}
		if (vReftype == dds.REFTYP.DIGIT or
			vReftype == dds.REFTYP.UDIGIT or
			vReftype == dds.REFTYP.DECIMAL or
			vReftype == dds.REFTYP.UDECIMAL)
		{
			if (std.mem.eql(u8, f.name, @tagName(fp02.fedtcar))) {
				vpnl.field.items[idx].protect = false;
			}
		}
	}


	if (vReftype == dds.REFTYP.DATE_ISO or
		vReftype == dds.REFTYP.DATE_FR or
		vReftype == dds.REFTYP.DATE_US)
	{
		for (vpnl.field.items, 0..) |f, idx| {
			if (std.mem.eql(u8, f.name, @tagName(fp02.fwidth))) {
				vpnl.field.items[idx].text = "10";
				vpnl.field.items[idx].protect = true;
			}
		}
	}

	if (vReftype == dds.REFTYP.YES_NO or vReftype == dds.REFTYP.SWITCH) {
		for (vpnl.field.items, 0..) |f, idx| {
			if (std.mem.eql(u8, f.name, @tagName(fp02.fwidth))) {
				vpnl.field.items[idx].text = "1";
				vpnl.field.items[idx].protect = true;
			}
		}
	}
	return;
}

fn TaskWidth(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
	var val = strToUsize(vfld.text);

	if (val + vfld.posx >= vpnl.cols) {
		const msg = std.fmt.allocPrint(dds.allocatorUtils,
			"{d} the length of the zone is excessive", .{val})
			catch |err| { @panic(@errorName(err)); };			
		pnl.msgErr(vpnl, msg);

		vpnl.keyField = kbd.task;
	}
	return;
}

fn TaskScal(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
	if (std.mem.eql(u8, vfld.text, "UDECIMAL") or std.mem.eql(u8, vfld.text, "DECIMAL")) {
		var width = strToUsize(fld.getText(vpnl, @intFromEnum(fp02.fwidth)) catch unreachable) ;
		if (std.mem.eql(u8, vfld.text, "DECIMAL")) width += 1;

		var vscal = strToUsize(vfld.text);

	
		if (vscal + width + vfld.posx >= vpnl.cols) {
			const msg = std.fmt.allocPrint(dds.allocatorUtils,
				"{d} the Scal of the zone is excessive", .{vscal}) 
				catch |err| { @panic(@errorName(err)); }; 
				
			pnl.msgErr(vpnl, msg);
			vpnl.keyField = kbd.task;
		}
	} else vfld.text = "";
	return;
}


fn TaskEdtcar(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
	if ( ! std.mem.eql(u8, vfld.text,"")) {
		
		var width = strToUsize(fld.getText(vpnl, @intFromEnum(fp02.fwidth))  catch unreachable) ;
		var vtype = fld.getText(vpnl, @intFromEnum(fp02.ftype))  catch unreachable ;
	
		if (std.mem.eql(u8, vtype, "DIGIT") or std.mem.eql(u8, vtype, "DECIMAL"))  width += 1;

		var scal = strToUsize(fld.getText(vpnl, @intFromEnum(fp02.fscal))  catch unreachable);

		if (width + scal + vfld.posx >= vpnl.cols) {
			const msg = std.fmt.allocPrint(dds.allocatorUtils,
				"the length of the zone is excessive", .{})
				catch |err| { @panic(@errorName(err)); };			
			pnl.msgErr(vpnl, msg);

			vpnl.keyField = kbd.task;
		}
	}
	return;
}

fn TaskErrmsg(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
	if (!vfld.zwitch and std.mem.eql(u8, "", vfld.text)) {
		pnl.msgErr(vpnl, "the error message text is invalid");
		vpnl.keyField = kbd.task;
	}

	return;
}

fn TaskFunc(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
	if (std.mem.eql(u8, vfld.text, "FUNC")) {
		if (std.mem.eql(u8, "", vfld.procfunc)) {
			pnl.msgErr(vpnl, "the function name is invalid");
			vpnl.keyField = kbd.task;
		}
	}

	return;
}
var callTask: TaskEnum = undefined;
//=================================================
// description Function
/// run emun Function ex: combo
pub const TaskEnum = enum {
	TaskName,
	TaskType,
	TaskWidth,
	TaskScal,
	TaskEdtcar,
	TaskErrmsg,
	TaskFunc,
	none,

	pub fn run(self: TaskEnum, vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
		switch (self) {
			.TaskName	=> TaskName(vpnl, vfld),
			.TaskType	=> TaskType(vpnl, vfld),
			.TaskWidth	=> TaskWidth(vpnl, vfld),
			.TaskScal	=> TaskScal(vpnl, vfld),
			.TaskEdtcar	=> TaskEdtcar(vpnl, vfld),
			.TaskErrmsg => TaskErrmsg(vpnl, vfld),
			.TaskFunc 	=> TaskFunc(vpnl, vfld),

			else => dsperr.errorForms(vpnl, ErrMain.main_run_EnumTask_invalide),
		}
	}
	fn searchFn(vtext: []const u8) TaskEnum {
		var max: usize = @typeInfo(TaskEnum).Enum.fields.len;

		inline for (@typeInfo(TaskEnum).Enum.fields) |f| {
			if (std.mem.eql(u8, f.name, vtext)) return @as(TaskEnum, @enumFromInt(f.value));
		}
		return @as(TaskEnum, @enumFromInt(max));
	}
};
//---------------------------------------------------------------------------

pub fn writefield(vpnl: *pnl.PANEL) void {
	term.getCursor();
	var v_posx: usize = term.posCurs.x;
	var v_posy: usize = term.posCurs.y;

	if (v_posx < 15) v_posx = 15 else v_posx = 2;

	// Init format panel
	var pFmt02 = Panel_Fmt02(v_posx);

	v_posx = term.posCurs.x;
	// init zone field
	fld.setText(pFmt02, @intFromEnum(fp02.fposx), std.fmt.allocPrint(dds.allocatorUtils, "{d}", .{v_posx})
		catch unreachable) catch unreachable;
	fld.setText(pFmt02, @intFromEnum(fp02.fposy), std.fmt.allocPrint(dds.allocatorUtils, "{d}", .{v_posy})
		catch unreachable) catch unreachable;

	// init struct key
	var Tkey: term.Keyboard = undefined; // defines the receiving structure of the keyboard
	var idx: usize = 0;
	var vReftyp: dds.REFTYP = undefined;
	var vText: []u8 = undefined;
	var vlen: usize = 0;
	var vText2: []u8 = undefined;
	while (true) {
		//Tkey = kbd.getKEY();

		forms.dspCursor(vpnl, v_posx, v_posy,"Field");
		Tkey.Key = pnl.ioPanel(pFmt02);
		switch (Tkey.Key) {
			// call function combo
			.func => {
				callFunc = FuncEnum.searchFn(pFmt02.field.items[pFmt02.idxfld].procfunc);
				callFunc.run(pFmt02, &pFmt02.field.items[pFmt02.idxfld]);
			},
			// call proc control chek value
			.task => {
				callTask = TaskEnum.searchFn(pFmt02.field.items[pFmt02.idxfld].proctask);
				callTask.run(pFmt02, &pFmt02.field.items[pFmt02.idxfld]);
			},
			// write field to panel
			.F9 => {
				vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
				vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
				
				vReftyp = strToEnum(dds.REFTYP, pFmt02.field.items[@intFromEnum(fp02.ftype)].text);
				@memset(vText[0..vlen], '#');

				switch (vReftyp) {
					dds.REFTYP.TEXT_FREE => {
						vpnl.field.append(fld.newFieldTextFree(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							 strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							 strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							 strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
							 "",
							 pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							 pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							 pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, "")
						)
						catch |err| { @panic(@errorName(err)); };

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };
						
						fld.setText(
							vpnl,
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.TEXT_FULL => {
						vpnl.field.append(fld.newFieldTextFull(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
							"",
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, ""))
							catch |err| { @panic(@errorName(err)); };

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
						catch |err| { @panic(@errorName(err)); };

						fld.setText(
							vpnl,
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.ALPHA => {
						vpnl.field.append(fld.newFieldAlpha(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
							"",
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
							"")
						) catch |err| { @panic(@errorName(err)); };

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };

						fld.setText(
							vpnl,
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.ALPHA_UPPER => {
						vpnl.field.append(fld.newFieldAlphaUpper(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
							"",
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
							"")
						) catch |err| { @panic(@errorName(err)); };

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };

						fld.setText(
							vpnl,
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.ALPHA_NUMERIC => {
						vpnl.field.append(fld.newFieldAlphaNumeric(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
							"",
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, "")) catch unreachable;

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };

						fld.setText(
							vpnl,  
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.ALPHA_NUMERIC_UPPER => {
						vpnl.field.append(fld.newFieldAlphaNumericUpper(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							 strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
							"", pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
							"")) catch |err| {
							@panic(@errorName(err));
						};

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
						catch |err| { @panic(@errorName(err)); };

						fld.setText(
							vpnl,  
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.PASSWORD => {
						vpnl.field.append(fld.newFieldPassword(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
							"",
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, ""))
							catch |err| { @panic(@errorName(err)); };

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };

						fld.setText(
							vpnl,
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.YES_NO => {
						vpnl.field.append(fld.newFieldYesNo(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							"",
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
						)) 
						catch |err| { @panic(@errorName(err)); };

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };

						fld.setText(
							vpnl,
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.UDIGIT => {
						vpnl.field.append(fld.newFieldUDigit(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
							"",
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
							"")
						) catch |err| { @panic(@errorName(err)); };

						vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
						vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
						@memset(vText[0..vlen], '0');

						// editcar
						if (pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text.len > 0) {
							vText = std.fmt.allocPrint(dds.allocatorUtils, "{s}{s}", .{
								vText, pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text })
								 catch |err| { @panic(@errorName(err)); };
						}
						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };
						
						fld.setText(
							vpnl,
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.DIGIT => {
						vpnl.field.append(fld.newFieldDigit(pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
							"", pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
							""))
							catch |err| { @panic(@errorName(err)); };

						vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
						vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
						@memset(vText[0..vlen], '0');

						vText = std.fmt.allocPrint(dds.allocatorUtils, "+{s}", .{vText})
								catch |err| { @panic(@errorName(err)); };
						//editcar
						if (pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text.len > 0) {
							vText = std.fmt.allocPrint(dds.allocatorUtils, "{s}{s}", .{
								vText, pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text }
							) catch |err| { @panic(@errorName(err)); };
						}

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };

						fld.setText(
							vpnl,
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.UDECIMAL => {
						vpnl.field.append(fld.newFieldUDecimal(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fscal)].text),
							"", pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, ""))
							catch |err| { @panic(@errorName(err)); };

						vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
						vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
						@memset(vText[0..vlen], '0');
						
						vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fscal)].text);
						vText2 = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
						@memset(vText2[0..vlen], '0');
						
						vText = std.fmt.allocPrint(dds.allocatorUtils, "{s},{s}", .{ vText, vText2 })
							catch |err| { @panic(@errorName(err)); };

						// editcar

						if (pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text.len > 0) {
							vText = std.fmt.allocPrint(dds.allocatorUtils, "{s}{s}", .{
								vText, pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text })
							catch |err| { @panic(@errorName(err)); };
						}

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };

						fld.setText(
							vpnl,
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.DECIMAL => {
						vpnl.field.append(fld.newFieldDecimal(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fscal)].text),
							"",
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
							"")) 
							catch |err| { @panic(@errorName(err)); };

						vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
						vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
						@memset(vText[0..vlen], '0');
						
						vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fscal)].text);
						vText2 = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
						@memset(vText2[0..vlen], '0');
						
						vText = std.fmt.allocPrint(dds.allocatorUtils, "+{s},{s}", .{ vText, vText2 })
							catch unreachable;

						// editcar
						if (pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text.len > 0) {
							vText = std.fmt.allocPrint(dds.allocatorUtils, "{s}{s}", .{
								vText, pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text })
							catch |err| { @panic(@errorName(err)); };
						}

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };

						fld.setText(
							vpnl,
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.DATE_ISO => {
						vpnl.field.append(fld.newFieldDateISO(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							"",
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
						))
							catch |err| { @panic(@errorName(err)); };

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };

						fld.setText(
							vpnl,
							idx,
							"YYYY/MM/DD",
						) catch |err| { @panic(@errorName(err)); };
					},
					dds.REFTYP.DATE_FR => {
						vpnl.field.append(fld.newFieldDateFR(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							"",
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
						)) 
							catch |err| { @panic(@errorName(err)); };
							
						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };

						fld.setText(
							vpnl,
							idx,
							"DD/MM/YYYY",
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.DATE_US => {
						vpnl.field.append(fld.newFieldDateUS(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							"",
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
						)) 
							catch |err| { @panic(@errorName(err)); };
							
						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };

						fld.setText(
							vpnl,
							idx,
							"MM/DD/YYYY",
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.TELEPHONE => {
						vpnl.field.append(fld.newFieldTelephone(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
							"",
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text, ""))
							catch |err| { @panic(@errorName(err)); };

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };
						
						vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
						vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
						@memset(vText[0..vlen], '*');
						
						fld.setText(
							vpnl,
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.MAIL_ISO => {
						vpnl.field.append(fld.newFieldMail(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
							"",
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text,
						)) 
							catch |err| { @panic(@errorName(err)); };

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };

						vlen = strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text);
						vText = std.heap.page_allocator.alloc(u8, vlen) catch unreachable;
						@memset(vText[0..vlen], '@');
						
						fld.setText(
							vpnl,
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.SWITCH => {
						vpnl.field.append(fld.newFieldSwitch(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text))
							catch |err| { @panic(@errorName(err)); };

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };

						
						fld.setText(
							vpnl,
							idx,
							dds.CTRUE,
						) catch |err| { @panic(@errorName(err)); };
					},

					dds.REFTYP.FUNC => {
						vpnl.field.append(fld.newFieldFunc(
							pFmt02.field.items[@intFromEnum(fp02.fname)].text,
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposx)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fposy)].text),
							strToUsize(pFmt02.field.items[@intFromEnum(fp02.fwidth)].text),
							"",
							pFmt02.field.items[@intFromEnum(fp02.frequi)].zwitch,
							pFmt02.field.items[@intFromEnum(fp02.ffunc)].text,
							pFmt02.field.items[@intFromEnum(fp02.ferrmsg)].text,
							pFmt02.field.items[@intFromEnum(fp02.fhelp)].text))
							catch |err| { @panic(@errorName(err)); };

						idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
							catch |err| { @panic(@errorName(err)); };
						@memset(vText[0..vlen], 'F');
						fld.setText(
							vpnl,
							idx,
							vText,
						) catch |err| { @panic(@errorName(err)); };
					}
				}
				idx = fld.getIndex(vpnl, pFmt02.field.items[@intFromEnum(fp02.fname)].text)
					catch |err| { @panic(@errorName(err)); };
					
				fld.setEdtcar(vpnl, idx, pFmt02.field.items[@intFromEnum(fp02.fedtcar)].text)
					catch |err| { @panic(@errorName(err)); };
					
				fld.setTask(vpnl, idx, pFmt02.field.items[@intFromEnum(fp02.ftask)].text)
					catch |err| { @panic(@errorName(err)); };
					
				fld.setProtect(vpnl, idx, pFmt02.field.items[@intFromEnum(fp02.fprotect)].zwitch)
					catch |err| { @panic(@errorName(err)); };
					
				pnl.freePanel(pFmt02);
				defer dds.allocatorPnl.destroy(pFmt02);
				return;
			},

			// exit panel field
			.F12 => {
				pnl.freePanel(pFmt02);
				defer dds.allocatorPnl.destroy(pFmt02);
				return;
			},
			else => {},
		}
	}
}

// Order field
pub fn orderField(vpnl: *pnl.PANEL) void {
	var idxligne: usize = 0;
	const allocatorOrder = std.heap.page_allocator;
	var newfield = std.ArrayList(fld.FIELD).init(allocatorOrder);
	var savfield = std.ArrayList(fld.FIELD).init(allocatorOrder);

	var Gkey: grd.GridSelect = undefined;
	defer Gkey.Buf.clearAndFree();

	for (vpnl.field.items) |p| {
		savfield.append(p) 
		catch |err| { @panic(@errorName(err)); };
	}

	var Origine: *grd.GRID = grd.newGridC(
		"Origine",
		2,
		2,
		32,
		grd.gridStyle,
		dds.CADRE.line1,
	);
	defer dds.allocatorPnl.destroy(Origine);

	var Order: *grd.GRID = grd.newGridC(
		"Order",
		2,
		70,
		32,
		grd.gridStyle,
		dds.CADRE.line1,
	);
	defer dds.allocatorPnl.destroy(Order);

	grd.newCell(Origine, "col", 3, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
	grd.newCell(Origine, "name", 6, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgYellow);
	grd.newCell(Origine, "reftype", 20, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
	grd.newCell(Origine, "X", 3, dds.REFTYP.UDIGIT , dds.ForegroundColor.fgGreen);
	grd.newCell(Origine, "Y", 3, dds.REFTYP.UDIGIT, dds.ForegroundColor.fgGreen);
	grd.newCell(Origine, "width", 3, dds.REFTYP.UDIGIT , dds.ForegroundColor.fgGreen);
	grd.newCell(Origine, "scal", 3, dds.REFTYP.UDIGIT, dds.ForegroundColor.fgGreen);
	grd.setHeaders(Origine);

	grd.newCell(Order, "col", 3, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
	grd.newCell(Order, "name", 6, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgYellow);
	grd.newCell(Order, "reftype", 20, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
	grd.newCell(Order, "X", 3, dds.REFTYP.UDIGIT , dds.ForegroundColor.fgCyan);
	grd.newCell(Order, "Y", 3, dds.REFTYP.UDIGIT , dds.ForegroundColor.fgCyan);
	grd.newCell(Order, "width", 3, dds.REFTYP.UDIGIT , dds.ForegroundColor.fgGreen);
	grd.newCell(Order, "scal", 3, dds.REFTYP.UDIGIT, dds.ForegroundColor.fgGreen);
	grd.setHeaders(Order);

	while (true) {
		grd.resetRows(Origine);
		for (vpnl.field.items, 0..) |f, idx| {
			var ridx = usizeToStr(idx);
			
			var posx = usizeToStr(f.posx) ;
			var posy = usizeToStr(f.posy) ;
			var width= usizeToStr(f.width) ;
			var scal = usizeToStr(f.scal) ;

			grd.addRows(Origine, &.{ ridx, f.name, @tagName(f.reftyp), posx , posy, width,scal });
		}

		Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
		if (Gkey.Key == kbd.esc) break;
		if (Gkey.Key == kbd.ctrlV) break;
		if (Gkey.Key == kbd.enter) {
			newfield.append(vpnl.field.items[ strToUsize(Gkey.Buf.items[0])])
				catch |err| { @panic(@errorName(err)); };

			var ridn =usizeToStr(idxligne);
 
			grd.addRows(Order, &.{ ridn, Gkey.Buf.items[1], Gkey.Buf.items[2],
				Gkey.Buf.items[3], Gkey.Buf.items[4], Gkey.Buf.items[5], Gkey.Buf.items[6] });
			idxligne += 1;
			grd.printGridHeader(Order);
			grd.printGridRows(Order);
			var ligne: usize = strToUsize(Gkey.Buf.items[0]);

			_ = vpnl.field.orderedRemove(ligne);
		}
	}

	vpnl.field.clearAndFree();
	vpnl.field = std.ArrayList(fld.FIELD).init(dds.allocatorPnl);
	vpnl.field.clearRetainingCapacity();
	// restor and exit
	if (Gkey.Key == kbd.esc) {
		for (savfield.items) |p| {
			vpnl.field.append(p) catch |err| { @panic(@errorName(err)); };
		}
	}
	// new Order and exit
	else {
		for (newfield.items) |p| {
			vpnl.field.append(p) catch |err| { @panic(@errorName(err)); };
		}
	}

	grd.freeGrid(Origine);
	grd.freeGrid(Order);

	newfield.clearAndFree();
	newfield.deinit();

	savfield.clearAndFree();
	savfield.deinit();

	return;
}
// remove Field
fn removeField(vpnl: *pnl.PANEL) void {
	const allocatorRemove = std.heap.page_allocator;
	var savfield: std.ArrayList(fld.FIELD) = std.ArrayList(fld.FIELD).init(allocatorRemove);

	var Gkey: grd.GridSelect = undefined;
	defer Gkey.Buf.clearAndFree();

	for (vpnl.field.items) |p| {
		savfield.append(p)  
			catch |err| { @panic(@errorName(err)); };
	}

	var Origine: *grd.GRID = grd.newGridC(
		"Origine",
		2,
		2,
		32,
		grd.gridStyle,
		dds.CADRE.line1,
	);
	defer dds.allocatorPnl.destroy(Origine);

	grd.newCell(Origine, "col", 3, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
	grd.newCell(Origine, "name", 6, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgYellow);
	grd.newCell(Origine, "reftype", 20, dds.REFTYP.TEXT_FREE, dds.ForegroundColor.fgGreen);
	grd.newCell(Origine, "X", 3, dds.REFTYP.UDIGIT , dds.ForegroundColor.fgGreen);
	grd.newCell(Origine, "Y", 3, dds.REFTYP.UDIGIT, dds.ForegroundColor.fgGreen);
	grd.newCell(Origine, "width", 3, dds.REFTYP.UDIGIT , dds.ForegroundColor.fgGreen);
	grd.newCell(Origine, "scal", 3, dds.REFTYP.UDIGIT, dds.ForegroundColor.fgGreen);
	grd.setHeaders(Origine);

	while (true) {
		grd.resetRows(Origine);
		for (vpnl.field.items, 0..) |f, idx| {
			var ridx = usizeToStr(idx);
			
			var posx = usizeToStr(f.posx) ;
			var posy = usizeToStr(f.posy) ;
			var width= usizeToStr(f.width) ;
			var scal = usizeToStr(f.scal) ;
			grd.addRows(Origine, &.{ ridx, f.name, @tagName(f.reftyp), posx , posy, width, scal });
		}

		Gkey = grd.ioGridKey(Origine, term.kbd.ctrlV, false);
		if (Gkey.Key == kbd.esc) break;
		if (Gkey.Key == kbd.ctrlV) break;
		if (Gkey.Key == kbd.enter) {
			var ligne: usize = strToUsize(Gkey.Buf.items[0]);

			_ = vpnl.field.orderedRemove(ligne);
		}
	}

	// restor and exit
	if (Gkey.Key == kbd.esc) {
		vpnl.field.clearAndFree();
		vpnl.field = std.ArrayList(fld.FIELD).init(dds.allocatorPnl);
		vpnl.field.clearRetainingCapacity();

		for (savfield.items) |p| {
			vpnl.field.append(p) 
			 catch |err| { @panic(@errorName(err)); };
		}
	}

	grd.freeGrid(Origine);

	savfield.clearAndFree();
	savfield.deinit();
}
 
