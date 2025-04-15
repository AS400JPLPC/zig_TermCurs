# zig_TermCurs

terminal access function <br />
<u>**zig 0.14.0**</u><BR />
<br />

**Major library restructuring:**
remove library
Libtui (curse, log, calling, crypt, mmap,regex)
Libznd (decimal,field,date)
libsql currently only includes sqlite, postgresql to follow

All builds have been changed accordingly 

The aim is to make projects independent






**TESTING** <br />
*look at the bottom of the testing page* <br />

**os linux** <br />
<u>Normally should work POSIX </u><br />
<br />
**the termcurs library, does what ncurse does (hopefully).<br />
it manages the interface between the terminal and the user.<br />
as does the 5250 of the OS400 with PC sauce.<br />
Panel, window, field, grid, menu etc.<br />
this can be used with a terminal with some editing eg: F10 etc. for convenience.<br />
the easiest way is to make your own terminal with libvte of which I provide an example in the src-c folder.<br />
this produces very lightweight programs for doing utilities or intensive typing for business management.<br />
Currently everything is not operational and the goal is to make a screen generator to simplify development, considering that this is only secondary and that the heart of the problem is the program itself and not the interface.<br />**
<br />
** I use the gencurs program to thoroughly test the termcurs lib.<br />**
<br />
<BR />
Thank you<br/>
a little more : XYAMAN
Resumption of the project https://github.com/xyaman/mibu<BR />

Thank you<BR />
https://zig.news/<BR />
https://zig.news/lhp/want-to-create-a-tui-application-the-basics-of-uncooked-terminal-io-17gm<BR /><BR />
thank you for your valuable explanations   David Vanderson<br />
https://zig.news/david_vanderson<br /> <br />
Structure the complex build
https://zig.news/xq/zig-build-explained-part-3-1ima <BR /><br />

thank you for your valuable explanations  Sam Atman 
https://github.com/mnemnion/mvzr/<BR /> <br />


extra..., to follow and have a history
https://github.com/kissy24/zig-logger/<BR /> <br />
<br />

![](assets/20230605_135950_Exemple.png)
<br />

**In the example, some errors are introduced such as the mail, all of this is voluntary and allows you to see the default interaction of the input control.<br />**
<br />

![](assets/20230213_012619_mdlPanel.png)

<br />

<br />

![](assets/20230812_012345_Field.png)

---

<BR/><BR/>


| Field                | Regex        | Text     | Type                                   |
| -------------------- | ------------ | -------- | -------------------------------------- |
| TEXT_FREE            | Y            | Y        | Free                                   |
| TEXT_FULL            | Y            | Y        | Letter Digit Char-special              |
| ALPHA                | Y            | Y        | Letter                                 |
| ALPHA_UPPER          | Y            | Y        | Letter                                 |
| ALPHA_NUMERIC        | Y            | Y        | Letter Digit espace -                  |
| ALPHA_NUMERICT_UPPER | Y            | Y        | Letter Digit espace -                  |
| PASSWORD             | N            | Y        | Letter Digit and normaliz char-special |
| YES_NO               | N            | Y        | 'y' or 'Y' / 'o' or 'O'                |
| UDIGIT               | N            | Y        | Digit unsigned                         |
| DIGIT                | N            | Y        | Digit signed                           |
| UDECIMAL             | N            | Y        | Decimal unsigned                       |
| DECIMAL              | N            | Y        | Decimal signed                         |
| DATE_ISO             | DEFAULT      | Y        | YYYY/MM/DD                             |
| DATE_FR              | DEFAULT      | Y        | DD/MM/YYYY                             |
| DATE_US              | DEFAULT      | Y        | MM/DD/YYYY                             |
| TELEPHONE            | Y OR DEFAULT | Y        | +(033) 6 00 01 00 02                   |
| MAIL_ISO             | DEFAULT      | Y        | normalize mail regex                   |
| SWITCH               | N            | N / BOOL | CTRUE CFALSE                           |
| FUNC                 | N            | y        | **dynamic function call**              |
| TASK                 | N            | y        | **dynamic function call ex: control**  |
| CALL                 | N            | y        | **dynamic call exter                   |
|                      |              |          |                                        |


