	///-----------------------
	/// forms 
	/// Label
	/// button
	/// cadre
	/// field
	/// panel
	/// zig 0.12.0 dev
	///-----------------------


const std = @import("std");
const utf = @import("std").unicode;
const kbd = @import("cursed").kbd;
const term= @import("cursed");
const utl = @import("utils");
const reg = @import("match");

const os = std.os;
const io = std.io;

const Child = @import("std").ChildProcess;

///-------------------------------
/// FORMS
///-------------------------------



// for panel all arraylist (forms. label button line field pnl:)
 var arenaForms = std.heap.ArenaAllocator.init(std.heap.page_allocator);
pub var  allocatorForms = arenaForms.allocator();
pub fn deinitForms() void {
	arenaForms.deinit();
	arenaForms = std.heap.ArenaAllocator.init(std.heap.page_allocator);
	allocatorForms = arenaForms.allocator();
}


pub const CTRUE  = "✔";
pub const CFALSE = "◉";

pub const LINE = enum {
	line1,
	line2
};

pub const CADRE = enum  {
	line0,
	line1,
	line2
};


pub const REFTYP = enum {
	TEXT_FREE,			// Free
	TEXT_FULL,			// Letter Digit Char-special
	ALPHA,				// Letter
	ALPHA_UPPER,		// Letter
	ALPHA_NUMERIC,		// Letter Digit espace -
	ALPHA_NUMERIC_UPPER,// Letter Digit espace -
	PASSWORD,			// Letter Digit and normaliz char-special
	YES_NO,				// 'y' or 'Y' / 'o' or 'O'
	UDIGIT,				// Digit unsigned
	DIGIT,				// Digit signed 
	UDECIMAL,			// Decimal unsigned
	DECIMAL,			// Decimal signed
	DATE_ISO,			// YYYY/MM/DD
	DATE_FR,			// DD/MM/YYYY
	DATE_US,			// MM/DD/YYYY
	TELEPHONE,			// (+123) 6 00 01 00 02 
	MAIL_ISO,			// normalize regex
	SWITCH,				// CTRUE CFALSE
	FUNC,				// call Function
};






// function special for developpeur
pub fn debeug(vline : usize, buf: [] const u8) void {
	
	const AtrDebug : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgYellow
	};

	term.getCursor();
	const Xterm = term.getSize();
	term.gotoXY(Xterm.height,1) ;
	const allocator = std.heap.page_allocator;
	const msg =std.fmt.allocPrint(allocator,"line_src:{d}  {s} ",.{vline, buf}) 
									catch |err| { @panic(@errorName(err));};
	term.writeStyled(msg,AtrDebug);
	_=term.kbd.getKEY();
	term.gotoXY(term.posCurs.x,term.posCurs.y);
	allocator.free(msg);
}


	



/// Errors that may occur when using String
pub const ErrForms = error{

				lbl_getIndex_Name_Label_Invalide,
				lbl_getName_Index_invalide,
				lbl_getPosx_Index_invalide,
				lbl_getPosy_Index_invalide,
				lbl_getText_Index_invalide,
				lbl_getActif_Index_invalide,

				lbl_setText_Index_invalide,
				lbl_setActif_Index_invalide,
				lbl_updateText_Index_invalide,

				lbl_dltRows_Index_invalide,

				line_getIndex_Name_Vertical_Invalide,
				line_getIndex_Name_Horizontal_Invalide,
	
				btn_getIndex_Key_Button_Invalide,
				btn_getName_Index_invalide,
				btn_getKey_Index_invalide,
				btn_getShow_Index_invalide,
				btn_getText_Index_invalide,
				btn_getCheck_Index_invalide,
				btn_getActif_Index_invalide,

				btn_setShow_Index_invalide,
				btn_setText_Index_invalide,
				btn_setCheck_Index_invalide,	
				btn_setActif_Index_invalide,


				btn_dltRows_Index_invalide,


				fld_getIndex_Name_Field_Invalide,
				fld_getName_Index_invalide,
				fld_getPosx_Index_invalide,
				fld_getPosy_Index_invalide,
				fld_getRefType_Index_invalide,
				fld_getWidth_Index_invalide,
				fld_getScal_Index_invalide,
				fld_getNbrCar_Index_invalide,
				fld_getRequier_Index_invalide,
				fld_getProtect_Index_invalide,
				fld_getPading_Index_invalide,
				fld_getEdtcar_Index_invalide,
				fld_getRegex_Index_invalide,
				fld_getErrMsg_Index_invalide,
				fld_getHelp_Index_invalide,
				fld_getText_Index_invalide,
				fld_getSwitch_Index_invalide,
				fld_getErr_Index_invalide,
				fld_getFunc_Index_invalide,
				fld_getTask_Index_invalide,
				fld_getCall_Index_invalide,
				fld_getTypeCall_Index_invalide,
				fld_getParmCall_Index_invalide,
				fld_getAttribut_Index_invalide,
				fld_getAtrProtect_Index_invalide,
				fld_getActif_Index_invalide,

				fld_setText_Index_invalide,
				fld_setName_Index_invalide,
				fld_setRefType_Index_invalide,
				fld_setWidth_Index_invalide,
				fld_setSwitch_Index_invalide,
				fld_setProtect_Index_invalide,
				fld_setRequier_Index_invalide,
				fld_setEdtcar_Index_invalide,
				fld_setRegex_Index_invalide,
				fld_setTask_Index_invalide,
				fld_setCall_Index_invalide,
				fld_setTypeCall_Index_invalide,
				fld_setParmCall_Index_invalide,
				fld_setActif_Index_invalide,

				fld_dltRows_Index_invalide,

				Invalide_subStrForms_Index,
				Invlide_subStrForms_pos,
		};


// Shows serious programming errors
pub const	dsperr = struct {		
	pub fn errorForms(vpnl: *pnl.PANEL, errpgm :anyerror ) void { 
		// define attribut default MSG Error
		const MsgErr : term.ZONATRB = .{
				.styled=[_]u32{@intFromEnum(term.Style.styleBlink),
											@intFromEnum(term.Style.notStyle),
											@intFromEnum(term.Style.notStyle),
											@intFromEnum(term.Style.notStyle)},
				.backgr = term.BackgroundColor.bgBlack,
				.foregr = term.ForegroundColor.fgYellow,
		};

		const allocator = std.heap.page_allocator;

		const errTxt:[]const u8 = std.fmt.allocPrint(allocator,"{any}",.{errpgm }) 
																		catch |err| { @panic(@errorName(err));};
		defer allocator.free(errTxt);
		

		const x: usize	= vpnl.lines;
		var n: usize	= vpnl.cols * (x - 2) ;
		var y: usize	= 1 ;

		var msgerr:[]const u8 = utl.concatStr("Info : ", errTxt) ;
		var boucle : bool= true ;

		if (vpnl.cols < (msgerr.len) )	msgerr = subStrForms(msgerr, 0,	vpnl.cols - 2);

		// clear line button 
		while (y <= (vpnl.cols - 2) ) : (y += 1) {
			term.gotoXY(vpnl.posx + x	- 2	 , y + vpnl.posy	);
			term.writeStyled(" ",vpnl.attribut);
		}
		// display msgerr
		y = 1 ;
		term.gotoXY(vpnl.posx + x	- 2, y + vpnl.posy	 );
		term.writeStyled(msgerr,MsgErr);

		while (boucle) {
			const e_key = kbd.getKEY();

			switch ( e_key.Key ) {
				.esc=>boucle = false,
			else =>	{},
			}
		}

		// restore line panel
		while (y <= (vpnl.cols - 2)) : (y += 1) {
			n += 1;
			term.gotoXY( vpnl.posx + x	- 2, y + vpnl.posy	);
			term.writeStyled(vpnl.buf.items[n].ch,vpnl.buf.items[n].attribut);
		} 
	}
};


// buffer terminal MATRIX
const TERMINAL_CHAR = struct {
	ch :	 [] const u8,
	attribut:term.ZONATRB,
	on:bool
};

pub fn subStrForms( a: []const u8,pos: usize, n:usize) []const u8 {
	if (n == 0 or n > a.len) {@panic(@errorName(ErrForms.Invalide_subStrForms_Index));}
	if (pos > a.len) {@panic(@errorName(ErrForms.Invlide_subStrForms_pos));}

	const allocator = std.heap.page_allocator;
	const result = allocator.alloc(u8, n - pos) 
								catch |err| { @panic(@errorName(err));};
	defer allocator.free(result);

	@memcpy(result, a[pos..n]);
	return std.fmt.allocPrint(allocator ,"{s}",.{result},)
								catch |err| { @panic(@errorName(err));};
}



// function special for developpeur
// activat fld.myMouse = true
// read ioField -> getKEY()
 pub fn dspMouse(vpnl: *pnl.PANEL) void {
		const AtrDebug: term.ZONATRB = .{
				.styled = [_]u32{ @intFromEnum(term.Style.notStyle), @intFromEnum(term.Style.notStyle), @intFromEnum(term.Style.notStyle), @intFromEnum(term.Style.notStyle) },
				.backgr = term.BackgroundColor.bgBlack,
				.foregr = term.ForegroundColor.fgRed,
		};
		const allocator = std.heap.page_allocator;
		const msg = std.fmt.allocPrint(allocator, "{d:0>2}{s}{d:0>3}", .{ term.MouseInfo.x, "/", term.MouseInfo.y }) 
											catch |err| { @panic(@errorName(err));};
		term.gotoXY(vpnl.posx + vpnl.lines - 1, (vpnl.posy + vpnl.cols - 1) - 7);
		term.writeStyled(msg, AtrDebug);
		term.gotoXY(term.MouseInfo.x, term.MouseInfo.y);
		allocator.free(msg);
}

// function special for developpeur
pub fn dspCursor(vpnl: *pnl.PANEL, x_posx: usize, x_posy: usize, text:[] const u8) void {
		const AtrDebug: term.ZONATRB = .{
				.styled = [_]u32{ @intFromEnum(term.Style.notStyle), @intFromEnum(term.Style.notStyle),
								 @intFromEnum(term.Style.notStyle), @intFromEnum(term.Style.notStyle) },
				.backgr = term.BackgroundColor.bgBlack,
				.foregr = term.ForegroundColor.fgRed,
		};

		if (std.mem.eql(u8, text, "") == false ) {
		term.gotoXY(vpnl.posx + vpnl.lines - 1, (vpnl.posy + vpnl.cols - 1) / 2);
		term.writeStyled(text, AtrDebug);
		}
		const allocator = std.heap.page_allocator;
		const msg = std.fmt.allocPrint(allocator, "{d:0>2}{s}{d:0>3}", .{ x_posx, "/", x_posy }) 
											catch |err| { @panic(@errorName(err));};
		term.gotoXY(vpnl.posx + vpnl.lines - 1, (vpnl.posy + vpnl.cols - 1) - 7);
		term.writeStyled(msg, AtrDebug);
		term.gotoXY(x_posx, x_posy);
		allocator.free(msg);
}


