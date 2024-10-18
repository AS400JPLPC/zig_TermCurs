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



f_offColor() { #off couleur
	echo  -en '\033[0;0m'
}


f_dsplyCentrer(){ #commande de positionnement	lines + couleur + text
	echo -en '\033[0;0m'
	let lig=$1
	let col=1
	echo -en '\033['$lig';'$col'f'$2$3

}

f_pause(){
	echo -en '\033[0;0m'
 	echo -en $faStabilo$fcRouge'Press[Enter] key to continue\n'
	tput civis 	# curseur invisible
	read -s -n 1
	echo -en '\033[0;0m'
}

f_cls() {

reset > /dev/null
	echo -en '\033[1;1H'
	echo -en '\033]11;#000000\007'
	echo -en '\033]10;#FFFFFF\007'	 
}
cd $HOME


echo -en "Zig\n"
~/.zig/zig version

echo -en "Zls\n"
~/.zls/zls --version
f_pause
f_cls

f_dsplyCentrer 1  $fcJaune '> ZIG\n'
f_offColor
f_pause
~/MgetZig.sh
f_cls

f_dsplyCentrer 1  $fcJaune '> ZLS\n'
f_offColor
f_pause
~/MgetZls.sh
f_cls

if  test -f ~/.zig/zig  ; then
	if  test -f ~/.zls/zls  ; then
		rm -rf ~/.zigsav
		rm -rf ~/.zlssav
	fi
fi

exit