<BR/>
MOUSE<BR/>


| Type   | up | down | left | Middle | right | X/Y |
| -------- | ---- | ------ | ------ | -------- | ------- | ----- |
| Menu   | Y  | Y    | Y    | Y      | Y     | N   |
| GRID   | Y  | Y    | Y    | Y      | Y     | N   |
| FIELD  | Y  | Y    | Y    | Y      | Y     | N   |
| getKEY | Y  | Y    | Y    | Y      | Y     | Y   |
| <BR/>  |    |      |      |        |       |     |

<BR/>
FIELD<BR/>




| KEY       | text                                           |
| ----------- | ---------------------------------------------|
| MOUSE     | mouse array reference                          |
| escape    | Restores the original area                     |
| ctrl-H    | Show help                                      |
| ctrl-P    | exec program extern                            |
| home      | Position at start of area                      |
| end       | Position at end   of area                      |
| right     | Position + 1 of area                           |
| tab       | Position + 1 of area                           |
| left      | Position - 1 of area                           |
| shift tab | Position - 1 of area                           |
| bacspace  | Position  of area and delete char              |
| insert    | Position  of area   change cursor              |
| enter     | Control valide update origine next field       |
| up        | Control valide update origine prior field      |
| down      | Control valide update origine next field       |
| char      | Treatment of the character of the area         |
| func      | Interactive function linked to the input area. |
| task      | Task executed after input in the zone.         |
| call      | Interactive function exec program extern       |

<BR/>

GRID<BR/>


| KEY      | text         |
| ---------- | -------------- |
| MOUSE    | active       |
| escape   | return key   |
| F12      | return key   |
| enter    | return ligne |
| up       | prior  ligne |
| down     | next   ligne |
| pageUp   | prior  page  |
| pageDown | next   page  |
| return   | Arg          |

<BR/>

COMBO<BR/>


| KEY      | text                   |
| ---------- | ------------------------ |
| CellPos  | Position start display |
| MOUSE    | active                 |
| escape   | return key             |
| enter    | return field           |
| up       | prior  ligne           |
| down     | next   ligne           |
| pageUp   | prior  page            |
| pageDown | next   page            |
| <BR/>    |                        |

<BR/><BR/>


<u>---Organization-project------------------------------------------</u><BR />
&rarr;&nbsp; folder deps: Filing of files zig including reference sources <br />
&rarr;&nbsp; folder libtui:   zig       source files <br />
&rarr;&nbsp; folder libznd:   zig       source files <br />
&rarr;&nbsp; folder libsql:   zig       source files <br />
&rarr;&nbsp; folder src_c:    C/C++     source files <br />
&rarr;&nbsp; folder src_zig:  ZIG-lang  source files <br />
&rarr;&nbsp; build: build+source-name ex: buildexemple <br />
&rarr;&nbsp; makefile <br />
<br /> <br />
**LIBRARY**

![](assets/20240815_012345_library.png)


<br /><br />
<u>--peculiarity-------------------------------------------------</u><BR />
test alt-ctrl ctrshift... etc for <br />

But it is no longer transportable.
another way is to use IOCTL but again, there is a good chance of being forced to use root.

Anyway, to make management applications or Terminal type tools are more than enough.

ctrl or alt combinations plus Fn(1..36) TAB Backspace home end insert delete pageup pagedown enter escape alt ctrl left rigth up down altgr mouse
and the utf8 keyboard is a lot.<br />