// defined Label
pub const	lbl = struct {

	// define attribut default LABEL
	pub var AtrLabel : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.styleDim),
										@intFromEnum(term.Style.styleItalic),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgGreen,
	};

	// define attribut default TITLE
	pub var AtrTitle : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.styleBold),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgGreen,
	};

	pub const LABEL = struct {
		name :	[]const u8,
		posx:	 usize,
		posy:	 usize,
		attribut:term.ZONATRB,
		text:	 []const u8,
		title:	bool,
		actif:	bool
		};

	pub const Elabel = enum {
		name,
		posx,
		posy,
		text,
		title
	};
	// New LABEL
	pub fn newLabel(vname: [] const u8, vposx:usize, vposy:usize,
							vtext: [] const u8) LABEL {

				const xlabel = LABEL {
						.name = vname,
						.posx = vposx ,
						.posy = vposy,
						.attribut = AtrLabel,
						.text = vtext,
						.title = false,
						.actif = true,
				};

				return xlabel;
	}


	// New LABEL-TITLE
	pub fn newTitle(vname: [] const u8, vposx:usize, vposy:usize,
							vtext: [] const u8) LABEL {

				const xlabel = LABEL {
						.name = vname,
						.posx = vposx ,
						.posy = vposy,
						.attribut = AtrTitle,
						.text = vtext,
						.title = true,
						.actif = true,
				};

				return xlabel;
	}


	// return index-label	---> arraylist panel-label
	pub fn getIndex(vpnl: *pnl.PANEL , name: [] const u8 )	ErrForms ! usize {

		for (vpnl.label.items, 0..) |l, idx| {
			if (std.mem.eql(u8, l.name, name)) return idx ;
		}
		return ErrForms.lbl_getIndex_Name_Label_Invalide;
	}

	// return name-label ---> arraylist panel-label
	pub fn getName(vpnl: *pnl.PANEL , n: usize) ErrForms ! [] const u8 {
		if ( n < vpnl.label.items.len) return vpnl.label.items[n].name;
		return ErrForms.lbl_getName_Index_invalide ;

	}

	// return posx-label ---> arraylist panel-label
	pub fn getPosx(vpnl: *pnl.PANEL , n: usize)	ErrForms ! usize {
		if ( n < vpnl.label.items.len) return vpnl.label.items[n].posx;
		return ErrForms.lbl_getPosx_Index_invalide ;
	}

	// return posy-label ---> arraylist panel-label
	pub fn getPosy(vpnl: *pnl.PANEL , n: usize)	ErrForms ! usize {
		if ( n < vpnl.label.items.len) return vpnl.label.items[n].posy;
		return ErrForms.lbl_getPosy_Index_invalide ;
	}

	// return Text-label ---> arraylist panel-label
	pub fn getText(vpnl: *pnl.PANEL , n: usize)	ErrForms ! usize {
		if ( n < vpnl.label.items.len) return vpnl.label.items[n].text;
		return ErrForms.lbl_getText_Index_invalide ;
	}

	// return ON/OFF-label ---> arraylist panel-label
	pub fn getActif(vpnl: *pnl.PANEL , n: usize)	ErrForms ! bool {
		if ( n < vpnl.label.items.len) return vpnl.label.items[n].actif;
		return ErrForms.lbl_getActif_Index_invalide ;
	}

	// Set TEXT -label ---> arraylist panel-label
	pub fn setText(vpnl: *pnl.PANEL , n: usize, val:[] const u8) ErrForms ! void {
		if ( n < vpnl.label.items.len)	vpnl.label.items[n].text = val
		else return ErrForms.lbl_setText_Index_invalide;
	}

	// Set ON/OFF -label ---> arraylist panel-label
	pub fn setActif(vpnl: *pnl.PANEL , n: usize, val :bool) ErrForms ! void {
		if ( n < vpnl.label.items.len) vpnl.label.items[n].actif = val
		else return ErrForms.lbl_setActif_Index_invalide;
	}

	// delete -label ---> arraylist panel-label
	pub fn dltRows(vpnl: *pnl.PANEL,	n :usize ) ErrForms ! void {
		if ( n < vpnl.label.items.len)	_= vpnl.label.orderedRemove(n)
		else return ErrForms.lbl_dltRows_Index_invalide;
	}

	// update Label and Display	---> arraylist panel-label
	pub fn updateText(vpnl: *pnl.PANEL , n: usize, val:[] const u8) ErrForms ! void {
		if ( n < vpnl.label.items.len) {
			clsLabel(vpnl, vpnl.label.items[n]);
			vpnl.label.items[n].text = val;
			printLabel(vpnl, vpnl.label.items[n]);
			displayLabel(vpnl, vpnl.label.items[n]);
		} else return ErrForms.lbl_updateText_Index_invalide;
	}

	// assign -label MATRIX TERMINAL	---> arraylist panel-label
	pub fn printLabel(vpnl: *pnl.PANEL, vlbl : LABEL ) void {
		var n	= (vpnl.cols * (vlbl.posx - 1)) + vlbl.posy - 1;
		var iter = utl.iteratStr.iterator(vlbl.text);
		defer iter.deinit();

		while (iter.next()) |ch| {
			if (vlbl.actif == true) {
				vpnl.buf.items[n].ch = std.fmt.allocPrint(allocatorForms,"{s}",.{ch}) catch unreachable;
				vpnl.buf.items[n].attribut = vlbl.attribut;
				vpnl.buf.items[n].on = true;
			}
			else {
				vpnl.buf.items[n].ch = "";
				vpnl.buf.items[n].attribut	= vpnl.attribut;
				vpnl.buf.items[n].on = false;
			}
			n += 1;
		}
	}


	// matrix cleaning from label
	pub fn clsLabel(vpnl: *pnl.PANEL, vlbl : LABEL )	void {
		// display matrice PANEL
		if (vpnl.actif == false ) return ;
		if (vlbl.actif == false ) return ;
			const x :usize = vlbl.posx - 1;
			const y :usize = vlbl.posy - 1;
			const vlen = utl.nbrCharStr(vlbl.text);
			var n :usize = 0;
			var npos :usize = (vpnl.cols * (vlbl.posx - 1)) + vlbl.posy - 1 ;
			while (n < vlen) : (n += 1) {
				vpnl.buf.items[npos].ch = " ";
				vpnl.buf.items[npos].attribut	= vpnl.attribut;
				vpnl.buf.items[npos].on = false;
				term.gotoXY(x + vpnl.posx	 , y + vpnl.posy + n	);
				term.writeStyled(vpnl.buf.items[npos].ch,vpnl.buf.items[npos].attribut);
				npos += 1;
			}
	}


	// display	MATRIX to terminal ---> arraylist panel-label
	fn displayLabel(vpnl: *pnl.PANEL, vlbl : LABEL )	void {
		// display matrice PANEL
		if (vpnl.actif == false ) return ;
			const x :usize = vlbl.posx - 1 ;
			const y :usize = vlbl.posy - 1;
			const vlen = utl.nbrCharStr(vlbl.text);
			var n :usize = 0;
			var npos :usize = (vpnl.cols * vlbl.posx) + vlbl.posy - 1 ;
			while (n < vlen) : (n += 1) {
				term.gotoXY(x + vpnl.posx	 , y + vpnl.posy + n	);
				term.writeStyled(vpnl.buf.items[npos].ch,vpnl.buf.items[npos].attribut);
				npos += 1;
			}
	}
};


// defined Trait and Frame for Panel
pub const frm = struct {

	// define attribut default FRAME
	pub var AtrFrame : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.styleDim),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgRed

	};

	// define attribut default TITLE FRAME
	pub var AtrTitle : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.styleBold),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgWhite,
			.foregr = term.ForegroundColor.fgBlue
	};


	/// FRAME

	pub const FRAME = struct {
		name:	[]const u8,
		posx:	usize,
		posy:	usize,
		lines:   usize,
		cols:	usize,
		cadre:   CADRE,
		attribut:term.ZONATRB,
		title:   []const u8,
		titleAttribut: term.ZONATRB,
		actif:   bool
		};

		// define Fram 
		pub fn newFrame(vname:[]const u8,
										vposx:usize, vposy:usize,
										vlines:usize,
										vcols:usize,
										vcadre:CADRE,
										vattribut:term.ZONATRB,
										vtitle:[]const u8,
										vtitleAttribut:term.ZONATRB,
										) FRAME {

					const xframe = FRAME {
							.name = vname,
							.posx = vposx,
							.posy = vposy,
							.lines = vlines,
							.cols = vcols,
							.cadre = vcadre,
							.attribut = vattribut,
							.title = vtitle,
							.titleAttribut = vtitleAttribut,
							.actif = true
					};
			return xframe;

		}


		// write MATRIX TERMINAL	---> arraylist panel-fram
		pub fn printFrame(vpnl : *pnl.PANEL , vfram: FRAME) void {

			// assigne FRAME to init matrice for display
			if (CADRE.line0 == vfram.cadre ) return ;

			const ACS_Hlines	= "─";
			const ACS_Vlines	= "│";
			const ACS_UCLEFT	= "┌";
			const ACS_UCRIGHT   = "┐";
			const ACS_LCLEFT	= "└";
			const ACS_LCRIGHT   = "┘";

			const ACS_Hline2	= "═";
			const ACS_Vline2	= "║";
			const ACS_UCLEFT2   = "╔";
			const ACS_UCRIGHT2  = "╗";
			const ACS_LCLEFT2   = "╚";
			const ACS_LCRIGHT2  = "╝";

			var trait: []const u8 = "";
			var edt :bool	 = undefined ;

			var row:	usize = 1 ;
			var y:	  usize = 0 ;
			var col:	usize = 0 ;
			var npos:   usize = 0 ;

			const wlen : usize = utl.nbrCharStr(vfram.title);

			var n:	  usize = 0 ;
			var x:usize = vfram.posx - 1 ;

			while (row <= vfram.lines) {
				y = vfram.posy - 1;
				col = 1;
				while ( col <= vfram.cols ){
					edt = false;
					if (row == 1) {
							if (col == 1) {
								if ( CADRE.line1 == vfram.cadre ) {
										trait = ACS_UCLEFT;
								} else	trait = ACS_UCLEFT2 ;
								edt = true;
							}
							if ( col == vfram.cols ) {
								if (CADRE.line1 == vfram.cadre) {
									trait = ACS_UCRIGHT;
								} else	trait = ACS_UCRIGHT2 ;
								edt = true;
							}
							if ( col > 1 and col < vfram.cols ) {
								if (CADRE.line1 == vfram.cadre ) {
									trait = ACS_Hlines;
								} else	trait = ACS_Hline2;
								edt = true;
							}
					} else if ( row == vfram.lines ) {
							if (col == 1) {
								if ( CADRE.line1 == vfram.cadre ) {
									trait = ACS_LCLEFT;
								} else	trait = ACS_LCLEFT2;
								edt = true;
							}
							if ( col == vfram.cols ) {
								if ( CADRE.line1 == vfram.cadre ) {
									trait = ACS_LCRIGHT;
								} else	trait = ACS_LCRIGHT2 ;
								edt = true ;
							}
							if ( col > 1 and col < vfram.cols ) {
								if ( CADRE.line1 == vfram.cadre ) {
									trait = ACS_Hlines;
								} else	trait = ACS_Hline2 ;
								edt = true;
							}
					} else if ( row > 1 and row < vfram.lines ) {
						if ( col == 1 or col == vfram.cols ) {
							if ( CADRE.line1 == vfram.cadre ) {
								trait = ACS_Vlines;
							} else trait = ACS_Vline2 ;
							edt = true;
						}
					}
					if	( edt ) {
							npos =	vfram.cols * x;
							n =	npos	+ y;
							vpnl.buf.items[n].ch = trait ;
							vpnl.buf.items[n].attribut = vfram.attribut;
							vpnl.buf.items[n].on = true;
					}

					y += 1;
					col += 1;
				}
				x += 1;
				row +=1 ;
			}

			if (wlen > vfram.cols - 2 or wlen == 0 )	return ;
				npos = vfram.posx;
				n =	npos + (((vfram.cols - wlen ) / 2)) - 1 ;
				var iter = utl.iteratStr.iterator(vfram.title);
				defer iter.deinit();
				while (iter.next()) |ch| {
					vpnl.buf.items[n].ch = std.fmt.allocPrint(allocatorForms,"{s}",.{ch}) catch unreachable;
					vpnl.buf.items[n].attribut = vfram.titleAttribut;
					vpnl.buf.items[n].on = true;
					n +=1;
				}
		}

};



// defined Line and vertical for Panel
pub const lnv = struct {

	// define attribut default FRAME
	pub var AtrLine : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.styleDim),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgYellow

	};


	pub const Elinev = enum {
		name,
		posx,
		posy,
		lng,
		trace
	};

	/// LINE VERTICAL

	pub const LINEV = struct {
		name :	[]const u8,
		posx:	 usize,
		posy:	 usize,
		lng:	  usize,
		trace:	LINE,
		attribut:term.ZONATRB,
		actif:	bool
		};

		// define Fram 
		pub fn newLine(vname:[]const u8,
										vposx:usize, vposy:usize,
										vlng:usize,
										vtrace:LINE,
										) LINEV {

					const xframe = LINEV {
							.name = vname,
							.posx = vposx,
							.posy = vposy,
							.lng = vlng,
							.trace = vtrace,
							.attribut = AtrLine,
							.actif = true
					};
			return xframe;

		}


		// write MATRIX TERMINAL	---> arraylist panel-line
		pub fn printLine(vpnl : *pnl.PANEL , vline: LINEV) void {
		if (vpnl.actif == false ) return ;
		if (vline.actif == false ) return ;

			// assigne FRAMELINE VERTICAL

			const ACS_Vlines	= "│";
			const ACS_Vline2	= "║";

			var row:	usize = 0 ;

			var x: usize = vline.posx - 1 ;

			var trait: []const u8 = "";
			var n : usize =	(vpnl.cols * (vline.posx - 1)) + vline.posy - 1 ;
			while (row <= vline.lng) {


				if ( LINE.line1 == vline.trace ) {
					trait = ACS_Vlines;
				} else trait = ACS_Vline2 ;
				vpnl.buf.items[n].ch = trait ;
				vpnl.buf.items[n].attribut = vline.attribut;
				vpnl.buf.items[n].on = true;
			
				row +=1 ;
				x += 1;
				n =	(vpnl.cols * x ) + vline.posy - 1 ;
			}
		}
	// return index-LINE	---> arraylist panel-line
	pub fn getIndex(vpnl: *pnl.PANEL , name: [] const u8 )	ErrForms ! usize {

		for (vpnl.linev.items, 0..) |l, idx| {
			if (std.mem.eql(u8, l.name, name)) return idx ;
		}
		return ErrForms.line_getIndex_Name_Vertical_Invalide;
	}
};


// defined Line and horizontal for Panel
pub const lnh = struct {

	// define attribut default FRAME
	pub var AtrLine : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.styleDim),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgYellow

	};

	pub const Elineh = enum {
		name,
		posx,
		posy,
		lng,
		trace
	};

	/// LINE HORIZONTAL

	pub const LINEH = struct {
		name :	[]const u8,
		posx:	 usize,
		posy:	 usize,
		lng:	  usize,
		trace:	LINE,
		attribut:term.ZONATRB,
		actif:	bool
		};

		// define Fram 
		pub fn newLine(vname:[]const u8,
					vposx:usize, vposy:usize,
					vlng:usize,
					vtrace:LINE,
					) LINEH {

					const xframe = LINEH {
							.name = vname,
							.posx = vposx,
							.posy = vposy,
							.lng  = vlng,
							.trace = vtrace,
							.attribut = AtrLine,
							.actif = true
					};
			return xframe;

		}


		// write MATRIX TERMINAL	---> arraylist panel-line
		pub fn printLine(vpnl : *pnl.PANEL , vline: LINEH) void {
		if (vpnl.actif == false ) return ;
		if (vline.actif == false ) return ;
			// assigne FRAMELINE HORIZONTAL

			const ACS_Hlines	= "─";
			const ACS_Hline2	= "═";

			var coln:	usize = 0 ;

			var n: usize = 0 ;

			var trait: []const u8 = "";

			n =	(vpnl.cols * (vline.posx - 1)) + vline.posy - 1 ;
			while (coln <= vline.lng) {


				if ( LINE.line1 == vline.trace ) {
					trait = ACS_Hlines;
				} else trait = ACS_Hline2 ;
				vpnl.buf.items[n].ch = trait ;
				vpnl.buf.items[n].attribut = vline.attribut;
				vpnl.buf.items[n].on = true;
			
				coln +=1 ;
				n += 1;
			}
		}

	// return index-LINE	---> arraylist panel-line
	pub fn getIndex(vpnl: *pnl.PANEL , name: [] const u8 )	ErrForms ! usize {

		for (vpnl.lineh.items, 0..) |l, idx| {
			if (std.mem.eql(u8, l.name, name)) return idx ;
		}
		return ErrForms.line_getIndex_Name_Horizontal_Invalide;
	}
};



