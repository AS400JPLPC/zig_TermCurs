#!/bin/sh
# clear Data
rm -v -rf $HOME/.config/VSCodium/CachedData/*

# clear Cache
rm -v -rf $HOME/.config/VSCodium/Cache/*

# clear log
rm -v -rf $HOME/.config/VSCodium/logs/*

# clear cache
rm -v -rf $HOME/.cache/zig*
exit