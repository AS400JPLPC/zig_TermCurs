	///-----------------------
	/// prog mdlRjson
	/// zig 0.13.0 dev
	///-----------------------
const std = @import("std");

// term

const term = @import("cursed");
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


pub const allocatorJson = std.heap.page_allocator;


// tools utility
const utl = @import("utils");

//..............................//
// define Ctype JSON
const Ctype = enum { null, bool, integer, float, number_string, string, array, object, decimal_string };

//..............................//
// define BUTTON JSON
//..............................//

const DEFBUTTON = struct { key: kbd, show: bool, check: bool, title: []const u8 };

const Jbutton = enum { key, show, check, title };

//..............................//
// define LABEL JSON
//..............................//

const DEFLABEL = struct { name: []const u8, posx: usize, posy: usize, text: []const u8, title: bool };

const Jlabel = enum { name, posx, posy, text, title };

//..............................//
// define FIELD JSON
//..............................//

pub const DEFFIELD = struct {
	name: []const u8,
	posx: usize,
	posy: usize,
	reftyp: forms.REFTYP,
	width: usize,
	scal: usize,
	requier: bool, // requier or FULL
	protect: bool, // only display
	edtcar: []const u8, // edtcar ex: monnaie

	regex: []const u8, //contrôle regex
	errmsg: []const u8, //message this field

	help: []const u8, //help this field

	text: []const u8,
	zwitch: bool, // CTRUE CFALSE

	procfunc: []const u8, //name proc

	proctask: []const u8, //name proc

	progcall: []const u8, //name program

	typecall: []const u8, //type SH APPTERM

	parmcall: bool, // parm Yes/No

	actif: bool,
};

const Jfield = enum { name, posx, posy, reftyp, width, scal, text, zwitch, requier, protect, edtcar, errmsg,
	 help, procfunc, proctask, progcall, typecall, parmcall, regex };

//..............................//
// define LINEV JSON
//..............................//

const DEFLINEV = struct { name: []const u8, posx: usize, posy: usize, lng: usize, trace: forms.LINE };

const Jlinev = enum { name, posx, posy, lng, trace };

//..............................//
// define LINEH JSON
//..............................//

const DEFLINEH = struct { name: []const u8, posx: usize, posy: usize, lng: usize, trace: forms.LINE };

const Jlineh = enum { name, posx, posy, lng, trace };

//..............................//
// define CELL JSON
//..............................//

const DEFCELL = struct { text: []const u8, long: usize, reftyp: grd.REFTYP,	
						posy: usize, edtcar: []const u8, atrCell: term.ForegroundColor };

const Jcell = enum {text, long, reftyp, posy, edtcar, atrcell };

//..............................//
// define GRID JSON
//..............................//

const ArgData = struct {
		buf: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(allocatorJson),
	};

const RGRID = struct { name: []const u8, posx: usize, posy: usize , pageRows: usize, separator: []const u8,
	 cadre: grd.CADRE, cells: std.ArrayList(DEFCELL), data: std.MultiArrayList(ArgData)};

const Jgrid = enum {name, posx, posy, pagerows, separator, cadre, cells, data};


//..............................//
// define MENU JSON
//..............................//

const DEFMENU = struct { name: []const u8, posx: usize, posy: usize , cadre: mnu.CADRE, mnuvh: mnu.MNUVH, 
						xitems : [][] const u8};

const Jmenu = enum {name, posx, posy, cadre, mnuvh, xitems};
const Jitem = enum {text};

	pub fn initMenuDef(
		vname: []const u8,
		vposx: usize,
		vposy: usize,
		vcadre: mnu.CADRE,
		vmnuvh: mnu.MNUVH,
		vxitems : [][] const u8	) 
		mnu.DEFMENU{
			const xmenu = mnu.DEFMENU{
			.name = vname,
			.posx = vposx,
			.posy = vposy,
			.cadre = vcadre,
			.mnuvh = vmnuvh,
			.xitems = vxitems
			};
		return xmenu;
	}
//..............................//
// define PANEL JSON
//..............................//
const RPANEL = struct { name: []const u8, posx: usize, posy: usize, lines: usize, cols: usize,
	cadre: forms.CADRE, title: []const u8,
	button: std.ArrayList(DEFBUTTON),
	label: std.ArrayList(DEFLABEL),
	field: std.ArrayList(DEFFIELD),
	linev: std.ArrayList(DEFLINEV),
	lineh: std.ArrayList(DEFLINEH) };

const Jpanel = enum { name, posx, posy, lines, cols, cadre, title, button, label, field, linev, lineh };

var NPANEL = std.ArrayList(RPANEL).init(allocatorJson);
var NGRID  = std.ArrayList(RGRID ).init(allocatorJson);
var NMENU  = std.ArrayList(DEFMENU ).init(allocatorJson);

//..............................//
//  string return enum
//..............................//

