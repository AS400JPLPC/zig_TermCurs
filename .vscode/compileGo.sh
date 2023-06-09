#!/bin/sh

faStabilo='\033[7m'
fcRouge='\033[31m'
fcJaune='\033[33;1m'
fcCyan='\033[36m'
fcGreen='\033[32m'

set +x

mode=$1
src=$2
objet=$3
folder_src=$4

#-------------------------------------------------------------------
# ccontrôle si projet nim
#-------------------------------------------------------------------
if [[ ! "$src" =~ '.go' ]]; then
echo -en $faStabilo$fcJaune"$projet_src -->"$faStabilo$fcRouge"ce n'est pas un fichier .go \033[0;0m\\n"
exit 0
fi


objet_lib=$objet".a"

folder_lib=$folder_src"/lib"

folder_docs=$folder_src"/docs"

result=$folder_lib"/"$objet_lib

projet_bin=$folder"/"$objet_lib

title="creat:"$objet_lib

#echo -en $objet\\n
#echo -en $src\\n
#echo -en $folder_src\\n
#echo -en $folder_lib\\n
#echo -en $objet_lib\\n
#echo -en $folder_docs\\n
echo -en $title\\n

#-------------------------------------------------------------------
# clean
#-------------------------------------------------------------------

if test -f $result ; then
	rm -r $result
fi


#-------------------------------------------------------------------
# creat lib GO   for Zig
#-------------------------------------------------------------------


if [ "$mode" == "RUN" ] ; then
	( set -x ; \

        go run  $folder_src"/"$src ;\
        exit;\
	)
fi



if [ "$mode" == "LIB" ] ; then
	( set -x ; \

        go build -ldflags="-s -w" -buildmode=c-archive -o $result  $folder_src"/"$src ;\
	)
fi


#-------------------------------------------------------------------
# resultat
#-------------------------------------------------------------------

	echo -en '\033[0;0m'	# video normal
	echo " "
	if test -f "$result"; then
		echo -en $faStabilo$fcCyan"BUILD "$mode"\033[0;0m  "$fcJaune$projet_src"->\033[0;0m  "$fcGreen $objet_lib "\033[0;0m"
		echo -en "  size : "
		ls -lrtsh $result| cut -d " " -f6

	fi
exit
