	///----------------------------
	/// gestion GRID / TABLEAU
	/// zig 0.12.0 dev
	///----------------------------

const std = @import("std");
const utf = @import("std").unicode;

/// terminal Fonction
const term = @import("cursed");
// keyboard
const kbd = @import("cursed").kbd;

// tools utility
const utl = @import("utils");

const os = std.os;
const io = std.io;

pub const CTRUE = "✔";
pub const CFALSE = " ";
//-------------------------------------------------------
// management grid
// ----------------
// PadingCell()
// setPageGrid()
// initGrid()
// getLenHeaders()
// countColumns()
// countRows()
// setHeaders()
// toRefColors()
// newCell()
// setCellEditCar()
// getcellLen()
// getHeadersText()
// getHeadersPosy()
// getHeadersType()
// getHeadersCar()
// getRowsText()

// addRows()
// dltRows()
// resetRows()
// resetGrid()
// GridBox()
// printGridHeader()
// printGridRows()
// ioGrid()
// ioCombo()
// ----------------
// defined GRID

/// Errors that may occur when using String
pub const ErrGrid = error{
	grd_dltRows_Index_invalide,
};

// buffer terminal MATRIX
const TERMINAL_CHAR = struct { ch: []const u8, attribut: term.ZONATRB, on: bool };

