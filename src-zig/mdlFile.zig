	///-----------------------
	/// prog mdlFile
	/// zig 0.12.0 dev
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


// grid
const grd = @import("grid").grd;
// menu
const mnu = @import("menu").mnu;

// tools utility
const utl = @import("utils");

// tools regex
const reg = @import("match");



// sauvegarde JSON
const mdlSjson = @import("mdlSjson");

// Restore JSON
const mdlRjson = @import("mdlRjson");


pub fn Panel_Fmt01(title: [] const u8) *pnl.PANEL {
	const termSize = term.getSize() ;


	var Panel : *pnl.PANEL = pnl.newPanelC("FRAM01",
										1, 1,
										termSize.height,
										termSize.width ,
										forms.CADRE.line1,
										title,
										);

	Panel.button.append(btn.newButton(
									kbd.F3,			// function
									true,			// show
									false,			// check field
									"Exit",			// title 
									)
								) catch unreachable ;



	Panel.button.append(btn.newButton(
									kbd.F9,				// function
									true,				// show
									true,				// check field
									"Creat File Json",	// title 
									)
								) catch unreachable ;



	Panel.button.append(btn.newButton(
									kbd.F11,			// function
										true,			// show
										false,			// check field
									"File recovery",	// title 
									)
								) catch unreachable ;




	Panel.label.append(lbl.newLabel("nameJson"	 ,2,2, "name.....:") ) catch unreachable ;



	Panel.field.append(fld.newFieldAlphaNumeric("nameJson",2,12,20,"",false,
								"required","please enter text ex:Panel09",
								"^[a-zA-Z]{1,1}[a-zA-Z0-9]{0,}$")) catch unreachable ;

	return Panel;
}


const vdir = "dspf";


fn isFile(name: []const u8 ) bool {

	
	const cDIR = std.fs.cwd().openDir(vdir,.{}) catch unreachable;
	
	var file = cDIR.createFile(name, .{ .read = true }) catch |e|
		switch (e) {
			error.PathAlreadyExists => return true,
			else =>return false,
		};

	defer file.close();
	return false;
}

fn newFile(name: []const u8 ) void {

	
	const cDIR = std.fs.cwd().openDir(vdir,.{}) catch unreachable;
	
	var file = cDIR.openFile(name, .{}) catch unreachable;
	cDIR.deleteFile(name) catch unreachable;
	file= cDIR.createFile(name, .{ .read = true }) catch unreachable;	
	defer file.close();
}

fn cleanProgram(vpnl : *pnl.PANEL, vgrid : *grd.GRID) void {

	pnl.freePanel(vpnl);
	forms.allocatorForms.destroy(vpnl);
	
	grd.freeGrid(vgrid);
	grd.allocatorGrid.destroy(vgrid);
	term.deinitTerm();
	grd.deinitGrid();
	utl.deinitUtl();
}

pub fn wrkJson (XPANEL: *std.ArrayList(pnl.PANEL), wrk: bool) !void {
	

	_= std.fs.cwd().openDir(vdir,.{})
		catch try std.fs.cwd().makeDir(vdir); 
	
	
	var twork: [] const u8 = undefined;
	if (wrk)  twork = "Save-File-JSON" 
	else twork = "Recovery-File-Json";
	
	var pFmt01 = Panel_Fmt01(twork);

	var Tkey : term.Keyboard = undefined ; 

	var err: bool = true ;
	var nameJson : [] const u8 = undefined;


	// Grid ---------------------------------------------------------------
	const Grid01 : *grd.GRID =	grd.newGridC(
					"Grid01",			// Name
					4, 2,				// posx, posy
					20,					// numbers lines
					grd.gridStyle,		// separator | or	space
					grd.CADRE.line1,	// type line 1
					);


	
	if (!wrk) try btn.setActif(pFmt01,try btn.getIndex(pFmt01,kbd.F9),false);

	while (true) {
			//Tkey = kbd.getKEY();

		Tkey.Key = pnl.ioPanel(pFmt01);
	
		switch (Tkey.Key) {
			.F9 => {
				for (pFmt01.field.items , 0..) |f , idx| {

					pFmt01.idxfld = idx ;
					pFmt01.keyField = kbd.none;
					err =false;
					
					if (f.text.len == 0) {
						pnl.msgErr(pFmt01, "Name Json incorrect ");
						err =true;
						continue;
					}
					else {
						nameJson = try fld.getText(pFmt01,try fld.getIndex(pFmt01,"nameJson"));
						err = isFile(nameJson);
						
						if (err) pnl.msgErr(pFmt01, "Name Json incorrect allready exist ")
						else {
							pnl.msgErr(pFmt01, try std.fmt.allocPrint(utl.allocUtl, "Save {s} Json", .{nameJson})) ;
							try mdlSjson.SavJson(XPANEL,nameJson);
							cleanProgram(pFmt01,Grid01);
						return;
						}
					}
				}
			},
			
			.F11 => {
				// 0.11.0
				// const iter_dir = try std.fs.cwd().openIterableDir(vdir,.{}) ;
				// 0.12.0 
				const iter_dir= std.fs.cwd().openDir(vdir,.{.iterate = true}) catch unreachable;

				var iterator = iter_dir.iterate();
				var ok_file= false;
				var Gkey :grd.GridSelect = undefined ;

				grd.resetRows(Grid01);

				if (grd.countColumns(Grid01) == 0) {
					grd.newCell(Grid01,"Name",25,grd.REFTYP.TEXT_FREE,term.ForegroundColor.fgYellow);
					grd.setHeaders(Grid01);
					grd.printGridHeader(Grid01);
				}
				
				while (try iterator.next()) |path| {
					ok_file = true;
					grd.addRows(Grid01, &.{path.name});
				}	

				if (!ok_file) { pnl.msgErr(pFmt01, "no file available"); continue; }
				while (true ){
					Gkey =grd.ioGrid(Grid01,false);

					pnl.displayPanel(pFmt01);
					if ( Gkey.Key == kbd.esc) {pnl.displayPanel(pFmt01); break; }

					if ( Gkey.Key == kbd.enter) {
						nameJson =Gkey.Buf.items[0];
						pnl.msgErr(pFmt01, try std.fmt.allocPrint(utl.allocUtl, "Working {s} Json", .{nameJson})) ;

						if (wrk){
							newFile(nameJson);
							try mdlSjson.SavJson(XPANEL, nameJson);
						} 
						else try mdlRjson.RstJson(XPANEL, nameJson) ;
					
						break;
					}
				}

				if ( Gkey.Key == kbd.enter) {
					cleanProgram(pFmt01,Grid01);
					return ; 
				}
			},
			
			// exit module panel 
			.F3 => {
				cleanProgram(pFmt01,Grid01);
				return ; 
			},

			else => {}
		}
	}
}
