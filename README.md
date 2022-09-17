# zig_Termkey
terminal access basic function


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

in development Source is not available available <BR />

<u>---peculiarity-------------------------------------------</u><BR />
test alt-ctrl ctrshift... etc for <BR />  
there is a possibility to recover all the keys if we pass through GTK and use sys/shm.h.  
  

But it is no longer transportable.
another way is to use IOCTL but again, there is a good chance of being forced to use root.

Anyway, to make management applications or Terminal type tools are more than enough.

ctrl or alt combinations plus Fn(1..24) TAB Backspace home end insert delete pageup pagedown enter escape altgr
and the utf8 keyboard is a lot.<BR />
<u>---------------------------------------------------------</u><BR />  
 <BR />
 <BR />
 <BR />
 <BR />
a little more<BR />  

.vscode  contains some tricks and simplification.<BR />

makefile to generate a terminal with GTK LIBVTE in C  <BR />