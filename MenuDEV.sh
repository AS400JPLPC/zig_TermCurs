#!/bin/bash
faStabilo='\033[7m'
fcRouge='\033[31m'
fcJaune='\033[33;1m'
fcCyan='\033[36m'
fcGreen='\033[32m'
fcBleu='\033[34m'
fcNoir='\033[0;0m'

faGras='\033[1m'

#=========================
# function  menu
#=========================

f_cls() {

reset > /dev/null
	echo -en '\033[1;1H'
	#echo -en '\033]11;#000000\007'
	#echo -en '\033]10;#FFFFFF\007'	 
}

f_pause(){
	echo -en '\033[0;0m'
 	echo -en $faStabilo$fcRouge'Press[Enter] key to continue'
	tput civis 	# curseur invisible
	read -s -n 1
	echo -en '\033[0;0m'
}

f_dsplyPos(){ #commande de positionnement	lines + coln + couleur + text
	echo -en '\033[0;0m'
	let lig=$1
	let col=$2
	echo -en '\033['$lig';'$col'f'$3$4

}
f_readPos() {	#commande de positionnement	lines + coln + text 
	echo -en '\033[0;0m'
	let lig=$1
	let col=$2
	let colR=$2+${#3}+1  # si on doit coller faire  $2+${#3}
	echo -en '\033['$lig';'$col'f'$fdVert$faGras$fcBlanc$3 
	echo -en '\033[0;0m' 
	tput cnorm	# curseur visible         			
 	echo -en '\033['$lig';'$colR'f'$faGras$fcGreen
	read   
	tput civis 	# curseur invisible
	echo -en '\033[0;0m'			  
}

# resize 
printf '\e[8;'35';'80't'

envCPP="1"
envZIG="2"
PROJECT="ZTERM"
LIBPROJECT=$HOME"/Zterm/"
LIBRARY=$HOME"/Zterm/libtui/"
choix=""

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
while [ "$choix" != "99" ]
do
	cd $LIBPROJECT
	f_cls
	f_dsplyPos  1  24 $faGras$fcJaune 'Project: '$faGras$fcCyan$PROJECT

	f_dsplyPos  3  24 $faGras$fcJaune '------------compile cpp-----------------'
	f_dsplyPos  4  20 $faGras$fcRouge' 1.'; f_dsplyPos  4  24 $faGras$fcGreen 'Gen'
	f_dsplyPos  5  20 $faGras$fcRouge' 2.'; f_dsplyPos  5  24 $faGras$fcGreen 'APPTERM'
	f_dsplyPos  6  20 $faGras$fcRouge' 3.'; f_dsplyPos  6  24 $faGras$fcGreen 'Src'

	f_dsplyPos  7  24 $faGras$fcJaune '------------compile Zig-----------------'
	f_dsplyPos  8  20 $faGras$fcRouge'11.'; f_dsplyPos  8  24 $faGras$fcGreen 'Gencurs'
	f_dsplyPos  9  20 $faGras$fcRouge'12.'; f_dsplyPos  9  24 $faGras$fcGreen 'Exemple'
	f_dsplyPos 10  20 $faGras$fcRouge'13.'; f_dsplyPos 10  24 $faGras$fcGreen 'exCallpgm'
	f_dsplyPos 11  20 $faGras$fcRouge'15.'; f_dsplyPos 11  24 $faGras$fcGreen 'Gensrc'

	f_dsplyPos 14  20 $faGras$fcRouge'20.'; f_dsplyPos 14  24 $faGras$fcGreen 'test'
    f_dsplyPos 15  20 $faGras$fcRouge'21.'; f_dsplyPos 15  24 $faGras$fcGreen 'test2'

	f_dsplyPos 16  24 $faGras$fcJaune '----------------------------------------'

	f_dsplyPos 17  20 $faGras$fcRouge'33.'; f_dsplyPos 17  24 $faGras$fcGreen 'Debug codelldb'

	f_dsplyPos 19  20 $faGras$fcRouge'44.'; f_dsplyPos 19  24 $faGras$fcCyan  'enScript Printer'

	f_dsplyPos 21  20 $faGras$fcRouge'50.'; f_dsplyPos 21  24 $faGras$fcCyan  'Edit my library LIBTUI'	

	f_dsplyPos 23  20 $faGras$fcRouge'60.'; f_dsplyPos 23  24 $faGras$fcCyan  'Edit my project'

	f_dsplyPos 24  20 $faGras$fcRouge'66.'; f_dsplyPos 24  24 $faGras$fcCyan  'Edit last source used'

	f_dsplyPos 26  20 $faGras$fcRouge'77.'; f_dsplyPos 26  24 $faGras$fcCyan  'clear helix.log'

	f_dsplyPos 28  20 $faGras$fcRouge'88.'; f_dsplyPos 28  24 $faGras$fcGreen 'Console'

	f_dsplyPos 30  20 $faGras$fcRouge'99.'; f_dsplyPos 30 24 $faGras$fcRouge  'Exit'

	f_dsplyPos 32  24 $faGras$fcBleu '----------------------------------------'
	f_readPos  34  20  'Votre choix  :'; choix=$REPLY;
	
	# Recherche de caractères non numériques dans les arguments.
	if echo $choix | tr -d [:blank:] | tr -d [:digit:] | grep . &> /dev/null; then
		f_readPos 34 70  'erreur de saisie Enter'
	else

 		case "$choix" in

# Gen
		1)
			$HOME/.Terminal/dispatch.sh $envCPP $LIBPROJECT   "Gen"
		;;
# APPTERM
		2)
			$HOME/.Terminal/dispatch.sh $envCPP $LIBPROJECT   "APPTERM"
		;;
# Src
		3)
			$HOME/.Terminal/dispatch.sh $envCPP $LIBPROJECT   "Src"
		;;

#Gencurs
		11)
			$HOME/.Terminal/dispatch.sh $envZIG $LIBPROJECT   "Gencurs"
		;;

#Example
		12)
			$HOME/.Terminal/dispatch.sh $envZIG $LIBPROJECT   "Exemple"
		;;

#callExample
		13)
			$HOME/.Terminal/dispatch.sh $envZIG $LIBPROJECT   "exCallpgm"
		;;

#Gensrc
		15)
			$HOME/.Terminal/dispatch.sh $envZIG $LIBPROJECT   "Gensrc"
		;;


#study 
        20)
			$HOME/.Terminal/dispatch.sh $envZIG  $LIBPROJECT   "test"	
		;;

#study 
        21)
			$HOME/.Terminal/dispatch.sh $envZIG  $LIBPROJECT   "test2"	
		;;


#debug
		33)
			$HOME/.Terminal/debugZig.sh $PROJECT
		;;

#print install enscript
		44)
			$HOME/.Terminal/enScript.sh  $LIBPROJECT
		;;

#library
		50)
			$HOME/.Terminal/myProject.sh  $PROJECT $LIBRARY
			#sleep 2
			#break
		;;

#project
		60)
			$HOME/.Terminal/myProject.sh  $PROJECT $LIBPROJECT"src-zig"
		;;

#?file
		66)
			$HOME/.Terminal/lastFileZig.sh $PROJECT $LIBPROJECT"src-zig"
		;;

#?clear 
		77)
			> $HOME/.cache/helix/helix.log
		;;

#console

		88)
			$HOME/.Terminal/console.sh 
		;;



# QUIT
		99)
			break
		;;

	esac 
	fi # fintest option

printf '\e[8;'35';'80't'

done

tput cnorm
exit 0
