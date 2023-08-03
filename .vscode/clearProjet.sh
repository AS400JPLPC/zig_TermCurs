#!/bin/sh

projet_src=$1
projet_lib=$2
folder_src=$3
set +x

folder_len=${#folder_src}


lib_len=${#projet_lib}

rlen=$(($lib_len-$folder_len))

projet_bin=${projet_src%.*}

lib_projet="$(cut -c 1-$rlen <<< $projet_lib)"

folder_bin=$lib_projet"zig-out/bin/"$projet_bin

folder_cache=$lib_projet"src-zig/zig-cache"

folder_cachetest=$lib_projet"src-zig/deps/curse/zig-cache"

folder_home="$HOME/.cache/zig"

echo -en $folder_bin\\n
echo -en $lib_projet\\n
echo -en $projet_src\\n
echo -en $folder_src\\n
echo -en $projet_typ\\n
echo -en $projet_bin\\n
echo -en $folder_cachetest\\n


if test -d $folder_cache ; then
	rm -r $folder_cache
fi
if test -f $projet_bin ; then
	rm -r $projet_bin
fi

if test -d $folder_cachetest ; then
	rm -r $folder_cachetest
fi

if test -d $folder_home; then
	rm -r $folder_home
fi