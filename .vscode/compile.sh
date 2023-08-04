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


folder_cache=$projet_lib"/zig-cache"
folder_out=$projet_lib"/zig-out"

folder_bin=$projet_lib"/zig-out/bin/"$projet_bin

folder_docs=$folder_out"/Doc_"$projet_bin

folder_homecache="$HOME/.cache/zig/"

tested="Projet:"$projet_bin


#echo -en $projet_lib\\n

#echo -en $folder_bin\\n
echo -en $folder_out\\n
echo -en $lib_projet\\n
#echo -en $projet_src\\n
#echo -en $folder_src\\n
#echo -en $projet_typ\\n
#echo -en $projet_bin\\n
#echo -en $folder_cache\\n
#echo -en $folder_docs\\n
echo -en $folder_homecache\\n
echo -en $tested\\n

echo -en $mode\\n
#-------------------------------------------------------------------
# clean
#-------------------------------------------------------------------

if test -f $projet_bin ; then
	rm -r $projet_bin
fi

if test -d $folder_cache ; then
	rm -r $folder_cache
fi

if test -d $folder_out ; then
	rm -r $folder_out
fi


#-------------------------------------------------------------------
# compile			 Security		Optimizations
# debug						Yes					No
# release-safe		Yes					Yes, Speed
# release-small		No					Yes, Size
# release-fast		No					Yes, Speed


# test  -fsummary --verbose
#-------------------------------------------------------------------

if [ "$mode" == "DEBUG" ] ; then
	if [ "$projet_typ" == "ALL" ] ; then
		( set -x ; \
					zig build  --build-file $projet_lib"/build"$projet_src ;\
		)
	else
		(set -x ; \
					zig  build test -fsummary  --build-file $projet_lib"/build"$projet_src ;\
          rm -r $folder_cache;\
		)
	fi
fi

if [ "$mode" == "PROD" ] ; then
	( set -x ; \
				zig build -Doptimize=ReleaseFast --build-file $projet_lib"/build"$projet_src ;\

	)
fi

if [ "$mode" == "SAFE" ] ; then
	( set -x ; \
				zig build -Doptimize=ReleaseSafe --build-file $projet_lib"/build"$projet_src ;\
	)
fi

if [ "$mode" == "SMALL" ] ; then
	( set -x ; \
				zig build -Doptimize=ReleaseSmall --build-file $projet_lib"/build"$projet_src ;\
	)
fi


# -Doptimize=Debug  --verbose -fno-summary -femit-docs

if [ "$mode" == "DOCS" ] ; then

		if test -d "docs_"$projet_bin ; then
			rm -r "docs_"$projet_bin  
		fi
	( set -x ; \
				zig build  docs  --build-file $projet_lib"/build"$projet_src ;\
				mv $folder_docs  "docs_"$projet_bin;\
				rm -r $folder_cache;\
        rm -r $folder_homecache; \
        rm -r $folder_out; \
				exit;\
	)


fi

#-------------------------------------------------------------------
# resultat
#-------------------------------------------------------------------

	echo -en '\033[0;0m'	# video normal
	echo " "
	if test -f "$folder_bin"; then
	echo -en $faStabilo$fcCyan"BUILD "$mode"\033[0;0m  "$fcJaune$projet_src"->\033[0;0m  "$fcGreen $projet_bin "\033[0;0m"
	echo -en "  size : "
	ls -lrtsh $folder_bin | cut -d " " -f6

	mv $folder_bin $lib_projet

	if test -d $folder_cache ; then
	rm -r $folder_cache
	fi
		
	if test -d $folder_out ; then
	rm -r $folder_out
	fi

	rm -r $folder_homecache;
	fi
exit
