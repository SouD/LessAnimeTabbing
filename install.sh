#!/bin/bash

# Path variables
SRC_DIR=/cygdrive/f/workspace/MALBot/src
OUT_DIR=/cygdrive/f/workspace/MALBot/bin
SRC=($SRC_DIR/*.lua)
EXT_NAME=MALBot.lua
OUT=$OUT_DIR/$EXT_NAME
VLC_DIR="/cygdrive/f/Program Files/VideoLAN/VLC/lua/extensions"

# Move to source dir
cd $SRC_DIR

# Empty out file
> $OUT

# Copy source files into out file
for i in ${SRC[@]}
do
    cat $i >> $OUT
done

# Strip out file
sed -i '/^\s*\-\-/d' $OUT
sed -i '/^$/d' $OUT

# Copy file from source dir to vlc extensions dir
cp -v $OUT "$VLC_DIR/$EXT_NAME"

# Exit script
exit 0