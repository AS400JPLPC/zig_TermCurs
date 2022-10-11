# zig_TermCurs
terminal access function<br />

**TESTING**<br />
*look at the bottom of the testing page*<br />

**os linux**

<u>Keyboard management and respect for the terminal philosophy</u><br />

Resumption of the project https://github.com/xyaman/mibu

a little more : XYAMAN

les news:<BR />
&rarr;&nbsp; 2022-09-17  activate mouse<BR />
&rarr;&nbsp; 2022-09-17  all keyboard keys are enabled<BR />

modification from :<BR />
&rarr;&nbsp; 2022-09-17   build... Misplaced comment lines<BR />
&rarr;&nbsp; 2022-09-17   compile.sh if ok remove cache<BR />

&rarr;&nbsp; 2022-09-21   Complete restructuring of the project<BR />
<BR />
&rarr;&nbsp; 2022-09-21   New methodology for styling (style.zig)<BR />
&rarr;&nbsp; 2022-09-21   New methodology for events  (event.zig)<BR />
&rarr;&nbsp; 2022-09-21   New methodology for mouse   (mouse.zig)<BR />
&rarr;&nbsp; 2022-09-21   New methodology for clear   (clear.zig)<BR />
&rarr;&nbsp; 2022-09-21   cursor  in development<BR />

&rarr;&nbsp; 2022-09-22   update  deps(mouse/cursor)  src-zig(update event)<BR />
&rarr;&nbsp; 2022-09-22   New methodology for cursor  verify (cursor.zig)<BR />

&rarr;&nbsp; 2022-09-22   Update  deps(event.zig cursor.zig) verify <BR />
&rarr;&nbsp; 2022-09-22
&nbsp;&nbsp;&nbsp;&nbsp;Check and change important, all keyboard keys tested module without beug and cancel job.<BR />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Mouse and cursor are harmonized.<BR />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Removed save/restore cursor, but gotoXY() & getCursor() <BR />
<BR />
<BR />
<BR />
&rarr;&nbsp; 2022-09-26   **project and code restructuring** <BR />
&rarr;&nbsp; 2022-09-26   *Read the Project installation documentation* <BR />
&rarr;&nbsp; 2022-09-26   After discussion on ZULIP it seems important to redesign the project that serves me as a ZIG learning and to simplify as much as possible the calls seen developer see Tcursed.zig    
doc : [ZULIP](https://zig-lang.zulipchat.com/) <BR />
* [READ-PROJECT](http://htmlpreview.github.io/?https://github.com/AS400JPLPC/zig_TermCurs/blob/master/Read_Projet.html)<BR />
&rarr;&nbsp; 2022-09-26   Read the Project installation documentation <BR />
&rarr;&nbsp; 2022-09-26   Update deps/curse/cursed contrôl full et testing scrash  <BR />
&rarr;&nbsp; 2022-09-26   creat deps/curse/dds common definition module for cursed and forms <BR />
<BR /><BR />
&rarr;&nbsp; 2022-10-08   creat deps/curse/ cursed change Title and resize terminal <BR />
&rarr;&nbsp; 2022-10-08   creat deps/string/ introduction of zig-string tests <BR />
&rarr;&nbsp; 2022-10-08   Testing manipulation char mult-problem unicode  <BR />
&rarr;&nbsp; 2022-10-08   creat deps/zyglyph/ working lowerStr and upperStr<BR />  
&rarr;&nbsp; 2022-10-08   stabilization deps/curse/cursed<BR />
<BR /><BR />
&rarr;&nbsp; 2022-10-10   add flushIO()<BR />
&rarr;&nbsp; 2022-10-10   update getCursor  add flushIO()<BR />
&rarr;&nbsp; 2022-10-10   update gotoXY     "\x1b[{d};{d}f" not H<BR />
&rarr;&nbsp; 2022-10-10   creat Forms only test  **Only to test my build in Zig-lang it's not fully operational nor stable, double buffer process is not in place**<BR />

<BR /><BR />
&rarr;&nbsp; 2022-10-11   creat deps/curse/ utils iterator for [] const u8  Retrieval "const char" allows to know the number of characters<BR />
<BR />
<BR />

<BR />
<BR />

<u>---.VSCODE-------------------------------------------</u><BR />
&rarr;&nbsp; 2022-09-21   New methodology for clear compile.sh<BR />
&rarr;&nbsp; 2022-09-21   New methodology for clear compilelib.sh<BR />
&rarr;&nbsp; 2022-09-21   New tasck.json  use: Task Manager<BR />
<BR />

<u>---Organization-project------------------------------------------</u><BR />
&rarr;&nbsp; folder deps: Filing of files zig including reference sources<BR />
&rarr;&nbsp; folder src_c: C/C++ source files<BR />
&rarr;&nbsp; folder src_zig: zig source files<BR />
&rarr;&nbsp; build: build+source-name ex: buildevent<BR />
&rarr;&nbsp; makefile<BR />
<BR />
<u>--peculiarity-------------------------------------------------</u><BR />
test alt-ctrl ctrshift... etc for <BR />
there is a possibility to recover all the keys if we pass through GTK and use sys/shm.h.


But it is no longer transportable.
another way is to use IOCTL but again, there is a good chance of being forced to use root.

Anyway, to make management applications or Terminal type tools are more than enough.

ctrl or alt combinations plus Fn(1..24) TAB Backspace home end insert delete pageup pagedown enter escape altgr
and the utf8 keyboard is a lot.<BR />

<u>--styling-------------------------------------------------</u><BR />
make it compatible as close as possible to IBM 400 ex:<BR />
<BR />
pub const defAtrLabel : stl.ZONATRB = .{<BR />
&nbsp;&nbsp;&nbsp;.styled=[_]i32{@enumToInt(stl.Style.styleBright),<BR />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@enumToInt(stl.Style.styleItalic),<BR />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@enumToInt(stl.Style.notstyle),<BR />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@enumToInt(stl.Style.notstyle)},<BR />
&nbsp;&nbsp;&nbsp;.backgr = stl.BackgroundColor.bgBlack,<BR />
&nbsp;&nbsp;&nbsp;.backBright = false,<BR />
&nbsp;&nbsp;&nbsp;.foregr = stl.ForegroundColor.fgGreen,<BR />
&nbsp;&nbsp;&nbsp;.foreBright = true<BR />
};


<u>-------Current treatments------------------------------------</u><BR />
&rarr;&nbsp; forms.zig<BR />
&rarr;&nbsp; box / panel <BR />

<u>-------TESTING------------------------------------</u><BR />
&rarr;&nbsp; *Use the gtk Term.c terminal, it's much simpler than xterm or other terminals* <BR />
&rarr;&nbsp; cursed  Tcursed.zig<BR />
&rarr;&nbsp; label forms.zig      code.zig<BR />

<u>-------To write and think--------------------------------</u><BR />
&rarr;&nbsp; inspiration<BR />
* [nim-termcurs](https://github.com/AS400JPLPC)<br />
&rarr;&nbsp; panel.zig<BR />
&rarr;&nbsp; label.zig<BR />
&rarr;&nbsp; field.zig<BR />
&rarr;&nbsp; menu.zig<BR />
&rarr;&nbsp; grid.zig<BR />
&rarr;&nbsp; button.zig<BR />

<u>---------------------------------------------------------</u><BR />
 <BR />
 <BR />
 <BR />
 <BR />
a little more<BR />

.vscode  contains some tricks and simplification.<BR />

makefile to generate a terminal with GTK LIBVTE in C  <BR />