fn strToEnum(comptime EnumTag: type, vtext: []const u8) EnumTag {
	inline for (@typeInfo(EnumTag).Enum.fields) |f| {
		if (std.mem.eql(u8, f.name, vtext)) return @field(EnumTag, f.name);
	}

	var buffer: [128]u8 = [_]u8{0} ** 128;
	const result = std.fmt.bufPrintZ(buffer[0..], "invalid Text {s} for strToEnum ", .{vtext}) catch unreachable;
	@panic(result);
}

//..............................//
// JSON
//..............................//

const T = struct {
	x: ?std.json.Value,
	var err: bool = false;

	pub fn init(self: std.json.Value) T {
		return T{ .x = self };
	}

	pub fn get(self: T, query: []const u8) T {
		err = false;

		if (self.x.?.object.get(query) == null) {
			err = true;
			return T.init(self.x.?);
		}

		return T.init(self.x.?.object.get(query).?);
	}

	pub fn ctrlPack(self: T, Xtype: Ctype) bool {
		var out = std.ArrayList(u8).init(allocatorJson);
		defer out.deinit();

		switch (self.x.?) {
			.null => {
				if (Xtype != .null) return false;
			},

			.bool => {
				if (Xtype != Ctype.bool) return false;
			},

			.integer => {
				if (Xtype != Ctype.integer) return false;
			},

			.float => {
				if (Xtype != Ctype.float) return false;
			},

			.number_string => {
				if (Xtype != Ctype.number_string) return false;
			},

			.string => {
				if (Xtype != Ctype.string) return false;
				if (Xtype == Ctype.decimal_string)
					return utl.isDecimalStr(std.fmt.allocPrint(allocatorJson, "{s}", .{self.x.?.string})
						catch unreachable);
			},

			.array => {
				if (Xtype != Ctype.array) return false;
			},

			.object => {
				if (Xtype != Ctype.object) return false;
				//try printPack(self,Xtype);
			},
		}

		return true;
	}

	pub fn index(self: T, i: usize) T {
		err = false;
		switch (self.x.?) {
			.array => {
				if (i > self.x.?.array.items.len) {
					std.debug.print("ERROR::{s}::\n\n", .{"index out of bounds"});
					err = true;
					return T.init(self.x.?);
				}
			},
			else => {
				std.debug.print("ERROR::{s}:: {s}\n\n", .{ "Not array", @tagName(self.x.?) });
				err = true;
				return T.init(self.x.?);
			},
		}
		return T.init(self.x.?.array.items[i]);
	}
};

//..............................//
// DECODEUR
//..............................//

