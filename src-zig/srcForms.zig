	///-----------------------
	/// prog mdlGrid 
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

// src def
const def = @import("srcdef");

// management JSON
// const mdlFile = @import("mdlFile");

// REFERENCE CONTROL
const deb_Log = @import("logsrc").openFile;   // open  file
const del_Log = @import("logsrc").deleteFile; // delete file
const end_Log = @import("logsrc").closeFile;  // close file
const new_Line = @import("logsrc").newLine;   // new line
const pref	  = @import("logsrc").scoped;     // print file 

const allocator = std.heap.page_allocator;


var NOBJET = std.ArrayList(def.DEFOBJET).init(allocator);
var NFIELD = std.ArrayList(def.DEFFIELD).init(allocator);
var NLABEL = std.ArrayList(def.DEFLABEL).init(allocator);
var NLINEH = std.ArrayList(def.DEFLINEH).init(allocator);
var NLINEV = std.ArrayList(def.DEFLINEV).init(allocator);
var NBUTTON= std.ArrayList(def.DEFBUTTON).init(allocator);

var NPANEL = std.ArrayList(pnl.PANEL).init(allocator);
var NGRID  = std.ArrayList(grd.GRID ).init(allocator);
var NMENU  = std.ArrayList(mnu.DEFMENU ).init(allocator);


var numPanel: usize = undefined;
var numGrid : usize = undefined;
var numMenu : usize = undefined;

var nopt : usize	= 0;
var workFunc : bool = false;
var workTask : bool = false;
var workCall : bool = false;


const choix = enum {
	outsrc,
	exit
};



const e0 = "─┬─";

const e1 = " │ ";

const e2 = "─┼─";

const e9 = "─┴─";

// define attribut default LABEL
const atrText : term.ZONATRB = .{
			.styled=[_]u32{@intFromEnum(term.Style.styleDim),
										@intFromEnum(term.Style.styleItalic),
										@intFromEnum(term.Style.notStyle),
										@intFromEnum(term.Style.notStyle)},
			.backgr = term.BackgroundColor.bgBlack,
			.foregr = term.ForegroundColor.fgGreen,
};

fn strToUsize(v: []const u8) usize {
	if (v.len == 0) return 0;
	return std.fmt.parseUnsigned(u64, v, 10) catch |err| {
		@panic(@errorName(err));
	};
}

fn usizeToStr(v: usize) []const u8 {
	return std.fmt.allocPrint(utl.allocUtl, "{d}", .{v}) catch |err| {
		@panic(@errorName(err));
	};
}

fn padingRight(a: []const u8, len: usize) []const u8 {
 	var b :[] const u8 = a;
 	while ( b.len < len ) {
		b = std.fmt.allocPrint(	utl.allocUtl,"{s} ",.{ b}) catch unreachable;
	}
	return b;	
}

fn padingLeft(a: []const u8, len: usize) []const u8 {
 	var b :[] const u8 = a;
 	while ( b.len < len ) {
		b = std.fmt.allocPrint(	utl.allocUtl," {s}",.{ b}) catch unreachable;
	}
	return b;	
}


// main----------------------------------

