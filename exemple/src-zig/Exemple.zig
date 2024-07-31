	///-----------------------
	/// prog Exemple 
	/// zig 0.13.0 dev
	///-----------------------

const std = @import("std");


/// terminal Fonction
const term = @import("cursed");
// keyboard
const kbd = @import("cursed").kbd;

// error
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

// tools utility
const utl = @import("utils");

// tools regex
const reg = @import("mvzr");

// tools execve Pgm
const mdl = @import("callpgm");

/// Errors 
pub const Error = error{
	main_function_Enum_invalide,
	main_run_EnumTask_invalide,
};


/// ---------------------------------------------------
/// Exemple defined Panel Label Field Button Menu Grid
/// ---------------------------------------------------

pub fn Panel_Fmt01() *pnl.PANEL {

	//-------------------------------------------------
	// Panel
	// Name Panel, Pos X, Pos Y,
	// nbr Lines, nbr columns
	// Attribut Panel
	// Type frame, Attribut frame
	// Title Panel, Attribut: Title
	var Panel	: *pnl.PANEL = pnl.newPanelC("Fmt01",
					1, 1,
					32,
					132,
					forms.CADRE.line1,
					"TITLE");

	//-------------------------------------------------
	// Label
	// Name , pos X, pos Y,
	// Text , Attribut Text
	Panel.label.append(lbl.newLabel("free",2,2,"Text-Free...................:")
	) catch unreachable ;

	Panel.label.append(lbl.newLabel("full",3,2,"Text-Full.....protect.......:")
	) catch unreachable ;
	
	Panel.label.append(lbl.newLabel("cb01",3,62,"Fonction 01..:")
	) catch unreachable ;

	Panel.label.append(lbl.newLabel("cb02",4,62,"Fonction 02..:")
	) catch unreachable ;

	Panel.label.append(lbl.newLabel("alpha",5,2,"Text-Alpha..................:")
	) catch unreachable ;

	Panel.label.append(lbl.newLabel("alphaupper",6,2,"Text-Alpha-Uppercase........:")
	) catch unreachable ;

	Panel.label.append(lbl.newLabel("alphanumeric",7,2,"Text-Alpha-Numeric..........:")
	) catch unreachable ;

	Panel.label.append(lbl.newLabel("alphanumericupper",8,2,"Text-Alpha-Numeric-Upercase.:")
	) catch unreachable ;

	Panel.label.append(lbl.newLabel("password",10,2,"Text-Password...............:")
	) catch unreachable ;

	Panel.label.append(lbl.newLabel("yesno",11,2,"Text-Yes or No..............:")
	) catch unreachable ;

	Panel.label.append(lbl.newLabel("udigit",13,2,"Text-Unsigned.Digit.........:")
	) catch unreachable ;	

	Panel.label.append(lbl.newLabel("digit",14,2,"Text-signed.Digit...........:")
	) catch unreachable ; 

	Panel.label.append(lbl.newLabel("udecimal",15,2,"Text-unsigned.Ddecimal......:")
	) catch unreachable ; 

	Panel.label.append(lbl.newLabel("decimal",16,2,"Text-signed.Ddecimal........:")
	) catch unreachable ;

	Panel.label.append(lbl.newLabel("dateiso",18,2,"Text-Date-ISO...............:")
	) catch unreachable ;

	Panel.label.append(lbl.newLabel("datefr",19,2,"Text-Date-FR................:")
	) catch unreachable;	 

	Panel.label.append(lbl.newLabel("dateus",20,2,"Text-Date-US................:")
	) catch unreachable;

	Panel.label.append(lbl.newLabel("telephone",22,2,"Text-Telephone..US..........:")
	) catch unreachable;

	Panel.label.append(lbl.newLabel("telephone2",24,2,"Text-Telephone..Standard....:")
	) catch unreachable;

	Panel.label.append(lbl.newLabel("mail",26,2,"Text-Mail...................:")
	) catch unreachable; 

	Panel.label.append(lbl.newLabel("switch",28,2,"Text-Switch.................:",)
	) catch unreachable; 

	Panel.label.append(lbl.newTitle("TITLE",29,70,"Title ex : FACTURE",)
	) catch unreachable; 

	//example: option specific
	Panel.label.items[1].attribut.styled[0] = @intFromEnum(term.Style.styleItalic);
	Panel.label.items[1].attribut.styled[1] = @intFromEnum(term.Style.notStyle);


 // Field 

	
	Panel.field.append(fld.newFieldTextFree("free",2,32,		// Name , posx posy
										30,						// width
										"free",					// text
										true,					// tofill
										"required",				// error msg
										"please enter text",	// help
										"",						// regex
										)
	) catch unreachable ;

	Panel.field.append(fld.newFieldTextFull("full",3,32,		// Name , posx posy
										30,						// width
										"full",					// text
										true,					// tofill
										"required",				// error msg
										"please enter text",	// help
										"",						// regex
										)
	) catch unreachable ;

	fld.setProtect(Panel,1,true) catch unreachable;

	Panel.field.append(fld.newFieldAlpha("alpha",5,32,				// Name , posx posy
										30,							// width
										"abcd",						// text
										true,						// tofill
										"required",					// error msg
										"please enter text Alpha crtl+p call Exemple",	// help
										"^[a-z]{1,1}[a-zA-Z]{0,}$"	// regex
										)
	) catch unreachable ;
	
	fld.setCall(Panel,fld.getIndex(Panel,"alpha") catch unreachable,"exCallpgm") catch unreachable; // test appel pgm
		
	Panel.field.append(fld.newFieldAlphaUpper("alphaU",6,32,					// Name , posx posy
										30,										// width
										"ABCD",									// text
										true,									// tofill
										"required",								// error msg
										"please enter text Alpha Uppercase",	// help
										"",										// regex
										)
	) catch unreachable ;

	Panel.field.append(fld.newFieldAlphaNumeric("alphaN",7,32,				// Name , posx posy
										30,									// width
										"abcd12345",						// text
										true,								// tofill
										"required",							// error msg
										"please enter text Alpha Numéric",	// help
										"^[a-zA-Z]{1,1}[a-zA-Z0-9]{0,}$",	// regex
										)
	) catch unreachable ;

	Panel.field.append(fld.newFieldAlphaNumericUpper("alphaNU",8,32,		// Name , posx posy
										30,									// width
										"ABCD12345",						// text
										true,								// tofill
										"required",							// error msg
										"please enter text Alpha Numéric",	// help
										"^[A-Z]{1,1}[A-Z0-9]{0,}$",			// regex
										)
	) catch unreachable ;

	Panel.field.append(fld.newFieldPassword("password",10,32,				// Name , posx posy
										30,									// width
										"SECRET",							// text
										true,								// tofill
										"required",							// error msg
										"please enter text Alpha Numéric",	// help
										"",									// regex
										)
	) catch unreachable ;

	Panel.field.append(fld.newFieldYesNo("yesno",11,32,		// Name , posx posy
										"N",				// text
										true,				// tofill
										"required Y or N",	// error msg
										"",					// help default "to validate Y or N "
										)
	) catch unreachable ;

	Panel.field.append(fld.newFieldUDigit("udigit",13,32,			// Name , posx posy
										5,							// width
										"00102",					// text
										true,						// tofill
										"Invalide value",			// error msg
										"value numeric not signed",	// help
										"",							// regex default standard
										)
	) catch unreachable ;

	Panel.field.append(fld.newFieldDigit("digit",14,32,			// Name , posx posy
										5,						// width
										"+00102",				// text
										true,					// tofill
										"Invalide value",		// error msg
										"value numeric signed",	// help
										"",						// regex default standard
										)
	) catch unreachable ;

	Panel.field.append(fld.newFieldUDecimal("udecimal",15,32,		 // Name , posx posy
										10,						 // width
										2,						// scal
										"001.02",				// text
										true,					// tofill
										"Invalide value",		// error msg
										"",						// help default
										"",						// regex default standard
										)
	) catch unreachable ;

	Panel.field.append(fld.newFieldDecimal("decimal",16,32,		// Name , posx posy
										10,						// width
										2,						// scal
										"+001.02",				// text
										true,					// tofill
										"Invalide value",		// error msg
										"",						// help default
										"",						// regex default standard
										)
	) catch unreachable ;
	
	Panel.field.append(fld.newFieldDateISO("dateiso",18,32,			// Name , posx posy
										"1951-10-12",				// text
										true,						// tofill
										"date out of calendar",		// error msg
										"",							// help default
										)
	) catch unreachable ;
	// test with a calendar file to know the opening days
	// single digit test
	
	// fld.setTask(Panel,fld.getIndex(Panel,"dateiso") catch unreachable,"TaskIso") catch unreachable ;

	
	Panel.field.append(fld.newFieldDateFR("datefr",19,32,			// Name , posx posy
										"12/10/1951",				// text
										true,						// tofill
										"date hors calendrier",		// error msg
										"",							// help default
										)
	) catch unreachable ;
	fld.setTask(Panel,fld.getIndex(Panel,"datefr") catch unreachable,"TaskFr") catch unreachable ;
	
	Panel.field.append(fld.newFieldDateUS("dateus",20,32,			// Name , posx posy
										"07/04/1776",				// text
										true,						// tofill
										"date out of calendar",	// error msg
										"",							// help default
										)
	) catch unreachable ;
	fld.setTask(Panel,fld.getIndex(Panel,"dateus") catch unreachable,"TaskUs") catch unreachable ;

	Panel.field.append(fld.newFieldTelephone("telephone",22,32,		// Name , posx posy
										25,							// width
										"+(001)451 452 453 545",	// text
										true,						// tofill
										"required or invalide",		// error msg
										"ex:+(001)456.123.789",		// help
				 "[+][(][0-9]{3}[)][0-9]{3}([-. ]?[0-9]{3}){1,4}"	// regex US default standard
										)
	) catch unreachable ;

	Panel.field.append(fld.newFieldTelephone("telephone2",24,32,	// Name , posx posy
										25,							// width
										"+(33)6 01 02 03 04",		// text
										false,						// tofill
										"required or invalide",		// error msg
										"ex:+(33)6.12.34.56.78",	// help
				"[+][(][0-9]{2,3}[)][0-9]([-. ]?[0-9]{2,3}){1,4}"	// regex default standard fr
										)
	) catch unreachable ;
	
	Panel.field.append(fld.newFieldMail("mail",26,32,			// Name , posx posy
										100,					// width
										"gloups@gmail.com",		// text	error
										true,					// tofill
										"required",				// error msg
										"",						// help default
										)
	) catch unreachable ;
	
	Panel.field.append(fld.newFieldSwitch("Switch",28,32,		// Name , posx posy
										true,					// switch
										"required",				// error msg
										"",						// help
										)
	) catch unreachable ;

	 Panel.field.append(fld.newFieldFunc("cb01",3,76,			// Name , posx posy
										20,						// width
										"Amis",					// text
										true,					// tofill
										"comboFn01",			// Process for FUNC 
										"required",				// error msg
										"select combo",			// help
										)
	) catch unreachable ;
	
	fld.setCall(Panel,fld.getIndex(Panel,"cb01") catch unreachable,"exCallpgm") catch unreachable; // test appel pgm
	
	Panel.field.append(fld.newFieldFunc("cb02",4,76,			// Name , posx posy
										20,						// width
										"",						// text
										false,					// tofill
										"comboFn02",			// Process for FUNC 
										"required",				// error msg
										"select combo",			// help
										)
	) catch unreachable ;


	// button--------------------------------------------------
	Panel.button.append(btn.newButton(
						kbd.F3,					// function
						true,					// show 
						false,					// check field
						"Exit"					// title
						)
	) catch unreachable ;

	Panel.button.append(btn.newButton(
						kbd.F2,					// function
						true,					// show
						true,					// check field
						"test"					// title 
						)
	) catch unreachable ;

	Panel.button.append(btn.newButton(
						kbd.F4,					// function
						true,					// show
						true,					// check field
						"test window"			// title 
						)
	) catch unreachable ;

	Panel.button.append(btn.newButton(
						kbd.F5,					// function
						true,					// show
						false,					// check field
						"Menu"					// title 
						)
	) catch unreachable ;

	Panel.button.append(btn.newButton(
						kbd.F8,					// function
						true,					// show 
						false,					// check control to Field 
						"Grid"					// title
						)
	) catch unreachable ;

	Panel.button.append(btn.newButton(
						kbd.F12,				// function
						true,					// show 
						false,					// check control to Field 
						"ClearPanel"			// title enrg record
						)
	) catch unreachable ;
	Panel.button.append(btn.newButton(
						kbd.F24,				// function
						true,					// show 
						false,					// check control to Field 
						"Refresh"				// title enrg record
						)
	) catch unreachable ;
	return Panel;
}