pub fn jsonDecode(my_json: []const u8) !void {
	var val: T = undefined;

	const parsed = try std.json.parseFromSlice(std.json.Value, allocatorJson, my_json, .{});
	defer parsed.deinit();

	const json = T.init(parsed.value);

//----------------------------------------------------
// PANEL
//----------------------------------------------------

	val = json.get("PANEL");

	const nbrPanel = val.x.?.array.items.len;

	var p: usize = 0;

	const Rpanel = std.enums.EnumIndexer(Jpanel);

	const Rbutton = std.enums.EnumIndexer(Jbutton);

	const Rlabel = std.enums.EnumIndexer(Jlabel);

	const Rfield = std.enums.EnumIndexer(Jfield);

	const Rlinev = std.enums.EnumIndexer(Jlinev);

	const Rlineh = std.enums.EnumIndexer(Jlineh);

	while (p < nbrPanel) : (p += 1) {
		var n: usize = 0; // index

		NPANEL.append(RPANEL{ .name = "", .posx = 0, .posy = 0, .lines = 0, .cols = 0,
			.cadre = forms.CADRE.line0, .title = "",
			.button = std.ArrayList(DEFBUTTON).init(allocatorJson),
			.label = std.ArrayList(DEFLABEL).init(allocatorJson),
			.field = std.ArrayList(DEFFIELD).init(allocatorJson),
			.linev = std.ArrayList(DEFLINEV).init(allocatorJson),
			.lineh = std.ArrayList(DEFLINEH).init(allocatorJson) }) catch unreachable;

		while (n < Rpanel.count) : (n += 1) {
			var v: usize = 0; // index
			var y: usize = 0; // array len
			var z: usize = 0; // compteur
			var b: usize = 0; // button
			var l: usize = 0; // label
			var f: usize = 0; // field
			var vx: usize = 0; // line vertical
			var hx: usize = 0; // line horizontal

			switch (Rpanel.keyForIndex(n)) {
				Jpanel.name => {
					val = json.get("PANEL").index(p).get(@tagName(Rpanel.keyForIndex(n)));
					if (T.err) break;

					if (val.ctrlPack(Ctype.string))
						NPANEL.items[p].name = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
					else
						@panic(try std.fmt.allocPrint(allocatorJson, "Json  Panel err_Field :{s}\n",
							.{@tagName(Rpanel.keyForIndex(n))}));
				},
				Jpanel.posx => {
					val = json.get("PANEL").index(p).get(@tagName(Rpanel.keyForIndex(n)));

					if (val.ctrlPack(Ctype.integer))
						NPANEL.items[p].posx = @intCast(val.x.?.integer)
					else
						@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
							.{@tagName(Rpanel.keyForIndex(n))}));
				},
				Jpanel.posy => {
					val = json.get("PANEL").index(p).get(@tagName(Rpanel.keyForIndex(n)));

					if (val.ctrlPack(Ctype.integer))
						NPANEL.items[p].posy = @intCast(val.x.?.integer)
					else
						@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
							.{@tagName(Rpanel.keyForIndex(n))}));
				},
				Jpanel.lines => {
					val = json.get("PANEL").index(p).get(@tagName(Rpanel.keyForIndex(n)));

					if (val.ctrlPack(Ctype.integer))
						NPANEL.items[p].lines = @intCast(val.x.?.integer)
					else
						@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
							.{@tagName(Rpanel.keyForIndex(n))}));
				},
				Jpanel.cols => {
					val = json.get("PANEL").index(p).get(@tagName(Rpanel.keyForIndex(n)));

					if (val.ctrlPack(Ctype.integer))
						NPANEL.items[p].cols = @intCast(val.x.?.integer)
					else
						@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
							.{@tagName(Rpanel.keyForIndex(n))}));
				},
				Jpanel.cadre => {
					val = json.get("PANEL").index(p).get(@tagName(Rpanel.keyForIndex(n)));

					if (val.ctrlPack(Ctype.string)) {
						NPANEL.items[p].cadre = strToEnum(forms.CADRE, val.x.?.string);
					} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
						.{@tagName(Rpanel.keyForIndex(n))}));
				},
				Jpanel.title => {
					val = json.get("PANEL").index(p).get(@tagName(Rpanel.keyForIndex(n)));

					if (val.ctrlPack(Ctype.string))
						NPANEL.items[p].title = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
					else
						@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
							.{@tagName(Rpanel.keyForIndex(n))}));
				},
				//===============================================================================
				// BUTTON
				//===============================================================================
				Jpanel.button => {
					val = json.get("PANEL").index(p).get(@tagName(Rpanel.keyForIndex(n)));
					if (T.err) break;

					var bt: DEFBUTTON = undefined;
					y = val.x.?.array.items.len;
					z = 0;
					b = 0;

					while (z < y) : (z += 1) {
						v = 0;
						while (v < Rbutton.count) : (v += 1) {
							val = json.get("PANEL").index(p).get("button").index(b)
								.get(@tagName(Rbutton.keyForIndex(v)));

							switch (Rbutton.keyForIndex(v)) {
								Jbutton.key => {
									if (val.ctrlPack(Ctype.string)) {
										bt.key = strToEnum(kbd, val.x.?.string);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rbutton.keyForIndex(v)) }));
								},
								Jbutton.show => {
									if (val.ctrlPack(Ctype.bool))
										bt.show = val.x.?.bool
									else
										@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
											.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rbutton.keyForIndex(v)) }));
								},
								Jbutton.check => {
									if (val.ctrlPack(Ctype.bool))
										bt.check = val.x.?.bool
									else
										@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
											.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rbutton.keyForIndex(v)) }));
								},
								Jbutton.title => {
									if (val.ctrlPack(Ctype.string))
										bt.title = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
									else
										@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
											.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rbutton.keyForIndex(v)) }));

									NPANEL.items[p].button.append(bt) catch unreachable;
								},
							}
						}
						b += 1;
					}
				},
				//===============================================================================
				// LABEL
				//===============================================================================

				Jpanel.label => {
					val = json.get("PANEL").index(p).get(@tagName(Rpanel.keyForIndex(n)));
					if (T.err) break;

					var lb: DEFLABEL = undefined;
					y = val.x.?.array.items.len;
					z = 0;
					l = 0;
					while (z < y) : (z += 1) {
						v = 0;
						while (v < Rlabel.count) : (v += 1) {
							val = json.get("PANEL").index(p).get("label").index(l)
								.get(@tagName(Rlabel.keyForIndex(v)));

							switch (Rlabel.keyForIndex(v)) {
								Jlabel.name => {
									if (val.ctrlPack(Ctype.string))
										lb.name = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
									else
										@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
											.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rlabel.keyForIndex(v)) }));
								},
								Jlabel.posx => {
									if (val.ctrlPack(Ctype.integer)) {
										lb.posx = @intCast(val.x.?.integer);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rlabel.keyForIndex(v)) }));
								},
								Jlabel.posy => {
									if (val.ctrlPack(Ctype.integer)) {
										lb.posy = @intCast(val.x.?.integer);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rlabel.keyForIndex(v)) }));
								},
								Jlabel.text => {
									if (val.ctrlPack(Ctype.string))
										lb.text = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
									else
										@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
											.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rlabel.keyForIndex(v)) }));
								},
								Jlabel.title => {
									if (val.ctrlPack(Ctype.bool))
										lb.title = val.x.?.bool
									else
										@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
											.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rlabel.keyForIndex(v)) }));

									NPANEL.items[p].label.append(lb) catch unreachable;
								},
							}
						}

						l += 1;
					}
				},
				//===============================================================================
				// FIELD
				//===============================================================================

				Jpanel.field => {
					val = json.get("PANEL").index(p).get(@tagName(Rpanel.keyForIndex(n)));
					if (T.err) break;

					var sreftyp: []const u8 = undefined;

					var lf: DEFFIELD = undefined;
					y = val.x.?.array.items.len;
					if (y == 0) break;

					z = 0;
					f = 0;
					while (z < y) : (z += 1) {
						v = 0;
						while (v < Rfield.count) : (v += 1) {
							val = json.get("PANEL").index(p).get("field").index(f)
								.get(@tagName(Rfield.keyForIndex(v)));

							switch (Rfield.keyForIndex(v)) {
								Jfield.name => {
									if (val.ctrlPack(Ctype.string))
										lf.name = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
									else
										@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
											.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},

								Jfield.posx => {
									if (val.ctrlPack(Ctype.integer)) {
										lf.posx = @intCast(val.x.?.integer);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},

								Jfield.posy => {
									if (val.ctrlPack(Ctype.integer)) {
										lf.posy = @intCast(val.x.?.integer);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},

								Jfield.reftyp => {
									if (val.ctrlPack(Ctype.string)) {
										sreftyp = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string});
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));

									lf.reftyp = strToEnum(forms.REFTYP, sreftyp);
								},

								Jfield.width => {
									if (val.ctrlPack(Ctype.integer)) {
										lf.width = @intCast(val.x.?.integer);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},

								Jfield.scal => {
									if (val.ctrlPack(Ctype.integer)) {
										lf.scal = @intCast(val.x.?.integer);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},

								Jfield.text => {
									lf.text = "";
								},

								Jfield.zwitch => {
									lf.zwitch = false;
								},

								Jfield.requier => {
									if (val.ctrlPack(Ctype.bool)) {
										lf.requier = val.x.?.bool;
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},

								Jfield.protect => {
									if (val.ctrlPack(Ctype.bool)) {
										lf.protect = val.x.?.bool;
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},

								Jfield.edtcar => {
									if (val.ctrlPack(Ctype.string)) {
										lf.edtcar = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string});
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},

								Jfield.errmsg => {
									if (val.ctrlPack(Ctype.string)) {
										lf.errmsg = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string});
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},

								Jfield.help => {
									if (val.ctrlPack(Ctype.string)) {
										lf.help = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string});
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},

								Jfield.procfunc => {
									if (val.ctrlPack(Ctype.string)) {
										lf.procfunc = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string});
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},

								Jfield.proctask => {
									if (val.ctrlPack(Ctype.string)) {
										lf.proctask = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string});
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},

								Jfield.progcall => {
									if (val.ctrlPack(Ctype.string)) {
										lf.progcall = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string});
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},

								Jfield.typecall => {
									if (val.ctrlPack(Ctype.string)) {
										lf.typecall = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string});
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},

								Jfield.parmcall => {
									if (val.ctrlPack(Ctype.bool)) {
										lf.parmcall = val.x.?.bool;
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rfield.keyForIndex(v)) }));
								},
								
								Jfield.regex => {
									lf.regex = "";

									NPANEL.items[p].field.append(lf) catch unreachable;
								},
							}
						}
						f += 1;
					}
				},
				//===============================================================================
				// LINEV
				//===============================================================================

				Jpanel.linev => {
					val = json.get("PANEL").index(p).get(@tagName(Rpanel.keyForIndex(n)));
					if (T.err) break;

					var lv: DEFLINEV = undefined;
					y = val.x.?.array.items.len;
					z = 0;
					vx = 0;
					while (z < y) : (z += 1) {
						v = 0;
						while (v < Rlinev.count) : (v += 1) {
							val = json.get("PANEL").index(p).get("linev").index(vx)
								.get(@tagName(Rlinev.keyForIndex(v)));

							switch (Rlinev.keyForIndex(v)) {
								Jlinev.name => {
									if (val.ctrlPack(Ctype.string))
										lv.name = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
									else
										@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
											.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rlinev.keyForIndex(v)) }));
								},
								Jlinev.posx => {
									if (val.ctrlPack(Ctype.integer)) {
										lv.posx = @intCast(val.x.?.integer);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rlinev.keyForIndex(v)) }));
								},
								Jlinev.posy => {
									if (val.ctrlPack(Ctype.integer)) {
										lv.posy = @intCast(val.x.?.integer);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rlinev.keyForIndex(v)) }));
								},
								Jlinev.lng => {
									if (val.ctrlPack(Ctype.integer)) {
										lv.lng = @intCast(val.x.?.integer);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rlinev.keyForIndex(v)) }));
								},
								Jlinev.trace => {
									if (val.ctrlPack(Ctype.string)) {
										lv.trace = strToEnum(forms.LINE, val.x.?.string);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
										.{@tagName(Rlinev.keyForIndex(n))}));

									NPANEL.items[p].linev.append(lv) catch unreachable;
								},
							}
						}

						vx += 1;
					}
				},
				//===============================================================================
				// LINEH
				//===============================================================================

				Jpanel.lineh => {
					val = json.get("PANEL").index(p).get(@tagName(Rpanel.keyForIndex(n)));
					if (T.err) break;

					var lh: DEFLINEH = undefined;
					y = val.x.?.array.items.len;
					z = 0;
					hx = 0;
					while (z < y) : (z += 1) {
						v = 0;
						while (v < Rlineh.count) : (v += 1) {
							val = json.get("PANEL").index(p).get("lineh").index(hx)
								.get(@tagName(Rlineh.keyForIndex(v)));

							switch (Rlineh.keyForIndex(v)) {
								Jlineh.name => {
									if (val.ctrlPack(Ctype.string))
										lh.name = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
									else
										@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
											.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rlineh.keyForIndex(v)) }));
								},
								Jlineh.posx => {
									if (val.ctrlPack(Ctype.integer)) {
										lh.posx = @intCast(val.x.?.integer);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rlineh.keyForIndex(v)) }));
								},
								Jlineh.posy => {
									if (val.ctrlPack(Ctype.integer)) {
										lh.posy = @intCast(val.x.?.integer);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rlineh.keyForIndex(v)) }));
								},
								Jlineh.lng => {
									if (val.ctrlPack(Ctype.integer)) {
										lh.lng = @intCast(val.x.?.integer);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
										.{ @tagName(Rpanel.keyForIndex(n)), @tagName(Rlineh.keyForIndex(v)) }));
								},
								Jlineh.trace => {
									if (val.ctrlPack(Ctype.string)) {
										lh.trace = strToEnum(forms.LINE, val.x.?.string);
									} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
										.{@tagName(Rlineh.keyForIndex(n))}));

									NPANEL.items[p].lineh.append(lh) catch unreachable;
								},
							}
						}

						hx += 1;
					}
				},
			}
		}
	}