pub const grd = struct {
	pub const CADRE = enum { line0, line1, line2 };

	pub const REFTYP = enum {
		TEXT_FREE, // Free
		TEXT_FULL, // Letter Digit Char-special
		ALPHA, // Letter
		ALPHA_UPPER, // Letter
		ALPHA_NUMERIC, // Letter Digit espace -
		ALPHA_NUMERIC_UPPER, // Letter Digit espace -
		PASSWORD, // Letter Digit and normaliz char-special
		YES_NO, // 'y' or 'Y' / 'o' or 'O'
		UDIGIT, // Digit unsigned
		DIGIT, // Digit signed
		UDECIMAL, // Decimal unsigned
		DECIMAL, // Decimal signed
		DATE_ISO, // YYYY/MM/DD
		DATE_FR, // DD/MM/YYYY
		DATE_US, // MM/DD/YYYY
		TELEPHONE, // (+123) 6 00 01 00 02
		MAIL_ISO, // normalize regex
		SWITCH, // CTRUE CFALSE
		FUNC, // call Function
	};

	pub const allocatorArgData = std.heap.page_allocator;
	var arenaGrid = std.heap.ArenaAllocator.init(std.heap.page_allocator);
	pub var allocatorGrid = arenaGrid.allocator();
	pub fn deinitGrid() void {
		arenaGrid.deinit();
		arenaGrid = std.heap.ArenaAllocator.init(std.heap.page_allocator);
		allocatorGrid = arenaGrid.allocator();
	}

	// define attribut default GRID
	pub var AtrGrid: term.ZONATRB = .{ .styled = [_]u32{
		@intFromEnum(term.Style.styleDim),
		@intFromEnum(term.Style.notStyle),
		@intFromEnum(term.Style.notStyle),
		@intFromEnum(term.Style.notStyle) },
		.backgr = term.BackgroundColor.bgBlack,
		.foregr = term.ForegroundColor.fgGreen };

	// define attribut default TITLE GRID
	pub var AtrTitle: term.ZONATRB = .{ .styled = [_]u32{
		@intFromEnum(term.Style.styleDim),
		@intFromEnum(term.Style.styleUnderscore),
		@intFromEnum(term.Style.notStyle),
		@intFromEnum(term.Style.notStyle) },
		.backgr = term.BackgroundColor.bgBlack,
		.foregr = term.ForegroundColor.fgGreen };

	// define attribut default CELL GRID
	pub var AtrCell: term.ZONATRB = .{ .styled = [_]u32{
		@intFromEnum(term.Style.styleItalic),
		@intFromEnum(term.Style.notStyle),
		@intFromEnum(term.Style.notStyle),
		@intFromEnum(term.Style.notStyle) },
		.backgr = term.BackgroundColor.bgBlack,
		.foregr = term.ForegroundColor.fgCyan };

	// define attribut default CELL GRID
	pub var AtrCellBar: term.ZONATRB = .{ .styled = [_]u32{
		@intFromEnum(term.Style.styleReverse),
		@intFromEnum(term.Style.styleItalic),
		@intFromEnum(term.Style.notStyle),
		@intFromEnum(term.Style.notStyle) },
		.backgr = term.BackgroundColor.bgBlack,
		.foregr = term.ForegroundColor.fgCyan };

	// use default Style separator
	pub var gridStyle: []const u8 = "│";
	pub var gridStyle2: []const u8 = "║";
	pub var gridnoStyle: []const u8 = " ";

	pub const CELL = struct {
		text: []const u8,
		long: usize,
		reftyp: REFTYP,
		posy: usize,
		edtcar: []const u8,
		atrCell: term.ZONATRB };

	const ArgData = struct {
		buf: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(allocatorArgData),
	};

	/// define GRID
	pub const GRID = struct {
		name: []const u8,
		posx: usize,
		posy: usize,
		lines: usize,
		cols: usize,
		pageRows: usize,
		data: std.MultiArrayList(ArgData),
		cell: std.ArrayList(CELL),
		headers: std.ArrayList(CELL),
		separator: []const u8,
		attribut: term.ZONATRB,
		atrTitle: term.ZONATRB,
		atrCell: term.ZONATRB,
		cadre: CADRE,
		actif: bool,
		lignes: usize,
		pages: usize,
		maxligne: usize,
		cursligne: usize,
		curspage: usize,
		buf: std.ArrayList(TERMINAL_CHAR) };

	/// concat String
	fn concatStr(a: []const u8, b: []const u8) []const u8 {
		return std.fmt.allocPrint(
			allocatorGrid,
			"{s}{s}",
			.{ a, b },
		) catch |err| {
			@panic(@errorName(err));
		};
	}

	/// substring String
	fn subStrGrid(a: []const u8, pos: usize, n: usize) []const u8 {
		if (n == 0 or n > a.len) @panic("Invalide_subStrGrid_Index");

		if (pos > a.len) @panic("ErrGrid.Invalide_subStr_pos");

		const result = allocatorGrid.alloc(u8, n - pos) catch |err| {
			@panic(@errorName(err));
		};
		defer allocatorGrid.free(result);

		@memcpy(result, a[pos..n]);
		return std.fmt.allocPrint(
			allocatorGrid,
			"{s}",
			.{result},
		) catch |err| {
			@panic(@errorName(err));
		};
	}

	// pading Cell
	fn padingCell(text: []const u8, cell: CELL) []const u8 {
		var i: usize = 0;

		var e_FIELD: []const u8 = text;
		var e_signed: []const u8 = undefined;

		if (cell.reftyp == REFTYP.PASSWORD) {
			i = 0;
			e_FIELD = "";
			while (i < utl.nbrCharStr(text)) : (i += 1) e_FIELD = concatStr(e_FIELD, "*");
		}

		if (cell.reftyp == REFTYP.UDIGIT or
			cell.reftyp == REFTYP.DIGIT or
			cell.reftyp == REFTYP.UDECIMAL or
			cell.reftyp == REFTYP.DECIMAL)
		{
			if (utl.isSignedStr(text) == true) {
				e_FIELD = subStrGrid(e_FIELD, 1, e_FIELD.len);
				e_signed = subStrGrid(text, 0, 1);
			}

			e_FIELD = utl.alignStr(e_FIELD, utl.ALIGNS.rigth, cell.long);

			if (cell.reftyp == REFTYP.DIGIT or cell.reftyp == REFTYP.DECIMAL) {
				e_FIELD = subStrGrid(e_FIELD, 1, e_FIELD.len);

				if (utl.isSignedStr(text) == false) e_FIELD = concatStr("+", e_FIELD)
				else e_FIELD = concatStr(e_signed, e_FIELD);
			}
		} else e_FIELD = utl.alignStr(e_FIELD, utl.ALIGNS.left, cell.long);

		if (cell.reftyp == REFTYP.SWITCH) {
			if (std.mem.eql(u8, text[0..], "true") or std.mem.eql(u8, text[0..], "1")) e_FIELD = CTRUE
			else e_FIELD = CFALSE;
		}

		if (std.mem.eql(u8, cell.edtcar, "") == false) e_FIELD = concatStr(e_FIELD, cell.edtcar);

		return e_FIELD;
	}

	// calculate the number of pages
	pub fn setPageGrid(self: *GRID) void {
		self.lignes = self.data.len;
		if (self.lignes < self.pageRows ) self.pages = 1 else {
			self.pages = self.lignes / (self.pageRows - 1);
			if (@rem(self.lignes, (self.pageRows - 1)) > 0) self.pages += 1;
		}
	}

	// new GRID object
	// Works like a panel with grid behavior
	pub fn initGrid(
		vname: []const u8,
		vposx: usize,
		vposy: usize,
		vpageRows: usize, // nbr ligne	+ header
		vseparator: []const u8,
		vcadre: CADRE,
	) GRID {
		const device = GRID{
		.name = vname,
		.posx = vposx,
		.posy = vposy,
		.lines = vpageRows + 2, //	row per page	+ cadre
		.cols  = 0,
		.separator = vseparator,
		.pageRows  = vpageRows,
		.data    = std.MultiArrayList(ArgData){},
		.headers = std.ArrayList(CELL).init(allocatorGrid),
		.cell    = std.ArrayList(CELL).init(allocatorGrid),
		.actif   = true,
		.attribut = AtrGrid,
		.atrTitle = AtrTitle,
		.atrCell  = AtrCell,
		.cadre  = vcadre,
		.lignes = 0,
		.pages  = 0,
		.maxligne  = 0,
		.cursligne = 0,
		.curspage  = 1,

		.buf = std.ArrayList(TERMINAL_CHAR).init(allocatorGrid)
		};

		return device;
	}

	pub fn newGridC(
		vname: []const u8,
		vposx: usize,
		vposy: usize,
		vpageRows: usize, // nbr ligne	+ header
		vseparator: []const u8,
		vcadre: CADRE,
	) *GRID {
		var device = allocatorGrid.create(GRID) catch |err| {
			@panic(@errorName(err));
		};

		device.name = vname;
		device.posx = vposx;
		device.posy = vposy;
		device.lines = vpageRows + 2; //	row per page	+ cadre
		device.cols  = 0;
		device.separator = vseparator;
		device.pageRows  = vpageRows;
		device.data    = std.MultiArrayList(ArgData){};
		device.headers = std.ArrayList(CELL).init(allocatorGrid);
		device.cell    = std.ArrayList(CELL).init(allocatorGrid);
		device.actif   = true;
		device.attribut = AtrGrid;
		device.atrTitle = AtrTitle;
		device.atrCell  = AtrCell;
		device.cadre  = vcadre;
		device.lignes = 0;
		device.pages  = 0;
		device.maxligne  = 0;
		device.cursligne = 0;
		device.curspage  = 1;

		device.buf = std.ArrayList(TERMINAL_CHAR).init(allocatorGrid);

		return device;
	}

	pub fn reLoadGrid(
		self: *GRID,
		vname: []const u8,
		vposx: usize,
		vposy: usize,
		vpageRows: usize, // nbr ligne	+ header
		vseparator: []const u8,
		vcadre: CADRE,
	) void {
		if (self.actif) return;

		self.name = vname;
		self.posx = vposx;
		self.posy = vposy;
		self.lines = vpageRows + 2; //	row per page	+ cadre
		self.cols = 0;
		self.separator = vseparator;
		self.pageRows = vpageRows;
		self.data = std.MultiArrayList(ArgData){};
		self.headers = std.ArrayList(CELL).init(allocatorGrid);
		self.cell = std.ArrayList(CELL).init(allocatorGrid);
		self.actif = true;
		self.attribut = AtrGrid;
		self.atrTitle = AtrTitle;
		self.atrCell = AtrCell;
		self.cadre = vcadre;
		self.lignes = 0;
		self.pages = 0;
		self.maxligne = 0;
		self.cursligne = 0;
		self.curspage = 1;

		self.buf = std.ArrayList(TERMINAL_CHAR).init(allocatorGrid);
	}

	// return len header	---> arraylist panel-grid
	pub fn getLenHeaders(self: *GRID) usize {
		var vlen: usize = 0;

		for (self.headers.items) |xcell| {
			vlen += 1; // separator
			vlen += xcell.long;
			if (std.mem.eql(u8, xcell.edtcar, "") == false) vlen += 1;
		}
		vlen += 1; // separator
		return vlen;
	}

	// return number items-header	---> arraylist panel-grid
	pub fn countColumns(self: *GRID) usize {
		return self.headers.items.len;
	}

	// return number row-Data	---> arraylist panel-grid
	pub fn countRows(self: *GRID) usize {
		return self.data.len;
	}

	// initialization CELL -header	---> arraylist panel-grid
	pub fn setHeaders(self: *GRID) void {
		self.cols = 0;
		for (self.cell.items) |xcell| {
			self.headers.append(xcell) catch |err| {
				@panic(@errorName(err));
			};
		}
		self.cols += getLenHeaders(self);
		// this.lines + 2 = cadre + header		cols + separator
		// INIT doublebuffer

		var i: usize = (self.lines) * self.cols;
		const doublebuffer = TERMINAL_CHAR{ .ch = " ", .attribut = self.attribut, .on = false };

		// init matrix
		while (true) {
			if (i == 0) break;
			self.buf.append(doublebuffer) catch |err| {
				@panic(@errorName(err));
			};
			i -= 1;
		}
	}

	// return color
	fn toRefColor(TextColor: term.ForegroundColor) term.ZONATRB {
		var vAtrCell = AtrCell;

		switch (TextColor) {
			.fgdBlack => vAtrCell.foregr = term.ForegroundColor.fgdBlack,
			.fgdRed => vAtrCell.foregr = term.ForegroundColor.fgdRed,
			.fgdGreen => vAtrCell.foregr = term.ForegroundColor.fgdGreen,
			.fgdYellow => vAtrCell.foregr = term.ForegroundColor.fgdYellow,
			.fgdBlue => vAtrCell.foregr = term.ForegroundColor.fgdBlue,
			.fgdMagenta => vAtrCell.foregr = term.ForegroundColor.fgdMagenta,
			.fgdCyan => vAtrCell.foregr = term.ForegroundColor.fgdCyan,
			.fgdWhite => vAtrCell.foregr = term.ForegroundColor.fgdWhite,

			.fgBlack => vAtrCell.foregr = term.ForegroundColor.fgBlack,
			.fgRed => vAtrCell.foregr = term.ForegroundColor.fgRed,
			.fgGreen => vAtrCell.foregr = term.ForegroundColor.fgGreen,
			.fgYellow => vAtrCell.foregr = term.ForegroundColor.fgYellow,
			.fgBlue => vAtrCell.foregr = term.ForegroundColor.fgBlue,
			.fgMagenta => vAtrCell.foregr = term.ForegroundColor.fgMagenta,
			.fgCyan => vAtrCell.foregr = term.ForegroundColor.fgCyan,
			.fgWhite => vAtrCell.foregr = term.ForegroundColor.fgWhite,
		}
		return vAtrCell;
	}

	// New	CELL	--> arraylist panel-grid
	pub fn newCell(self: *GRID, vtext: []const u8, vlong: usize, vreftyp: REFTYP, TextColor: term.ForegroundColor)
	void {

		var nlong: usize = 0;
		if (utl.nbrCharStr(vtext) > vlong) nlong = utl.nbrCharStr(vtext) else nlong = vlong;

		const cell = CELL{
			.text = vtext, .reftyp = vreftyp, .long = nlong, .posy = self.cell.items.len, .edtcar = "",
			.atrCell = toRefColor(TextColor) };

		self.cell.append(cell) catch |err| {
			@panic(@errorName(err));
		};
	}

	// Set Char	-cell ---> arraylist panel-grid
	pub fn setCellEditCar(self: *CELL, vedtcar: []const u8) void {
		self.edtcar = vedtcar;
	}

	// return len	-cell ---> arraylist panel-grid
	pub fn getcellLen(cell: *CELL) usize {
		return cell.long;
	}

	// return name	-header ---> arraylist panel-grid
	pub fn getHeadersText(self: *GRID, r: usize) []const u8 {
		return self.header.items[r].text;
	}

	// return posy	-header ---> arraylist panel-grid
	pub fn getHeadersPosy(self: *GRID, r: usize) usize {
		return self.header.items[r].posy;
	}

	// return reference Type	-header ---> arraylist panel-grid
	pub fn getHeadersType(self: *GRID, r: usize) REFTYP {
		return self.header.items[r].reftyp;
	}

	// return edit Char	-header ---> arraylist panel-grid
	pub fn getHeadersCar(self: *GRID, r: usize) []const u8 {
		return self.header.items[r].edtcar;
	}

	// return Text	-data ---> arraylist panel-grid
	// get text from grid,rows (multiArray)
	pub fn getRowsText(self: *GRID, r: usize, i: usize) []const u8 {
		return self.data.items(.buf)[r].items[i];
	}

	//	panel-grid ACTIF
	pub fn getActif(self: *GRID) bool {
		return self.actif;
	}

	// add row	-data ---> arraylist panel-grid
	pub fn addRows(self: *GRID, vrows: []const []const u8) void {
		const vlist = std.ArrayList([]const u8);
		var m = vlist.init(allocatorGrid);
		m.appendSlice(vrows) catch |err| {
			@panic(@errorName(err));
		};
		self.data.append(allocatorArgData, .{ .buf = m }) catch |err| {
			@panic(@errorName(err));
		};
		setPageGrid(self);
	}

	// delete row	-data ---> arraylist panel-grid
	pub fn dltRows(self: *GRID, r: usize) ErrGrid!void {
		if (r < self.data.len) {
			self.data.orderedRemove(r);
			setPageGrid(self);
		} else return ErrGrid.grd_dltRows_Index_invalide;
	}

	// reset row data	-GRID ---> arraylist panel-grid
	pub fn resetRows(self: *GRID) void {
		while (self.data.len > 0) {
			self.data.orderedRemove(self.data.len - 1);
		}
		self.lignes = 0;
		self.pages = 0;
		self.maxligne = 0;
		self.cursligne = 0;
		self.curspage = 1;
		self.actif = true;
	}

	// reset -GRID ---> arraylist panel-grid
	pub fn freeGrid(self: *GRID) void {
		while (self.data.len > 0) {
			self.data.orderedRemove(self.data.len - 1);
		}

		self.data.deinit(allocatorArgData);

		self.headers.clearAndFree();
		self.headers.deinit();
		self.cell.clearAndFree();
		self.cell.deinit();
		self.lignes = 0;
		self.pages = 0;
		self.maxligne = 0;
		self.cursligne = 0;
		self.curspage = 0;
		self.buf.clearAndFree();
		self.buf.deinit();
		self.actif = false;
	}

	// assign -Box(fram) MATRIX TERMINAL	---> arraylist panel-grid
	fn GridBox(self: *GRID) void {
		if (CADRE.line0 == self.cadre) return;

		const ACS_Hlines = "─";
		const ACS_Vlines = "│";
		const ACS_UCLEFT = "┌";
		const ACS_UCRIGHT = "┐";
		const ACS_LCLEFT = "└";
		const ACS_LCRIGHT = "┘";

		const ACS_Hline2 = "═";
		const ACS_Vline2 = "║";
		const ACS_UCLEFT2 = "╔";
		const ACS_UCRIGHT2 = "╗";
		const ACS_LCLEFT2 = "╚";
		const ACS_LCRIGHT2 = "╝";

		var trait: []const u8 = "";
		var edt: bool = undefined;

		var row: usize = 1;
		var y: usize = 0;
		var col: usize = 0;
		const cols: usize = getLenHeaders(self);

		var n: usize = 0;
		var x: usize = self.posx - 1;

		while (row <= self.lines) {
			y = self.posy;
			col = 1;
			while (col <= cols) {
				edt = false;
				if (row == 1) {
					if (col == 1) {
						if (CADRE.line1 == self.cadre) {
							trait = ACS_UCLEFT;
						} else trait = ACS_UCLEFT2;
						edt = true;
					}
					if (col == cols) {
						if (CADRE.line1 == self.cadre) {
							trait = ACS_UCRIGHT;
						} else trait = ACS_UCRIGHT2;
						edt = true;
					}
					if (col > 1 and col < cols) {
						if (CADRE.line1 == self.cadre) {
							trait = ACS_Hlines;
						} else trait = ACS_Hline2;
						edt = true;
					}
				} else if (row == self.lines) {
					if (col == 1) {
						if (CADRE.line1 == self.cadre) {
							trait = ACS_LCLEFT;
						} else trait = ACS_LCLEFT2;
						edt = true;
					}
					if (col == cols) {
						if (CADRE.line1 == self.cadre) {
							trait = ACS_LCRIGHT;
						} else trait = ACS_LCRIGHT2;
						edt = true;
					}
					if (col > 1 and col < cols) {
						if (CADRE.line1 == self.cadre) {
							trait = ACS_Hlines;
						} else trait = ACS_Hline2;
						edt = true;
					}
				} else if (row > 1 and row < self.lines) {
					if (col == 1 or col == cols) {
						if (CADRE.line1 == self.cadre) {
							trait = ACS_Vlines;
						} else trait = ACS_Vline2;
						edt = true;
					}
				}
				if (edt) {
					self.buf.items[n].ch = trait;
					self.buf.items[n].attribut = self.attribut;
					self.buf.items[n].on = true;
				}
				n += 1;
				y += 1;
				col += 1;
			}
			x += 1;
			row += 1;
		}
	}

	// assign and display -header MATRIX TERMINAL	---> arraylist panel-grid
	pub fn printGridHeader(self: *GRID) void {
		if (self.actif == false) return;

		var buf: []const u8 = "";
		const Blanc = " ";
		var pos: usize = 0;

		for (self.headers.items, 0..) |_, idx| {
			self.headers.items[idx].posy = pos;
			if (self.headers.items[idx].edtcar.len == 0) pos = pos + self.headers.items[idx].long + 1
			else pos = pos + self.headers.items[idx].long + 1 + 1;
		}

		for (self.headers.items) |cellx| {
			if (std.mem.eql(u8, cellx.edtcar, "") == true)
				buf = std.fmt.allocPrint(allocatorGrid, "{s}{s}{s}",
					.{ buf, self.separator, utl.alignStr(" ", utl.ALIGNS.left, cellx.long) })
					catch |err| {@panic(@errorName(err));
				}
			else
				buf = std.fmt.allocPrint(allocatorGrid, "{s}{s}{s}{s}",
					.{ buf, self.separator, utl.alignStr(" ", utl.ALIGNS.left, cellx.long), Blanc })
					catch |err| {@panic(@errorName(err));};
		}
		buf = std.fmt.allocPrint(allocatorGrid, "{s}{s}", .{ buf, self.separator }) catch |err| {
			@panic(@errorName(err));
		};

		defer allocatorGrid.free(buf);

		var x: usize = 1;
		var y: usize = 0;
		var n: usize = 0;

		while (x <= self.lines) : (x += 1) {
			y = 1;
			var iter = utl.iteratStr.iterator(buf);
			defer iter.deinit();
			while (iter.next()) |ch| : (n += 1) {
				self.buf.items[n].ch = std.fmt.allocPrint(allocatorGrid, "{s}", .{ch}) catch unreachable;
				self.buf.items[n].attribut = self.attribut;
				self.buf.items[n].on = false;
			}
		}

		buf = "";
		for (self.headers.items) |cellx| {
			if (cellx.reftyp == REFTYP.UDIGIT or
				cellx.reftyp == REFTYP.DIGIT or
				cellx.reftyp == REFTYP.UDECIMAL or
				cellx.reftyp == REFTYP.DECIMAL)
				buf = std.fmt.allocPrint(allocatorGrid, "{s}{s}{s}",
					.{ buf, self.separator, utl.alignStr(cellx.text, utl.ALIGNS.rigth, cellx.long) })
					catch |err| {@panic(@errorName(err));
				}
			else
				buf = std.fmt.allocPrint(allocatorGrid, "{s}{s}{s}", 
					.{ buf, self.separator, utl.alignStr(cellx.text, utl.ALIGNS.left, cellx.long) })
					catch |err| {@panic(@errorName(err));
				};

			if (std.mem.eql(u8, cellx.edtcar, "") == false) buf =std.fmt.allocPrint(allocatorGrid, "{s}{s}",
				.{ buf, Blanc }) catch |err| {@panic(@errorName(err));
			};

			n = getLenHeaders(self);
			var iter = utl.iteratStr.iterator(buf);
			defer iter.deinit();
			while (iter.next()) |ch| : (n += 1) {
				self.buf.items[n].ch = std.fmt.allocPrint(allocatorGrid, "{s}", .{ch}) catch unreachable;
				self.buf.items[n].attribut = self.atrTitle;
				self.buf.items[n].on = true;
			}

			// this.lines + 2 = cadre + header
			GridBox(self);

			x = 1;
			y = 0;
			n = 0;
			while (x <= self.lines) : (x += 1) {
				y = 1;
				while (y <= getLenHeaders(self)) : (y += 1) {
					term.gotoXY(x + self.posx, y + self.posy);
					term.writeStyled(self.buf.items[n].ch, self.buf.items[n].attribut);
					n += 1;
				}
			}
		}
	}

	// assign and display -data MATRIX TERMINAL	---> arraylist panel-grid
	pub fn printGridRows(self: *GRID) void {
		if (self.actif == false) return;

		var nposy: usize = (getLenHeaders(self) * 2) + 1;
		var n: usize = 0;
		var x: usize = 0;
		var y: usize = 0;
		var h: usize = 0;
		const nColumns: usize = countColumns(self);
		var start: usize = 0;
		var l: usize = 0;
		var buf: []const u8 = "";
		var bufItems: []const u8 = "";

		self.maxligne = 0;
		if (self.curspage == 0) start = 0 else start = (self.pageRows - 1) * (self.curspage - 1);
		var r: usize = 0;
		while (r < self.pageRows - 1) : (r += 1) {
			l = r + start;
			if (l < self.lignes) {
				self.maxligne = r;
				h = 0;
				while (h < nColumns) : (h += 1) {

					// formatage buffer
					bufItems = self.data.items(.buf)[l].items[h];

					buf = padingCell(bufItems, self.headers.items[h]);

					// write matrice
					var iter = utl.iteratStr.iterator(buf);
					defer iter.deinit();
					n = nposy + self.headers.items[h].posy;
					while (iter.next()) |ch| : (n += 1) {
						self.buf.items[n].ch = std.fmt.allocPrint(allocatorGrid, "{s}", .{ch}) catch unreachable;
						if (self.cursligne == l or self.cursligne == r) self.buf.items[n].attribut = AtrCellBar
						else self.buf.items[n].attribut = self.headers.items[h].atrCell;
						self.buf.items[n].on = true;
					}
				}
				nposy = nposy + self.cols;
			}
		}

		x = 1;
		y = 0;
		n = 0;
		while (x <= self.lines) : (x += 1) {
			y = 1;
			while (y <= self.cols) : (y += 1) {
				if (self.buf.items[n].on == true) {
					term.gotoXY(x + self.posx, y + self.posy);
					term.writeStyled(self.buf.items[n].ch, self.buf.items[n].attribut);
				}
				n += 1;
			}
		}
	}

	//----------------------------------------------------------------
	// Management GRID enter = select	1..n 0 = abort (Escape)
	// Turning on the mouse
	// UP DOWn PageUP PageDown
	// Automatic alignment based on the type reference
	//----------------------------------------------------------------

	pub const GridSelect = struct { Key: term.kbd, Buf: std.ArrayList([]const u8) };

	//------------------------------------
	// manual= on return pageUp/pageDown no select
	// esc	 = return no select
	// enter = return enter and line select
	// -----------------------------------

	pub fn ioGrid(self: *GRID, manual: bool) GridSelect {
		var gSelect: GridSelect = .{ .Key = term.kbd.none, .Buf = std.ArrayList([]const u8).init(allocatorGrid) };

		if (self.actif == false) return gSelect;

		gSelect.Key = term.kbd.none;

		var CountLigne: usize = 0;
		self.cursligne = 0;
		printGridHeader(self);

		term.cursHide();
		term.onMouse();

		var grid_key: term.Keyboard = undefined;
		while (true) {
			printGridRows(self);

			grid_key = kbd.getKEY();
			// bar espace
			if (grid_key.Key == kbd.char and
				std.mem.eql(u8, grid_key.Char, " "))
			{
				grid_key.Key = kbd.enter;
				grid_key.Char = "";
			}

			if (grid_key.Key == kbd.mouse) {
				grid_key.Key = kbd.none;

				if (term.MouseInfo.scroll) {
					switch (term.MouseInfo.scrollDir) {
						term.ScrollDirection.msUp => grid_key.Key = kbd.up,
						term.ScrollDirection.msDown => grid_key.Key = kbd.down,
						else => {},
					}
				} else {
					if (term.MouseInfo.action == term.MouseAction.maReleased) continue;
					switch (term.MouseInfo.button) {
						term.MouseButton.mbLeft => grid_key.Key = kbd.enter,
						term.MouseButton.mbMiddle => grid_key.Key = kbd.enter,
						term.MouseButton.mbRight => grid_key.Key = kbd.enter,
						else => {},
					}
				}
			}

			switch (grid_key.Key) {
				.none => continue,

				.esc => {
					self.cursligne = 0;
					gSelect.Key = kbd.esc;
					term.offMouse();
					return gSelect;
				},

				.enter => if (self.lignes > 0) {
					gSelect.Key = kbd.enter;
					if (self.curspage > 0) {
						CountLigne = (self.pageRows - 1) * (self.curspage - 1);
						CountLigne += self.cursligne;
					}

					gSelect.Buf = self.data.items(.buf)[CountLigne];
					term.offMouse();
					self.cursligne = 0;
					return gSelect;
				},

				.up => if (CountLigne > 0) {
					CountLigne -= 1;
					self.cursligne -= 1;
				},

				.down => if (CountLigne < self.maxligne) {
					CountLigne += 1;
					self.cursligne += 1;
				},

				.pageUp => {
					if (self.curspage > 1) {
						self.curspage -= 1;
						self.cursligne = 0;
						CountLigne = 0;
						printGridHeader(self);
					} else {
						if (manual == true) {
							self.cursligne = 0;
							gSelect.Key = kbd.pageUp;
							term.offMouse();
							return gSelect;
						}
					}
				},
				.pageDown => {
					if (self.curspage < self.pages) {
						self.curspage += 1;
						self.cursligne = 0;
						CountLigne = 0;
						printGridHeader(self);
					} else {
						if (manual == true) {
							self.cursligne = 0;
							gSelect.Key = kbd.pageDown;
							term.offMouse();
							return gSelect;
						}
					}
				},
				else => {},
			}
		}
	}

	///------------------------------------
	/// manual= on return pageUp/pageDown no select
	/// esc	 = return no select
	/// KEY	 = return select valide ex: management Grid to Grid
	/// enter = return enter and line select
	/// -----------------------------------
	pub fn ioGridKey(self: *GRID, gKey: term.kbd, manual: bool) GridSelect {
		var gSelect: GridSelect = .{ .Key = term.kbd.none, .Buf = std.ArrayList([]const u8).init(allocatorGrid) };

		if (self.actif == false) return gSelect;

		gSelect.Key = term.kbd.none;

		var CountLigne: usize = 0;
		self.cursligne = 0;
		printGridHeader(self);

		term.cursHide();
		term.onMouse();

		var grid_key: term.Keyboard = undefined;
		while (true) {
			printGridRows(self);

			grid_key = kbd.getKEY();
			// bar espace
			if (grid_key.Key == kbd.char and
				std.mem.eql(u8, grid_key.Char, " "))
			{
				grid_key.Key = kbd.enter;
				grid_key.Char = "";
			}

			if (grid_key.Key == kbd.mouse) {
				grid_key.Key = kbd.none;

				if (term.MouseInfo.scroll) {
					switch (term.MouseInfo.scrollDir) {
						term.ScrollDirection.msUp => grid_key.Key = kbd.up,
						term.ScrollDirection.msDown => grid_key.Key = kbd.down,
						else => {},
					}
				} else {
					if (term.MouseInfo.action == term.MouseAction.maReleased) continue;

					switch (term.MouseInfo.button) {
						term.MouseButton.mbLeft => grid_key.Key = kbd.enter,
						term.MouseButton.mbMiddle => grid_key.Key = kbd.enter,
						term.MouseButton.mbRight => grid_key.Key = kbd.enter,
						else => {},
					}
				}
			}

			if (grid_key.Key == gKey) {
				self.cursligne = 0;
				gSelect.Key = kbd.ctrlV;
				term.offMouse();
				return gSelect;
			}

			switch (grid_key.Key) {
				.none => continue,
				.F1 => {},
				.esc => {
					self.cursligne = 0;
					gSelect.Key = kbd.esc;
					term.offMouse();
					return gSelect;
				},

				.enter => if (self.lignes > 0) {
					gSelect.Key = kbd.enter;
					if (self.curspage > 0) {
						CountLigne = (self.pageRows - 1) * (self.curspage - 1);
						CountLigne += self.cursligne;
					}
					gSelect.Buf = self.data.items(.buf)[CountLigne];
					term.offMouse();
					self.cursligne = 0;
					return gSelect;
				},

				.up => if (CountLigne > 0) {
					CountLigne -= 1;
					self.cursligne -= 1;
				},

				.down => if (CountLigne < self.maxligne) {
					CountLigne += 1;
					self.cursligne += 1;
				},

				.pageUp => {
					if (self.curspage > 1) {
						self.curspage -= 1;
						self.cursligne = 0;
						CountLigne = 0;
						printGridHeader(self);
					} else {
						if (manual == true) {
							self.cursligne = 0;
							gSelect.Key = kbd.pageUp;
							term.offMouse();
							return gSelect;
						}
					}
				},

				.pageDown => {
					if (self.curspage < self.pages) {
						self.curspage += 1;
						self.cursligne = 0;
						CountLigne = 0;
						printGridHeader(self);
					} else {
						if (manual == true) {
							self.cursligne = 0;
							gSelect.Key = kbd.pageDown;
							term.offMouse();
							return gSelect;
						}
					}
				},
				else => {},
			}
		}
	}

	// idem iogrid with Static table data
	pub fn ioCombo(self: *GRID, pos: usize) GridSelect {
		var CountLigne: usize = 0;

		var gSelect: GridSelect = .{ .Key = term.kbd.none, .Buf = std.ArrayList([]const u8).init(allocatorGrid) };

		gSelect.Key = term.kbd.none;
		if (self.actif == false) return gSelect;

		printGridHeader(self);

		if (pos == 0) self.cursligne = 0 else {
			var r: usize = 0;
			var n: usize = 0;
			self.curspage = 1;
			while (r < self.lignes) : (r += 1) {
				if (n == self.pageRows - 1) {
					self.curspage += 1;
					n = 0;
				}
				if (r == pos) {
					self.cursligne = r;
					break;
				}
				n += 1;
			}
			if (self.curspage > 1) {
				if (((self.pageRows - 1) * (self.curspage - 1)) < pos) CountLigne = 0 
				else CountLigne = ((self.pageRows - 1) * (self.curspage - 1)) - pos;
			}
			CountLigne = pos;
		}

		term.cursHide();
		term.onMouse();

		var grid_key: term.Keyboard = undefined;

		while (true) {
			printGridRows(self);

			grid_key = kbd.getKEY();

			// bar espace
			if (grid_key.Key == kbd.char and
				std.mem.eql(u8, grid_key.Char, " "))
			{
				grid_key.Key = kbd.enter;
				grid_key.Char = "";
			}

			if (grid_key.Key == kbd.mouse) {
				grid_key.Key = kbd.none;

				if (term.MouseInfo.scroll) {
					switch (term.MouseInfo.scrollDir) {
						term.ScrollDirection.msUp => grid_key.Key = kbd.up,
						term.ScrollDirection.msDown => grid_key.Key = kbd.down,
						else => {},
					}
				} else {
					if (term.MouseInfo.action == term.MouseAction.maReleased) continue;
					switch (term.MouseInfo.button) {
						term.MouseButton.mbLeft => grid_key.Key = kbd.enter,
						term.MouseButton.mbMiddle => grid_key.Key = kbd.enter,
						term.MouseButton.mbRight => grid_key.Key = kbd.enter,
						else => {},
					}
				}
			}

			switch (grid_key.Key) {
				.none => continue,

				.esc => {
					self.cursligne = 0;
					gSelect.Key = kbd.esc;
					term.offMouse();
					return gSelect;
				},

				.enter => if (self.lignes > 0) {
					gSelect.Key = kbd.enter;
					if (self.curspage > 0) {
						const vline = (self.pageRows - 1) * (self.curspage - 1);
						CountLigne += vline;
					}
					gSelect.Buf = self.data.items(.buf)[CountLigne];
					term.offMouse();
					self.cursligne = 0;
					return gSelect;
				},

				.up => if (CountLigne > 0) {
					CountLigne -= 1;
					self.cursligne -= 1;

				},

				.down => if (CountLigne < self.maxligne) {
					CountLigne += 1;
					self.cursligne += 1;
				},

				.pageUp => if (self.curspage > 1) {
					self.curspage -= 1;
					self.cursligne = 0;
					CountLigne = 0;
					printGridHeader(self);
				},

				.pageDown => if (self.curspage < self.pages) {
					self.curspage += 1;
					self.cursligne = 0;
					CountLigne = 0;
					printGridHeader(self);
				},
				else => {},
			}
		}
	}
};
