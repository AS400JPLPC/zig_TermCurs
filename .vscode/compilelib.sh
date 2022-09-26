#!/bin/sh

faStabilo='\033[7m'
fcRouge='\033[31m'
fcJaune='\033[33;1m'
fcCyan='\033[36m'
fcGreen='\033[32m'

set +x

#fullpath=$2
#projet_src="${fullpath##*/}"                      # Strip longest match of */ from start

projet_typ=$2
projet_src=$3
projet_lib=$4
folder_src=$5


folder_len=${#folder_src}

lib_len=${#projet_lib}

rlen=$(($lib_len-$folder_len))

#-------------------------------------------------------------------
# ccontrôle si projet nim
#-------------------------------------------------------------------
if [[ ! "$projet_src" =~ '.zig' ]]; then
echo -en $faStabilo$fcJaune"$projet_src -->"$faStabilo$fcRouge"ce n'est pas un fichier .zig \033[0;0m\\n"
exit 0
fi


mode=$1

projet_bin=${projet_src%.*}

lib_projet="$(cut -c 1-$rlen <<< $projet_lib)"

folder_bin=$lib_projet"zig-out/lib/"

folder_cache=$lib_projet"zig-cache"

folder_lib=$folder_bin$projet_bin.a

#echo -en $folder_bin\\n

#echo -en $lib_projet\\n

echo  -en $folder_lib\\n

#echo -en $projet_bin\\n
#-------------------------------------------------------------------
# clean
#-------------------------------------------------------------------
if test -d $folder_cache ; then
	rm -r $folder_cache
fi
if test -f $projet_bin.a ; then
	rm -r $projet_bin.a
fi

#-------------------------------------------------------------------
# compile			 Security		Optimizations
# debug						Yes					No
# release-safe		Yes					Yes, Speed
# release-small		No					Yes, Size
# release-fast		No					Yes, Speed
#-------------------------------------------------------------------

if [ "$mode" == "DEBUG" ] ; then
	( set -x ; \
				zig build --build-file $lib_projet"build"$projet_src ;\
	)
fi

if [ "$mode" == "PROD" ] ; then
	( set -x ; \
				zig build -Drelease-small=true --build-file $lib_projet"build"$projet_src ;\
	)
fi

if [ "$mode" == "FAST" ] ; then
	( set -x ; \
				zig build -Drelease-fast=true --build-file $lib_projet"build"$projet_src ;\
	)
fi

#-------------------------------------------------------------------
# resultat
#-------------------------------------------------------------------

	echo -en '\033[0;0m'	# video normal
	echo " "
	if test -f "$folder_lib"; then
		echo -en $faStabilo$fcCyan"BUILD "$mode"\033[0;0m  "$fcJaune$projet_src"->\033[0;0m  "$fcGreen $projet_bin "\033[0;0m"
		echo -en "  size : "
		ls -lrtsh $folder_lib | cut -d " " -f6

		mv $folder_lib $lib_projet
		rm -r $folder_cache
	fi

exit
