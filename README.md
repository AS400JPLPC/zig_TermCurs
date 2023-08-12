# zig_TermCurs

terminal access function <br />
<u>**zig 0.11.0**</u><BR />
<br />

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
Thank you
Resumption of the project https://github.com/xyaman/mibu
a little more : XYAMAN
<BR />
Thank you
https://zig.news/<BR />
https://zig.news/lhp/want-to-create-a-tui-application-the-basics-of-uncooked-terminal-io-17gm<BR />
https://zig.news/david_vanderson<BR /> thank you for your valuable explanations   David Vanderson <BR />
https://zig.news/xq/zig-build-explained-part-3-1ima <BR /> Structure the complex build<BR />
https://www.openmymind.net/Regular-Expressions-in-Zig/<BR /> inspiration<BR />
<br />

![](assets/20230605_135950_Exemple.png)
<br />

**In the example, some errors are introduced such as the mail, all of this is voluntary and allows you to see the default interaction of the input control.<br />**
<br />
<br />


![](assets/20230213_012619_mdlPanel.png)


<br />
---

<BR/><BR/>

| Field                | Regex        | Text     | Type                                        |
| -------------------- | ------------ | -------- | ------------------------------------------- |
| TEXT_FREE            | Y            | Y        | Free                                        |
| TEXT_FULL            | Y            | Y        | Letter Digit Char-special                   |
| ALPHA                | Y            | Y        | Letter                                      |
| ALPHA_UPPER          | Y            | Y        | Letter                                      |
| ALPHA_NUMERIC        | Y            | Y        | Letter Digit espace -                       |
| ALPHA_NUMERICT_UPPER | Y            | Y        | Letter Digit espace -                       |
| PASSWORD             | N            | Y        | Letter Digit and normaliz char-special      |
| YES_NO               | N            | Y        | 'y' or 'Y' / 'o' or 'O'                     |
| UDIGIT               | N            | Y        | Digit unsigned                              |
| DIGIT                | N            | Y        | Digit signed                                |
| UDECIMAL             | N            | Y        | Decimal unsigned                            |
| DECIMAL              | N            | Y        | Decimal signed                              |
| DATE_ISO             | DEFAULT      | Y        | YYYY/MM/DD                                  |
| DATE_FR              | DEFAULT      | Y        | DD/MM/YYYY                                  |
| DATE_US              | DEFAULT      | Y        | MM/DD/YYYY                                  |
| TELEPHONE            | Y OR DEFAULT | Y        | +(033) 6 00 01 00 02                        |
| MAIL_ISO             | DEFAULT      | Y        | normalize mail regex                        |
| SWITCH               | N            | N / BOOL | CTRUE CFALSE                                |
| FUNC                 | N            | y        | **dynamic function call**             |
| TASK                 | N            | y        | **dynamic function call ex: control** |
|                      |              |          |                                             |

<BR/>
MOUSE<BR/>

| Type      | up | down | left | Middle | right | X/Y |
| --------- | -- | ---- | ---- | ------ | ----- | --- |
| Menu      | Y  | Y    | Y    | Y      | Y     | N   |
| GRID      | Y  | Y    | Y    | Y      | Y     | N   |
| FIELD     | Y  | Y    | Y    | Y      | Y     | N   |
| getKEY    | Y  | Y    | Y    | Y      | Y     | Y   |
| <BR/> |    |      |      |        |       |     |

<BR/>
FIELD<BR/>

| KEY       | text                                      |
| --------- | ----------------------------------------- |
| MOUSE     | mouse array reference                     |
| escape    | Restores the original area                |
| ctrl-H    | Show help                                 |
| home      | Position at start of area                 |
| end       | Position at end   of area                 |
| right     | Position + 1 of area                      |
| tab       | Position + 1 of area                      |
| left      | Position - 1 of area                      |
| shift tab | Position - 1 of area                      |
| bacspace  | Position -1 of area and delete char       |
| bacspace  | Position  of area and delete char         |
| insert    | Position  of area   change cursor         |
| enter     | Control valide update origine next field  |
| up        | Control valide update origine prior field |
| down      | Control valide update origine next field  |
| char      | Treatment of the character of the area    |
| func      | dynamic function call                     |
| task      | dynamic function call for controle etc... |

