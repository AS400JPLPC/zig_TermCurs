	///-----------------------
	/// prog exCallpgm
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

/// Errors 
pub const Error = error{
	main_function_Enum_invalide,
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
	

	Panel.label.append(lbl.newLabel("alpha",5,2,"Text-Alpha..................:")
	) catch unreachable ;


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

	// fld.setActif(Panel,0,false) catch unreachable;
	 // fld.setProtect(Panel,0,true) catch unreachable;
	
	
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
										"Abcd",						// text
										true,						// tofill
										"required",					// error msg
										"please enter text Alpha crtl+p call Exemple",	// help
										"^[A-Z]{1}[a-zA-Z]{0,}$",			// regex
										)
	) catch unreachable ;
		
	// fld.setProtect(Panel,2,true) catch unreachable;


	
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

	// define Panel
	var pFmt01 = Panel_Fmt01();

	
	var mMenu01:mnu.MENU = Menu01();


	// defines the receiving structure of the keyboard
	var Tkey : term.Keyboard = undefined ;

	// work Panel-01
	term.resizeTerm(pFmt01.lines,pFmt01.cols);


	while (true) {
		// clean works
		term.deinitTerm();
		grd.deinitGrid();
		utl.deinitUtl();
		
		Tkey.Key = pnl.ioPanel(pFmt01);
		
		switch (Tkey.Key) {

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
