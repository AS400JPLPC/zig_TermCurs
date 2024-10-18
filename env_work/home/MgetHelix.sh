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
$HOME/.helix/hx --version

f_offColor

if test -d ~/.helix ; then
	if test -d ~/.helixsav ; then
		f_dsply 'déjà une version  build active  courveuilez faire Enter'
		f_read
		exit
	else
		mv ~/.helix  ~/.helixsav
	fi
fi

if test -d ~/.helix ; then
		rm -rf ~/.helix
	fi


if test -d ~/.cache/zig/ ; then
		rm -rf ~/.cache/zig/
	fi

if test -d ~/.cargo/ ; then
		rm -r ~/.cargo
	fi

mkdir $HOME/.helix

git clone https://github.com/helix-editor/helix
#git clone https://github.com/AS400JPLPC/helix
cd $HOME/helix

cp $HOME/.config/helix/default.rs  $HOME/helix/helix-term/src/keymap/default.rs

cargo install --path helix-term --locked


cp  $HOME/.cargo/bin/hx $HOME/.helix/hx
mv  $HOME/helix/contrib $HOME/.helix/
mv  $HOME/helix/runtime $HOME/.helix/



if test -d ~/.cargo/ ; then
		rm -r ~/.cargo
	fi
if test -d ~/helix/ ; then
		rm -rf ~/helix
	fi

f_dsplyCentrer 22  $fcVert '> '
$HOME/.helix/hx --version

f_offColor
f_dsply '\r\nveuilez faire Enter\n'
  
f_read

if  test -d ~/.helixsav  ; then
	rm -rf ~/.helixsav
fi

exit 0
