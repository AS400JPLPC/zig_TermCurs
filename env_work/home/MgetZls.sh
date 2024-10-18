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

cd $HOME

f_dsplyCentrer 1  $fcJaune '> '
~/.zls/zls --version

f_offColor



if test -d ~/.zls ; then
	if test -d ~/.zlssav ; then
		f_dsply 'déjà une version  build active  courveuilez faire Enter'
		f_read
		exit
	else
		mv $HOME/.zls  $HOME/.zlssav
	fi
fi


if test -d ~/.cache/zig/ ; then
		rm -rf ~/.cache/zig/
	fi

git clone https://github.com/zigtools/zls

cd $HOME/zls

$HOME/.zig/zig build -Doptimize=ReleaseSafe

mkdir $HOME/.zls

mv  $HOME/zls/zig-out/bin/zls $HOME/.zls/zls

if test -d ~/zls ; then
		rm -rf ~/zls
	fi
if test -d ~/.cache/zig/ ; then
		rm -rf ~/.cache/zig/
	fi


f_dsplyCentrer 22  $fcVert '> '
~/.zls/zls --version

f_offColor
f_dsply 'veuilez faire Enter'
  
f_read

exit