// defined button
pub const btn = struct{

	// nbr espace intercaler
	pub var btnspc : usize =3 ;
	// define attribut default PANEL
	pub var AtrButton : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.styleDim),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgRed
	};
	pub var AtrTitle : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.styleDim),
										@intFromEnum(term.Style.styleItalic),
										@intFromEnum(term.Style.styleUnderscore),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgdCyan,
	};



	// define BUTTON
	pub const BUTTON = struct {
		name:	[] const u8,
		key :	kbd,
		show:	bool,
		check:   bool,
		title:   []const u8,
		attribut:term.ZONATRB,
		titleAttribut: term.ZONATRB,
		actif:   bool,
	};

	pub const Ebutton = enum {
		name,
		key,
		show,
		check,
		title
	};


	// func BUTTON
	pub fn newButton(
				vkey : kbd,
				vshow : bool,
				vcheck:bool,
				vtitle: [] const u8) BUTTON {

				const xbutton = BUTTON {
						.name = kbd.enumToStr(vkey),
						.key	= vkey,
						.show = vshow,
						.check = vcheck,
						.title = vtitle,
						.attribut = AtrButton,
						.titleAttribut = AtrTitle,
						.actif = true
				};

				return xbutton;
	}

	// return index-button	---> arraylist panel-button
	pub fn getIndex(vpnl: *pnl.PANEL , key: kbd	) ErrForms ! usize {

		for (vpnl.button.items, 0..) |b ,idx	| {
			if (b.key == key) return idx;
		}
		return ErrForms.btn_getIndex_Key_Button_Invalide;
	}

	// return name-button	---> arraylist panel-button
	pub fn getName(vpnl: *pnl.PANEL , n: usize) ErrForms ! [] const u8 {
		if ( n < vpnl.button.items.len) return vpnl.button.items[n].name;
		return ErrForms.btn_getName_Index_invalide ;

	}

	// return key-button	---> arraylist panel-button
	pub fn getKey(vpnl: *pnl.PANEL , n: usize) ErrForms ! kbd {
		if ( n < vpnl.button.items.len) return vpnl.button.items[n].key;
		return ErrForms.btn_getKey_Index_invalide ;

	}

	// return show-button	---> arraylist panel-button
	pub fn getShow(vpnl: *pnl.PANEL , n: usize) ErrForms ! bool {
		if ( n < vpnl.button.items.len) return vpnl.button.items[n].show;
		return ErrForms.btn_getShow_Index_invalide ;
	}

	// return text-button	---> arraylist panel-button
	pub fn getTitle(vpnl: *pnl.PANEL , n: usize) ErrForms ! [] const u8 {
		if ( n < vpnl.button.items.len) return vpnl.button.items[n].title;
		return ErrForms.btn_getText_Index_invalide ;
	}

	// return check-button	---> arraylist panel-button
	// work for field input-field
	pub fn getCheck(vpnl: *pnl.PANEL , n: usize) ErrForms ! bool {
		if ( n < vpnl.button.items.len) return vpnl.button.items[n].check;
		return ErrForms.btn_getCheck_Index_invalide ;
	}

	// return ON/OFF-button	---> arraylist panel-button
	pub fn getActif(vpnl: *pnl.PANEL , n: usize) ErrForms ! bool {
		if ( n < vpnl.button.items.len) return vpnl.button.items[n].actif;
		return ErrForms.btn_getActif_Index_invalide ;
	}

	// set show-button	---> arraylist panel-button
	pub fn setShow(vpnl: *pnl.PANEL , n: usize, val :bool) ErrForms ! void {
		if ( n < vpnl.button.items.len)	vpnl.button.items[n].show = val
		else return ErrForms.btn_setShow_Index_invalide ;
	}

	// set text-button	---> arraylist panel-button
	pub fn setText(vpnl: *pnl.PANEL , n: usize, val:[] const u8) ErrForms ! void {
		if ( n < vpnl.button.items.len) vpnl.button.items[n].text = val
		else return ErrForms.btn_setText_Index_invalide ;
	}

	// set chek-button	---> arraylist panel-button
	pub fn setCheck(vpnl: *pnl.PANEL , n: usize, val :bool) ErrForms ! void {
		if ( n < vpnl.button.items.len) vpnl.button.items[n].check = val
		else return ErrForms.btn_setCheck_Index_invalide ;
	}

	// set ON/OFF-button	---> arraylist panel-button
	pub fn setActif(vpnl: *pnl.PANEL , n: usize, val :bool) ErrForms ! void {
		if ( n < vpnl.button.items.len) vpnl.button.items[n].actif = val
		else return ErrForms.btn_setActif_Index_invalide ;
	}



	// delete -button	---> arraylist panel-button
	pub fn dltRows(vpnl:*pnl.PANEL,	n :usize ) ErrForms ! void {
		if ( n < vpnl.button.items.len) _= vpnl.button.orderedRemove(n)
		else return ErrForms.btn_dltRows_Index_invalide ;
	}


	// assign -button MATRIX TERMINAL	---> arraylist panel-button
	pub fn printButton(vpnl: *pnl.PANEL) void {
		if (vpnl.actif == false ) return ;
	
		const espace :usize = 3;
		var x :usize = 0;
		var y :usize = 0;

		if (vpnl.frame.cadre == CADRE.line0 ) {
			x = vpnl.lines - 1;
			y = 1;
		}
		else {
			x = vpnl.lines - 2;
			y = 2;
		}

		const npos : usize = vpnl.cols * x ;
		var n =	npos + y;

		for (vpnl.button.items) |button| {

			if (button.show == true) {

				// text Function KEY
				var iter = utl.iteratStr.iterator(button.name);
				defer iter.deinit();
				while (iter.next()) |ch| {
					if (button.actif == true) {
						vpnl.buf.items[n].ch = std.fmt.allocPrint(allocatorForms,"{s}",.{ch}) catch unreachable;

						vpnl.buf.items[n].attribut = button.attribut;
						vpnl.buf.items[n].on = true;
					}
					else {
						vpnl.buf.items[n].ch = " ";
						vpnl.buf.items[n].attribut	= vpnl.attribut;
						vpnl.buf.items[n].on = false;
					}
					n += 1;
				}
				n += 1;

				//text Title button
				iter = utl.iteratStr.iterator(button.title);

				while (iter.next()) |ch| {
					if (button.actif == true) {
						vpnl.buf.items[n].ch = std.fmt.allocPrint(allocatorForms,"{s}",.{ch}) catch unreachable;

						vpnl.buf.items[n].attribut = button.titleAttribut;
						vpnl.buf.items[n].on = true;
					}
					else {
						vpnl.buf.items[n].ch = " ";
						vpnl.buf.items[n].attribut	= vpnl.attribut;
						vpnl.buf.items[n].on = false;
					}
					n += 1;
				}
				n += espace;
			}
		}
	}

};