//----------------------------------------------------
// GRID
//----------------------------------------------------

	val = json.get("GRID");
	if (!T.err)  {
	const nbrGrid = val.x.?.array.items.len;
	var g: usize = 0;
	const Rcell = std.enums.EnumIndexer(Jcell);
	const Rgrid = std.enums.EnumIndexer(Jgrid);
	
	while (g < nbrGrid) : (g += 1) {
		
		NGRID.append(RGRID{.name = "", .posx = 0, .posy = 0, .pageRows = 0 ,
			.separator = " ", .cadre = grd.CADRE.line1,
			.cells = std.ArrayList(DEFCELL).init(allocatorJson),
			.data  = std.MultiArrayList(ArgData){}	} 
		) catch unreachable;

		var n: usize = 0; // index
	while (n < Rgrid.count) : (n += 1) {
		var v: usize = 0; // index
		var y: usize = 0; // array len
		var z: usize = 0; // compteur
		var c: usize = 0; // cell
		switch (Rgrid.keyForIndex(n)) {
			Jgrid.name => {
					val = json.get("GRID").index(g).get(@tagName(Rgrid.keyForIndex(n)));
					if (T.err) break;

					if (val.ctrlPack(Ctype.string))
						NGRID.items[g].name = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
					else
						@panic(try std.fmt.allocPrint(allocatorJson, "Json  Panel err_Field :{s}\n",
							.{@tagName(Rgrid.keyForIndex(n))}));
			},
			Jgrid.posx => {
				val = json.get("GRID").index(g).get(@tagName(Rgrid.keyForIndex(n)));

				if (val.ctrlPack(Ctype.integer))
					NGRID.items[g].posx = @intCast(val.x.?.integer)
				else
					@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
						.{@tagName(Rgrid.keyForIndex(n))}));
			},
			Jgrid.posy => {
				val = json.get("GRID").index(g).get(@tagName(Rgrid.keyForIndex(n)));

				if (val.ctrlPack(Ctype.integer))
					NGRID.items[g].posy = @intCast(val.x.?.integer)
				else
					@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
						.{@tagName(Rgrid.keyForIndex(n))}));
			},
			Jgrid.pagerows => {
				val = json.get("GRID").index(g).get(@tagName(Rgrid.keyForIndex(n)));

				if (val.ctrlPack(Ctype.integer))
					NGRID.items[g].pageRows = @intCast(val.x.?.integer)
				else
					@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
						.{@tagName(Rgrid.keyForIndex(n))}));
			},
			Jgrid.separator => {
					val = json.get("GRID").index(g).get(@tagName(Rgrid.keyForIndex(n)));
					if (T.err) break;

					if (val.ctrlPack(Ctype.string))
						NGRID.items[g].separator = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
					else
						@panic(try std.fmt.allocPrint(allocatorJson, "Json  Panel err_Field :{s}\n",
							.{@tagName(Rgrid.keyForIndex(n))}));
			},
			Jgrid.cadre => {
				val = json.get("GRID").index(g).get(@tagName(Rgrid.keyForIndex(n)));

				if (val.ctrlPack(Ctype.string)) {
					NGRID.items[g].cadre = strToEnum(grd.CADRE, val.x.?.string);
				} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
					.{@tagName(Rgrid.keyForIndex(n))}));
			},
			Jgrid.cells => {
				val = json.get("GRID").index(g).get(@tagName(Rgrid.keyForIndex(n)));
				if (T.err) break;

				var cl: DEFCELL = undefined;
				var sreftyp: []const u8 = undefined;
				var satrcell: []const u8 = undefined;
				y = val.x.?.array.items.len;
				z = 0;
				c = 0;
				while (z < y) : (z += 1) {
					v = 0;
					while (v < Rcell.count) : (v += 1  ) {
						val = json.get("GRID").index(g).get("cells").index(c)
								.get(@tagName(Rcell.keyForIndex(v)));
							
						switch (Rcell.keyForIndex(v)) {
							Jcell.text => {
								if (val.ctrlPack(Ctype.string))
									cl.text = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
								else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
									.{ @tagName(Rgrid.keyForIndex(g)), @tagName(Rgrid.keyForIndex(v)) }));
							},
							Jcell.long => {
								if (val.ctrlPack(Ctype.integer))
									cl.long = @intCast(val.x.?.integer)
								else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
									.{ @tagName(Rgrid.keyForIndex(g)), @tagName(Rgrid.keyForIndex(v)) }));

							},
							Jcell.reftyp => {
								if (val.ctrlPack(Ctype.string)) 
									sreftyp = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
								else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
									.{ @tagName(Rgrid.keyForIndex(g)), @tagName(Rgrid.keyForIndex(v)) }));
								cl.reftyp = strToEnum(grd.REFTYP, sreftyp);
							},
							Jcell.posy => {
								if (val.ctrlPack(Ctype.integer))
								cl.posy = @intCast(val.x.?.integer)
								else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
									.{ @tagName(Rgrid.keyForIndex(g)), @tagName(Rgrid.keyForIndex(v)) }));

							},
							Jcell.edtcar => {
								if (val.ctrlPack(Ctype.string))
								cl.edtcar = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
								else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
									.{ @tagName(Rgrid.keyForIndex(g)), @tagName(Rgrid.keyForIndex(v)) }));
							},
							Jcell.atrcell => {
								if (val.ctrlPack(Ctype.string)) 
									satrcell = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
								else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
									.{ @tagName(Rgrid.keyForIndex(g)), @tagName(Rgrid.keyForIndex(v)) }));
								cl.atrCell = strToEnum(term.ForegroundColor, satrcell);
								NGRID.items[g].cells.append(cl) catch |err| {@panic(@errorName(err));};
							}
						}
					}
					c += 1 ;
				}
			},
			Jgrid.data => {}
		}
	} // Rgrid
	} //nbrGrid
	} // Terr
