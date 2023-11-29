const std = @import("std");
const utf = @import("std").unicode;

const dds = @import("dds");

/// terminal Fonction
const term = @import("cursed");
// keyboard
const kbd = @import("cursed").kbd;

// tools utility
const utl = @import("utils");


// panel
const pnl = @import("forms").pnl;


const os = std.os;
const io = std.io;

///-------------------------------
/// MENU
///-------------------------------


/// Errors that may occur when using String
pub const ErrMenu = error{

				mnu_getIndex_Name_Menu_Invalide,
	
				mnu_getName_Index_invalide,
				mnu_getPosx_Index_invalide,
				mnu_getPosy_Index_invalide,
				mnu_getText_Index_invalide,
				mnu_getActif_Index_invalide,

				mnu_dltRows_Index_invalide,
	};

// defined Menu
pub const	mnu = struct {

	// nbr espace intercaler
	pub var	mnuspc : usize =3 ;

	// define attribut default CADRE
	pub var AtrMnu : dds.ZONATRB = .{
		.styled=[_]u32{ @intFromEnum(dds.Style.styleDim),
						@intFromEnum(dds.Style.notStyle),
						@intFromEnum(dds.Style.notStyle),
						@intFromEnum(dds.Style.notStyle)},
		.backgr = dds.BackgroundColor.bgBlack,
		.foregr = dds.ForegroundColor.fgRed

	};

	pub var AtrBar : dds.ZONATRB = .{
		.styled=[_]u32{ @intFromEnum(dds.Style.styleReverse),
						@intFromEnum(dds.Style.styleItalic),
						@intFromEnum(dds.Style.notStyle),
						@intFromEnum(dds.Style.notStyle)},
		.backgr = dds.BackgroundColor.bgBlack,
		.foregr = dds.ForegroundColor.fgWhite

	};

	pub var AtrCell : dds.ZONATRB= .{
		.styled=[_]u32{ @intFromEnum(dds.Style.styleItalic),
						@intFromEnum(dds.Style.notStyle),
						@intFromEnum(dds.Style.notStyle),
						@intFromEnum(dds.Style.notStyle)},
		.backgr = dds.BackgroundColor.bgBlack,
		.foregr = dds.ForegroundColor.fgWhite,
	};

	// define MENU
	pub const MENU = struct {

		name : [] const u8,
		posx : usize,
		posy : usize,
		lines: usize,
		cols : usize,

		cadre: dds.CADRE,
		mnuvh : dds.MNUVH,

		attribut: dds.ZONATRB,
		attrBar: dds.ZONATRB,
		attrCell: dds.ZONATRB,

		xitems: []const[]const u8,
		nbr: usize,
		actif: bool
	};

	// NEW MENU
	pub fn newMenu( vname: [] const u8,
					vposx: usize, vposy: usize,
					vcadre : dds.CADRE,
					vmnuvh : dds.MNUVH,
					vitems: []const[]const u8
					) MENU {

		var xmenu = MENU {
						.name = vname,
						.posx	 = vposx,
						.posy	 = vposy,
						.lines   = 0,
						.cols	 = 0,
						.cadre = vcadre,
						.mnuvh = vmnuvh,
						.attribut = AtrMnu,
						.attrBar  = AtrBar,
						.attrCell = AtrCell,
						.xitems	= vitems,
						.nbr = 0,
						.actif = true
				};


				for (xmenu.xitems) |txt| {
					if (xmenu.cols < txt.len) xmenu.cols = txt.len;
					xmenu.nbr +=1;
				}
				xmenu.lines += xmenu.nbr + 2; //nbr ligne	+ header =cadre
				xmenu.cols	+= 2;
		return xmenu;
	}


	// return index-menu	---> arraylist panel-menu
	pub fn getIndex(vmnu: *mnu.MENU , name: [] const u8 )	ErrMenu ! usize {

		for (vmnu.items, 0..) |l, idx| {
			if (std.mem.eql(u8, l.name, name)) return idx;
		}
		return ErrMenu.mnu_getIndex_Name_Menu_Invalide;
	}

	// return name-menu ---> arraylist panel-menu
	pub fn getName(vmnu: *mnu.MENU , n: usize) ErrMenu ! [] const u8 {
		if ( n < vmnu.items.len) return vmnu.items[n].name;
		return ErrMenu.mnu_getName_Index_invalide ;

	}

	// return posx-menu ---> arraylist panel-menu
	pub fn getPosx(vmnu: *mnu.MENU , n: usize)	ErrMenu ! usize {
		if ( n < vmnu.items.len) return vmnu.items[n].posx;
		return ErrMenu.mnu_getPosx_Index_invalide ;
	}

	// return posy-menu ---> arraylist panel-menu
	pub fn getPosy(vmnu: *mnu.MENU , n: usize)	ErrMenu ! usize {
		if ( n < vmnu.items.len) return vmnu.items[n].posy;
		return ErrMenu.mnu_getPosy_Index_invalide ;
	}

	// return Text-menu ---> arraylist panel-menu
	pub fn getText(vmnu: *mnu.MENU , n: usize)	ErrMenu ! usize {
		if ( n < vmnu.items.len) return vmnu.items[n].text;
		return ErrMenu.mnu_getText_Index_invalide ;
	}

	// return ON/OFF-menu ---> arraylist panel-menu
	pub fn getActif(vmnu: *mnu.MENU , n: usize)	ErrMenu ! bool {
		if ( n < vmnu.items.len) return vmnu.items[n].actif;
		return ErrMenu.mnu_getActif_Index_invalide ;
	}


	// delete -menu ---> arraylist panel-menu
	pub fn dltRows(vmnu: *mnu.MENU,	n :usize ) ErrMenu ! void {
		if ( n < vmnu.items.len) _= vmnu.orderedRemove(n)
		else return ErrMenu.mnu_dltRows_Index_invalide ;
	}


	// assign -menu MATRIX TERMINAL	---> arraylist panel-menu
	fn printMenu(vpnl: *pnl.PANEL, vmnu: MENU) void {
		if (vpnl.actif == false ) return ;
		const ACS_Hlines	= "─";
		const ACS_Vlines	= "│";
		const ACS_UCLEFT	= "┌";
		const ACS_UCRIGHT = "┐";
		const ACS_LCLEFT	= "└";
		const ACS_LCRIGHT = "┘";

		const ACS_Hline2		= "═";
		const ACS_Vline2		= "║";
		const ACS_UCLEFT2	 = "╔";
		const ACS_UCRIGHT2	= "╗";
		const ACS_LCLEFT2	 = "╚";
		const ACS_LCRIGHT2	= "╝";

		var trait: []const u8 = "";
		var edt :bool	 = undefined ;

		var row:	usize = 1 ;
		var y:		usize = 0 ;
		var col:	usize = 0 ;

		var x :usize =	vmnu.posx - 1 ;

		// if line 0 ex: directory tab
		if (dds.CADRE.line0 != vmnu.cadre ) {
			while (row <= vmnu.lines) : (row +=1) {
				y = vmnu.posy - 1;
				col = 1;
				while ( col <= vmnu.cols ){
					edt = false;
					if (row == 1) {
							if (col == 1) {
								if ( dds.CADRE.line1 == vmnu.cadre ) {
										trait = ACS_UCLEFT;
								} else	trait = ACS_UCLEFT2 ;
								edt = true;
							}
							if ( col == vmnu.cols ) {
								if (dds.CADRE.line1 == vmnu.cadre) {
									trait = ACS_UCRIGHT;
								} else	trait = ACS_UCRIGHT2 ;
								edt = true;
							}
							if ( col > 1 and col < vmnu.cols ) {
								if (dds.CADRE.line1 == vmnu.cadre ) {
									trait = ACS_Hlines;
								} else	trait = ACS_Hline2;
								edt = true;
							}
					} else if ( row == vmnu.lines ) {
							if (col == 1) {
								if ( dds.CADRE.line1 == vmnu.cadre ) {
									trait = ACS_LCLEFT;
								} else	trait = ACS_LCLEFT2;
								edt = true;
							}
							if ( col == vmnu.cols ) {
								if ( dds.CADRE.line1 == vmnu.cadre ) {
									trait = ACS_LCRIGHT;
								} else	trait = ACS_LCRIGHT2 ;
								edt = true ;
							}
							if ( col > 1 and col < vmnu.cols ) {
								if ( dds.CADRE.line1 == vmnu.cadre ) {
									trait = ACS_Hlines;
								} else	trait = ACS_Hline2 ;
								edt = true;
							}
					} else if ( row > 1 and row < vmnu.lines ) {
						if ( col == 1 or col == vmnu.cols ) {
							if ( dds.CADRE.line1 == vmnu.cadre ) {
								trait = ACS_Vlines;
							} else trait = ACS_Vline2 ;
							edt = true;
						}
					}
					if	( edt ) {
						term.gotoXY(row + vmnu.posx + vpnl.posx - 2	, col + vmnu.posy + vpnl.posy - 2);
						term.writeStyled(trait,vmnu.attribut);
					}
					else {
						term.gotoXY(row + vmnu.posx + vpnl.posx - 2	, col + vmnu.posy + vpnl.posy - 2);
						term.writeStyled(" ",vmnu.attribut);
					}

					y += 1;
					col += 1;
				}
				x += 1;
			}
		}


	}

	// display	MATRIX to terminal ---> arraylist panel-menu
	fn displayMenu(vpnl: *pnl.PANEL, vmnu:MENU, npos: usize) void {
		var pos : usize = npos;
		var n : usize = 0;
		var h : usize = 0;

		var x :usize = vmnu.posx - 1;
		var y :usize = vmnu.posy - 1;

		printMenu(vpnl, vmnu);

		term.onMouse();
		term.cursHide();


		if (npos > vmnu.nbr or npos == 0 )	pos = 0	;

		n = 0;
		h = 0;
		for (vmnu.xitems) | cell |	{
			if (vmnu.mnuvh == dds.MNUVH.vertical) {
				if (vmnu.cadre == dds.CADRE.line0)
					term.gotoXY(vpnl.posx + x + n	,		vpnl.posy + y	)
				else
					term.gotoXY(vpnl.posx + x + n + 1 , vpnl.posy + y	+ 1);
			}
			if (vmnu.mnuvh == dds.MNUVH.horizontal) {
				if (vmnu.cadre == dds.CADRE.line0 )
					term.gotoXY(vpnl.posx + x	,		h	 + vpnl.posy + y	 )
				else
					term.gotoXY(vpnl.posx + x + 1	, h	+ vpnl.posy + y	+ 1);
			}
			//var xcell = utl.Trim(cell);
			if (pos == n)
				term.writeStyled(cell,vmnu.attrBar)
			else
				term.writeStyled(cell,vmnu.attrCell);

			n += 1;
			h += utl.nbrCharStr(cell);
			if (vmnu.mnuvh == dds.MNUVH.horizontal) h += mnuspc;
		}
	}

	// restor -panel	MATRIX to terminal ---> arraylist panel-menu 
	pub fn rstPanel( vsrc : MENU , vdst : *pnl.PANEL) void {
		if (vdst.actif == false)	return ;
		if (vsrc.posx + vsrc.lines > vdst.posx + vdst.lines	)	return ;
		if (vsrc.posy + vsrc.cols	> vdst.posy + vdst.cols	)	return ;
		var x :usize = 0;
		var y :usize = 0;
		var n :usize = 0;
		var npos : usize =	vsrc.posx - vdst.posx;
		while (x <= vsrc.lines) : (x += 1) {
				n = vdst.cols * npos + vsrc.posy - vdst.posy	;
				y = 0;
				while (y <= vsrc.cols) : (y += 1) {
					term.gotoXY(x + vsrc.posx	 , y + vsrc.posy	);
					term.writeStyled(vdst.buf.items[n].ch,vdst.buf.items[n].attribut);
					n += 1;
				}
			npos += 1;
		}
	}
	//----------------------------------------------------------------
	// menu	enter = select	1..n 0 = abort (Escape)
	// Turning on the mouse
	// UP DOWN LEFT RIGHT
	// movement width the wheel and validation width the clik
	//----------------------------------------------------------------
	pub fn ioMenu(vpnl: *pnl.PANEL, vmnu: MENU, npos: usize) usize {
		if (vpnl.actif == false ) return 999 ;
		if (vmnu.actif == false ) return 999 ;
		var pos : usize = npos;
		var n	 : usize = 0;
		var h	 : usize = 0;
		var x :usize = vmnu.posx - 1;
		var y :usize = vmnu.posy - 1;

		term.onMouse();
		term.cursHide();



		if (npos > vmnu.nbr or npos == 0 )	pos = 0;


		displayMenu(vpnl,vmnu,pos);


		term.flushIO();
		while (true) {
			n = 0;
			h = 0;
			for (vmnu.xitems) | cell |	{

				if (vmnu.mnuvh == dds.MNUVH.vertical) {
					if (vmnu.cadre == dds.CADRE.line0 )
						term.gotoXY(vpnl.posx + x	+ n	,	 vpnl.posy + y )
					else
						term.gotoXY(vpnl.posx + x	+ n + 1, vpnl.posy + y + 1);
					}
				if (vmnu.mnuvh == dds.MNUVH.horizontal) {
					if (vmnu.cadre == dds.CADRE.line0)
						term.gotoXY(vpnl.posx + x	 ,	 h + vpnl.posy + y )
					else
						term.gotoXY(vpnl.posx + x	+ 1, h + vpnl.posy + y + 1);
				}
				if (pos == n)
					term.writeStyled(cell,vmnu.attrBar)
				else
					term.writeStyled(cell,vmnu.attrCell);

				n += 1;
				h += utl.nbrCharStr(cell);
				if (vmnu.mnuvh == dds.MNUVH.horizontal) h += mnuspc;
			}

			var Tkey	= kbd.getKEY();

			if (Tkey.Key == kbd.char and
					std.mem.eql(u8,Tkey.Char," " ) ) {Tkey.Key = kbd.enter; Tkey.Char ="";}


			if (Tkey.Key == kbd.mouse) {
				Tkey.Key = kbd.none;
				if (term.MouseInfo.scroll ) {
					if ( term.MouseInfo.scrollDir == term.ScrollDirection.msUp ) {
						if (vmnu.mnuvh == dds.MNUVH.vertical)		Tkey.Key = kbd.up;
						if (vmnu.mnuvh == dds.MNUVH.horizontal)	Tkey.Key = kbd.left;
					}

					if (term.MouseInfo.scrollDir == term.ScrollDirection.msDown) {
						if (vmnu.mnuvh == dds.MNUVH.vertical)		Tkey.Key = kbd.down;
						if (vmnu.mnuvh == dds.MNUVH.horizontal)	Tkey.Key = kbd.right;
					}
				}
				else {
					if (term.MouseInfo.action == term.MouseAction.maReleased ) continue;
					switch (term.MouseInfo.button) {
						term.MouseButton.mbLeft		=>	Tkey.Key = kbd.enter,
						term.MouseButton.mbMiddle	=>	Tkey.Key = kbd.enter,
						term.MouseButton.mbRight	 =>	Tkey.Key = kbd.enter,
						else => {}
					}
				}
			}

			switch (Tkey.Key) {
				.none => continue,
				.esc	=> {
					term.offMouse();
					return 9999;
				},
				.enter => {
					term.offMouse();
					return pos ;
				},
				.down	=> { if (pos < vmnu.nbr - 1 )	pos +=1; } ,
				.up		=> { if (pos > 0 ) pos -=1; },
				.right => { if (pos < vmnu.nbr - 1 )	pos +=1; },
				.left	=> { if (pos > 0 ) pos -=1; },
				else => {},
			}
		}
	}

};