// defined INPUT_FIELD
pub const	fld = struct {


	pub fn ToStr(text : [] const u8 ) []const u8 {
		return std.fmt.allocPrint(allocatorForms,"{s}",.{text}) 
									catch |err| { @panic(@errorName(err));};
	}

	// define attribut default Field
	pub var AtrField : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgWhite
	};

	// field not input
	pub var AtrNil : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.styleDim),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgWhite
	};

	// define attribut default func ioField
	pub var AtrIO : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.styleReverse ),
										@intFromEnum(term.Style.styleDim),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgWhite,
	};

	// define attribut default Field protect
	pub var AtrProtect : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.styleItalic),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgCyan,
	};

	// associated field and call program 
	pub var AtrCall : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgYellow
	};
	
	pub var AtrCursor : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgCyan,
	};


	pub var MsgErr : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgRed
	};


	/// define FIELD
	pub const FIELD = struct {
		name :	[]const u8,
		posx:	 usize,
		posy:	 usize,
		attribut:term.ZONATRB,
		atrProtect:term.ZONATRB,
		atrCall:term.ZONATRB,
		reftyp:   REFTYP,
		width:	usize,
		scal:	 usize,
		nbrcar:   usize,  // nbrcar DECIMAL = (precision+scale + 1'.' ) + 1 this signed || other nbrcar = ALPA..DIGIT..

		requier: bool,	// requier or FULL
		protect: bool,	// only display

		pading: bool,	 // pading blank
		edtcar: []const u8,	// edtcar for monnaie		€ $ ¥ ₪ £ or %

		regex:  []const u8,	//contrôle regex
		errmsg: []const u8,	//message this field

		help: []const u8,	  //help this field

		text: []const u8,
		zwitch: bool,		  // CTRUE CFALSE

		procfunc: []const u8,	//name proc

		proctask: []const u8,	//name proc

		progcall: []const u8,	//name call

		typecall: []const u8,	//type call  SH / APPTERM

		parmcall: bool,			// parm call  Yes/No

		actif:bool,
	};

	pub const Efield = enum {
		name,
		posx,
		posy,
		reftyp,
		width,
		scal,
		text,
		requier,
		protect,
		edtcar,
		errmsg,
		help,
		procfunc,
		proctask,
		progcall,
		typecall,
		parmcall,
		regex
	};

	// for developpeur 
	pub var MouseDsp : bool = false ;





	// New Field String ---> arraylist panel-label
	// refence type
	// TEXT_FREE,
	// ALPHA,
	// ALPHA_UPPER,
	// ALPHA_NUMERIC,
	// ALPHA_NUMERIC_UPPER,
	// ALPHA_FULL,
	// PASSWORD,
	// YES_NO,
	fn initFieldString(
						vname: [] const u8,
						vposx: usize,
						vposy: usize,
						vreftyp: REFTYP,
						vwidth:	usize,
						vtext: []const u8,
						vrequier: bool,
						verrmsg: []const u8,
						vhelp: []const u8,
						vregex: []const u8) FIELD {

		var xfield = FIELD {	 
			.name	 = vname,
			.posx	 = vposx,
			.posy	 = vposy,
			.reftyp   = vreftyp,
			.width	= vwidth,
			.scal	 = 0,
			.nbrcar   = vwidth,
			.requier  = vrequier,
			.protect  = false,
			.pading   = true,
			.edtcar   ="",
			.regex	= "",
			.errmsg   = verrmsg,
			.help	 = vhelp,
			.text	 = vtext,
			.zwitch   = false,
			.procfunc ="",
			.proctask ="",
			.progcall ="",
			.typecall ="",
			.parmcall = false,
			.attribut   = AtrField,
			.atrProtect = AtrProtect,
			.atrCall    = AtrCall,
			.actif	= true
		};
		if (vregex.len > 0 ) xfield.regex = std.fmt.allocPrint(allocatorForms,
			"{s}",.{vregex}) catch |err| { @panic(@errorName(err));};
		return xfield;

	}

	// New Field String	---> arraylist panel-lfield
	// refence type
	// .TEXT_FREE
	pub fn newFieldTextFree(
							vname: [] const u8,
							vposx: usize,
							vposy: usize,
							vwidth:	usize,
							vtext: []const u8,
							vrequier: bool,
							verrmsg: []const u8,
							vhelp: []const u8,
							vregex: []const u8) FIELD {

		return initFieldString(
								vname,
								vposx,
								vposy,
								REFTYP.TEXT_FREE,
								vwidth,
								vtext,
								vrequier,
								verrmsg,
								vhelp,
								vregex);
	}

	// New Field String	---> arraylist panel-lfield
	// letter numeric punct 
	// refence type
	// .TEXT_FULL
	pub fn newFieldTextFull(
							vname: [] const u8,
							vposx: usize,
							vposy: usize,
							vwidth:	usize,
							vtext: []const u8,
							vrequier: bool,
							verrmsg: []const u8,
							vhelp: []const u8,
							vregex: []const u8) FIELD {

		return initFieldString(
							vname,
							vposx,
							vposy,
							REFTYP.TEXT_FULL,
							vwidth,
							vtext,
							vrequier,
							verrmsg,
							vhelp,
							vregex);
	}

	// New Field String	---> arraylist panel-lfield
	// refence type
	// .ALPHA
	pub fn newFieldAlpha(vname: [] const u8,
										vposx: usize, vposy: usize,
										vwidth:	usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8,
										vregex: []const u8) FIELD {
		
		return initFieldString(vname,	vposx, vposy,
													REFTYP.ALPHA,
													vwidth, vtext, vrequier, verrmsg, vhelp, vregex);
	}

	// New Field String	---> arraylist panel-lfield
	// refence type
	// .ALPHA_UPPER
	pub fn newFieldAlphaUpper(vname: [] const u8,
										vposx: usize, vposy: usize,
										vwidth:	usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8,
										vregex: []const u8) FIELD {

		return initFieldString(vname,	vposx, vposy,
													REFTYP.ALPHA_UPPER,
													vwidth, vtext, vrequier, verrmsg, vhelp, vregex);
	}

	// New Field String	---> arraylist panel-lfield
	// refence type
	// .ALPHA_NUMERIC
	pub fn newFieldAlphaNumeric(vname: [] const u8,
										vposx: usize, vposy: usize,
										vwidth:	usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8,
										vregex: []const u8) FIELD {

		return initFieldString(vname,	vposx, vposy,
													REFTYP.ALPHA_NUMERIC,
													vwidth, vtext, vrequier, verrmsg, vhelp, vregex);
	}

	// New Field String	---> arraylist panel-lfield
	// refence type
	// .ALPHA_NUMERIC
	pub fn newFieldAlphaNumericUpper(vname: [] const u8,
										vposx: usize, vposy: usize,
										vwidth:	usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8,
										vregex: []const u8) FIELD {

		return initFieldString(vname,	vposx, vposy,
													REFTYP.ALPHA_NUMERIC_UPPER,
													vwidth, vtext, vrequier, verrmsg, vhelp, vregex);
	}

	// New Field String	---> arraylist panel-lfield
	// refence type
	// .PASSWORD
	pub fn newFieldPassword(vname: [] const u8,
										vposx: usize, vposy: usize,
										vwidth:	usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8,
										vregex: []const u8) FIELD {

		return initFieldString(vname,	vposx, vposy,
													REFTYP.PASSWORD,
													vwidth, vtext, vrequier, verrmsg, vhelp, vregex);
	}

	// New Field String	---> arraylist panel-lfield
	// refence type
	// .YES_NO
	pub fn newFieldYesNo(vname: [] const u8,
										vposx: usize, vposy: usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8) FIELD {


			var xfield = FIELD {	 
					.name	 = vname,
					.posx	 = vposx,
					.posy	 = vposy,
					.reftyp   = REFTYP.YES_NO ,
					.width	= 1,
					.scal	 = 0,
					.nbrcar   = 1,
					.requier  = vrequier,
					.protect  = false,
					.pading   = false,
					.edtcar   = "",
					.regex	= "",
					.errmsg   = verrmsg,
					.help	 = vhelp,
					.text	 = vtext,
					.zwitch   = false,
					.procfunc ="",
					.proctask ="",
					.progcall ="",
					.typecall ="",
					.parmcall = false,
					.attribut   = AtrField,
					.atrProtect = AtrProtect,
					.atrCall    = AtrCall,
					.actif	= true
				};
										
		if (xfield.help.len == 0 ) xfield.help = "to validate Y or N " ;

		return xfield;
	}

	// New Field Switch ---> arraylist panel-field
	// refence type
	// SWITCH,
	pub fn newFieldSwitch(vname: [] const u8,
										vposx: usize, vposy: usize,
										vzwitch: bool,
										verrmsg: []const u8,
										vhelp: []const u8) FIELD {

		var xfield = FIELD {
				.name	 = vname,
				.posx	 = vposx,
				.posy	 = vposy,
				.reftyp   = REFTYP.SWITCH ,
				.width	= 1,
				.scal	 = 0,
				.nbrcar   = 1,
				.requier  = false,
				.protect  = false,
				.pading   = false,
				.edtcar   = "",
				.regex	= "",
				.errmsg   = verrmsg,
				.help	 = vhelp,
				.text	 = "",
				.zwitch   = vzwitch,
				.procfunc ="",
				.proctask ="",
				.progcall ="",
				.typecall ="",
				.parmcall = false,
				.attribut   = AtrField,
				.atrProtect = AtrProtect,
				.atrCall    = AtrCall,
				.actif	= true
		};

		if (xfield.help.len == 0 ) xfield.help = "check ok= ✔ not= ◉  : Select espace bar " ;

		if (xfield.zwitch == true ) xfield.text = CTRUE
		else xfield.text = CFALSE;

		return xfield;

	}

	// New Field Date ---> arraylist panel-field
	// refence type
	// DATE_FR,
	// regex fixe standard
	// Control yyyy = 0001-9999 as well as the traditional MM 02 DAY 28 or 29 values
	// I do not take into account the offset before 1500 ... etc.
	pub fn newFieldDateFR(vname: [] const u8,
										vposx: usize, vposy: usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8) FIELD {


		var xfield = FIELD {
				.name	  = vname,
				.posx	  = vposx,
				.posy	  = vposy,
				.reftyp   = REFTYP.DATE_FR,
				.width    = 10,
				.scal	  = 0,
				.nbrcar   = 10,
				.requier  = vrequier,
				.protect  = false,
				.pading   = false,
				.edtcar   ="",
				.regex	  = "",
				.errmsg   = verrmsg,
				.help	  = vhelp,
				.text	  = vtext,
				.zwitch   = false,
				.procfunc ="",
				.proctask ="",
				.progcall ="",
				.typecall ="",
				.parmcall = false,
				.attribut   = AtrField,
				.atrProtect = AtrProtect,
				.atrCall    = AtrCall,
				.actif	= true
		};


		xfield.regex = std.fmt.allocPrint(allocatorForms,"{s}"
		,.{"^(0[1-9]|[12][0-9]|3[01])[\\/](0[1-9]|1[012])[\\/][0-9]{4,4}$"}) 
		catch |err| { @panic(@errorName(err));};

		if (xfield.help.len == 0 ) xfield.help = "ex: date DD/MM/YYYY" ;

		return xfield;

	}

	// New Field Date ---> arraylist panel-field
	// refence type
	// DATE_US,
	// regex fixe standard
	// Control yyyy = 0001-9999 as well as the traditional MM 02 DAY 28 or 29 values
	// I do not take into account the offset before 1500 ... etc.
	pub fn newFieldDateUS(vname: [] const u8,
										vposx: usize, vposy: usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8) FIELD {


		var xfield = FIELD {
				.name	 = vname,
				.posx	 = vposx,
				.posy	 = vposy,
				.reftyp   = REFTYP.DATE_US,
				.width	= 10,
				.scal	 = 0,
				.nbrcar   = 10,
				.requier  = vrequier,
				.protect  = false,
				.pading   = false,
				.edtcar   ="",
				.regex	= "",
				.errmsg   = verrmsg,
				.help	 = vhelp,
				.text	 = vtext,
				.zwitch   = false,
				.procfunc ="",
				.proctask ="",
				.progcall ="",
				.typecall ="",
				.parmcall = false,
				.attribut = AtrField,
				.atrProtect = AtrProtect,
				.atrCall    = AtrCall,
				.actif	= true
		};

		xfield.regex = std.fmt.allocPrint(allocatorForms,"{s}"
		,.{"^(0[1-9]|1[012])[\\/](0[1-9]|[12][0-9]|3[01])[\\/][0-9]{4,4}$" })
		catch |err| { @panic(@errorName(err));};

		if (xfield.help.len == 0 ) xfield.help = "ex: date MM/DD/YYYY";

		return xfield;

	}


	// New Field Date ---> arraylist panel-field
	// refence type
	// DATE_ISO,
	// regex fixe standard
	// Control yyyy = 0001-9999 as well as the traditional MM 02 DAY 28 or 29 values
	// I do not take into account the offset before 1500 ... etc.
	pub fn newFieldDateISO(vname: [] const u8,
										vposx: usize, vposy: usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8) FIELD {


		var xfield = FIELD {
				.name	 = vname,
				.posx	 = vposx,
				.posy	 = vposy,
				.reftyp   = REFTYP.DATE_ISO,
				.width	= 10,
				.scal	 = 0,
				.nbrcar   = 10,
				.requier  = vrequier,
				.protect  = false,
				.pading   = false,
				.edtcar   ="",
				.regex	= "",
				.errmsg   = verrmsg,
				.help	 = vhelp,
				.text	 = vtext,
				.zwitch   = false,
				.procfunc ="",
				.proctask ="",
				.progcall ="",
				.typecall ="",
				.parmcall = false,
				.attribut   = AtrField,
				.atrProtect = AtrProtect,
				.atrCall    = AtrCall,
				.actif	= true
		};


		xfield.regex = std.fmt.allocPrint(allocatorForms,"{s}"
		,.{"^([0-9]{4,4})[-](0[1-9]|1[012])[-](0[1-9]|[12][0-9]|3[01])$"})
		catch |err| { @panic(@errorName(err));};

		if (xfield.help.len == 0 )	xfield.help = "ex: date YYYY-MM-DD" ;

		return xfield;

	}


	// New Field Mail ---> arraylist panel-field
	// refence type
	// MAIL_ISO,
	// regex fixe standard
	pub fn newFieldMail(vname: [] const u8,
										vposx: usize, vposy: usize,
										vwidth:	usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8) FIELD {

		var xfield = FIELD {
				.name	 = vname,
				.posx	 = vposx,
				.posy	 = vposy,
				.reftyp   = REFTYP.MAIL_ISO,
				.width	= vwidth,
				.scal	 = 0,
				.nbrcar   = vwidth,
				.requier  = vrequier,
				.protect  = false,
				.pading   = true,
				.edtcar   ="",
				.regex	="",
				.errmsg   = verrmsg,
				.help	 = vhelp,
				.text	 = vtext,
				.zwitch   = false,
				.procfunc ="",
				.proctask ="",
				.progcall ="",
				.typecall ="",
				.parmcall = false,
				.attribut   = AtrField,
				.atrProtect = AtrProtect,
				.atrCall    = AtrCall,
				.actif	= true
		};


	// https://stackoverflow.com/questions/201323/how-can-i-validate-an-email-address-using-a-regular-expression
			xfield.regex = std.fmt.allocPrint(allocatorForms,"{s}"
			,.{"^[a-zA-Z0-9_!#$%&'*+/=?`{|}~^.-]+@([a-zA-Z0-9.-])+$"})
			catch |err| { @panic(@errorName(err));};
			
			if (xfield.help.len == 0 ) xfield.help = "ex: myname.my_firstname@gmail.com" ;
				
		return xfield;

	}


	// New Field telephone ---> arraylist panel-field
	// refence type
	// TELEPHONE,
	// regex fixe standard
	pub fn newFieldTelephone(vname: [] const u8,
										vposx: usize, vposy: usize,
										vwidth:	usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8,
										vregex: []const u8) FIELD {

			var xfield = FIELD {
				.name	 = vname,
				.posx	 = vposx,
				.posy	 = vposy,
				.reftyp   = REFTYP.TELEPHONE,
				.width	= vwidth,
				.scal	 = 0,
				.nbrcar   = vwidth,
				.requier  = vrequier,
				.protect  = false,
				.pading   = true,
				.edtcar   ="",
				.regex	= "",
				.errmsg   = verrmsg,
				.help	 = vhelp,
				.text	 = vtext,
				.zwitch   = false,
				.procfunc ="",
				.proctask ="",
				.progcall ="",
				.typecall ="",
				.parmcall = false,
				.attribut = AtrField,
				.atrProtect = AtrProtect,
				.atrCall    = AtrCall,
				.actif	= true
			};

			if (vregex.len > 0 ) xfield.regex = std.fmt.allocPrint(allocatorForms,
			"^{s}",.{vregex}) catch |err| { @panic(@errorName(err));};
			// regex standar
			if (vregex.len == 0 ) xfield.regex = std.fmt.allocPrint(allocatorForms,"{s}"
			,.{"^[+]{1,1}[(]{0,1}[0-9]{1,3}[)]([0-9]{1,3}){1,1}([-. ]?[0-9]{2,3}){2,4}$"})
			catch |err| { @panic(@errorName(err));};

			if (xfield.help.len == 0 ) xfield.help = "ex fr : +(33)6.12.131.141" ;

		return xfield;

	}

	// New Field Digit	---> arraylist panel-lfield
	// refence type
	// .DIGIT unsigned
	pub fn newFieldUDigit(vname: [] const u8,
										vposx: usize, vposy: usize,
										vwidth:	usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8,
										vregex: []const u8) FIELD {

		var xfield = FIELD {
				.name	 = vname,
				.posx	 = vposx,
				.posy	 = vposy,
				.reftyp   = REFTYP.UDIGIT,
				.width	= vwidth,
				.scal	 = 0,
				.nbrcar   = vwidth,
				.requier  = vrequier,
				.protect  = false,
				.pading   = true,
				.edtcar   ="",
				.regex	= vregex,
				.errmsg   = verrmsg,
				.help	 = vhelp,
				.text	 = vtext,
				.zwitch   = false,
				.procfunc ="",
				.proctask ="",
				.progcall ="",
				.typecall ="",
				.parmcall = false,
				.attribut   = AtrField,
				.atrProtect = AtrProtect,
				.atrCall    = AtrCall,
				.actif	= true
		};

			if (vregex.len == 0 ) {
				xfield.regex = std.fmt.allocPrint(allocatorForms,"^[0-9]{{1,{d}}}$",.{xfield.width})
				catch |err| { @panic(@errorName(err));};
			}
			if (xfield.help.len == 0 ) xfield.help = "ex: 0..9" ;

		return xfield;
	}

	// New Field DIGIT	---> arraylist panel-lfield
	// refence type
	// .DIGIT SIGNED
	pub fn newFieldDigit(vname: [] const u8,
										vposx: usize, vposy: usize,
										vwidth:	usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8,
										vregex: []const u8) FIELD {

		var xfield = FIELD {	 
				.name	 = vname,
				.posx	 = vposx,
				.posy	 = vposy,
				.reftyp   = REFTYP.DIGIT,
				.width	= vwidth,
				.scal	 = 0,
				.nbrcar   = 0,
				.requier  = vrequier,
				.protect  = false,
				.pading   = true,
				.edtcar   ="",
				.regex	= vregex,
				.errmsg   = verrmsg,
				.help	 = vhelp,
				.text	 = vtext,
				.zwitch   = false,
				.procfunc ="",
				.proctask ="",
				.progcall ="",
				.typecall ="",
				.parmcall = false,
				.attribut   = AtrField,
				.atrProtect = AtrProtect,
				.atrCall    = AtrCall,
				.actif	= true
		};
			xfield.nbrcar = xfield.width + xfield.scal	+ 1 ;
			if (vregex.len == 0 ) {
				xfield.regex = std.fmt.allocPrint(allocatorForms,"^[+-][0-9]{{1,{d}}}$",.{xfield.width})
				catch |err| { @panic(@errorName(err));};
			}
			if (xfield.help.len == 0 ) xfield.help = "ex: +0..9" ;

		return xfield;
	}

	// New Field Decimal	---> arraylist panel-lfield
	// refence type
	// .DECIMAL UNSIGNED
	pub fn newFieldUDecimal(vname: [] const u8,
										vposx: usize, vposy: usize,
										vwidth:	usize,
										vscal:	usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8,
										vregex: []const u8) FIELD {

		var xfield = FIELD {	 
				.name	 = vname,
				.posx	 = vposx,
				.posy	 = vposy,
				.reftyp   = REFTYP.UDECIMAL,
				.width	= vwidth,
				.scal	 = vscal,
				.nbrcar   = 0,
				.requier  = vrequier,
				.protect  = false,
				.pading   = true,
				.edtcar   ="",
				.regex	= vregex,
				.errmsg   = verrmsg,
				.help	 = vhelp,
				.text	 = vtext,
				.zwitch   = false,
				.procfunc ="",
				.proctask ="",
				.progcall ="",
				.typecall ="",
				.parmcall = false,
				.attribut   = AtrField,
				.atrProtect = AtrProtect,
				.atrCall    = AtrCall,
				.actif	= true
		};

		// caculate len = width add scal add .	
		if (vscal == 0 ) xfield.nbrcar = xfield.width 
		else xfield.nbrcar = xfield.width + xfield.scal	+ 1 ;

		if (vregex.len == 0 ) {
			if (vscal == 0 ) xfield.regex = std.fmt.allocPrint(allocatorForms,
			"^[0-9]{{1,{d}}}$",.{vwidth})	catch |err| { @panic(@errorName(err));}

			else xfield.regex = std.fmt.allocPrint(allocatorForms,
			"^[0-9]{{1,{d}}}[.][0-9]{{{d}}}$",.{vwidth,vscal,})
			catch |err| { @panic(@errorName(err));};
		}
		if (xfield.help.len == 0 ) xfield.help = "ex: 12301 or 123.01" ;

		return xfield;
	}

	// New Field Decimal	---> arraylist panel-lfield
	// refence type
	// .DECIMAL SIGNED
	pub fn newFieldDecimal(vname: [] const u8,
										vposx: usize, vposy: usize,
										vwidth: usize,
										vscal:	usize,
										vtext: []const u8,
										vrequier: bool,
										verrmsg: []const u8,
										vhelp: []const u8,
										vregex: []const u8) FIELD {

		var xfield = FIELD {	 
				.name	 = vname,
				.posx	 = vposx,
				.posy	 = vposy,
				.reftyp   = REFTYP.DECIMAL,
				.width	= vwidth,
				.scal	 = vscal,
				.nbrcar   = 0,
				.requier  = vrequier,
				.protect  = false,
				.pading	= true,
				.edtcar   ="",
				.regex	= vregex,
				.errmsg   = verrmsg,
				.help	 = vhelp,
				.text	 = vtext,
				.zwitch   = false,
				.procfunc ="",
				.proctask ="",
				.progcall ="",
				.typecall ="",
				.parmcall = false,
				.attribut   = AtrField,
				.atrProtect = AtrProtect,
				.atrCall    = AtrCall,
				.actif	= true
		};

		// caculate len = width add scal add + . 
		if (vscal == 0 ) xfield.nbrcar = xfield.width + 1
		else xfield.nbrcar = xfield.width + xfield.scal	+ 2 ;
		if (vregex.len == 0 ) {

			if (vscal == 0 ) xfield.regex =	std.fmt.allocPrint(allocatorForms,
			"^[+-][0-9]{{1,{d}}}$",.{vwidth}) catch |err| { @panic(@errorName(err));}

			else xfield.regex = std.fmt.allocPrint(allocatorForms,
			"^[+-][0-9]{{1,{d}}}[.][0-9]{{{d}}}$",.{vwidth,vscal}) 
			catch |err| { @panic(@errorName(err));};

		}
		if (xfield.help.len == 0 ) xfield.help = "ex: +12301 or +123.01" ;

		return xfield;
	}


	// New Field Switch ---> arraylist panel-field
	// refence type
	// FUNC,
	pub fn newFieldFunc(vname: [] const u8,
										vposx: usize, vposy: usize,
										vwidth: usize,
										vtext: []const u8,
										vrequier: bool,
										vprocfunc:	[] const u8,
										verrmsg: []const u8,
										vhelp: []const u8) FIELD {

		var xfield = FIELD {	 
				.name	 = vname,
				.posx	 = vposx,
				.posy	 = vposy,
				.reftyp   = REFTYP.FUNC,
				.width	= vwidth,
				.scal	 = 0,
				.nbrcar   = vwidth,
				.requier  = vrequier,
				.protect  = false,
				.pading   = false,
				.edtcar   = "",
				.regex	= "",
				.errmsg   = verrmsg,
				.help	 = vhelp,
				.text	 = vtext,
				.zwitch   = false,
				.procfunc =vprocfunc,
				.proctask ="",
				.progcall ="",
				.typecall ="",
				.parmcall = false,
				.attribut   = AtrField,
				.atrProtect = AtrProtect,
				.atrCall    = AtrCall,
				.actif	= true
		};

		if (xfield.help.len == 0 ) xfield.help = " Select espace bar " ;
		return xfield;

	}
	//========================================================================
	//========================================================================
	pub fn getIndex(vpnl: *pnl.PANEL , name: [] const u8 )	ErrForms ! usize {
		for (vpnl.field.items, 0..) |f, idx | {
			if (std.mem.eql(u8, f.name, name)) return idx;
		}
		return ErrForms.fld_getIndex_Name_Field_Invalide;
	}

	pub fn getName(vpnl: *pnl.PANEL , n: usize) ErrForms ! [] const u8 {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].name;
		return ErrForms.fld_getName_Index_invalide ;

	}
	pub fn getPosx(vpnl: *pnl.PANEL , n: usize)	ErrForms ! usize {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].posx;
		return ErrForms.fld_getPosx_Index_invalide ;
	}
	pub fn getPosy(vpnl: *pnl.PANEL , n: usize)	ErrForms ! usize {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].posy;
		return ErrForms.fld_getPosy_Index_invalide ;
	}
	pub fn getRefType(vpnl: *pnl.PANEL , n: usize)	ErrForms ! REFTYP {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].reftyp;
		return ErrForms.fld_getRefType_Index_invalide ;
	}
	pub fn getWidth(vpnl: *pnl.PANEL , n: usize)	ErrForms ! usize {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].width;
		return ErrForms.fld_getWidth_Index_invalide ;
	}
	pub fn getScal(vpnl: *pnl.PANEL , n: usize)	ErrForms ! usize {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].scal;
		return ErrForms.fld_getScal_Index_invalide ;
	}
	pub fn getNbrCar(vpnl: *pnl.PANEL , n: usize)	ErrForms ! usize {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].nbrcar;
		return ErrForms.fld_getNbrCar_Index_invalide ;
	}
	pub fn getRequier(vpnl: *pnl.PANEL , n: usize)	ErrForms ! bool {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].requier;
		return ErrForms.fld_getRequier_Index_invalide ;
	}
	pub fn getProtect(vpnl: *pnl.PANEL , n: usize)	ErrForms ! bool {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].protect;
		return ErrForms.fld_getProtect_Index_invalide ;
	}
	pub fn getPading(vpnl: *pnl.PANEL , n: usize)	ErrForms ! bool {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].pading;
		return ErrForms.fld_getPading_Index_invalide ;
	}
	pub fn getEdtcar(vpnl: *pnl.PANEL , n: usize)	ErrForms ! [] const u8 {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].edtcar;
		return ErrForms.fld_getEdtcar_Index_invalide ;
	}
	pub fn getRegex(vpnl: *pnl.PANEL , n: usize)	ErrForms ! [] const u8 {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].regex;
		return ErrForms.fld_getRegex_Index_invalide ;
	}
	pub fn getErrMsg(vpnl: *pnl.PANEL , n: usize)	ErrForms ! [] const u8 {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].errmsg;
		return ErrForms.fld_getErrMsg_Index_invalide ;
	}
	pub fn getHelp(vpnl: *pnl.PANEL , n: usize)	ErrForms ! [] const u8 {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].help;
		return ErrForms.fld_getHelp_Index_invalide ;
	}
	pub fn getText(vpnl: *pnl.PANEL , n: usize)	ErrForms ! [] const u8 {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].text;
		return ErrForms.fld_getText_Index_invalide ;
	}
	pub fn getSwitch(vpnl: *pnl.PANEL , n: usize)	ErrForms ! bool {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].zwitch;
		return ErrForms.fld_getSwitch_Index_invalide ;
	}
	pub fn getErr(vpnl: *pnl.PANEL , n: usize)	ErrForms ! bool {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].err;
		return ErrForms.fld_getErr_Index_invalide ;
	}
	pub fn getFunc(vpnl: *pnl.PANEL , n: usize)	ErrForms ! [] const u8 {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].procfunc;
		return ErrForms.fld_getFunc_Index_invalide ;
	}
	pub fn getTask(vpnl: *pnl.PANEL , n: usize)	ErrForms ! [] const u8 {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].proctask;
		return ErrForms.fld_getTask_Index_invalide ;
	}
	pub fn getCall(vpnl: *pnl.PANEL , n: usize)	ErrForms ! [] const u8 {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].progcall;
		return ErrForms.fld_getCall_Index_invalide ;
	}
	pub fn getTypeCall(vpnl: *pnl.PANEL , n: usize)	ErrForms ! [] const u8 {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].typecall;
		return ErrForms.fld_getTypeCall_Index_invalide ;
	}
	pub fn getParmCall(vpnl: *pnl.PANEL , n: usize)	ErrForms ! bool {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].parmcall;
		return ErrForms.fld_getParmCall_Index_invalide ;
	}
	pub fn getAttribut(vpnl: *pnl.PANEL , n: usize)	ErrForms ! term.ZONATRB {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].atribut;
		return ErrForms.fld_getAttribut_Index_invalide ;
	}
	pub fn getAtrProtect(vpnl: *pnl.PANEL , n: usize)	ErrForms ! term.ZONATRB {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].atrProtect;
		return ErrForms.fld_AtrProtect_Index_invalide ;
	}
	pub fn getActif(vpnl: *pnl.PANEL , n: usize)	ErrForms ! bool {
		if ( n < vpnl.field.items.len) return vpnl.field.items[n].actif;
		return ErrForms.fld_getActif_Index_invalide ;
	}


	pub fn setText(vpnl: *pnl.PANEL , n: usize, val:[] const u8) ErrForms ! void {
		if ( n < vpnl.field.items.len) vpnl.field.items[n].text = val
		else return ErrForms.fld_setText_Index_invalide;
	}

	//	Input Field 
	pub fn setSwitch(vpnl: *pnl.PANEL , n: usize, val :bool)	ErrForms ! void {
		if ( n < vpnl.field.items.len) {
			vpnl.field.items[n].zwitch = val;
			vpnl.field.items[n].text = utl.boolToCbool(val);
		}
		else return ErrForms.fld_setSwitch_Index_invalide;

	}
	pub fn setProtect(vpnl: *pnl.PANEL , n: usize, val :bool)	ErrForms ! void {
		if ( n < vpnl.field.items.len)	vpnl.field.items[n].protect = val
		else return ErrForms.fld_setProtect_Index_invalide;
	}

	pub fn setRequier(vpnl: *pnl.PANEL , n: usize, val :bool)	ErrForms ! void {
		if ( n < vpnl.field.items.len)	vpnl.field.items[n].protect = val
		else return ErrForms.fld_setRequier_Index_invalide;
	}

	pub fn setEdtcar(vpnl: *pnl.PANEL , n: usize, val:[] const u8)	ErrForms ! void {
		if ( n < vpnl.field.items.len) vpnl.field.items[n].edtcar = val
		else return ErrForms.fld_setEdtcar_Index_invalide;
	}
	pub fn setRegex(vpnl: *pnl.PANEL , n: usize, val:[] const u8)	ErrForms ! void {
		if ( n < vpnl.field.items.len) vpnl.field.items[n].reftyp = val
		else return ErrForms.fld_setRegex_Index_invalide;
	}
	pub fn setTask(vpnl: *pnl.PANEL , n: usize, val :[]const u8)	ErrForms ! void {
		if ( n < vpnl.field.items.len) vpnl.field.items[n].proctask = val
		else return ErrForms.fld_setTask_Index_invalide;
	}
	pub fn setCall(vpnl: *pnl.PANEL , n: usize, val :[]const u8)	ErrForms ! void {
		if ( n < vpnl.field.items.len) vpnl.field.items[n].progcall = val
		else return ErrForms.fld_setCall_Index_invalide;
	}
	pub fn setTypeCall(vpnl: *pnl.PANEL , n: usize, val :[]const u8)	ErrForms ! void {
		if ( n < vpnl.field.items.len) vpnl.field.items[n].typecall = val
		else return ErrForms.fld_setTypeCall_Index_invalide ;
	}
	pub fn setParmCall(vpnl: *pnl.PANEL , n: usize, val :bool)	ErrForms ! void {
		if ( n < vpnl.field.items.len) vpnl.field.items[n].parmcall = val
		else return ErrForms.fld_setParmCall_Index_invalide ;
	}
	pub fn setActif(vpnl: *pnl.PANEL , n: usize, val :bool)	ErrForms ! void {
		if ( n < vpnl.field.items.len) vpnl.field.items[n].actif = val
		else return ErrForms.fld_setActif_Index_invalide;
	}

	pub fn dltRows(vpnl: *pnl.PANEL,	n :usize ) ErrForms ! void {
		if ( n < vpnl.field.items.len)	_= vpnl.field.orderedRemove(n)
		else return ErrForms.fld_dltRows_Index_invalide;
	}


	// clear value ALL FIELD
	pub fn clearAll(vpnl: *pnl.PANEL) void {
		var n : usize = 0;
		for (vpnl.field.items) |_ | {
			vpnl.field.items[n].text = "";
			vpnl.field.items[n].zwitch = false;
			n += 1 ;
		}
	}
	pub fn clearField(vpnl: *pnl.PANEL , n: usize,)	void {
		if ( n > vpnl.field.items.len) return;
		vpnl.field.items[n].text = "";
		vpnl.field.items[n].zwitch = false;
	}


	// matrix cleaning from Field
	pub fn clsField(vpnl: *pnl.PANEL, vfld : FIELD )	void {
		// display matrice PANEL
		if (vpnl.actif == false ) return ;
		if (vfld.actif == false ) return ;
			const x :usize = vfld.posx - 1;
			const y :usize = vfld.posy - 1;
			var n :usize = 0;
			var npos :usize = (vpnl.cols * vfld.posx) + vfld.posy - 1 ;
			while (n < vfld.nbrcar) : (n += 1) {
				vpnl.buf.items[npos].ch = " ";
				vpnl.buf.items[npos].attribut	= vpnl.attribut;
				vpnl.buf.items[npos].on = false;
				term.gotoXY(x + vpnl.posx	 , y + vpnl.posy - n	);
				term.writeStyled(vpnl.buf.items[npos].ch,vpnl.buf.items[npos].attribut);
				npos += 1;
			}
	}


	pub fn printField(vpnl: *pnl.PANEL, vfld : FIELD) void {
		if ( vpnl.actif == false ) return ; 
		// assigne FIELD to matrice for display
		var n = (vpnl.cols * (vfld.posx - 1)) + vfld.posy - 1;
		var nn: usize = 0;

		while (nn < vfld.nbrcar) : (nn += 1 ) {
			if (vfld.actif == true) {
				vpnl.buf.items[n].ch = " " ;
				if (vfld.protect == true) vpnl.buf.items[n].attribut = vfld.atrProtect
				else {
					if (std.mem.eql(u8,vfld.progcall ,"")) vpnl.buf.items[n].attribut = vpnl.attribut
					else vpnl.buf.items[n].attribut = vfld.atrCall;
				}
				vpnl.buf.items[n].on = true;
			}
			else {
				vpnl.buf.items[n].ch = " ";
				vpnl.buf.items[n].attribut	= vpnl.attribut;
				vpnl.buf.items[n].on = false;
			}
			n += 1;
		}

		// The err field takes precedence, followed by protection, followed by the base attribute
		n = (vpnl.cols * (vfld.posx - 1)) + vfld.posy - 1	;

		var nfld = vfld.text;
		var nile = false ;
		if (nfld.len == 0 and !vfld.protect ) {
			nfld = "_";
			nile = true;
		}
		if (vfld.reftyp == REFTYP.SWITCH) {
			if ( vfld.zwitch ) nfld = CTRUE
			else nfld= CFALSE;
		}
		
		var iter = utl.iteratStr.iterator(nfld);
		defer iter.deinit();
		while (iter.next()) |ch| {
			if (vfld.actif == true ) {
				if (vfld.reftyp == REFTYP.PASSWORD) vpnl.buf.items[n].ch = "*" 
				else vpnl.buf.items[n].ch = std.fmt.allocPrint(allocatorForms,"{s}",.{ch}) catch unreachable;


				vpnl.buf.items[n].on = true;

				if (vfld.protect) vpnl.buf.items[n].attribut = vfld.atrProtect
				else {
						if (nile)vpnl.buf.items[n].attribut	= AtrNil
						else {
							if (std.mem.eql(u8,vfld.progcall ,"")) vpnl.buf.items[n].attribut = vpnl.attribut
							else vpnl.buf.items[n].attribut = vfld.atrCall;
						}
				}

			}
			n += 1;
		}
	}

	pub fn displayField(vpnl: *pnl.PANEL, vfld : FIELD )	void {
		// display matrice PANEL
		if (vpnl.actif == false ) return ;
		if (vfld.actif == false ) return ;
			const x :usize = vfld.posx - 1;
			const y :usize = vfld.posy - 1;
			var n :usize = 0;
			var npos :usize = (vpnl.cols * (vfld.posx - 1)) + vfld.posy - 1 ;
			while (n < vfld.nbrcar) : (n += 1) {
				term.gotoXY(x + vpnl.posx	 , y + vpnl.posy + n	);
				term.writeStyled(vpnl.buf.items[npos].ch,vpnl.buf.items[npos].attribut);
				npos += 1;
			}
	}


	//----------------------------------------------------==
	// Input buffer management modeled on 5250/3270
	// inspiration ncurse
	// application hold principe and new langage
	//----------------------------------------------------==

	var e_FIELD : std.ArrayList([] const u8) = undefined;

	var e_switch: bool = false;

	fn nbrCarField() usize {
		var wl : usize =0;
		var iter = utl.iteratStr.iterator(utl.listToStr(e_FIELD));
		defer iter.deinit();
		while (iter.next()) |_|	{ wl += 1 ;}
		return wl;
	}


	fn delete(n : usize) void {
		_=e_FIELD.orderedRemove(n);
		e_FIELD.append(" ") catch |err| { @panic(@errorName(err));};
	}

	fn insert(c: [] const u8 , n : usize) void {
		_=e_FIELD.orderedRemove(nbrCarField() - 1);

		const allocator = std.heap.page_allocator;
		var x_FIELD = std.ArrayList([] const u8).init(allocator);
		defer x_FIELD.deinit();

		for ( e_FIELD.items) |ch | {
			x_FIELD.append(ch) catch |err| { @panic(@errorName(err));};
		}
		e_FIELD.clearRetainingCapacity();


		for ( x_FIELD.items ,0..) |ch , idx | {
			if ( n != idx) e_FIELD.append(ch) catch |err| { @panic(@errorName(err));};
			if ( n == idx) { 
				e_FIELD.append(c)	catch |err| { @panic(@errorName(err));};
				e_FIELD.append(ch)	catch |err| { @panic(@errorName(err));};
			} 
		}
	}



	fn isrequier() bool {
		var text = utl.listToStr(e_FIELD);
		text = utl.trimStr(text);

		if (text.len == 0 ) return true ;
		return false ;
	}
	
	/// Check if it is a space
	fn isSpace(c: [] const u8) bool { 
		if ( std.mem.eql(u8, c, " ") ) return true;
		return false ;
	}

	/// if it is a KEY function
	fn isfuncKey(vpnl: *pnl.PANEL, e_key: term.Keyboard) bool {
		for ( vpnl.button.items) |xbtn| {
			if (xbtn.key == e_key.Key ) return true;
		}
		return false;
	}
	
	/// if it is a KEY function Check
	fn ischeckKey(vpnl: *pnl.PANEL, e_key: term.Keyboard) bool {
		for ( vpnl.button.items) |xbtn| {
			if (xbtn.key == e_key.Key and xbtn.check ) return true;
		}
		return false;
	}
	
	/// Hides the area entered with *
	fn password(s: std.ArrayList([] const u8)) [] const u8 {
		var i: usize = 0;
		var buf : [] const u8 = "";
		while ( i < s.items.len ) : (i += 1) {
				if ( std.mem.eql(u8,s.items[i]," " )) buf = utl.concatStr(buf," ") 
				else	buf = utl.concatStr(buf,"*");
		}
		return buf;
	}

	/// initialize the input field e_FIELD
	/// switch convert bool CTRUE /CFALSE
	/// the buffer displays field the text and completes with blanks
	fn initData(f:FIELD) void {
		e_FIELD.clearRetainingCapacity();
		if ( f.reftyp == REFTYP.SWITCH) {
			if (e_switch == true ) 
				utl.addListStr(&e_FIELD	, CTRUE) 
			else
				utl.addListStr(&e_FIELD	, CFALSE);
		}
		else {
				utl.addListStr(&e_FIELD	, f.text);
			var i:usize = 0 ;
			while (i < (f.nbrcar - utl.nbrCharStr(f.text))) : ( i += 1) {
				e_FIELD.append(" ") catch |err| { @panic(@errorName(err));};
			}
		}
	}


	fn msgHelp(vpnl: *pnl.PANEL, f : FIELD ) void {

		// define attribut default MSG Error
		const MsgHelp : term.ZONATRB = .{
				.styled=[_]u32{@intFromEnum(term.Style.notStyle),
											@intFromEnum(term.Style.notStyle),
											@intFromEnum(term.Style.notStyle),
											@intFromEnum(term.Style.notStyle)},
				.backgr = term.BackgroundColor.bgBlack,
				.foregr = term.ForegroundColor.fgRed
		};


		const x: usize	= vpnl.lines;
		var n: usize	= vpnl.cols * (x - 2) ;
		var y: usize	= 1 ;

		var msghlp:[]const u8 = utl.concatStr("Help : ", f.help) ;
		var boucle : bool= true ;

		if (vpnl.cols < (msghlp.len) )	msghlp = subStrForms( msghlp,0,	vpnl.cols - 2);

		// clear line button 
		while (y <= (vpnl.cols - 2) ) : (y += 1) {
			term.gotoXY(vpnl.posx + x	- 2	 , y + vpnl.posy );
			term.writeStyled(" ",vpnl.attribut);
		}
		// display msgerr
		y = 1 ;
		term.gotoXY(vpnl.posx + x	- 2, y + vpnl.posy );
		term.writeStyled(msghlp,MsgHelp);

		while (boucle) {
			const e_key = kbd.getKEY();

			switch ( e_key.Key ) {
				.esc=>boucle = false,
			else =>	{},
			}
		}

		// restore line panel
		y = 1 ;
		while (y <= (vpnl.cols - 2)) : (y += 1) {
			n += 1;
			term.gotoXY( vpnl.posx + x	- 2, y + vpnl.posy);
			term.writeStyled(vpnl.buf.items[n].ch,vpnl.buf.items[n].attribut);
		}
	}

	///------------------------------------------------
	/// Definition of the panel (window) on a lines
	/// Message display
	/// to exit press the Escape key
	/// restoration of the original panel lines
	///------------------------------------------------

	pub fn msgErr(vpnl: *pnl.PANEL, f : FIELD,	info: [] const u8 ) void {

		term.gotoXY(vpnl.posx + f.posx - 1 , vpnl.posy + f.posy - 1);
		term.writeStyled(utl.listToStr(e_FIELD),MsgErr);


		const x: usize	= vpnl.lines;
		var n: usize	= vpnl.cols * (x - 2) ;
		var y: usize	= 1 ;

		var msgerr:[]const u8 = utl.concatStr("Info : ", info) ;
		var boucle : bool= true ;

		if (vpnl.cols < (msgerr.len) )	msgerr = subStrForms( msgerr, 0,	vpnl.cols - 2);

		// clear line button 
		while (y <= (vpnl.cols - 2) ) : (y += 1) {
			term.gotoXY(vpnl.posx + x	- 2	 , y + vpnl.posy	);
			term.writeStyled(" ",vpnl.attribut);
		}
		// display msgerr
		y = 1 ;
		term.gotoXY(vpnl.posx + x	- 2, y + vpnl.posy	 );
		term.writeStyled(msgerr,MsgErr);

		while (boucle) {
			const e_key = kbd.getKEY();

			switch ( e_key.Key ) {
				.esc=>boucle = false,
			else =>	{},
			}
		}

		// restore line panel
		while (y <= (vpnl.cols - 2)) : (y += 1) {
			n += 1;
			term.gotoXY( vpnl.posx + x	- 2, y + vpnl.posy	);
			term.writeStyled(vpnl.buf.items[n].ch,vpnl.buf.items[n].attribut);
		}
	}


	//====================================================
	// ioFIELD
	//====================================================
	
	pub fn ioField(vpnl: *pnl.PANEL, vfld : FIELD ) kbd	{
		if (vfld.protect or !vfld.actif)	return kbd.none;

		const e_posx :usize = vpnl.posx + vfld.posx - 1;
		const e_posy :usize = vpnl.posy + vfld.posy - 1;
		var e_curs :usize = e_posy ;
		var e_count :usize	= 0;
		const e_nbrcar:usize	= vfld.nbrcar;
		var statusCursInsert : bool = false ;
		var nfield :usize = 0 ;

		const allocator = std.heap.page_allocator;
		e_FIELD = std.ArrayList([] const u8).init(allocator);
		e_FIELD.clearAndFree();
		defer e_FIELD.deinit();
		
		e_switch = vfld.zwitch;
		const e_reftyp = vfld.reftyp;

		var tampon: [] const u8 = undefined;

		if ( e_posx == 0) return kbd.enter;
		
		vpnl.keyField = kbd.none;
		
		// prepare the switch edition
		initData(vfld);

		var Fkey : term.Keyboard = undefined ;
		var boucle : bool= true ;

		term.defCursor(term.typeCursor.cBlink);

		term.onMouse();


		//===========================
		// boucle saisie
		//===========================
		while( boucle == true) {
			

			term.gotoXY(e_posx ,e_posy);
			switch(e_reftyp) {
				.PASSWORD =>	term.writeStyled(password(e_FIELD),AtrIO) ,
				.SWITCH	 =>	if (e_switch) term.writeStyled(CTRUE,AtrIO)
							else term.writeStyled(CFALSE,AtrIO),
				else => term.writeStyled(utl.listToStr(e_FIELD),AtrIO)
			}

			term.gotoXY(e_posx,e_curs);

			if (statusCursInsert) term.defCursor(term.typeCursor.cSteadyBar)	
			else term.defCursor(term.typeCursor.cBlink); // CHANGE CURSOR FORM BAR/BLOCK

			switch(e_reftyp) {
				.PASSWORD => { 
							if ( std.mem.eql(u8,e_FIELD.items[e_count] , " ")	) term.writeStyled(" ", AtrCursor)
							else term.writeStyled("*", AtrCursor);
				},
				else =>term.writeStyled(e_FIELD.items[e_count], AtrCursor),
			}
			term.gotoXY(e_posx,e_curs);
			term.cursShow();

			Fkey = kbd.getKEY();

			term.resetStyle();

			if (isfuncKey(vpnl,Fkey)) boucle = false
			else {
				if (Fkey.Key == kbd.mouse ) {
					Fkey.Key = kbd.none;

					if (term.MouseInfo.scroll ) {
							switch (term.MouseInfo.scrollDir) {
							term.ScrollDirection.msUp =>		Fkey.Key = kbd.up,
							term.ScrollDirection.msDown =>	Fkey.Key = kbd.down,
							else => {}
						}
					}
					else {
				
						if (term.MouseInfo.action == term.MouseAction.maReleased ) continue;
						
						if (MouseDsp) dspMouse(vpnl);	// active display Cursor x/y mouse

						switch (term.MouseInfo.button) {
							term.MouseButton.mbLeft		=>	Fkey.Key = kbd.left,

							term.MouseButton.mbMiddle	=>	Fkey.Key = kbd.enter,

							term.MouseButton.mbRight	 =>	Fkey.Key = kbd.right,
							else => {}
						}
					}
				}



				switch(Fkey.Key) {
					.none => {
									term.gotoXY(e_posx,e_curs);
					},
					.esc => {
									initData(vfld) ;
					}, 
					.ctrlH => {
						if (	vfld.help.len > 0 ) msgHelp(vpnl,vfld);
					},
					.ctrlP => {
						// Call pgm
						if ( vfld.progcall.len > 0) {
							Fkey.Key = kbd.call;
							break; 
						}
					},
					.home => {
						e_count = 0;
						e_curs = e_posy;
					},
					.end => {
						tampon	= utl.listToStr(e_FIELD);
						if ( utl.trimStr(tampon).len > 0) {
							e_count = utl.trimStr(tampon).len - 1;
							e_curs	= e_posy + utl.trimStr(tampon).len - 1;
						}
						else {
							e_count = 0 ;
							e_curs	= e_posy;
						}
					},
					.right , .tab	=> {
						if ( e_count < e_nbrcar - 1 and !isSpace(e_FIELD.items[0])) {
								e_count += 1;
								e_curs	+= 1;
						}
					},
					.left , .stab=> {
						if( e_curs > e_posy) {
						e_count -= 1;
						e_curs	-= 1;
						}
					},
					.backspace => {
						if( e_reftyp != REFTYP.SWITCH) {
							delete(e_count);
							tampon	= utl.listToStr(e_FIELD);
							if( e_count > 0 ) {
								e_count = utl.trimStr(tampon).len - 1 ;
								e_curs	= e_posy + e_count;
							}
							else {e_count = 0; e_curs	= e_posy ;}
						}
					},
					.delete=> {
						if( e_reftyp != REFTYP.SWITCH) {
							if( e_count >= 0) {
								if (e_reftyp == REFTYP.DIGIT	and e_count >= 0 or	e_reftyp == REFTYP.DECIMAL and
									e_count >= 0 ) {
										delete(e_count);
									}
									else if (e_reftyp != REFTYP.DIGIT	 and	e_reftyp != REFTYP.DECIMAL)	{
													delete(e_count);
												}
							}
						}
					},
					.ins=> {
						if( statusCursInsert )	statusCursInsert = false
						else statusCursInsert = true;
					},
					.enter , .up , .down => {	// enrg to Field

						//check requier and field.len > 0
						if (vfld.requier and utl.trimStr(utl.listToStr(e_FIELD)).len == 0 ) {
							msgErr(vpnl,vfld,vfld.errmsg);
							e_curs = e_posy;
							e_count = 0;
							continue;
						}

						//check field.len > 0 and regexLen > 0 execute regex
						if ( vfld.regex.len > 0 and utl.trimStr(utl.listToStr(e_FIELD)).len > 0) {
								if ( ! reg.isMatch(utl.trimStr(utl.listToStr(e_FIELD)) ,vfld.regex) ) {
									msgErr(vpnl,vfld,vfld.errmsg);
									e_curs = e_posy;
									e_count = 0 ;
									continue;
								}
						}


						//write value keyboard to field.text return key
						nfield = getIndex(vpnl,vfld.name) catch |err| { @panic(@errorName(err));};

						if (vfld.reftyp == REFTYP.SWITCH) setSwitch(vpnl, nfield, e_switch ) 
							catch |err| { @panic(@errorName(err));}
						
						else {
							setText(vpnl, nfield, ToStr(utl.trimStr(utl.listToStr(e_FIELD)))) 
							catch |err| { @panic(@errorName(err));};
						}
						vpnl.keyField = Fkey.Key; 
						// control is task 
						if ( vfld.proctask.len > 0) {
							Fkey.Key = kbd.task;
							break; 
						}
						

						break;
					},
					.char=> {
						if (utl.isCarOmit(Fkey.Char) == false ) 
							switch(e_reftyp) {
								.TEXT_FREE=> {
									if ( (e_count < e_nbrcar and isSpace(Fkey.Char) == false ) or
										(isSpace(Fkey.Char) == true and e_count > 0 and e_count < e_nbrcar) ) {
										
										if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
										else	e_FIELD.items[e_count] = Fkey.Char;

										e_count += 1;
										e_curs	+= 1;
										if (e_count == e_nbrcar) {
											e_count -= 1;
											e_curs	-= 1;
										}
										

									}
								},
								.TEXT_FULL=> {
									if ( (e_count < e_nbrcar and isSpace(Fkey.Char) == false ) or
										(utl.isLetterStr(Fkey.Char) or utl.isDigitStr(Fkey.Char) or
										utl.isSpecialStr(Fkey.Char)) or
										(isSpace(Fkey.Char) == true and e_count > 0 and e_count < e_nbrcar) ) {
										
										if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
										else	e_FIELD.items[e_count] = Fkey.Char;

										e_count += 1;
										e_curs	+= 1;
										if (e_count == e_nbrcar) {
											e_count -= 1;
											e_curs	-= 1;
										}
										

									}
								},
								.ALPHA, .ALPHA_UPPER => {
									if ( (e_count < e_nbrcar and isSpace(Fkey.Char) == false ) and
									(utl.isLetterStr(Fkey.Char) or std.mem.eql(u8, Fkey.Char, "-")) or
									(isSpace(Fkey.Char) == true and e_count > 0 and e_count < e_nbrcar) ) {
										
										if (vfld.reftyp == .ALPHA_UPPER) Fkey.Char = utl.upperStr(Fkey.Char);

										if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
										else	e_FIELD.items[e_count] = Fkey.Char;

										e_count += 1;
										e_curs	+= 1;
										if (e_count == e_nbrcar) {
											e_count -= 1;
											e_curs	-= 1;
										}
									}
								},
								.ALPHA_NUMERIC, .ALPHA_NUMERIC_UPPER => {
									if ( (e_count < e_nbrcar and isSpace(Fkey.Char) == false ) and
									(utl.isLetterStr(Fkey.Char) or utl.isDigitStr(Fkey.Char) or
									 std.mem.eql(u8, Fkey.Char, "-")) or
									(isSpace(Fkey.Char) == true and e_count > 0 and e_count < e_nbrcar) ) {

										if (vfld.reftyp == .ALPHA_NUMERIC_UPPER) Fkey.Char = utl.upperStr(Fkey.Char);

										if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
										else	e_FIELD.items[e_count] = Fkey.Char;

										e_count += 1;
										e_curs	+= 1;
										if (e_count == e_nbrcar) {
											e_count -= 1;
											e_curs	-= 1;
										}
									}
								},
								.PASSWORD => {
									if ( (e_count < e_nbrcar and isSpace(Fkey.Char) == false ) and
									(utl.isPassword(Fkey.Char) ) ) {

										if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
										else	e_FIELD.items[e_count] = Fkey.Char;

										e_count += 1;
										e_curs	+= 1;
										if (e_count == e_nbrcar) {
											e_count -= 1;
											e_curs	-= 1;
										}
									}
								},
								.YES_NO => {
									if (std.mem.eql(u8, Fkey.Char, "Y")	or
										std.mem.eql(u8, Fkey.Char, "y")	or 
										std.mem.eql(u8, Fkey.Char, "N")	or 
										std.mem.eql(u8, Fkey.Char, "n")	) {
										
										Fkey.Char = utl.upperStr(Fkey.Char);

										if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
										else	e_FIELD.items[e_count] = Fkey.Char;
										}
								},
								.UDIGIT => {
									if (e_count < e_nbrcar and utl.isDigitStr(Fkey.Char)	and 
										! std.mem.eql(u8, Fkey.Char, "-") and
										! std.mem.eql(u8, Fkey.Char, "+")	) {
										
										if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
										else	e_FIELD.items[e_count] = Fkey.Char;

										e_count += 1;
										e_curs	+= 1;
										if (e_count == e_nbrcar) {
											e_count -= 1;
											e_curs	-= 1;
										}
									}
								},
								.DIGIT => {
									if (e_count < e_nbrcar and utl.isDigitStr(Fkey.Char) and e_count > 0 or
										(std.mem.eql(u8, Fkey.Char, "-") and e_count == 0) or
										(std.mem.eql(u8, Fkey.Char, "+") and e_count == 0)) {
										
										if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
										else	e_FIELD.items[e_count] = Fkey.Char;

										e_count += 1;
										e_curs	+= 1;
										if (e_count == e_nbrcar) {
											e_count -= 1;
											e_curs	-= 1;
										}
									}
								},
								.UDECIMAL => {
									if (e_count < e_nbrcar and utl.isDigitStr(Fkey.Char) or 
										(std.mem.eql(u8, Fkey.Char, ".") and e_count > 1) or
										!std.mem.eql(u8, Fkey.Char, "-") and ! std.mem.eql(u8, Fkey.Char, "+") ) {

										if (vfld.scal == 0 and std.mem.eql(u8, Fkey.Char, ".") ) continue ;
										

										if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
										else	e_FIELD.items[e_count] = Fkey.Char;

										e_count += 1;
										e_curs	+= 1;
										if (e_count == e_nbrcar) {
											e_count -= 1;
											e_curs	-= 1;
										}
										
									}
								},
								.DECIMAL => {
									if (e_count < e_nbrcar and utl.isDigitStr(Fkey.Char) and e_count > 0 or 
										(std.mem.eql(u8, Fkey.Char, ".") and e_count > 1) or
										(std.mem.eql(u8, Fkey.Char, "-") and e_count == 0) or
										(std.mem.eql(u8, Fkey.Char, "+") and e_count == 0)) {

										if (vfld.scal == 0 and std.mem.eql(u8, Fkey.Char, ".") ) continue; 

										if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
										else	e_FIELD.items[e_count] = Fkey.Char;

										e_count += 1;
										e_curs	+= 1;
										if (e_count == e_nbrcar) {
											e_count -= 1;
											e_curs	-= 1;
										}
										
									}
								},
								.DATE_ISO => {
									if (e_count < e_nbrcar) {
										if (( utl.isDigitStr(Fkey.Char) and e_count <= 3) or
											( utl.isDigitStr(Fkey.Char) and e_count == 5 ) or
											( utl.isDigitStr(Fkey.Char) and e_count == 6 ) or
											( utl.isDigitStr(Fkey.Char) and e_count == 8 ) or
											( utl.isDigitStr(Fkey.Char) and e_count == 9 ) or
											(std.mem.eql(u8, Fkey.Char, "-") and e_count == 4) or
											(std.mem.eql(u8, Fkey.Char, "-") and e_count == 7) ) {
										
											if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
											else	e_FIELD.items[e_count] = Fkey.Char;

											e_count += 1;
											e_curs	+= 1;
											if (e_count == e_nbrcar) {
												e_count -= 1;
												e_curs	-= 1;
											}
										}
									}
								},
								.DATE_FR , .DATE_US	=> {
									if (e_count < e_nbrcar ) {
										if (( utl.isDigitStr(Fkey.Char) and e_count <= 1) or
											( utl.isDigitStr(Fkey.Char) and e_count == 3 ) or
											( utl.isDigitStr(Fkey.Char) and e_count == 4 ) or
											( utl.isDigitStr(Fkey.Char) and e_count >= 6 ) or
											(std.mem.eql(u8, Fkey.Char, "/") and e_count == 2) or
											(std.mem.eql(u8, Fkey.Char, "/") and e_count == 5) ) {
											
											if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
											else	e_FIELD.items[e_count] = Fkey.Char;

											e_count += 1;
											e_curs	+= 1;
											if (e_count == e_nbrcar) {
												e_count -= 1;
												e_curs	-= 1;
											}
										}
									}
								},
								.TELEPHONE=> {
									if ((e_count < e_nbrcar ) and
										(utl.isDigitStr(Fkey.Char) or 
										std.mem.eql(u8, Fkey.Char, "(") or
										std.mem.eql(u8, Fkey.Char, ")") or
										std.mem.eql(u8, Fkey.Char, " ") or
										std.mem.eql(u8, Fkey.Char, "+") or
										std.mem.eql(u8, Fkey.Char, "-") or
										std.mem.eql(u8, Fkey.Char, ".") ) ){
										
										if (statusCursInsert) insert(Fkey.Char,e_count)
										else	e_FIELD.items[e_count] = Fkey.Char;

										e_count += 1;
										e_curs	+= 1;
										if (e_count == e_nbrcar) {
											e_count -= 1;
											e_curs	-= 1;
										}
									}
								},
								.MAIL_ISO => {
									if (e_count < e_nbrcar and isSpace(Fkey.Char) == false and 
										utl.isMailStr(Fkey.Char)) {
										
										if (statusCursInsert and e_count < e_nbrcar - 1) insert(Fkey.Char,e_count)
										else	e_FIELD.items[e_count] = Fkey.Char;

										e_count += 1;
										e_curs	+= 1;
										if (e_count == e_nbrcar) {
											e_count -= 1;
											e_curs	-= 1;
										}
										

									}
								},
								.SWITCH => {
									if (isSpace(Fkey.Char)) {
										
										if (e_switch == false) {
											e_FIELD.items[e_count] = CTRUE;
											e_switch = true;
										}
										else {
											e_FIELD.items[e_count] = CFALSE;
											e_switch = false;
										}
									}
								},
								.FUNC => {
									Fkey.Key =kbd.func;
									break;
								}
							};
							
					},
					else => {},
					
				}
			}
		}


		return Fkey.Key;
	}

};


