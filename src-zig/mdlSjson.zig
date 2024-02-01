const std = @import("std");

// keyboard
const kbd = @import("cursed").kbd;

// panel
const pnl = @import("forms").pnl;
// button
const btn = @import("forms").btn;
// label
const lbl = @import("forms").lbl;
// flied
const fld = @import("forms").fld;
// line horizontal
const lnh = @import("forms").lnh;
// line vertival
const lnv = @import("forms").lnv;

// grid
const grd = @import("grid").grd;
// menu
const mnu = @import("menu").mnu;

// full delete for produc
const forms = @import("forms");


const allocator = std.heap.page_allocator;


pub fn SavJson(XPANEL: *std.ArrayList(pnl.PANEL), nameJson: []const u8) !void {



	
	const cDIR = std.fs.cwd().openDir("dspf",.{})
	catch |err| {@panic(try std.fmt.allocPrint(allocator,"err Open DIR.{any}\n", .{err}));};

	var fjson = cDIR.openFile(nameJson, .{.mode = .read_write}) catch |err| {
				@panic(try std.fmt.allocPrint(allocator,"err Open FILE.{any}\n", .{err}));};
	defer fjson.close();

	const out  = fjson.writer();

	var w = std.json.writeStream( out, .{ .whitespace = .indent_2 });


	const Ipanel = std.enums.EnumIndexer(pnl.Epanel);

	
	w.beginObject()   catch |err| {
				@panic(try std.fmt.allocPrint(allocator,"err Open FILE.{any}\n", .{err}));};

	
	try w.objectField("PANEL");
	const nbrPnl: usize = XPANEL.items.len;
	var np: usize = 0;
	while (np < nbrPnl) : (np += 1) {
		try w.beginArray();
		try w.beginObject();
		var p: usize = 0;
		while (p < Ipanel.count) : (p += 1) {
			switch (Ipanel.keyForIndex(p)) {
				.name => {
					try w.objectField(@tagName(pnl.Epanel.name));
					try w.print("\"{s}\"", .{XPANEL.items[np].name});
				},
				.posx => {
					try w.objectField(@tagName(pnl.Epanel.posx));
					try w.print("{d}", .{XPANEL.items[np].posx});
				},
				.posy => {
					try w.objectField(@tagName(pnl.Epanel.posy));
					try w.print("{d}", .{XPANEL.items[np].posy});
				},
				.lines => {
					try w.objectField(@tagName(pnl.Epanel.lines));
					try w.print("{d}", .{XPANEL.items[np].lines});
				},
				.cols  => {
					try w.objectField(@tagName(pnl.Epanel.cols));
					try w.print("{d}", .{XPANEL.items[np].cols});
				},
				.cadre => {
					try w.objectField(@tagName(pnl.Epanel.cadre));
					try w.print("\"{s}\"", .{@tagName(XPANEL.items[np].frame.cadre)});
				},
				.title => {
					try w.objectField(@tagName(pnl.Epanel.title));
					try w.print("\"{s}\"", .{XPANEL.items[np].frame.title});
				},
				.button => {
					const Ibutton = std.enums.EnumIndexer(btn.Ebutton);
					const nbrBtn: usize = XPANEL.items[np].button.items.len;
					var bp: usize = 0;
					try w.objectField("button");
					try w.beginArray();
					while (bp < nbrBtn) : (bp += 1) {
						try w.beginObject();
						var b: usize = 0;
						while (b < Ibutton.count) : (b += 1) {
							switch (Ibutton.keyForIndex(b)) {
								.name => {
									try w.objectField(@tagName(btn.Ebutton.name));
									try w.print("\"{s}\"", .{XPANEL.items[np].button.items[bp].name});
								},
								.key => {
									try w.objectField(@tagName(btn.Ebutton.key));
									try w.print("\"{s}\"", .{@tagName(XPANEL.items[np].button.items[bp].key)});
								},
								.show => {
									try w.objectField(@tagName(btn.Ebutton.show));
									if (@intFromBool(XPANEL.items[np].button.items[bp].show) == 1)
													try w.print("true", .{})
									else try w.print("false", .{});
								},
								.check => {
									try w.objectField(@tagName(btn.Ebutton.check));
									if (@intFromBool(XPANEL.items[np].button.items[bp].check) == 1)
													try w.print("\"true\"", .{})
									else try w.print("false", .{});
								},
								.title => {
									try w.objectField(@tagName(btn.Ebutton.title));
									try w.print("\"{s}\"", .{XPANEL.items[np].button.items[bp].title});
								},
							}
						}
						try w.endObject();
					}

					try w.endArray();
				},
				.label => {
					const Ilabel = std.enums.EnumIndexer(lbl.Elabel);
					var l: usize = 0;
					const nbrLbl: usize = XPANEL.items[np].label.items.len;

					var lp: usize = 0;
					try w.objectField("label");
					try w.beginArray();
					while (lp < nbrLbl) : (lp += 1) {
						try w.beginObject();
						l = 0;
						while (l < Ilabel.count) : (l += 1) {
							switch (Ilabel.keyForIndex(l)) {
								.name => {
									try w.objectField(@tagName(lbl.Elabel.name));
									try w.print("\"{s}\"", .{XPANEL.items[np].label.items[lp].name});
								},
								.posx => {
									try w.objectField(@tagName(lbl.Elabel.posx));
									try w.print("{d}", .{XPANEL.items[np].label.items[lp].posx});
								},
								.posy => {
									try w.objectField(@tagName(lbl.Elabel.posy));
									try w.print("{d}", .{XPANEL.items[np].label.items[lp].posy});
								},
								.text => {
									try w.objectField(@tagName(lbl.Elabel.text));
									try w.print("\"{s}\"", .{XPANEL.items[np].label.items[lp].text});
								},
								.title => {
									try w.objectField(@tagName(lbl.Elabel.title));
									if (@intFromBool(XPANEL.items[np].label.items[lp].title) == 1)
													try w.print("true", .{})
									else try w.print("false", .{});

								},
							}
						}
						try w.endObject();
					}

					try w.endArray();
				},
				.field => {
					const Ifield = std.enums.EnumIndexer(fld.Efield);
					var f: usize = 0;
					const nbrFld: usize = XPANEL.items[np].field.items.len;

					var fp: usize = 0;
					try w.objectField("field");
					try w.beginArray();
					while (fp < nbrFld) : (fp += 1) {
						try w.beginObject();
						f = 0;
						while (f < Ifield.count) : (f += 1) {
							switch (Ifield.keyForIndex(f)) {
								.name => {
									try w.objectField(@tagName(fld.Efield.name));
									try w.print("\"{s}\"", .{XPANEL.items[np].field.items[fp].name});
								},
								.posx => {
									try w.objectField(@tagName(fld.Efield.posx));
									try w.print("{d}", .{XPANEL.items[np].field.items[fp].posx});
								},
								.posy => {
									try w.objectField(@tagName(fld.Efield.posy));
									try w.print("{d}", .{XPANEL.items[np].field.items[fp].posy});
								},
								.reftyp => {
									try w.objectField(@tagName(fld.Efield.reftyp));
									try w.print("\"{s}\"", .{@tagName(XPANEL.items[np].field.items[fp].reftyp)});
								},
								.width => {
									try w.objectField(@tagName(fld.Efield.width));
									try w.print("{d}", .{XPANEL.items[np].field.items[fp].width});
								},
								.scal => {
									try w.objectField(@tagName(fld.Efield.scal));
									try w.print("{d}", .{XPANEL.items[np].field.items[fp].scal});
								},
								.text => {
									try w.objectField(@tagName(fld.Efield.text));
									try w.print("\"\"", .{});
								},
								.requier => {
									try w.objectField(@tagName(fld.Efield.requier));
									if (@intFromBool(XPANEL.items[np].field.items[fp].requier) == 1)
													try w.print("true", .{})
									else try w.print("false", .{});
								},
								.protect => {
									try w.objectField(@tagName(fld.Efield.protect));
									if (@intFromBool(XPANEL.items[np].field.items[fp].protect) == 1)
													try w.print("true", .{})
									else try w.print("false", .{});
								},
								.edtcar => {
									try w.objectField(@tagName(fld.Efield.edtcar));
									try w.print("\"{s}\"", .{XPANEL.items[np].field.items[fp].edtcar});
								},
								.errmsg => {
									try w.objectField(@tagName(fld.Efield.errmsg));
									try w.print("\"{s}\"", .{XPANEL.items[np].field.items[fp].errmsg});
								},
								.help => {
									try w.objectField(@tagName(fld.Efield.help));
									try w.print("\"{s}\"", .{XPANEL.items[np].field.items[fp].help});
								},
								.procfunc => {
									try w.objectField(@tagName(fld.Efield.procfunc));
									try w.print("\"{s}\"", .{XPANEL.items[np].field.items[fp].procfunc});
								},
								.proctask => {
									try w.objectField(@tagName(fld.Efield.proctask));
									try w.print("\"{s}\"", .{XPANEL.items[np].field.items[fp].proctask});
								},
								.progcall => {
									try w.objectField(@tagName(fld.Efield.progcall));
									try w.print("\"{s}\"", .{XPANEL.items[np].field.items[fp].progcall});
								},
								.regex=> {
									try w.objectField(@tagName(fld.Efield.regex));
									try w.print("\"\"", .{});
								},

							}
						}
						try w.endObject();
					}

					try w.endArray();
				},
				.linev => {
					const Ilinev = std.enums.EnumIndexer(lnv.Elinev);
					var lx: usize = 0;
					const nbrLineh: usize = XPANEL.items[np].linev.items.len;

					var lv: usize = 0;
					try w.objectField("linev");
					try w.beginArray();
					while (lv < nbrLineh) : (lv += 1) {
						try w.beginObject();
						lx = 0;
						while (lx < Ilinev.count) : (lx += 1) {
							switch (Ilinev.keyForIndex(lx)) {
								.name => {
									try w.objectField(@tagName(lnv.Elinev.name));
									try w.print("\"{s}\"", .{XPANEL.items[np].linev.items[lv].name});
								},
								.posx => {
									try w.objectField(@tagName(lnv.Elinev.posx));
									try w.print("{d}", .{XPANEL.items[np].linev.items[lv].posx});
								},
								.posy => {
									try w.objectField(@tagName(lnv.Elinev.posy));
									try w.print("{d}", .{XPANEL.items[np].linev.items[lv].posy});
								},
								.lng => {
									try w.objectField(@tagName(lnv.Elinev.lng));
									try w.print("{d}", .{XPANEL.items[np].linev.items[lv].lng});
								},
								.trace => {
									try w.objectField(@tagName(lnv.Elinev.trace));
									try w.print("\"{s}\"", .{
											@tagName(XPANEL.items[np].linev.items[lv].trace)});
								},
							}
						}
						try w.endObject();
					}
					try w.endArray();
				},
				.lineh => {
					const Ilineh = std.enums.EnumIndexer(lnh.Elineh);
					var ly: usize = 0;
					const nbrLineh: usize = XPANEL.items[np].lineh.items.len;

					var lh: usize = 0;
					try w.objectField("lineh");
					try w.beginArray();
					while (lh < nbrLineh) : (lh += 1) {
						try w.beginObject();
						ly = 0;
						while (ly < Ilineh.count) : (ly += 1) {
							switch (Ilineh.keyForIndex(ly)) {
								.name => {
									try w.objectField(@tagName(lnh.Elineh.name));
									try w.print("\"{s}\"", .{XPANEL.items[np].lineh.items[lh].name});
								},
								.posx => {
									try w.objectField(@tagName(lnh.Elineh.posx));
									try w.print("{d}", .{XPANEL.items[np].lineh.items[lh].posx});
								},
								.posy => {
									try w.objectField(@tagName(lnh.Elineh.posy));
									try w.print("{d}", .{XPANEL.items[np].lineh.items[lh].posy});
								},
								.lng => {
									try w.objectField(@tagName(lnh.Elineh.lng));
									try w.print("{d}", .{XPANEL.items[np].lineh.items[lh].lng});
								},
								.trace => {
									try w.objectField(@tagName(lnh.Elineh.trace));
									try w.print("\"{s}\"", .{
											@tagName(XPANEL.items[np].lineh.items[lh].trace)});
								},
							}
						}
						try w.endObject();
					}
					try w.endArray();
				},
			}
		}
		try w.endObject();
		try w.endArray();
	}
	try w.endObject();
return ;
}