// pub fn main() !void {
pub fn wrtForms( xPANEL : std.ArrayList(pnl.PANEL ),
				 xGRID  : std.ArrayList(grd.GRID),
				 xMENU  : std.ArrayList(mnu.DEFMENU),
				 xOBJET : std.ArrayList(def.DEFOBJET),
				 xFIELD : std.ArrayList(def.DEFFIELD),
			     xLABEL : std.ArrayList(def.DEFLABEL),
			     xLINEH : std.ArrayList(def.DEFLINEH),
			     xLINEV : std.ArrayList(def.DEFLINEV),
			     xBUTTON : std.ArrayList(def.DEFBUTTON)
			   )  void {
	//term.offscrool();
	// open terminal and config and offMouse , cursHide->(cursor hide)
	term.enableRawMode();
	defer term.disableRawMode() ;

	// Initialisation
	term.titleTerm("DESIGNER");


	term.resizeTerm(44,168);
	const termSize = term.getSize();


	fld.MouseDsp = true ; // active display cursor x/y mouse

	const base : *pnl.PANEL = pnl.newPanelC("base",
					1, 1,
					termSize.height,
					termSize.width ,
					forms.CADRE.line1,
					"") ;
	//-------------------------------------------------
	//the menu is not double buffered it is not a Panel

	const MenuPrincipal = mnu.newMenu(
					"Screen",				// name
					2, 2,					// posx, posy
					mnu.CADRE.line1,		// type line fram
					mnu.MNUVH.vertical,		// type menu vertical / horizontal
					&.{
					"mainForms",
					"Exit...",
					}
					) ;

	pnl.printPanel(base);
	term.deinitTerm();
	utl.deinitUtl();
	nopt = mnu.ioMenu(MenuPrincipal,0);

	if (nopt == @intFromEnum(choix.exit ) or nopt == 999) {return; }
 
	for( xPANEL.items) | p | {NPANEL.append(p) catch unreachable;}
	for( xGRID.items)  | g | {NGRID.append(g) catch unreachable;}
	for( xMENU.items)  | m | {NMENU.append(m) catch unreachable;}

	for( xOBJET.items) | o | {NOBJET.append(o) catch unreachable;}
	for( xFIELD.items) | f | {NFIELD.append(f) catch unreachable;}
	for( xLABEL.items) | l | {NLABEL.append(l) catch unreachable;}
	for( xLINEH.items) | h | {NLINEH.append(h) catch unreachable;}
	for( xLINEV.items) | v | {NLINEV.append(v) catch unreachable;}
	for( xBUTTON.items) | b | {NBUTTON.append(b) catch unreachable;}
		



	wrtSrc(NOBJET, NFIELD) ;

	

	utl.deinitUtl();
	grd.deinitGrid();
			
	if (NPANEL.items.len > 0) {
		NPANEL.clearRetainingCapacity();
	}
	if (NGRID.items.len > 0) {
		NGRID.clearRetainingCapacity();
	}
	if (NMENU.items.len > 0) {
		NMENU.clearRetainingCapacity();
	}
	if (NOBJET.items.len > 0) {
		NOBJET.clearRetainingCapacity();
	}
	if (NFIELD.items.len > 0) {
		NFIELD.clearRetainingCapacity();
	}
	if (NLABEL.items.len > 0) {
		NLABEL.clearRetainingCapacity();
	}
	if (NLINEH.items.len > 0) {
		NLINEH.clearRetainingCapacity();
	}
	if (NLINEV.items.len > 0) {
		NLINEV.clearRetainingCapacity();
	}

	if (NBUTTON.items.len > 0) {
		NBUTTON.clearRetainingCapacity();
	}
	term.disableRawMode();
}
fn wrtSrc(xobjet: std.ArrayList(def.DEFOBJET ) , xfield: std.ArrayList(def.DEFFIELD))  void {
	 
	for( NPANEL.items) | p | {
		for (p.field.items) | f | {
			if ( !std.mem.eql(u8, f.procfunc, "")) workFunc = true ;
			if ( !std.mem.eql(u8, f.proctask, "")) workTask = true ;
			if ( !std.mem.eql(u8, f.progcall, "")) workCall = true ;
		}
	}

	const file = std.fs.cwd().createFile(
        "Formsrc.zig", .{ .read = true } ) catch unreachable;
    defer file.close();
    const wrt = file.writer();

    
    
	wrt.print("//----------------------\n",.{}) catch {};
	wrt.print("//---date text----------\n",.{}) catch {};
	wrt.print("//----------------------\n",.{}) catch {};
	wrt.print("\n\n\nconst std = @import(\"std\");\n",.{}) catch {};

	wrt.print("// terminal Fonction\n",.{}) catch {};
	wrt.print("const term = @import(\"cursed\");\n",.{}) catch {};

	wrt.print("// keyboard\n",.{}) catch {};
	wrt.print("const kbd = @import(\"cursed\").kbd;\n",.{}) catch {};

	wrt.print("\n// cadre\n",.{}) catch {};
	wrt.print("const cdr = @import(\"forms\").CADRE;\n",.{}) catch {};
	wrt.print("const lne = @import(\"forms\").LINE;\n",.{}) catch {};
	
	wrt.print("\n// Error\n",.{}) catch {};
	wrt.print("const dsperr = @import(\"forms\").dsperr;\n",.{}) catch {};
	
	wrt.print("\n// frame\n",.{}) catch {};
	wrt.print("const frm = @import(\"forms\").frm;\n",.{}) catch {};
	
	wrt.print("\n// panel\n",.{}) catch {};
	wrt.print("const pnl = @import(\"forms\").pnl;\n",.{}) catch {};
	
	wrt.print("\n// button\n",.{}) catch {};
	wrt.print("const btn = @import(\"forms\").btn;\n",.{}) catch {};
	
	wrt.print("\n// label\n",.{}) catch {};
	wrt.print("const lbl = @import(\"forms\").lbl;\n",.{}) catch {};
	
	wrt.print("\n// flied\n",.{}) catch {};
	wrt.print("const fld = @import(\"forms\").fld;\n",.{}) catch {};
	
	wrt.print("\n// line horizontal\n",.{}) catch {};
	wrt.print("const lnh = @import(\"forms\").lnh;\n",.{}) catch {};
	
	wrt.print("\n// line vertival\n",.{}) catch {};
	wrt.print("const lnv = @import(\"forms\").lnv;\n",.{}) catch {};
	
	for( xobjet.items) | m | {
		if (m.objtype == def.OBJTYPE.SFLD or m.objtype == def.OBJTYPE.COMBO)	{
			wrt.print("\n// line grid/combo\n",.{}) catch {};
			wrt.print("const grd = @import(\"grid\").grd;\n",.{}) catch {};
			break;
		}
	}
	
	for( xobjet.items) | m | {
		if (m.objtype == def.OBJTYPE.MENU)	{
			wrt.print("\n// menu\n",.{}) catch {};
			wrt.print("const mnu = @import(\"menu\").mnu;\n",.{}) catch {};
			break;
		}
	}

	for( xfield.items) | f | {
		if ( ! std.mem.eql(u8 ,f.call ,"")){
			wrt.print("\n// tools execve Pgm\n",.{}) catch {};
			wrt.print("\nconst mdl = @import(\"callpgm\");\n",.{}) catch {};
			break;
		}	
	}		
	wrt.print("\n// tools utility\n",.{}) catch {};
	wrt.print("const utl = @import(\"utils\");\n",.{}) catch {};


for( xobjet.items) | m | {

	if (m.objtype == def.OBJTYPE.PANEL)	{
		wrt.print("\n\n\n//----------------------\n",.{}) catch {};
		wrt.print("// Define Global DSPF PANEL\n",.{}) catch {};
		wrt.print("//----------------------\n",.{}) catch {};
	
		wrt.print("\n\n\npub fn Panel_{s}() *pnl.PANEL{{\n",.{NPANEL.items[m.index].name}) catch {};
	
		wrt.print("\t\t\t//----------------------\n",.{}) catch {};
		wrt.print("\t\t\tvar Panel : *pnl.PANEL = pnl.newPanelC(\"{s}\",\n", 
			.{NPANEL.items[m.index].name }) catch {};

		wrt.print("\t\t\t{d}, {d},\n", .{ NPANEL.items[m.index].posx, NPANEL.items[m.index].posy} ) catch {};
		wrt.print("\t\t\t{d}, {d},\n", .{ NPANEL.items[m.index].lines, NPANEL.items[m.index].cols}) catch {};
		wrt.print("\t\t\tcdr.{s},\n", .{ @tagName(NPANEL.items[m.index].frame.cadre)}) catch {};
		wrt.print("\t\t\t\"{s}\");\n", .{ NPANEL.items[m.index].frame.title} ) catch {};


// Button
		if (NBUTTON.items.len > 0) {
			wrt.print("\n\t\t\t//----------------------\n",.{}) catch {};
			for( NPANEL.items[m.index].button.items) | b | {
					wrt.print("\t\t\tPanel.button.append(btn.newButton(kbd.{s},{},{},\"{s}\")) catch unreachable ;\n"
					,.{@tagName(b.key), b.show, b.check, b.title}) catch {} ;
			}
		}

// Label
		if (NLABEL.items.len > 0) {
			wrt.print("\n\t\t\t//----------------------\n",.{}) catch {};
			for( NPANEL.items[m.index].label.items) | l | {
				if (l.title == true ) {
					wrt.print("\t\t\tPanel.label.append(lbl.newTitle(\"{s}\",{d},{d},\"{s}\")) catch unreachable ;\n"
					,.{l.name, l.posx, l.posy, l.text}) catch {} ;
					}
					else {
					wrt.print("\t\t\tPanel.label.append(lbl.newLabel(\"{s}\",{d},{d},\"{s}\")) catch unreachable ;\n"
					,.{l.name, l.posx, l.posy, l.text}) catch {} ;
					}
			}
		}


// Field
		if (NFIELD.items.len > 0) {
			wrt.print("\n\t\t\t//----------------------\n",.{}) catch {};
			for( NPANEL.items[m.index].field.items) | f | {
				wrt.print("\n",.{}) catch {};
				switch(f.reftyp) {
				forms.REFTYP.TEXT_FREE => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldTextFree(\"{s}\",{d},{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.width, f.text, f.requier, f.errmsg, f.help, f.regex}) catch {} ;
				},
			
				forms.REFTYP.TEXT_FULL => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldTextFull(\"{s}\",{d},{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.width, f.text, f.requier, f.errmsg, f.help, f.regex}) catch {} ;
				},
			
				forms.REFTYP.ALPHA => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldAlpha(\"{s}\",{d},{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.width, f.text, f.requier, f.errmsg, f.help, f.regex}) catch {} ;
				},
			
				forms.REFTYP.ALPHA_UPPER => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldAlphaUpper(\"{s}\",{d},{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.width, f.text, f.requier, f.errmsg, f.help, f.regex}) catch {} ;
				},
			
				forms.REFTYP.ALPHA_NUMERIC => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldAlphaNumeric(\"{s}\",{d},{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.width, f.text, f.requier, f.errmsg, f.help, f.regex}) catch {} ;
				},

				forms.REFTYP.ALPHA_NUMERIC_UPPER=> {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldAlphaNumericUpper(\"{s}\",{d},{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.width, f.text, f.requier, f.errmsg, f.help, f.regex}) catch {} ;
				},
			
				forms.REFTYP.PASSWORD => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldPassword(\"{s}\",{d},{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.width, f.text, f.requier, f.errmsg, f.help, f.regex}) catch {} ;
				},
			
				forms.REFTYP.YES_NO => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldYesNo(\"{s}\",{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.text, f.requier, f.errmsg, f.help}) catch {} ;
				},
			
				forms.REFTYP.UDIGIT => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldUDigit(\"{s}\",{d},{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.width, f.text, f.requier, f.errmsg, f.help, f.regex}) catch {} ;
				},
			
				forms.REFTYP.DIGIT => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldDigit(\"{s}\",{d},{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.width, f.text, f.requier, f.errmsg, f.help, f.regex}) catch {} ;
				},
			
				forms.REFTYP.UDECIMAL => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldUDecimal(\"{s}\",{d},{d},{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.width, f.scal, f.text, f.requier, f.errmsg, f.help, f.regex}) catch {} ;
				},
			
				forms.REFTYP.DECIMAL => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldDecimal(\"{s}\",{d},{d},{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.width, f.scal, f.text, f.requier, f.errmsg, f.help, f.regex}) catch {} ;
				},
			
				forms.REFTYP.DATE_ISO => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldDateISO(\"{s}\",{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.text, f.requier, f.errmsg, f.help}) catch {} ;
				},
			
				forms.REFTYP.DATE_FR => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldDateFR(\"{s}\",{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.text, f.requier, f.errmsg, f.help}) catch {} ;
				},
			
				forms.REFTYP.DATE_US => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldDateUS(\"{s}\",{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.text, f.requier, f.errmsg, f.help}) catch {} ;
				},
			
				forms.REFTYP.TELEPHONE => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldTelephone(\"{s}\",{d},{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.width, f.text, f.requier, f.errmsg, f.help, f.regex}) catch {} ;
				},
			
				forms.REFTYP.MAIL_ISO => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldMail(\"{s}\",{d},{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.width, f.text, f.requier, f.errmsg, f.help, f.regex}) catch {} ;
				},
			
				forms.REFTYP.SWITCH => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldSwitchl(\"{s}\",{d},{d},{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy,f.zwitch,f.errmsg, f.help}) catch {} ;
				},
			
				forms.REFTYP.FUNC => {
				wrt.print("\t\t\tPanel.field.append(fld.newFieldFunc(\"{s}\",{d},{d},{d},\n\t\t\t\"{s}\",\n\t\t\t{},\n\t\t\t\"{s}\",\n\t\t\t\"{s}\",\n\t\t\t\"{s}\")) catch unreachable ;\n"
				,.{f.name, f.posx, f.posy, f.width,"?",f.requier, f.procfunc, f.errmsg, f.help}) catch {} ;
				},

			}
		
		}

// Line H
		if (NLINEH.items.len > 0) {
			wrt.print("\n\t\t\t//----------------------\n",.{}) catch {};
			for( NPANEL.items[m.index].lineh.items) | h | {
				wrt.print("\t\t\tPanel.lineh.append(lnh.newLine(\"{s}\",{d},{d},{d},lne.{s})) catch unreachable ;\n"
					,.{h.name, h.posx, h.posy, h.lng,@tagName(h.trace)}) catch {} ;
			}
		}
// Line V
		if (NLINEV.items.len > 0) {
			wrt.print("\n\t\t\t//----------------------\n",.{}) catch {};
			for( NPANEL.items[m.index].linev.items) | v | {
				wrt.print("\t\t\tPanel.linev.append(lnv.newLine(\"{s}\",{d},{d},{d},lne.{s})) catch unreachable ;\n"
					,.{v.name, v.posx, v.posy, v.lng,@tagName(v.trace)}) catch {} ;
			}
		}


		wrt.print("\n\n\t\t\treturn Panel;\n",.{}) catch {};
		wrt.print("\n\n\t}}\n",.{}) catch {};
	}
		

		

	if (m.objtype == def.OBJTYPE.MENU)	{

		wrt.print("\n\n\n//----------------------\n",.{}) catch {};
		wrt.print("// Define Global DSPF MENU\n",.{}) catch {};
		wrt.print("//----------------------\n",.{}) catch {};
					
		wrt.print("const x{s} = enum {{\n", 
			.{NMENU.items[m.index].name}) catch {};
		for(NMENU.items[m.index].xitems) |text| {
			wrt.print("\t\t\t{s},\n", .{text}) catch {};
		}
		wrt.print("\t\t\t}};\n\n", .{}) catch {};

		
		wrt.print("const {s} = mnu.newMenu(\n", 
			.{NMENU.items[m.index].name}) catch {};
		wrt.print("\t\t\t\"{s}\",\n", 
			.{NMENU.items[m.index].name}) catch {};
		wrt.print("\t\t\t{d}, {d},\n",
			 .{ NMENU.items[m.index].posx, NMENU.items[m.index].posy} ) catch {};
		wrt.print("\t\t\tmnu.CADRE.{s},\n", 
			.{ @tagName(NMENU.items[m.index].cadre)}) catch {};
		wrt.print("\t\t\tmnu.MNUVH.{s},\n", 
			.{ @tagName(NMENU.items[m.index].mnuvh)}) catch {};
		wrt.print("\t\t\t&.{{\n", .{}) catch {};
		for(NMENU.items[m.index].xitems) |text| {
			wrt.print("\t\t\t\"{s}\",\n", .{text}) catch {};
		}
		wrt.print("\t\t\t}}\n", .{}) catch {};
		wrt.print("\t\t\t);\n", .{}) catch {};
	}

}

} // end full NOBJET

	wrt.print("\n\n\n\t//Errors\n",.{}) catch {};
	wrt.print("\tpub const Error = error{{\n",.{}) catch {};
	wrt.print("\t\tmain_function_Enum_invalide,\n",.{}) catch {};
	wrt.print("\t\tmain_run_EnumTask_invalide,\n",.{}) catch {};
	wrt.print("\t}};\n\n\n",.{}) catch {};

if (workFunc) {
	wrt.print("\n\n\n//----------------------------------\n",.{}) catch {};
	wrt.print("//  run emun Function ex: combo\n",.{}) catch {};
	wrt.print("//----------------------------------\n",.{}) catch {};

	for ( NOBJET.items) | o | {
		if ( o.objtype  == def.OBJTYPE.COMBO ) {
			wrt.print("\tfn {s}( vpnl : *pnl.PANEL , vfld :* fld.FIELD) void {{\n",.{o.name}) catch {};
			wrt.print("\t\tvar cellPos:usize = 0;\n",.{}) catch {};
			wrt.print("\t\tconst Xcombo : *grd.GRID = grd.newGridC(\n",.{}) catch {};
			wrt.print("\t\t\t\t\"{s}\",\n",.{o.name}) catch {};
			wrt.print("\t\t\t\t{d}, {d},\n",.{NGRID.items[o.index].posx, NGRID.items[o.index].posy,}) catch {};
			wrt.print("\t\t\t\t{d},\n",.{NGRID.items[o.index].pageRows}) catch {};
			if (std.mem.eql(u8,NGRID.items[o.index].separator , grd.gridStyle) )
			wrt.print("\t\t\t\tgrd.gridStyle,\n",.{}) catch {}
			else wrt.print("\t\t\t\tgrd.gridStyle2,\n",.{}) catch {};
			wrt.print("\t\t\t\tgrd.CADRE.{s},\n",.{@tagName(NGRID.items[o.index].cadre)}) catch {};
			wrt.print("\t\t);\n\n",.{}) catch {};
			
			wrt.print("\t\tdefer grd.freeGrid(Xcombo);\n",.{}) catch {};
			wrt.print("\t\tdefer grd.allocatorGrid.destroy(Xcombo);\n\n",.{}) catch {};
			for(NGRID.items[o.index].cell.items) |c| {
			wrt.print("\t\tgrd.newCell(Xcombo,\"{s}\",{d}, grd.REFTYP.{s}, term.ForegroundColor.{s});\n"
				,.{c.text,c.long,@tagName(c.reftyp),@tagName(c.atrCell.foregr) }) catch {};
			}
			wrt.print("\t\tgrd.setHeaders(Xcombo) ;\n\n",.{}) catch {};
			
			wrt.print("\t\t// data\n",.{}) catch {};

			wrt.print("\t\tgrd.addRows(Xcombo , &.{{\"??\"}});\n\n",.{}) catch {};

			wrt.print("\t\tif (std.mem.eql(u8,vfld.text,\"??\") == true) \tcellPos = 0;\n",.{}) catch {};

			wrt.print("\n\t\t// Interrogation\n",.{}) catch {};
			wrt.print("\t\tvar Gkey :grd.GridSelect = undefined ;\n",.{}) catch {};
			wrt.print("\t\tdefer Gkey.Buf.deinit();\n\n",.{}) catch {};

			wrt.print("\t\tGkey =grd.ioCombo(Xcombo,cellPos);\n",.{}) catch {};
			wrt.print("\t\tpnl.rstPanel(grd.GRID,Xcombo, vpnl);\n\n",.{}) catch {};
			
			wrt.print("\t\tif ( Gkey.Key == kbd.esc ) return ;\n",.{}) catch {};

			wrt.print("\t\tvfld.text = Gkey.Buf.items[0];\n",.{}) catch {};

			wrt.print("\t\treturn ;\n",.{}) catch {};

			wrt.print("\t}}\n\n\n",.{}) catch {};
		}	
	}

	wrt.print("\tconst FuncEnum = enum {{\n",.{}) catch {};
	for(NFIELD.items) | f | {
		if ( !std.mem.eql(u8,f.func ,"" ) )
		wrt.print("\t\t{s},\n\n",.{f.func}) catch {};
	}

	wrt.print("\t\tnone,\n",.{}) catch {};

	wrt.print("\t\tfn run(self: FuncEnum, vpnl : *pnl.PANEL, vfld: *fld.FIELD ) void {{\n",.{}) catch {};

	wrt.print("\t\t\tswitch (self) {{\n",.{}) catch {};
	for(NFIELD.items) | f | {
		if ( !std.mem.eql(u8,f.func ,"" ) )
		wrt.print("\t\t\t.{s} => {s}(vpnl,vfld),\n",.{f.func,f.fgrid}) catch {};
	}
	wrt.print("\t\t\telse => dsperr.errorForms(vpnl, Error.main_function_Enum_invalide),\n",.{}) catch {};
	wrt.print("\t\t\t}}\n",.{}) catch {};
	wrt.print("\t\t}}\n",.{}) catch {};

	wrt.print("\t\tfn searchFn ( vtext: [] const u8 ) FuncEnum {{\n",.{}) catch {};

	wrt.print("\t\t\tinline for (@typeInfo(FuncEnum).@\"{s}\".fields) |f| {{\n",.{"enum"}) catch {}; 
	wrt.print("\t\t\t\tif ( std.mem.eql(u8, f.name , vtext) ) return @as(FuncEnum,@enumFromInt(f.value));\n"
		,.{}) catch {};
	wrt.print("\t\t\t}}\n",.{}) catch {};
	wrt.print("\t\t\treturn FuncEnum.none;\n",.{}) catch {};
	wrt.print("\t\t}}\n",.{}) catch {};
	wrt.print("\t}};\n",.{}) catch {};
	wrt.print("\tvar callFunc: FuncEnum = undefined;\n",.{}) catch {};

}

if (workTask) {


	wrt.print("\n\n\n//----------------------------------\n",.{}) catch {};
	wrt.print("//  run emun Task ex: control Field\n",.{}) catch {};
	wrt.print("//----------------------------------\n",.{}) catch {};

	for(NFIELD.items) | t | {
	if ( !std.mem.eql(u8,t.task ,"" ) ) {
		if ( std.mem.eql(u8,t.task ,"TaskDateIso" ) ) {
			wrt.print("\tfn TaskDateIso( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {{\n",.{}) catch {};

			wrt.print("\t\tif ( ! fld.isMatchiFixedIso(vfld.text) ) {{\n",.{}) catch {};

			wrt.print("\t\t\tconst allocator = std.heap.page_allocator;\n",.{}) catch {};
			wrt.print("\t\t\tconst msg = std.fmt.allocPrint(allocator,\n",.{}) catch {};
			wrt.print("\t\t\t\"{{s}} Invalid date format ISO \",.{{vfld.text}}) catch unreachable;\n",.{}) catch {};
			wrt.print("\t\t\tdefer allocator.free(msg);\n",.{}) catch {};
			wrt.print("\t\t\tpnl.msgErr(vpnl, msg);\n",.{}) catch {};
			wrt.print("\t\t\tvpnl.keyField = kbd.task;\n",.{}) catch {};
			wrt.print("\t\t}}\n",.{}) catch {};
			wrt.print("\treturn;\n",.{}) catch {};
			wrt.print("\t}}\n",.{}) catch {};
		}
		else if ( std.mem.eql(u8,t.task ,"TaskDateFr" ) ) {
			wrt.print("\tfn TaskDateFr( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {{\n",.{}) catch {};

			wrt.print("\t\tif ( ! fld.isMatchiFixedIso(vfld.text) ) {{\n",.{}) catch {};

			wrt.print("\t\t\tconst allocator = std.heap.page_allocator;\n",.{}) catch {};
			wrt.print("\t\t\tconst msg = std.fmt.allocPrint(allocator,\n",.{}) catch {};
			wrt.print("\t\t\t\"{{s}} Invalid date format Fr \",.{{vfld.text}}) catch unreachable;\n",.{}) catch {};
			wrt.print("\t\t\tdefer allocator.free(msg);\n",.{}) catch {};
			wrt.print("\t\t\tpnl.msgErr(vpnl, msg);\n",.{}) catch {};
			wrt.print("\t\t\tvpnl.keyField = kbd.task;\n",.{}) catch {};
			wrt.print("\t\t}}\n",.{}) catch {};
			wrt.print("\treturn;\n",.{}) catch {};
			wrt.print("\t}}\n",.{}) catch {};
		}
		else if ( std.mem.eql(u8,t.task ,"TaskDateUs" ) ) {
			wrt.print("\tfn TaskDateFr( vpnl: *pnl.PANEL , vfld: *fld.FIELD) void {{\n",.{}) catch {};

			wrt.print("\t\tif ( ! fld.isMatchiFixedIso(vfld.text) ) {{\n",.{}) catch {};

			wrt.print("\t\t\tconst allocator = std.heap.page_allocator;\n",.{}) catch {};
			wrt.print("\t\t\tconst msg = std.fmt.allocPrint(allocator,\n",.{}) catch {};
			wrt.print("\t\t\t\"{{s}} Invalid date format Us \",.{{vfld.text}}) catch unreachable;\n",.{}) catch {};
			wrt.print("\t\t\tdefer allocator.free(msg);\n",.{}) catch {};
			wrt.print("\t\t\tpnl.msgErr(vpnl, msg);\n",.{}) catch {};
			wrt.print("\t\t\tvpnl.keyField = kbd.task;\n",.{}) catch {};
			wrt.print("\t\t}}\n",.{}) catch {};
			wrt.print("\treturn;\n",.{}) catch {};
			wrt.print("\t}}\n",.{}) catch {};
		}
		else {
			wrt.print("\tfn {s}(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {{\n",.{t.task}) catch {};
			wrt.print("\t\tif (std.mem.eql(u8, vfld.text ,\"\")) {{\n",.{}) catch {};
			wrt.print("\t\t\tpnl.msgErr(vpnl, \"{s}\");\n",.{NPANEL.items[t.npnl].field.items[t.index].errmsg}) 
				catch {};
			wrt.print("\t\t\tvpnl.keyField = kbd.task;\n",.{}) catch {};
			wrt.print("\t\t}}\n",.{}) catch {};
			wrt.print("\t}}\n",.{}) catch {};
		}
	}
	}




	wrt.print("\n\n\tconst TaskEnum = enum {{\n",.{}) catch {};
	for(NFIELD.items) | t | {
		if ( !std.mem.eql(u8,t.task ,"" ) )
		wrt.print("\t\t{s},\n\n",.{t.task}) catch {};
	}

	wrt.print("\t\tnone,\n",.{}) catch {};

	wrt.print("\t\tfn run(self: TaskEnum, vpnl : *pnl.PANEL, vfld: *fld.FIELD ) void {{\n",.{}) catch {};

	wrt.print("\t\t\tswitch (self) {{\n",.{}) catch {};
		for(NFIELD.items) | t | {
			if ( !std.mem.eql(u8,t.task ,"" ) )
			wrt.print("\t\t\t.{s} => {s}(vpnl,vfld),\n",.{t.task,t.task}) catch {};
	}
	wrt.print("\t\t\telse => dsperr.errorForms(vpnl, Error.main_run_EnumTask_invalide),\n",.{}) catch {};
	wrt.print("\t\t\t}}\n",.{}) catch {};
	wrt.print("\t\t}}\n",.{}) catch {};

	wrt.print("\t\tfn searchFn ( vtext: [] const u8 ) TaskEnum {{\n",.{}) catch {};

	wrt.print("\t\t\tinline for (@typeInfo(TaskEnum).@\"{s}\".fields) |f| {{\n",.{"enum"}) catch {}; 
	wrt.print("\t\t\t\tif ( std.mem.eql(u8, f.name , vtext) ) return @as(TaskEnum,@enumFromInt(f.value));\n"
		,.{}) catch {};
	wrt.print("\t\t\t}}\n",.{}) catch {};
	wrt.print("\t\t\treturn TaskEnum.none;\n",.{}) catch {};
	wrt.print("\t\t}}\n",.{}) catch {};
	wrt.print("\t}};\n",.{}) catch {};
	wrt.print("\tvar callTask: TaskEnum = undefined;\n",.{}) catch {};

}
	

	wrt.print("\n\n\n//----------------------------------\n",.{}) catch {};
	wrt.print("// squelette\n",.{}) catch {};
	wrt.print("//----------------------------------\n\n",.{}) catch {};

	wrt.print("pub fn main() !void {{\n",.{}) catch {};
    wrt.print("// init terminal\n",.{}) catch {};
    wrt.print("term.enableRawMode();\n",.{}) catch {};
    wrt.print("defer term.disableRawMode() ;\n\n",.{}) catch {};

	wrt.print("// Initialisation\n",.{}) catch {};
	wrt.print("term.titleTerm(\"MY-TITLE\");\n\n",.{}) catch {};

	wrt.print("term.cls();\n\n",.{}) catch {};
	
	wrt.print("// define Panel\n",.{}) catch {};
	wrt.print("var p{s} = Panel_{s}();\n\n",.{NPANEL.items[0].name,NPANEL.items[0].name}) catch {};
	
	wrt.print("// work Panel-01\n",.{}) catch {};
	wrt.print("term.resizeTerm(p{s}.lines,p{s}.cols);\n\n",.{NPANEL.items[0].name,NPANEL.items[0].name}) catch {};

	wrt.print("// defines the receiving structure of the keyboard\n",.{}) catch {};
	wrt.print("var Tkey : term.Keyboard = undefined ;\n\n",.{}) catch {};
	
	wrt.print("\twhile (true) {{\n",.{}) catch {};
	wrt.print("\t\tTkey.Key = pnl.ioPanel(p{s});\n",.{NPANEL.items[0].name}) catch {};
	wrt.print("\t\t//--- ---\n\n",.{}) catch {};
	
	wrt.print("\t\tswitch (Tkey.Key) {{\n",.{}) catch {};

if (workFunc) {
	wrt.print("\t\t\t.func => {{\n",.{}) catch {};

	wrt.print("\t\t\tcallFunc = FuncEnum.searchFn(p{s}.field.items[p{s}.idxfld].procfunc);\n"
		,.{NPANEL.items[0].name,NPANEL.items[0].name}) catch {}; 
	wrt.print("\t\t\tcallFunc.run(p{s}, &p{s}.field.items[p{s}.idxfld]);\n"
		,.{NPANEL.items[0].name,NPANEL.items[0].name,NPANEL.items[0].name}) catch {};
	wrt.print("\t\t\t}},\n\n",.{}) catch {};
}
if (workTask) {
	wrt.print("\t\t\t// call proc contrôl chek value\n",.{}) catch {};
	wrt.print("\t\t\t.task => {{\n",.{}) catch {};
	wrt.print("\t\t\tcallTask = TaskEnum.searchFn(p{s}.field.items[p{s}.idxfld].proctask);\n"
		,.{NPANEL.items[0].name,NPANEL.items[0].name}) catch {};
	wrt.print("\t\t\tcallTask.run(p{s}, &p{s}.field.items[p{s}.idxfld]);\n"
		,.{NPANEL.items[0].name,NPANEL.items[0].name,NPANEL.items[0].name}) catch {};
	wrt.print("\t\t\t}},\n\n",.{}) catch {};
}

if (workCall) {
	wrt.print("\t\t\t.call => {{\n",.{}) catch {};

	wrt.print("\t\t\tcallProg = FnProg.searchFn(p{s}.field.items[p{s}.idxfld].progcall);\n"
		,.{NPANEL.items[0].name,NPANEL.items[0].name}) catch {};
	wrt.print("\t\t\tcallProg.run(p{s}, &p{s}.field.items[p{s}.idxfld]);\n"
		,.{NPANEL.items[0].name,NPANEL.items[0].name,NPANEL.items[0].name}) catch {};
	wrt.print("\t\t\t}},\n\n",.{}) catch {};
}

	wrt.print("\t\t\telse => {{}},\n\n",.{}) catch {};
	
	wrt.print("\t\t}}\n\n",.{}) catch {};
	
	
	wrt.print("\t\tif (Tkey.Key == kbd.F3) break; // end work\n",.{}) catch {};
	wrt.print("\t}}\n\n",.{}) catch {};
	wrt.print("}}\n\n",.{}) catch {};

}