// defined Panel
pub const	pnl = struct {

	// define attribut default PANELallocatorForms
	pub var AtrPanel : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.styleDim),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgWhite
	};


	pub var MsgErr : term.ZONATRB = .{
				.styled=[_]u32{@intFromEnum(term.Style.notStyle),
											@intFromEnum(term.Style.notStyle),
											@intFromEnum(term.Style.notStyle),
											@intFromEnum(term.Style.notStyle)},
				.backgr = term.BackgroundColor.bgBlack,
				.foregr = term.ForegroundColor.fgRed
		};





	/// define PANEL
	pub const PANEL = struct {
		name:	 [] const u8,
		posx:	 usize,
		posy:	 usize,

		lines:	usize,
		cols:	 usize,

		attribut: term.ZONATRB,

		frame:  frm.FRAME ,

		label:  std.ArrayList(lbl.LABEL),

		button: std.ArrayList(btn.BUTTON),

		field:  std.ArrayList(fld.FIELD),

		linev:  std.ArrayList(lnv.LINEV),

		lineh:  std.ArrayList(lnh.LINEH),

		// double buffer screen
		buf:std.ArrayList(TERMINAL_CHAR),

		idxfld: usize,

		key	  : kbd ,	// Func task call

		keyField : kbd ,	// enter up down

		actif: bool
	};

