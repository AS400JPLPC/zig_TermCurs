#!/bin/bash


fdNoir='\033[40m'
fdRouge='\033[41m'
fdVert='\033[42m'
fdJaune='\033[43;1m'
fcOrange='\033[43m'
fdBleu='\033[44m'
fdRose='\033[45m'
fdCyan='\033[46m'
fdGris='\033[47m'
fdBlanc='\033[47;1m'


fcNoir='\033[30m'
fcRouge='\033[31m'
fcVert='\033[32m'
fcJaune='\033[33;1m'
fcOrange='\033[33m'
fcBleu='\033[1;34m'
fcRose='\033[35m'
fcCyan='\033[36m'
fcGris='\033[37m'
fcBlanc='\033[37;1m'

faGras='\033[1m'
faBarrer='\033[9m'
faSouligner='\033[4m'
faClignotant='\033[5m'
faStabilo='\033[7m'	# read préférez lui couleur fond & face
faCache='\033[8m'


f_dsply(){
	echo -en '\033[0;0m'
	echo  -e $1
	echo -en '\033[0;0m'
}


f_read() {
	echo -en '\033[0;0m'
	echo -en $fdBlanc$fcNoir
	read
	echo -en '\033[0;0m'
}

f_offColor() { #off couleur
	echo  -en '\033[0;0m'
}


f_dsplyCentrer(){ #commande de positionnement	lines + couleur + text
	echo -en '\033[0;0m'
	let lig=$1
	let col=1
	echo -en '\033['$lig';'$col'f'$2$3

}

f_dsplyCentrer 1  $fcJaune '> '
~/.zig/zig version

if test -d ~/.zig ; then
	if test -d ~/.zigsav ; then
		f_dsply 'déjà une version  build active  courveuilez faire Enter'
		f_read
		exit
	else
		mv ~/.zig  ~/.zigsav
	fi
fi

f_offColor

rm -r $HOME/.cache/zig
rm -r $HOME/.zig

wget https://zigbin.io/master/x86_64-linux.tar.xz
tar -xf x86_64-linux.tar.xz
mv zig-linux-x86_64* $HOME/.zig
rm x86_64-linux*




f_dsplyCentrer 22  $fcVert '> '
~/.zig/zig version

f_offColor
f_dsply 'veuilez faire Enter'
  
f_read

exit