<u>--styling-------------------------------------------------</u><BR />
make it compatible as close as possible to IBM 400 ex:<br />
<br />
ex: pub const AtrLabel : stl.ZONATRB = .{<br />
&nbsp;&nbsp;&nbsp;.styled=[_]i32{@enumToInt(stl.Style.styleBright),<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@enumToInt(stl.Style.styleItalic),<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@enumToInt(stl.Style.notstyle),<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@enumToInt(stl.Style.notstyle)},<br />
&nbsp;&nbsp;&nbsp;.backgr = stl.BackgroundColor.bgBlack,<br />
&nbsp;&nbsp;&nbsp;.backBright = false,<br />
&nbsp;&nbsp;&nbsp;.foregr = stl.ForegroundColor.fgGreen,<br />
&nbsp;&nbsp;&nbsp;.foreBright = true <br />
};

<u>-------Current treatments------------------------------------</u><BR />
&rarr;&nbsp; forms.zig <br />
&rarr;&nbsp; fram / panel / label /button / Menu / Grid / Combo / dynamic function Exec ** OK <br />
&rarr;&nbsp; Preparation of "Field" processing as well as keyboard input.

Please wait, if there are bugs everything is not fixed.<br />

<u>-------TESTING------------------------------------</u><BR />
&rarr;&nbsp; *Use the gtk Term.c terminal, it's much simpler terminals  ex: exf4-terminal* <br />
<u>-------To write and think--------------------------------</u><BR />
&rarr;&nbsp; inspiration `<br />`