pub fn Panel_Fmt0X() *pnl.PANEL {

	//-------------------------------------------------
	// Panel
	// Name Panel, Pos X, Pos Y,
	// nbr Lines, nbr columns
	// Attribut Panel
	// Type frame, Attribut frame
	// Title Panel, Attribut: Title
	var Panel	: *pnl.PANEL = pnl.newPanelC("Fmt01",
					1, 1,
					8,
					70,
					forms.CADRE.line1,
					"TEST WINDOW");

	//-------------------------------------------------
	// Label
	// Name , pos X, pos Y,
	// Text , Attribut Text
	Panel.label.append(lbl.newLabel("free",2,2,"Text-Free...................:")
	) catch unreachable ;

	Panel.label.append(lbl.newLabel("full",3,2,"Text-Full.....protect.......:")
	) catch unreachable ;

	// button--------------------------------------------------
	Panel.button.append(btn.newButton(
						kbd.F12,				// function
						true,					// show 
						false,					// check field
						"Return"				// title
						)
	) catch unreachable ;
	return Panel;
}
//-------------------------------------------------
//the menu is not double buffered it is not a Panel
pub fn Menu01() mnu.MENU {
	const  m01 = mnu.newMenu(
					"Menu01",				// name
					2, 2,					// posx, posy	
					mnu.CADRE.line1,		// type line fram
					mnu.MNUVH.vertical,		// type menu vertical / horizontal
					&.{"Open..",			// item
					"List..",
					"View..",
					"Delete",
					"New..",
					"Src...",
					"Exit.."}
					);
	return m01;
}