pub const Epanel = enum {
	name,
	posx,
	posy,
	lines,
	cols,
	cadre,
	title,
	button,
	label,
	field,
	linev,
	lineh,
};

	// Init Panel for arrayList exemple Gencurs modlPanel
	pub fn initPanel(vname: [] const u8,
					vposx: usize, vposy: usize,
					vlines: usize,
					vcols: usize,
					vcadre : CADRE,
					vtitle: [] const u8 ) PANEL {

		var xpanel = PANEL {
					.name	 = vname,
					.posx	 = vposx,
					.posy	 = vposy,
					.lines   = vlines,
					.cols	 = vcols,
					.attribut = AtrPanel,
					.frame  = undefined,
					.label	= std.ArrayList(lbl.LABEL).init(allocatorForms),
					.button = std.ArrayList(btn.BUTTON).init(allocatorForms),
					.field	= std.ArrayList(fld.FIELD).init(allocatorForms),
					.linev	= std.ArrayList(lnv.LINEV).init(allocatorForms),
					.lineh	= std.ArrayList(lnh.LINEH).init(allocatorForms),
					.buf	= std.ArrayList(TERMINAL_CHAR).init(allocatorForms),
					.idxfld = 9999,
					.key	=	kbd.none,
					.keyField = kbd.none,
					.actif	= true,
		};
		// INIT doublebuffer
		var i:usize = (xpanel.lines+1) * (xpanel.cols+1);
		const doublebuffer = TERMINAL_CHAR	{ .ch =	" ",
											.attribut = xpanel.attribut,
											.on = false};

		// init matrix
		while (true) {
				if (i == 0) break ;
				xpanel.buf.append(doublebuffer) catch |err| { @panic(@errorName(err));};
				i -=1 ;
		}


		// init frame Panel
		xpanel.frame = frm.newFrame(xpanel.name,
									1 , 1,	// border panel
									xpanel.lines, xpanel.cols,
									vcadre, frm.AtrFrame,
									vtitle, frm.AtrTitle );

		return xpanel;

	}


	// decl New Panel use programe style C commun allocator
	pub	fn newPanelC(vname: [] const u8,
					vposx: usize, vposy: usize,
					vlines: usize,
					vcols: usize,
					vcadre : CADRE,
					vtitle: [] const u8 ) *PANEL {

		var device = allocatorForms.create(PANEL) 
									catch |err| { @panic(@errorName(err)) ; };

		device.name	 = vname;
		device.posx	 = vposx;
		device.posy	 = vposy;
		device.lines	= vlines;
		device.cols	 = vcols;
		device.attribut = AtrPanel;
		device.frame	= undefined;
		device.label	= std.ArrayList(lbl.LABEL).init(allocatorForms);
		device.button   = std.ArrayList(btn.BUTTON).init(allocatorForms);
		device.field	= std.ArrayList(fld.FIELD).init(allocatorForms);
		device.linev	= std.ArrayList(lnv.LINEV).init(allocatorForms);
		device.lineh	= std.ArrayList(lnh.LINEH).init(allocatorForms);
		device.buf	  = std.ArrayList(TERMINAL_CHAR).init(allocatorForms);
		device.idxfld   = 9999;
		device.key	  = kbd.none;
		device.keyField = kbd.none;
		device.actif	= true;


		// INIT doublebuffer
		var i:usize = (device.lines+1) * (device.cols+1);
		const doublebuffer = TERMINAL_CHAR	{ .ch =	" ",
											.attribut = device.attribut,
											.on = false};

		// init matrix
		while (true) {
				if (i == 0) break ;
				device.buf.append(doublebuffer) catch |err| { @panic(@errorName(err));};
				i -=1 ;
		}


		// init frame Panel
		device.frame = frm.newFrame(device.name,
									1 , 1,	// border panel
									device.lines, device.cols,
									vcadre, frm.AtrFrame,
									vtitle, frm.AtrTitle );

		return device;

	}

	pub fn initMatrix(vpnl: *PANEL) void {
		vpnl.buf.deinit();
		vpnl.buf		= std.ArrayList(TERMINAL_CHAR).init(allocatorForms);

				// INIT doublebuffer
		var i:usize = (vpnl.lines+1) * (vpnl.cols+1);
		const doublebuffer = TERMINAL_CHAR	{ .ch =	" ",
											.attribut = vpnl.attribut,
											.on = false};

		// init matrix
		while (true) {
				if (i == 0) break ;
				vpnl.buf.append(doublebuffer) catch |err| { @panic(@errorName(err));};
				i -=1 ;
		}
	}


	pub fn freePanel(vpnl: *PANEL) void {
		vpnl.label.clearAndFree();
		vpnl.button.clearAndFree();
		vpnl.field.clearAndFree();
		vpnl.lineh.clearAndFree();
		vpnl.linev.clearAndFree();
		vpnl.buf.clearAndFree();
		vpnl.label.deinit();
		vpnl.button.deinit();
		vpnl.field.deinit();
		vpnl.lineh.deinit();
		vpnl.linev.deinit();
		vpnl.buf.deinit();
	}


	pub fn getName(vpnl: *PANEL)	[] const u8 {
		return vpnl.name;
	}
	pub fn getPosx(vpnl: *PANEL) usize {
		return vpnl.posx;
	}
	pub fn getPosy(vpnl: *PANEL) usize {
		return vpnl.posy;
	}
	pub fn getCols(vpnl: *PANEL) usize {
		return vpnl.cols;
	}
	pub fn getLines(vpnl: *PANEL) usize {
		return vpnl.lines;
	}
	pub fn getTitle(vpnl: *PANEL)	[] const u8 {
		return vpnl.frame.title;
	}
	pub fn getIdxfld(vpnl: *PANEL) usize {
		return vpnl.idxfld;
	}
	pub fn getActif(vpnl: *PANEL) bool {
		return vpnl.actif;
	}

	pub fn setIdxfld(vpnl: *PANEL , n :usize) void {
		vpnl.idxfld = n ;
	}
	pub fn setActif(vpnl: *PANEL , b :bool) void {
		vpnl.items.actif = b ;
	}


	pub fn displayPanel(vpnl: *PANEL)	void {
		// display matrice PANEL
		if (vpnl.actif == false ) return ;
			var x :usize = 1;
			var y :usize = 0;
			var n :usize = 0;

			while (x <= vpnl.lines) : (x += 1) {
				y = 1;
				while (y <= vpnl.cols) : (y += 1) {
					term.gotoXY(x + vpnl.posx - 1	, y + vpnl.posy - 1 );
					term.writeStyled(vpnl.buf.items[n].ch,vpnl.buf.items[n].attribut);
					n += 1;
				}
			}
	}


	// clear matrix
	pub fn clsPanel( vpnl : *PANEL) void {
		var x :usize = 0;
		var y :usize = 0;
		var n :usize = 0;

		while (x < vpnl.lines) : (x += 1) {
				y = 1;
				while (y <= vpnl.cols) : (y += 1) {
					vpnl.buf.items[n].ch = " ";
					vpnl.buf.items[n].attribut	= vpnl.attribut;
					vpnl.buf.items[n].on = false;
					n += 1;
				}
			}
		//displayPanel(vpnl);
	}
	
	// clear Panel
	pub fn clearPanel( vpnl : *PANEL) void {

		vpnl.idxfld =9999;

		vpnl.keyField =kbd.none;

		for (vpnl.field.items, 0..) |_, idx| {
			vpnl.field.items[idx].text =" ";
			vpnl.field.items[idx].zwitch =false;

		}
	}
	// restor -panel	MATRIX to terminal
	pub fn rstPanel(comptime T: type , vsrc: *T , vdst : *PANEL) void {
		if (vdst.actif == false)	return ;
		if (vsrc.posx + vsrc.lines > vdst.posx + vdst.lines	)	return ;
		if (vsrc.posy + vsrc.cols	> vdst.posy + vdst.cols	)	return ;

		var x :usize = 0;
		var y :usize = 0;
		var n :usize = 0;
		var npos : usize =	 vsrc.posx - vdst.posx   ;

	
		while (x <= vsrc.lines) : (x += 1) {
				n = (vdst.cols * npos) + vsrc.posy - vdst.posy ;
				y = 0;
				while (y <= vsrc.cols ) : (y += 1) {
					term.gotoXY(x + vsrc.posx  , y + vsrc.posy  );
					term.writeStyled(vdst.buf.items[n].ch,vdst.buf.items[n].attribut);
					n += 1;
				}
			npos += 1;
		}
	}

	/// print PANEL
	pub fn printPanel	(vpnl: *PANEL) void {
		if ( vpnl.actif == false ) return; 

		// assigne PANEL and all OBJECT to matrix for display

		// cursor HIDE par défault
		term.cursHide();

		// clear matrix
		clsPanel(vpnl);

		// FRAME (window panel)
		frm.printFrame(vpnl,vpnl.frame);

		// LABEL
		for (vpnl.label.items) |lblprt| {
			if (lblprt.actif) lbl.printLabel(vpnl, lblprt);
		}

		// FIELD
		for (vpnl.field.items) |fldprt| {
			if (fldprt.actif) fld.printField(vpnl, fldprt);
		}

		// BUTTON
		if (vpnl.button.items.len > 0) {

			btn.printButton(vpnl);
		}
		
		// LINE Vertical
		for (vpnl.linev.items) |lnvprt| {
			if (lnvprt.actif) lnv.printLine(vpnl, lnvprt);
		}
				
		// LINE Horizontal
		for (vpnl.lineh.items) |lnhprt| {
			if (lnhprt.actif) lnh.printLine(vpnl, lnhprt);
		}



		displayPanel(vpnl);
	}

	pub fn msgErr(vpnl: *PANEL, info: [] const u8) void {

		const x: usize  = vpnl.lines;
		var n: usize	= vpnl.cols * (x - 2) ;
		var y: usize	= 1 ;


		var msgerr:[]const u8 = utl.concatStr("Info : ", info);

		if (vpnl.cols < (msgerr.len) )	msgerr = subStrForms( msgerr, 0, vpnl.cols - 2) ;


		while (y <= (vpnl.cols - 2) ) : (y += 1) {
			term.gotoXY(vpnl.posx + x	- 2	, y + vpnl.posy	);
			term.writeStyled(" ",vpnl.attribut);
		}
		y = 1 ;
		term.gotoXY(vpnl.posx + x	- 2 , y + vpnl.posy	 );
		term.writeStyled(msgerr,MsgErr);

		while (true) {
			const e_key = kbd.getKEY();

			switch ( e_key.Key ) {
				.esc => break,
			else =>	{},
			}
		}


		while (y <= (vpnl.cols - 2)) : (y += 1) {
			n += 1;
			term.gotoXY(vpnl.posx + x	- 2, y + vpnl.posy	);
			term.writeStyled(vpnl.buf.items[n].ch,vpnl.buf.items[n].attribut);
		}
		
	}

	/// Check if it is a KEY function
	fn isPanelKey(vpnl:	*PANEL, e_key: kbd) bool {
		for ( vpnl.button.items) |xbtn| {
		if (xbtn.key == e_key ) return true;
		}
		return false;
	}

	/// if it is a KEY function Check
	fn isPanelCtrl( vpnl: *PANEL, e_key: kbd)	bool {
		for ( vpnl.button.items) |xbtn| {
		if ( xbtn.check and xbtn.key == e_key ) return true;
		}
		return false;
	}

	///search there available field
	fn isNextIO(vpnl: *PANEL, idx : usize ) usize {
		var i : usize = idx + 1;
		if (idx == vpnl.field.items.len) i = 0;
		while ( i < vpnl.field.items.len) : (i += 1) {
			if (vpnl.field.items[i].actif and !vpnl.field.items[i].protect ) break ;
		}
		if (i == vpnl.field.items.len) i = vpnl.field.items.len - 1;
		if (vpnl.field.items[i].actif  and vpnl.field.items[i].protect ) i = isPriorIO(vpnl, i);
		return i;
	}

	///search there available field
	fn isPriorIO(vpnl: *PANEL, idx : usize) usize {
		const x : i64 = @intCast(idx - 1) ;
		var i : usize = 0;
		if ( x > 0) i = @intCast(x);
		while ( i > 0 ) : (i -= 1) {
			if (vpnl.field.items[i].actif and !vpnl.field.items[i].protect ) break ;
		}
		if (vpnl.field.items[i].actif  and vpnl.field.items[i].protect ) i = isNextIO(vpnl, i);
		return i;
	}


	pub fn isValide(vpnl: *PANEL) bool {
		if (vpnl.actif == false ) return	false ;


		for (vpnl.field.items, 0..) |f, idx| {
			if ( !f.protect and f.actif) {
				//check requier and field.len > 0
				if (f.requier and utl.trimStr(f.text).len == 0 ) {
						vpnl.idxfld = idx;
						return false;
				}
				//check requier and field.len > 0 and regexLen > 0 execute regex
				if ( f.regex.len > 0 and f.requier and utl.trimStr(f.text).len > 0) {
						if ( !reg.isMatch(utl.trimStr(f.text) ,f.regex)) {
							vpnl.idxfld = idx;
							return false;
						}
				}
				// function call proctask
			}
		}
		vpnl.idxfld = 0;
		return true;

	}

	///------------------------------------------------------
	/// Format management including zones
	/// idxfld == 9999 print panel else position field
	/// keyboard proction keys are returned to the calling procedure
	///
	/// only the key CtrlH = Aide / Help for field
	/// only the key CtrlP = call to the program associated with the Field zone
	/// Reserved keys for FIELD management
	/// traditionally	UP, DOWN, TAB, STAB, CtrlA, F1..F24,
	/// ENTER, HOME, END, RIGTH, LEFt, BACKSPACE, DELETE, INSERT
	/// FUNC Triggered by ioField function
	/// predefined and customizable REGEX control
	/// CALL execve Application Terminal and module
	///------------------------------------------------------
	pub fn ioPanel(vpnl: *PANEL) kbd {
		if (vpnl.actif == false ) return	kbd.none;

		var nField :usize = 0;
		var fld_key : kbd = kbd.enter;
		const nbrFieldIO : usize = vpnl.field.items.len;
		var   nbrField   : usize = 0;

		// search field activ
		if (vpnl.field.items.len > 0 ) {
			for(0..vpnl.field.items.len) | x | {
			if (vpnl.field.items[x].actif and
				!vpnl.field.items[x].protect ) nbrField  += 1;
			}
		}
			
		// first time
		if ( vpnl.idxfld == 9999) {
				printPanel(vpnl); 
				nField = 0;
				// positioning on the first active Field zone
				if (nbrField > 0 ) {
					if (!vpnl.field.items[0].actif  or vpnl.field.items[0].protect ) nField = isNextIO(vpnl, 0);}
		} else {

			switch(vpnl.key ) { 
				.func => nField = vpnl.idxfld,
				.task => {
							nField = vpnl.idxfld;
							switch(vpnl.keyField) {
								.enter => {
									if ( nField + 1 > nbrFieldIO - 1 ) nField = 0
									else nField= isNextIO(vpnl,nField);
									vpnl.idxfld = nField;
								},
								.up	=> {
									if (nField == 0) nField = nbrFieldIO - 1
									else nField= isPriorIO(vpnl,nField);
									vpnl.idxfld = nField;
								},
								.down	=> {
									if (nField	+ 1 > nbrFieldIO - 1) nField = 0
									else nField= isNextIO(vpnl,nField);
									vpnl.idxfld = nField;
								},
								else => nField = vpnl.idxfld,
							}
						},
				else => nField = vpnl.idxfld,
			}
		}
		vpnl.keyField = kbd.none; 

		// Processing of the panel's Fields
		while (true) {

		
			if (nbrField == 0 or vpnl.field.items.len == 0 )	{
				const vKey= kbd.getKEY();

				if (isPanelKey(vpnl,vKey.Key)) {
					vpnl.idxfld = 9999;
					return vKey.Key;
				}
				continue ;
			}
			else 
				if ( !vpnl.field.items[nField ].protect and vpnl.field.items[nField ].actif) {

					fld.printField(vpnl,vpnl.field.items[nField ]);
					fld.displayField(vpnl,vpnl.field.items[nField ]);

					fld_key = fld.ioField(vpnl,vpnl.field.items[nField ]);

					fld.printField(vpnl,vpnl.field.items[nField ]);
					fld.displayField(vpnl,vpnl.field.items[nField ]);
				
					vpnl.key = kbd.none;

					// function call procfunc
					if (fld_key == kbd.func ) {
						vpnl.idxfld = nField;
						vpnl.key = kbd.func;
						return fld_key;
					}
					// function call proctask
					if (fld_key == kbd.task) {
						vpnl.idxfld = nField;
						vpnl.key = kbd.task;
						return fld_key;
					}
					// function call pgm
					if (fld_key == kbd.call) {
						vpnl.idxfld = nField;
						vpnl.key = kbd.call;
						return fld_key;
					}




					
					// control validity
					if (isPanelKey(vpnl,fld_key )) {
						if (!isPanelCtrl(vpnl,fld_key)){
								vpnl.idxfld = nField ;
								return fld_key;
							}
						else {
							if (isValide(vpnl)) {
								return fld_key;
							}
							else { 
								msgErr(vpnl,"Format invalide");
								nField = vpnl.idxfld ;
								fld_key = kbd.none ;
							}
						}

					}
				}

			switch(fld_key) {
				.enter	=> {
					if ( nField + 1 > nbrFieldIO - 1 ) nField = 0
					else nField= isNextIO(vpnl,nField);
					vpnl.idxfld = nField;
				},
				.up	=> {
					if (nField == 0) nField = nbrFieldIO - 1 
					else nField= isPriorIO(vpnl,nField);
					vpnl.idxfld = nField;
				},
				.down	=> {
					if (nField	+ 1 > nbrFieldIO - 1) nField = 0
					else nField= isNextIO(vpnl,nField);
					vpnl.idxfld = nField;
				},
				else => {}

			}
		}
	}

};