* [nim-termcurs](https://github.com/AS400JPLPC)<br />

<u>---------------------------------------------------------</u><BR />
<br />
|   for information|
→  2023-02-28<br />
Hello, it is now possible to use a terminal without leaving a trace, I added in "curse" the "reset" function,
on the other hand, i included in the cls function the underlying cleanup of the terminal, i put here the terminal start function for, you help ( xfce4-terminal --hide-menubar --hide-scrollbar --hide -toolbar --geometry="158x42" --font="DejaVu Sans Mono 12" just add -e ./...program <br />
→  2023-02-28<br />
**Applications no longer need lib-GTK VTE**
in general to debug well, to use the console, it is advisable to deactivate preferences F10 and ALT... ,
then compile with SMALL and to ensure violation of ALT-F4 use the cpp program gtk-vte an example is there.
But in terminal mode the application is viable (to do with the commit data-base)<br />
<br />
→  2023-02-05 Doc version 0.11.1 "view use TermCurs"
[READ-DOCS](http://htmlpreview.github.io/?https://github.com/AS400JPLPC/zig_TermCurs/blob/master/Docs_Exemples/index.html) <br />
<BR/>


![](assets/20231129_012345_Gen00.png)

<br />

![](assets/20231122_012345_Gen01.png)
<BR />
<BR />
les news:<BR />
<br />
→  2024-01-04<br />
LINUX<br />
Should it work with MAC?<br />
TRADUCTOR chatgpt<br />
Hello, there are very significant changes, why?<br />
Firstly, for better memory management.<br />
Greater coherence.<br />
All modules have their own allocators.<br />
Avoiding back-and-forth between modules.<br />
<br />
<br />
"CURSED" (named in memory of "NCURSEW"):<br />
Encompasses everything needed for writing to a terminal, including reading keyboard codes, mouse management, cursor handling, UTF8 work. I may introduce the "termios" concept for META codes. I took advantage of the restructuring to bring clarification.<br />
<br />
"FORMS":<br />
Includes management for:<br />
LABEL - BUTTON - LINEV - LINEH - FIELD - FRAME - PANEL<br />
Works with a matrix corresponding to the terminal surface so that the window can be restored. The FORMS allocator is designed for Fields and panel initialization. FORMS no longer includes GRID management, which is autonomous, nor MENU, which is autonomous<br />
<br />
"GRID":<br />
Functions similarly to forms, allowing the display and retrieval of arguments either from a database or working as a combo. It is autonomous, but you must consider that it should be included in your Panel, as it positions itself within the terminal window.<br />
<br />
"MENU":<br />
Operates like GRID but is much simplified; the returned argument is usize.which doesn't work with the matrix but directly with the terminal.<br />
<br />
"UTILS": (various tools and functions)<br />
Contains various functions to manage the control needs of FIELD or STRING management ([] u8 const).<br />
<br />
The Example program demonstrates how to manage and use these functions. A tip: the first Panel can serve as the definition of the terminal window.<br />
<br />
"MATCH": (regex MVZR pur zig)<br />
<br />
"LOGGER": <br />
Allows for a written record of variables or waypoints.<br />
<br />
"CALLPGM": Executes in Zig mode, manages the call and the wait.<br />
<br />

→  PANEL<BR/>
Adding the 'mdlPanel' function.<br />
- F2   : view panel<BR/>
- F6   : Choix panel for update<BR/>
- F9   : Create Panel<BR/>
- F11  : Update Panel<BR/>
- F12  : return<BR/>


→  FORMS<BR/>
Adding the 'mdlForms' function.<br />
- F1   : help<BR/>
- F11  : update and return<BR/>
- F12  : return<BR/>
- Alt-T: Create Title<BR/>
- Alt-L: Create Label<BR/>
- Alt-F: Create Field<BR/>
- Alt-G: View Grid<BR/>
- Alt-U: Update Field<BR/>
- Alt-H: Creat Line Horizontal<BR/>
- Alt-V: Creat Line Vertical<BR/>
- Alt-W: Tools menu (View ,  Order , Remove )<br />

→  GRID<BR/>
Adding the 'mdlGrid' function.<br />
- F1   : help<BR/>
- F11  : update and return<BR/>
- F12  : return<BR/>
- Alt-G: Create GRID definition<BR/>
- Alt-C: Create text columns<BR/>
- Alt-R: Remove GRID<BR/>
- Alt-W: Tools menu (View GRID, View Cell, Order Cell, Remove Cell, Update Grid)<br />


→  MENU<BR/>
Added MENU definition function
you have to understand the menu option as a fixed combo with constant values <br />
- F1   : help<BR/>
- F11  : update and return<BR/>
- F12  : return<BR/>
- Alt-M: Create MENU definition<BR/>
- Alt-C: Create / UPDATE  text columns<BR/> 
- Alt-V: View MENU<br />
- Alt-D: Remove MENU<br />
- Alt-H: display higth MENU<BR>
- Alt-L: display low MENU<BR>
- Alt-X: Fixed display work menu<br />
- Alt-R: Fefresh terminal<br />



→  Gensrc<BR/>
Added Gensrc definition Programme<br />
- Folder       : choix du model <BR/>
- Control    : list control <BR/>
- List       : List of the DSPF nomencalature <BR/>
- Link-Combo : combo assignment    CtrlV validation <BR/>
- SrcMenu    : output srs-lst <BR/>
- SrcForms   : output srs-lst <BR/>
- Clear *all : Cleaning arraylist buffers<BR/> 
- Exit       : Exit <BR/>

<BR/>
<BR/>
<BR/>
<BR/>

→ 2024-11-20 15:40<BR/>
-  update library CURSED  -> Modification of keyboard key retrieval for a terminal in a more functional way. <BR/>
-  update module MDLFILE  -> Improved sorting algorithm integrated, with the ability to add a file attribute.<BR/>
-  I am currently testing source code generation, and sometimes I question my code, particularly the way I approach the matrix.<BR/>
<BR/>

→ 2024-11-23 15:40<BR/>
-  update MOUSE  -> click Left Middle = none click Right Enter for MENU and GRID <BR/>
-  new module    -> Gensrc SrcMenu SrcForms générate source main<BR/>
-  I am currently testing source code generation, and sometimes I question my code, particularly the way I approach the matrix.<BR/>
-  update ENV-WORK<BR/>
-  update MenuDEV.sh new MenuTEST.sh<br/>
-  First test Gensrc - srcforms - srcMenu <BR/>
-  folder OUT-ZIG to test <BR/>
-  use for test only folder(repertoire) 
<BR/><BR/>
→ 2024-11-26 20:28<BR/>
Please refer to the files in the directory: dspf/repertoire/.<BR/>
You will notice that function keys are assigned, such as F9 for adding a record and F11 for updating a record; these are standard industrial practices recommended in management.<BR/>
You can compare the output source with the SRC program.<BR/>
<BR/><BR/><BR/>
→ 2024-12:18 00:00<BR/>

"I have refactored all the sources to make them compatible with Zig's LSP and code editors: all indentation tabs are spaces '....' and not '→'.
At the moment, I just finished testing the decimal function, and I now need to test the zstring function to ensure everything complies with industrial SQL database standards, such as varchar(10) or decimal(5,2).
For decimal, see my Git repository Zdecimal; the number of digits goes far beyond the limitations of C or Zig."

<BR/>
→ 2024-12-19 04:20<BR/>
add ztring 
<BR/>
→ 2024-12-21 04:20<BR/>
  harmonization of functions between ZSTRING AND DECIMAL, in order to have a simplification in programming<br>
<BR/>
→ 2025-01-05 02:52<BR/>
    Fixed bug for range detected zig 0.14.0-dev.2598 from "mdlforms" / "mdlgrids".<BR/>
    err: for (vgrd.items[gridNum].pageRows)...<BR/>
    ex: for (0..vgrd.items[gridNum].pageRows)...><BR/>
<BR/>
→ 2025-01-05 18:31 update Terminal.7z clear cache <BR/>
<BR/>
→ 2025-01-16 10:32 <BR/>
</BR>
<BR/>
→ 2025-03-12 02:52   update 0.14.0<BR/>
</BR>
→ 2025-03-12 06:40   unicode.Decode deprecated change Utf8View <BR/>
</BR>
→ 2025-04-15 11:00   add function update Grid<BR/>
→ 2025-04-15 11:00   standardization of color functions<BR/>
→ 2025-04-15 11:00   Correction of a position cursor bug with the mouse<BR/>
→ 2025-04-15 11:00   new “isfile” test with “access”.<BR/>
</BR>
</BR>
</BR>
</BR>
</BR>
**big bug input  change module utils of libtui**<BR/>
Anyway, it's all fixed now.<BR/>
</BR>
I've been chasing memory leaks too much
Hello, sorry for the bug in the zone entry, I tried to run after the leaks euuhh a big slap.<BR/>

I worked on the dates and that led me to restructure all the libraries for a smoother future.<BR/>
I retested and only compiled.<BR/>
LIBTUI: includes everything related to the terminal and its execution.<BR/>
LIBZND: processing -> Decimal, Zfield, Date-time.<BR/>
LIBSQL: in preparation now that I've finished DATE-TIME<BR/>

I'm going to work on open date space so that FIELDs are easy to access.<BR/>

the source generator isn't finished, I'd like to process the GRIDs, that's why I'm on sql....<BR/>
<BR/>
<BR/>
<BR/>
<BR/>
<BR/>
I recommend using the GENSRC program (C/C++) that emulates a clean terminal and allows for debugging.<BR/>
You can see the source generation of formsrc and formtest, which has been reworked.<BR/>
<BR/>
Keep in mind that the generation is a skeleton; I am trying to reduce the repetitive overhead of programming so we can focus on the requested functionality.<BR/>
I haven't finished yet; I still need to make changes, for example, the GRID SFLD, which is a grid with data, etc.<BR/>
<BR/>
<BR/>

------------------------------------------------------------------<br />

Now that the entire designer allows for saving and restoring the code, this has allowed me to test my functions, and especially to take a little tour of the Zig language. I opted for working and writing with maximum use of the Zig language, so I don't use addressing or hex code; everything is in Zig.<br /> <br />

PAUSE<br /> <br />

In the current state, one could very well use JSON files and encapsulate them in the program, and why not make the forms in the project dynamic... I did this on the AS400.<br />
