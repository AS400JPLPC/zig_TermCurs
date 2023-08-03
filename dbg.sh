#!/bin/sh
# standard 1980/1080
#xfce4-terminal --hide-menubar --hide-scrollbar --hide-toolbar    --geometry="158x42"  --font="DejaVu Sans Mono 12"

cd $1
# ecran 32" 3841x2610 
xfce4-terminal --hide-menubar --hide-scrollbar --hide-toolbar    --geometry="172x52"  --font="DejaVu Sans Mono 15"  --execute $2

exit 0