// combo-------------------------------------
fn comboFn01( vpnl : *pnl.PANEL , vfld :* fld.FIELD) void {
	var cellPos:usize = 0;

	const Xcombo : *grd.GRID =	grd.newGridC(
					"Combo01",
					3, 75,
					5 ,
					grd.gridStyle,
					grd.CADRE.line1,
					);
	defer grd.freeGrid(Xcombo);
	defer grd.allocatorGrid.destroy(Xcombo);	

	grd.newCell(Xcombo,"Choix",15,grd.REFTYP.TEXT_FREE,term.ForegroundColor.fgGreen);
	grd.setHeaders(Xcombo) ;

	grd.addRows(Xcombo , &.{"---"});
	grd.addRows(Xcombo , &.{"Famille"});
	grd.addRows(Xcombo , &.{"Amis"});
	grd.addRows(Xcombo , &.{"Professionel"});
	grd.addRows(Xcombo , &.{"Docteur"});

	if (std.mem.eql(u8,vfld.text,"---") == true)		cellPos = 0;
	if (std.mem.eql(u8,vfld.text,"Famille") == true)	cellPos = 1;
	if (std.mem.eql(u8,vfld.text,"Amis") == true)		cellPos = 2;
	if (std.mem.eql(u8,vfld.text,"Professionel") == true) cellPos = 3;
	if (std.mem.eql(u8,vfld.text,"Docteur") == true)	cellPos = 4;


	// Interrogation
	var Gkey :grd.GridSelect = undefined ;
	defer Gkey.Buf.deinit();

	Gkey =grd.ioCombo(Xcombo,cellPos);
	pnl.rstPanel(grd.GRID,Xcombo, vpnl);


	if ( Gkey.Key == kbd.esc )	 return ;
	vfld.text = Gkey.Buf.items[0];
	return ;
}

