#!/bin/bash
#
# Generates IC elements
# Copyright (C) 2019 by di0x7c5
#

for PARTS in $(ls parts)
do
    if [ -d parts/$PARTS/ic/ ]; then
        for IC in parts/$PARTS/ic/*.ic
        do
            # Basename here is filename without extension
            BASENAME=$(basename $(echo $IC | sed 's/.ic$//'))

            SVG_PATH=build/svg/core/schematic
            SVG=$SVG_PATH/$BASENAME.svg

            FZP_PATH=build/core
            FZP=$FZP_PATH/$BASENAME.fzp

            # LMT - stands for "Last Modification Timestamp"
            IC_LMT=$(stat $IC -c %Y)

            SVG_LMT=0 && [ -f $SVG ] && SVG_LMT=$(stat $SVG -c %Y)
            FZP_LMT=0 && [ -f $FZP ] && FZP_LMT=$(stat $FZP -c %Y)

            if [ $IC_LMT -gt $SVG_LMT ] || [ $IC_LMT -gt $FZP_LMT ]; then
                echo "[$PARTS] Generating from \"${BASENAME}.ic\""
                scripts/icgen.sh --svg-out $SVG_PATH --fzp-out $FZP_PATH $IC
            fi
        done
    fi
done