//----------------------------------------------------
// MENU
//----------------------------------------------------

	val = json.get("MENU");
	if (!T.err)  {
	const nbrMenu = val.x.?.array.items.len;
	var m: usize = 0;
	const Ritem = std.enums.EnumIndexer(Jitem);
	const Rmenu = std.enums.EnumIndexer(Jmenu);
	
	while (m < nbrMenu) : (m += 1) {
		
		NMENU.append(DEFMENU{.name = "", .posx = 0, .posy = 0,
			 .cadre = mnu.CADRE.line1, .mnuvh = mnu.MNUVH.vertical ,
			 .xitems  = undefined,
			 }
	 
		) catch unreachable;

		var n: usize = 0; // index
	while (n < Rmenu.count) : (n += 1) {
		var v: usize = 0; // index
		var y: usize = 0; // array len
		var z: usize = 0; // compteur
		var c: usize = 0; // cell
		switch (Rmenu.keyForIndex(n)) {
			Jmenu.name => {
					val = json.get("MENU").index(m).get(@tagName(Rmenu.keyForIndex(n)));
					if (T.err) break;

					if (val.ctrlPack(Ctype.string))
						NMENU.items[m].name = try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string})
					else
						@panic(try std.fmt.allocPrint(allocatorJson, "Json  Panel err_Field :{s}\n",
							.{@tagName(Rmenu.keyForIndex(n))}));
			},
			Jmenu.posx => {
				val = json.get("MENU").index(m).get(@tagName(Rmenu.keyForIndex(n)));

				if (val.ctrlPack(Ctype.integer))
					NMENU.items[m].posx = @intCast(val.x.?.integer)
				else
					@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
						.{@tagName(Rmenu.keyForIndex(n))}));
			},
			Jmenu.posy => {
				val = json.get("MENU").index(m).get(@tagName(Rmenu.keyForIndex(n)));

				if (val.ctrlPack(Ctype.integer))
					NMENU.items[m].posy = @intCast(val.x.?.integer)
				else
					@panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
						.{@tagName(Rmenu.keyForIndex(n))}));
			},
			Jmenu.cadre => {
				val = json.get("MENU").index(m).get(@tagName(Rmenu.keyForIndex(n)));

				if (val.ctrlPack(Ctype.string)) {
					NMENU.items[m].cadre = strToEnum(mnu.CADRE, val.x.?.string);
				} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
					.{@tagName(Rmenu.keyForIndex(n))}));
			},
			Jmenu.mnuvh => {
				val = json.get("MENU").index(m).get(@tagName(Rmenu.keyForIndex(n)));

				if (val.ctrlPack(Ctype.string)) {
					NMENU.items[m].mnuvh = strToEnum(mnu.MNUVH, val.x.?.string);
				} else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}\n",
					.{@tagName(Rmenu.keyForIndex(n))}));
			},
			Jmenu.xitems => {
				val = json.get("MENU").index(m).get(@tagName(Rmenu.keyForIndex(n)));
				if (T.err) break;
				var xmenu =  std.ArrayList([]const u8).init(allocatorJson);
				defer xmenu.clearAndFree();
				y = val.x.?.array.items.len;
				z = 0;
				c = 0;
				while (z < y) : (z += 1) {
					v = 0;
					while (v < Ritem.count) : (v += 1  ) {
						val = json.get("MENU").index(m).get("xitems").index(c)
								.get(@tagName(Ritem.keyForIndex(v)));
							
						switch (Ritem.keyForIndex(v)) {
							Jitem.text => {
								if (val.ctrlPack(Ctype.string))
								try xmenu.append(try std.fmt.allocPrint(allocatorJson, "{s}", .{val.x.?.string}))
								else @panic(try std.fmt.allocPrint(allocatorJson, "Json  err_Field :{s}.{s}\n",
									.{ @tagName(Rmenu.keyForIndex(m)), @tagName(Rmenu.keyForIndex(v)) }));
							}
						}
					}
					c += 1 ;
				}
				
				NMENU.items[m].xitems = try allocatorJson.alloc([]const u8, y);
				for (xmenu.items, 0.. ) |_,idx | {
					NMENU.items[m].xitems[idx]  = xmenu.items[idx];  
				}
			},
		}
	} // nbrMenu
	} // Rmenu
	} // Terr
	
}