fn comboFn02( vpnl : *pnl.PANEL , vfld :* fld.FIELD) void {
	var cellPos:usize = 0;
	
	const Xcombo : *grd.GRID =	grd.newGridC(
										"Combo02",
										4, 75,
										3 ,	
										grd.gridStyle,
										grd.CADRE.line1,
										);

	defer grd.freeGrid(Xcombo);
	defer grd.allocatorGrid.destroy(Xcombo);

	grd.newCell(Xcombo,"Choix",15, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
	grd.setHeaders(Xcombo) ;

	grd.addRows(Xcombo , &.{"---"});
	grd.addRows(Xcombo , &.{"Informaticien"});
	grd.addRows(Xcombo , &.{"sportif"}); 

	if (std.mem.eql(u8,vfld.text,"---") == true)			cellPos = 0;
	if (std.mem.eql(u8,vfld.text,"Informaticien") == true)	cellPos = 1;
	if (std.mem.eql(u8,vfld.text,"sportif") == true)	 cellPos = 2;

	// Interrogation
	var Gkey :grd.GridSelect = undefined ;
	defer Gkey.Buf.deinit();

	Gkey =grd.ioCombo(Xcombo,cellPos);
	pnl.rstPanel(grd.GRID,Xcombo, vpnl);

	if ( Gkey.Key == kbd.esc )	return ;
	vfld.text = Gkey.Buf.items[0];
	return ;
}

/// run emun Function ex: combo
pub const FnEnum = enum {
	comboFn01,
	comboFn02,
	none,

	pub fn run(self: FnEnum, vpnl : *pnl.PANEL, vfld: *fld.FIELD ) void	{
		switch (self) {
			.comboFn01 => comboFn01(vpnl,vfld),
			.comboFn02 => comboFn02(vpnl,vfld),
			else => dsperr.errorForms(vpnl, Error.main_function_Enum_invalide),
		}
	}

	fn searchFn ( vtext: [] const u8 ) FnEnum {
	var i	 :usize = 0;
	const max :usize = @typeInfo(FnEnum).Enum.fields.len;
		while( i < max ) : (i += 1) {
		if ( std.mem.eql(u8, @tagName(@as(FnEnum,@enumFromInt(i))), vtext)) return @as(FnEnum,@enumFromInt(i));
		}
		return FnEnum.none;

	}
};
var callFunc: FnEnum = undefined;



var callTask: TaskEnum = undefined;
fn TaskIso( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {

	if ( ! fld.ctrlDate(vfld.text) ) {

		const allocator = std.heap.page_allocator;
		const msg = std.fmt.allocPrint(allocator,
			"{s} inconsistent date  ",.{vfld.text}) catch unreachable;
		defer allocator.free(msg);
		pnl.msgErr(vpnl, msg);
		vpnl.keyField = kbd.task;
		}
	return;
}


fn TaskFr( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {

	const valtest = std.fmt.allocPrint(
		utl.allocUtl,
		"{s}-{s}-{s}",
		.{ vfld.text[6..10], vfld.text[3..5], vfld.text[0..2]}) catch unreachable;

	if ( ! fld.ctrlDate(valtest) ) {

		const allocator = std.heap.page_allocator;
		const msg = std.fmt.allocPrint(allocator,
			"{s} inconsistent date  ",.{vfld.text}) catch unreachable;
		defer allocator.free(msg);
		pnl.msgErr(vpnl, msg);
		vpnl.keyField = kbd.task;
		}
	return;
}


fn TaskUs( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {

	const valtest = std.fmt.allocPrint(
		utl.allocUtl,
		"{s}-{s}-{s}",
		.{ vfld.text[6..10], vfld.text[0..2], vfld.text[3..5]}) catch unreachable;

	if ( ! fld.ctrlDate(valtest) ) {

		const allocator = std.heap.page_allocator;
		const msg = std.fmt.allocPrint(allocator,
			"{s} inconsistent date  ",.{vfld.text}) catch unreachable;
		defer allocator.free(msg);
		pnl.msgErr(vpnl, msg);
		vpnl.keyField = kbd.task;
		}
	return;
}

pub const TaskEnum = enum {
	TaskIso,
	TaskFr,
	TaskUs,
	none,

	pub fn run(self: TaskEnum, 	vpnl : *pnl.PANEL, vfld: *fld.FIELD) void	{
				switch (self) {
				.TaskIso	=> TaskIso(vpnl,vfld),
				.TaskFr		=> TaskFr(vpnl,vfld),
				.TaskUs		=> TaskUs(vpnl,vfld),

				else => dsperr.errorForms(vpnl,	Error.main_run_EnumTask_invalide),

				}
	}
	fn searchFn ( vtext: [] const u8 ) TaskEnum {
		const max :usize = @typeInfo(TaskEnum).Enum.fields.len - 1;
		
		inline for (@typeInfo(TaskEnum).Enum.fields) |f| { 
				if ( std.mem.eql(u8, f.name , vtext) ) return @as(TaskEnum,@enumFromInt(f.value));
		}
		return @as(TaskEnum,@enumFromInt(max));
	}
};



var callProg: FnProg = undefined;
/// call program estern
pub const FnProg = enum {
	exCallpgm,
	none,

	pub fn run(self: FnProg, vpnl : *pnl.PANEL, vfld: *fld.FIELD ) void	{
		switch (self) {
			.exCallpgm=> {
			const pgmParm : ?[] const u8 = null;
			 mdl.callPgmPid("APPTERM",vfld.progcall,pgmParm) 
						catch |err | switch(err)  {
								mdl.ErrChild.Module_Invalid => {
								const msgerr  = std.fmt.allocPrint(utl.allocUtl,
								" module {s} invalide appeller service Informatique ",
								.{vfld.progcall}) catch unreachable;
								defer utl.allocUtl.free(msgerr);
								forms.debeug(9999,msgerr);
								},
								else => unreachable,
						};
					
			},
			else => dsperr.errorForms(vpnl, Error.main_function_Enum_invalide),
		}
	}

	fn searchFn ( vtext: [] const u8 ) FnProg {
	var i	 :usize = 0;
	const max :usize = @typeInfo(FnProg).Enum.fields.len;
		while( i < max ) : (i += 1) {
		if ( std.mem.eql(u8, @tagName(@as(FnProg,@enumFromInt(i))), vtext)) return @as(FnProg,@enumFromInt(i));
		}
		return FnProg.none;

	}
};

// clean work
 pub fn deinitWrk() void {
	term.deinitTerm();
	grd.deinitGrid();
	utl.deinitUtl();
}

//test ---------- pas de sortie output

test "test" {
	var infox : []const u8 = "";
	infox = utl.concatStr("Info : ", infox );
	std.debug.print("{s}",.{infox});
}



// main----------------------------------
pub fn main() !void {

	// open terminal and config and offMouse , cursHide->(cursor hide)
	term.enableRawMode();
	defer term.disableRawMode() ;
	term.resizeTerm(32,132);
	// define Panel
	var pFmt01 = Panel_Fmt01();

	
	var mMenu01:mnu.MENU = Menu01();


	// defines the receiving structure of the keyboard
	var Tkey : term.Keyboard = undefined ;

	// work Panel-01
	term.resizeTerm(pFmt01.lines,pFmt01.cols);


	while (true) {
		deinitWrk();
		Tkey.Key = pnl.ioPanel(pFmt01);
		
		switch (Tkey.Key) {

			.func => {
			callFunc = FnEnum.searchFn(pFmt01.field.items[pFmt01.idxfld].procfunc); // User clicks "increment"
			callFunc.run(pFmt01, &pFmt01.field.items[pFmt01.idxfld]);
			},

			// call proc contrôl chek value
			.task => {
				callTask = TaskEnum.searchFn(pFmt01.field.items[pFmt01.idxfld].proctask); 
				callTask.run(pFmt01, &pFmt01.field.items[pFmt01.idxfld]) ;
			},
			
			.call => {
			callProg = FnProg.searchFn(pFmt01.field.items[pFmt01.idxfld].progcall); 
			callProg.run(pFmt01, &pFmt01.field.items[pFmt01.idxfld]) ;
			},

			.F2 => {
				// test control chek field
				pnl.msgErr(pFmt01,"le test de la saisie est OK");
			},
			.F4 => {
				const pFmt0X = Panel_Fmt0X();
				_= pnl.ioPanel(pFmt0X);
				pnl.rstPanel(pnl.PANEL,pFmt0X, pFmt01);
				pnl.freePanel(pFmt0X);
				forms.allocatorForms.destroy(pFmt0X);
			},
			.F5 => {
				const nitem = mnu.ioMenu(mMenu01,0);
				pnl.rstPanel(mnu.MENU,&mMenu01, pFmt01);
				std.debug.print("n°item {}",.{nitem});
			},
			.F8 => {
				var Gkey :grd.GridSelect = undefined ;
				Gkey.Key = term.kbd.none;
				Gkey.Buf = std.ArrayList([]const u8).init(grd.allocatorGrid);

				// Grid ---------------------------------------------------------------
				var Grid01 : *grd.GRID =	grd.newGridC(
							"Grid01",			// Name
							20, 62,				// posx, posy
							7,					// numbers lines
							grd.gridStyle,		// separator | or	space
							grd.CADRE.line1,	// type line 1
							);


				if (grd.countColumns(Grid01) == 0) {

					grd.newCell(Grid01,"ID",2,grd.REFTYP.UDIGIT,term.ForegroundColor.fgCyan) ;
					grd.newCell(Grid01,"Name",15,grd.REFTYP.TEXT_FREE,term.ForegroundColor.fgYellow);
					grd.newCell(Grid01,"animal",20,grd.REFTYP.TEXT_FREE,term.ForegroundColor.fgWhite) ;
					grd.newCell(Grid01,"prix",10,grd.REFTYP.DECIMAL,term.ForegroundColor.fgWhite) ;
					grd.setCellEditCar(&Grid01.cell.items[3],"€");
					grd.newCell(Grid01,"HS",1,grd.REFTYP.SWITCH,term.ForegroundColor.fgRed) ;
					//grd.newCell(&Grid01,"Password",10,grd.REFTYP.PASSWORD,term.ForegroundColor.fgGreen) ;
					grd.setHeaders(Grid01);
					grd.printGridHeader(Grid01);
				}

				grd.resetRows(Grid01);

				grd.addRows(Grid01 , &.{"1", "Adam","Aigle","+1000.00","1","tictac"});
				grd.addRows(Grid01 , &.{"2", "Eve", "poisson","-1001.00","1","tictac2"});
				grd.addRows(Grid01 , &.{"3", "Rouge","Aigle","1002.00","0","tictac3"});
				grd.addRows(Grid01 , &.{"4", "Bleu", "poisson","100.00","0","tictac"});
				grd.addRows(Grid01 , &.{"5", "Bleu5", "poisson","100.00","0","tictac"});
				grd.addRows(Grid01 , &.{"6", "Bleu6", "poisson","100.00","0","tictac"});
				grd.addRows(Grid01 , &.{"7", "Bleu7", "poisson","100.00","1","tictac"});
				grd.addRows(Grid01 , &.{"8", "Bleu8", "poisson","100.00","0","tictac"});
				grd.addRows(Grid01 , &.{"9", "Bleu9", "poisson","100.00","0","tictac"});
				grd.addRows(Grid01 , &.{"10", "Bleu10", "poisson","100.00","0","tictac"});
				grd.addRows(Grid01 , &.{"11", "Bleu11", "poisson","100.00","0","tictac"});
				grd.addRows(Grid01 , &.{"12", "Bleu12", "Canard","100,00","0","tictac"});

				//grd.dltRows(&Grid01 , 5) catch |err| {dsperr.errorForms(err); return;};
				while (true ){
					Gkey =grd.ioGrid(Grid01,true);

					if ( Gkey.Key == kbd.enter and pFmt01.idxfld == 0) {
					fld.setText(pFmt01,0,Gkey.Buf.items[2]) catch |err| {dsperr.errorForms(pFmt01,err); return;};
					// exemple key reccord hiden 
					//fld.setText(&pFmt01,0,Gkey.Buf.items[5]) catch |err| {dsperr.errorForms(err); return;};
					break;
					}
					if ( Gkey.Key == kbd.esc) {
					break;
					}

					if (Gkey.Key	== kbd.pageDown) {
					grd.resetRows(Grid01);
					grd.addRows(Grid01 , &.{"1", "Adam","Aigle","1000,00","1","tictac"});
					grd.addRows(Grid01 , &.{"2", "Eve", "poisson","1001,00","1","tictac"});
					grd.addRows(Grid01 , &.{"3", "Rouge","Aigle","1002,00","0","tictac"});
					grd.addRows(Grid01 , &.{"4", "Bleu", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"5", "Bleu5", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"6", "Bleu6", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"7", "Bleu7", "poisson","100,00","1","tictac"});
					grd.addRows(Grid01 , &.{"8", "Bleu8", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"9", "Bleu9", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"10", "Bleu10", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"11", "Bleu11", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"12", "Bleu12", "Canard","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"13", "Bleu13", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"14", "Bleu14", "Vache","100,00","0","tictac"});
					}
					if (Gkey.Key	== kbd.pageUp) {
					grd.resetRows(Grid01);
					grd.addRows(Grid01 , &.{"1", "Adam","Aigle","1000,00","1","tictac"});
					grd.addRows(Grid01 , &.{"2", "Eve", "poisson","1001,00","1","tictac"});
					grd.addRows(Grid01 , &.{"3", "Rouge","Aigle","1002,00","0","tictac"});
					grd.addRows(Grid01 , &.{"4", "Bleu", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"5", "Bleu5", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"6", "Bleu6", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"7", "Bleu7", "poisson","100,00","1","tictac"});
					grd.addRows(Grid01 , &.{"8", "Bleu8", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"9", "Bleu9", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"10", "Bleu10", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"11", "Bleu11", "poisson","100,00","0","tictac"});
					grd.addRows(Grid01 , &.{"12", "Bleu12", "Canard","100,00","0","tictac"});
					}
				}
				pnl.rstPanel(grd.GRID,Grid01, pFmt01);
				// if you have several grids please do a freeGrid on exit and a reloadGrid on enter
				grd.freeGrid(Grid01);
				grd.allocatorGrid.destroy(Grid01);
				Gkey.Buf.deinit();
				grd.deinitGrid();
				// for debug control memoire in test CODELLDB
				// _= kbd.getKEY();
			},

			.F12 => {
			// function test clean 
				deinitWrk();
				pnl.clearPanel(pFmt01);
				pnl.printPanel(pFmt01);
			},
			.F24 => {
			// function enrg file record
				pnl.freePanel(pFmt01);
				forms.deinitForms();
				deinitWrk();
				pFmt01 = Panel_Fmt01();
				pnl.printPanel(pFmt01);
			},
			else => {},
		}
		if (Tkey.Key == kbd.F3) break; // end work
	}
}