<BR/>

GRID<BR/>

| KEY       | text                                      |
| --------- | ----------------------------------------- |
| MOUSE     | active                                    |
| escape    | return key                                |
| F12       | return key                                |
| enter     | return ligne                              |
| up        | prior  ligne                              |
| down      | next   ligne                              |
| pageUp    | prior  page                               |
| pageDown  | next   page                               |

<BR/>

COMBO<BR/>

| KEY       | text                                      |
| --------- | ----------------------------------------- |
| CellPos   | Position start display                    |
| MOUSE     | active                                    |
| escape    | return key                                |
| enter     | return field                              |
| up        | prior  ligne                              |
| down      | next   ligne                              |
| pageUp    | prior  page                               |
| pageDown  | next   page                               |
<BR/>


<BR/><BR/>
<u>---.VSCODE-------------------------------------------</u><BR />
&rarr;&nbsp; New methodology for clear compile.sh <br />
&rarr;&nbsp; New tasck.json  use: Task Manager <br />
<br />

<u>---Organization-project------------------------------------------</u><BR />
&rarr;&nbsp; folder deps: Filing of files zig including reference sources <br />
&rarr;&nbsp; folder src_c:    C/C++     source files <br />
&rarr;&nbsp; folder src_zig:  ZIG-lang  source files <br />
&rarr;&nbsp; folder lib:      src xx.H  source files regex.h<br />
&rarr;&nbsp; build: build+source-name ex: buildexemple <br />
&rarr;&nbsp; makefile <br />
<br />


<u>--peculiarity-------------------------------------------------</u><BR />
test alt-ctrl ctrshift... etc for <br />
there is a possibility to recover all the keys if we pass through GTK and use sys/shm.h.

But it is no longer transportable.
another way is to use IOCTL but again, there is a good chance of being forced to use root.

Anyway, to make management applications or Terminal type tools are more than enough.

ctrl or alt combinations plus Fn(1..24) TAB Backspace home end insert delete pageup pagedown enter escape alt ctrl left rigth up down altgr mouse
and the utf8 keyboard is a lot.<br />