//..............................//
// Main function
//..............................//
pub fn RstJson(XPANEL: *std.ArrayList(pnl.PANEL), 
		XGRID: *std.ArrayList(grd.GRID),
		XMENU: *std.ArrayList(mnu.DEFMENU),
		dir: [] const u8 ,
		nameJson: []const u8) !void {

	const cDIR = std.fs.cwd().openDir(dir, .{}) catch |err| {
		@panic(try std.fmt.allocPrint(allocatorJson, "err Open.{any}\n", .{err}));
	};

	var my_file = cDIR.openFile(nameJson, .{}) catch |err| {
		@panic(try std.fmt.allocPrint(allocatorJson, "err Open.{any}\n", .{err}));
	};
	defer my_file.close();

	const file_size = try my_file.getEndPos();
	var buffer: []u8 = allocatorJson.alloc(u8, file_size) catch unreachable;

	_ = try my_file.read(buffer[0..buffer.len]);

	jsonDecode(buffer) catch |err| {
		@panic(try std.fmt.allocPrint(allocatorJson, "err JsonDecode.{any}\n", .{err}));
	};

	XPANEL.clearAndFree();

	for (NPANEL.items, 0..) |pnlx, idx| {
		var vPanel: pnl.PANEL = undefined;
		vPanel = pnl.initPanel(NPANEL.items[idx].name, NPANEL.items[idx].posx, NPANEL.items[idx].posy,
			NPANEL.items[idx].lines, NPANEL.items[idx].cols, NPANEL.items[idx].cadre, NPANEL.items[idx].title);

		for (pnlx.button.items) |p| {
			var vButton: btn.BUTTON = undefined;

			vButton = btn.newButton(p.key, p.show, p.check, p.title);

			vPanel.button.append(vButton) catch |err| {
				@panic(@errorName(err));
			};
		}

		for (pnlx.label.items) |p| {
			var vLabel: lbl.LABEL = undefined;

			if (p.title) vLabel = lbl.newTitle(p.name, p.posx, p.posy, p.text)
			else vLabel = lbl.newLabel(p.name, p.posx, p.posy, p.text);

			vPanel.label.append(vLabel) catch |err| {
				@panic(@errorName(err));
			};
		}

		for (pnlx.field.items) |p| {
			var vField: fld.FIELD = undefined;
			switch (p.reftyp) {
				forms.REFTYP.TEXT_FREE => {
					vField = fld.newFieldTextFree(
						p.name,
						p.posx,
						p.posy,
						p.width,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
						p.regex,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.TEXT_FULL => {
					vField = fld.newFieldTextFull(
						p.name,
						p.posx,
						p.posy,
						p.width,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
						p.regex,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.ALPHA => {
					vField = fld.newFieldAlpha(
						p.name,
						p.posx,
						p.posy,
						p.width,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
						p.regex,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.ALPHA_UPPER => {
					vField = fld.newFieldAlphaUpper(
						p.name,
						p.posx,
						p.posy,
						p.width,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
						p.regex,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.ALPHA_NUMERIC => {
					vField = fld.newFieldAlphaNumeric(
						p.name,
						p.posx,
						p.posy,
						p.width,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
						p.regex,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.ALPHA_NUMERIC_UPPER => {
					vField = fld.newFieldAlphaNumericUpper(
						p.name,
						p.posx,
						p.posy,
						p.width,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
						p.regex,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.PASSWORD => {
					vField = fld.newFieldPassword(
						p.name,
						p.posx,
						p.posy,
						p.width,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
						p.regex,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.YES_NO => {
					vField = fld.newFieldYesNo(
						p.name,
						p.posx,
						p.posy,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.SWITCH => {
					vField = fld.newFieldSwitch(
						p.name,
						p.posx,
						p.posy,
						p.zwitch,
						p.errmsg,
						p.help,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.DATE_FR => {
					vField = fld.newFieldDateFR(
						p.name,
						p.posx,
						p.posy,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.DATE_US => {
					vField = fld.newFieldDateUS(
						p.name,
						p.posx,
						p.posy,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.DATE_ISO => {
					vField = fld.newFieldDateISO(
						p.name,
						p.posx,
						p.posy,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.MAIL_ISO => {
					vField = fld.newFieldMail(
						p.name,
						p.posx,
						p.posy,
						p.width,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.TELEPHONE => {
					vField = fld.newFieldTelephone(
						p.name,
						p.posx,
						p.posy,
						p.width,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
						p.regex,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.DIGIT => {
					vField = fld.newFieldDigit(
						p.name,
						p.posx,
						p.posy,
						p.width,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
						p.regex,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.UDIGIT => {
					vField = fld.newFieldUDigit(
						p.name,
						p.posx,
						p.posy,
						p.width,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
						p.regex,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.DECIMAL => {
					vField = fld.newFieldDecimal(
						p.name,
						p.posx,
						p.posy,
						p.width,
						p.scal,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
						p.regex,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.UDECIMAL => {
					vField = fld.newFieldUDecimal(
						p.name,
						p.posx,
						p.posy,
						p.width,
						p.scal,
						p.text,
						p.requier,
						p.errmsg,
						p.help,
						p.regex,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},

				forms.REFTYP.FUNC => {
					vField = fld.newFieldFunc(
						p.name,
						p.posx,
						p.posy,
						p.width,
						p.text,
						p.requier,
						p.procfunc,
						p.errmsg,
						p.help,
					);
					vField.proctask = p.proctask;
					vField.progcall = p.progcall;
					vField.typecall = p.typecall;
					vField.parmcall = p.parmcall;
					vField.protect = p.protect;
				},
			}

			vPanel.field.append(vField) catch |err| {
				@panic(@errorName(err));
			};
		}

		for (pnlx.linev.items) |p| {
			var vlinev: lnv.LINEV = undefined;

			vlinev = lnv.newLine(p.name, p.posx, p.posy, p.lng, p.trace);

			vPanel.linev.append(vlinev) catch |err| {
				@panic(@errorName(err));
			};
		}

		for (pnlx.lineh.items) |p| {
			var vlineh: lnh.LINEH = undefined;

			vlineh = lnh.newLine(p.name, p.posx, p.posy, p.lng, p.trace);

			vPanel.lineh.append(vlineh) catch |err| {
				@panic(@errorName(err));
			};
		}

		XPANEL.append(vPanel) catch unreachable;
	}

	defer NPANEL.clearAndFree();


	XGRID.clearRetainingCapacity();

	for (NGRID.items, 0.. ) |xgrd, idx | {
				XGRID.append( grd.initGrid(
							xgrd.name,
							xgrd.posx,
							xgrd.posy,
							xgrd.pageRows,
							xgrd.separator,
							xgrd.cadre)
						 ) catch |err| {@panic(@errorName(err));};
	 
			 for (xgrd.cells.items ) |pcell | {
				 	XGRID.items[idx].cell.append(grd.CELL{
					.text = pcell.text, .reftyp = pcell.reftyp, .long = pcell.long,
					.posy = pcell.posy, .edtcar = pcell.edtcar, .atrCell = grd.toRefColor(pcell.atrCell) })
				catch |err| {@panic(@errorName(err));};
			}
	}
	


	defer NGRID.clearAndFree();

	XMENU.clearRetainingCapacity();

	for (NMENU.items ) |xmnu| {
				XMENU.append(initMenuDef(
									xmnu.name,
									xmnu.posx,
									xmnu.posy,
									xmnu.cadre,
									xmnu.mnuvh,
									xmnu.xitems
								)
						 ) catch |err| {@panic(@errorName(err));};
	 
	}
	


	defer NMENU.clearAndFree();
	return;
}


