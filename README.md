# zig_TermCurs

terminal access function<br />

**TESTING**<br />
*look at the bottom of the testing page*<br />

**os linux**
<u>Normally should work POSIX</u><br />

<u>---2023-01-04  **Very important modification of the project structure to generate the documentation**---</u><BR />

</u><br />

Resumption of the project https://github.com/xyaman/mibu

a little more : XYAMAN

Thank you
https://zig.news/<BR />
https://zig.news/lhp/want-to-create-a-tui-application-the-basics-of-uncooked-terminal-io-17gm<BR />

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
&rarr;&nbsp; 2022-09-26   After discussion on ZULIP it seems important to redesign the project that serves me as a ZIG learning and to simplify as much as possible the calls seen developer see Tcursed.zigdoc : [ZULIP](https://zig-lang.zulipchat.com/) <BR />

[READ-PROJECT](http://htmlpreview.github.io/?https://github.com/AS400JPLPC/zig_TermCurs/blob/master/Read_Projet.html)<BR />
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
&rarr;&nbsp; 2022-10-10   update getCursor <BR />
&rarr;&nbsp; 2022-10-10   ~~update gotoXY     "\x1b[{d};{d}f" not H~~<BR />
&rarr;&nbsp; 2022-10-10   creat Forms only test  **Only to test my build in Zig-lang it's not fully operational nor stable, double buffer process is not in place**<BR />

<BR /><BR />
&rarr;&nbsp; 2022-10-11   creat deps/curse/ utils iterator for [] const u8  Retrieval "const char" allows to know the number of characters<BR />
&rarr;&nbsp; 2022-10-11   Frame-border Panel Label are operational no double buffer <BR />
<BR /><BR />
&rarr;&nbsp; 2022-10-12   Frame-border Panel Label are **operational  double buffer** Opens the possibility of backup restore Panel 👍  😄 <BR/>
&rarr;&nbsp; 2022-10-12   Introduction of fn cls Panel <BR />
&rarr;&nbsp; 2022-10-12   double buffer: it is a matrix which is the decomposition  [ character + attribute + on/off] * (nbr line * column)<BR />
<BR /><BR />
&rarr;&nbsp; 2022-10-13   change hide/show  cursHide cursShow <BR />
&rarr;&nbsp; 2022-10-13   change printPanel  cursHide and open terminal<BR />
&rarr;&nbsp; 2022-10-13   ~~add getFunc F1..24 alt.. ctrl..~~ <BR />
&rarr;&nbsp; 2022-10-13   ~~add parsecsiFunc~~ <BR />
&rarr;&nbsp; 2022-10-13   the Hide/Show cursor is managed by getKey ~~getFunc ~~<BR />
&rarr;&nbsp; 2022-10-13   exemple :Panel show    code.zig <BR />
&rarr;&nbsp; 2022-10-13   use code.zig for test window and Term ex: cd folder ....  click ./term  <BR />
<BR /><BR />
&rarr;&nbsp; 2022-10-17   **Change the processing of getKEY: return struct {key, char}for button and input processing **<BR />
&rarr;&nbsp; 2022-10-17   extensive testing of labels panels frame restore panel cls panel<BR />
<BR /><BR />
&rarr;&nbsp; 2022-10-21   **There's still much to do. I'm progressing slowly Thank you for your patience**<BR />
&rarr;&nbsp; 2022-10-21   no global variable except system<BR />
&rarr;&nbsp; 2022-10-21   This programme **code.zig** my testing<BR />
&rarr;&nbsp; 2022-10-21   This programme** Exemple. zig** => *Exemple*<BR />
&rarr;&nbsp; 2022-10-21   update src_c/term.cpp<BR />
<BR /><BR />
&rarr;&nbsp; 2022-10-26   creat Menu -> forms.zig<BR />
&rarr;&nbsp; 2022-10-26   creat Lenw number word String -> utils.zig<BR />
&rarr;&nbsp; 2022-10-26   creat Trim String -> utils.zig<BR />
&rarr;&nbsp; 2022-10-26   Update Exemple add menu  <BR />
<BR /><BR />

&rarr;&nbsp; 2022-12-23   **General Overhaul**
<BR />
****Cursed taking into account Linux STDIN Handle****
****purge of the source and net improvement of the getkey function****
****cursed cleaning.** <BR />
<BR />
&rarr;&nbsp; 2022-12-23  update flushIO flushing stdin / output <BR />
&rarr;&nbsp; 2022-12-23  **grid creation** **Not all functions that need to be implemented are present**
<BR />
&rarr;&nbsp; 2022-12-23  Enrichment of "utils" tools
<BR />
&rarr;&nbsp; 2022-12-23  the grid is considered as a processing subfile:MultiArrayList
<BR />
&rarr;&nbsp; 2022-12-23  Exemple.zig show the progress
<BR />
&rarr;&nbsp; 2022-12-23  Grid row deletion enabled
<BR />
<BR />
&rarr;&nbsp; 2022-12-24  Add ioCombo see example <BR />
&rarr;&nbsp; 2022-12-24  Update different GRID setting<BR />
&rarr;&nbsp; 2022-12-24  GRID cursor fix<BR />
<BR />

BR />
→  2022-12-25  grid ioCombo fix scrool <BR />
→  2022-12-25  terminal assignment test<BR />
→  2022-12-26  Update cursed <BR />
→  2022-12-26  restore terminal fix<BR />
<BR />
→  2022-12-26  update printRows taking into account edtcar and alignment if digit ex: grd.setCellEditCar(&Cell.items[3],"€");<BR />
<BR />
→  2022-12-26  <u>FIX Solving problem TTY Correct TERMINAL access</u> <BR />
<BR />
→  2022-12-27  Color line grid fix<BR />

![](assets/20221227_135950_Exemple.png)<BR />
→  2023-01-02  Keyboard input preparation (FIELD) <BR />
→  2023-01-02  extend label/menu<BR />
→  2023-01-02  creat field<BR />
→  2023-01-02  Introduction catch and return errorForms<BR />

![](assets/20230102_235321_errorFormspng)<BR /><BR /> <BR />

→  2023-01-03  extend attribut ForegroundColor <BR />
→  2023-01-03  add updateLabel()   Matrix and label update<BR />

<u>---**Very important modification of the project structure to generate the documentation**---</u><BR />

→  2023-01-04  use zig 0.10.0 ... last dev.1183 zig tetsting DOCS
→  2023-01-04  Restructuring of the project to have the possibility of doing documentation with the zig build command.... <BR />
→  2023-01-05  update compil.sh<BR />
→  2023-01-05  update task.json<BR />
→  2023-01-05  update buildExemple.zig introduction docs<BR />
→  2023-01-05  update *all .zig* for @import<BR />
→  2023-01-05  document management<BR />
→  2023-01-05  update function for return errorForms <BR />
→  2023-01-05  Update compile.sh -> DOCS <BR />

[READ-DOCS](http://htmlpreview.github.io/?https://github.com/AS400JPLPC/zig_TermCurs/blob/master/docs_Exemple/index.html)<BR />

<u>---.VSCODE-------------------------------------------</u><BR />
&rarr;&nbsp; New methodology for clear compile.sh<BR />
&rarr;&nbsp; New tasck.json  use: Task Manager<BR />
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

ctrl or alt combinations plus Fn(1..24) TAB Backspace home end insert delete pageup pagedown enter escape altgr mouse
and the utf8 keyboard is a lot.<BR />

<u>--styling-------------------------------------------------</u><BR />
make it compatible as close as possible to IBM 400 ex:<BR />
<BR />
pub const AtrLabel : stl.ZONATRB = .{<BR />
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
&rarr;&nbsp; fram / panel / label /button / Menu / Grid OK <BR />
&rarr;&nbsp; Preparation of "Field" processing as well as keyboard input.

I'm looking to improve error trapping when changing values, and overall consistency.<BR />

<u>-------TESTING------------------------------------</u><BR />
&rarr;&nbsp; *Use the gtk Term.c terminal, it's much simpler than xterm or other terminals* <BR />
&rarr;&nbsp; forms.zig   Exemple --->  exemple.zig<BR />
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