<u>--styling-------------------------------------------------</u><BR />
make it compatible as close as possible to IBM 400 ex:<br />
<br />
pub const AtrLabel : stl.ZONATRB = .{<br />
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
&rarr;&nbsp; fram / panel / label /button / Menu / Grid / Combo / **dynamic function call** OK <br />
&rarr;&nbsp; Preparation of "Field" processing as well as keyboard input.

Please wait, if there are bugs everything is not fixed.<br />

<u>-------TESTING------------------------------------</u><BR />
&rarr;&nbsp; *Use the gtk Term.c terminal, it's much simpler than xterm or other terminals* <br />
&rarr;&nbsp; forms.zig   Exemple --->  exemple.zig <br />
<u>-------To write and think--------------------------------</u><BR />
&rarr;&nbsp; inspiration `<br />`

* [nim-termcurs](https://github.com/AS400JPLPC)<br />
  &rarr;&nbsp; panel.zig  <br />
  &rarr;&nbsp; label.zig  <br />
  &rarr;&nbsp; field.zig  <br />
  &rarr;&nbsp; menu.zig   <br />
  &rarr;&nbsp; grid.zig   <br />
  &rarr;&nbsp; button.zig <br />

<u>---------------------------------------------------------</u><BR />
<br />
<br />
<br />
<br />



<u>2023-02-26 correction code for (xxx.item) |l,i| new code ---> var idx: suize = 0 for (...) |l| { ... idx += 1;}<br />
<br />
<u>2023-05-22 correction code regex processing change no external software, only the libc with the regex.huse match<br />
<br />
<br />
<br />
|   for information|
→  2023-02-28<br />
Hello, it is now possible to use a terminal without leaving a trace, I added in "curse" the "reset" function,
on the other hand, i included in the cls function the underlying cleanup of the terminal, i put here the terminal start function for, you help ( xfce4-terminal --hide-menubar --hide-scrollbar --hide -toolbar --geometry="158x42" --font="DejaVu Sans Mono 12") just add -e ./...program <br />
→  2023-02-28<br />
**Applications no longer need lib-GTK VTE**
in general to debug well, to use the console, it is advisable to deactivate preferences F10 and ALT... ,
then compile with SMALL and to ensure violation of ALT-F4 use the cpp program gtk-vte an example is there.
But in terminal mode the application is viable (to do with the commit data-base)<br />
<u>I wish the friend google translate my french slang correctly </u>


les news:<BR />

→  2023-02-05 Doc version 0.10.1  
[READ-DOCS](http://htmlpreview.github.io/?https://github.com/AS400JPLPC/zig_TermCurs/blob/master/docs_Gencurs/index.html) <br />
<BR/>

<BR/>

<br />
→  2023-05-22  changed regex processing, discontinued use of GO, and introduced regex.zig (https://github.com/tiehuis/zig-regex) <br />
<br />
→  2023-05-22  <s>add function match (match.zig) updating controls in forms with regex</s><br />
→  2023-05-22  **add function isMatch regex.h libc  updating controls in forms with regex**<br />
→  2023-05-22  controls conform standard <br />
→  2023-05-22  ex: https://stackoverflow.com/questions/201323/how-can-i-validate-an-email-address-using-a-regular-expression<br />
→  2023-05-22  chapitre RFC 6532 updates 5322 to allow and include full, clean UTF-8.<br />
<br />


<BR/>
-  2023-06-19  Tuning and learning, memory management MODULE <br />
<BR/>
<BR/>
-  2023-06-20  Tuning  memory OK, I will be able to progress in the project <br />
<BR/>

<BR/>
-  2023-06-22  memory management validation <br />
-  2023-06-22  Simplification of registration of a grid and management of several grids <br />
-  2023-06-22  Enabling TTY output<br />
<BR/>

<BR/>
-  2023-08-1  I am preparing for the version change in order to take advantage of advancements and modify the code if necessary.
My experience, you have to review the "FOR" loop the "ENUM" and "BUILD" functions what I did<br />
<BR/>
-  2023-08-1  Studies of memory cleaning and various functions   0.11<br />
-  2023-08-1  Add func Grid  ioGridKey  (parm,parm, button KEY return) for management grid to grid ex: modlObjet fn Order <br />
<br />
-  2023-08-1  <u>Adjustment for 0.11 test  A lot of changes since version 0.10.1 </u> <br />
<br />
-  2023-08-1  look at the build has changed a lot. <br />
-  2023-08-1  Gencurs modlPanel OK <br />
-  2023-08-1  Gencurs modlObjet testing "label define  - order remove" OK <br />
-  2023-08-1  modlObjet alt-T Title alt-L Label  alt-w Menu(order/remove) <br />
-  2023-08-1  modlObjet ESC abord ctrl-V valide   F10 write all Objet for Panel ... F12 abord and return <br />
<br />
<br />
-  2023-08-1  Changing and reorganizing the code:<br />
-             new "grid.zig"<br />
-             the "forms.zig" no longer includes grid management<br />
-             I reviewed the initialization of the panel and grid<br />
-             with create mode to better manage memory and make memory allocation more consistent<br />
-             [ziggit](https://ziggit.dev/t/philosophical-question-about-memory/1343)<br />
-             testing memoory<br />
-             [zulipchat](https://zig-lang.zulipchat.com/#narrow/stream/346105-FR-General/topic/.E2.9C.94.20Debeuger)<br />  
<br />
<br />  
-  2023-08-4 Watch the build version zig 0.11.0 new formula to generate documentation<br />
<br />
-  2023-08-09 small update project due to version change<br />
-  2023-08-09 modlObjet alt-F start of field processing <br />
-  2023-08-09 Json studies to encapsulate the generation (IN/OUT) <br />




