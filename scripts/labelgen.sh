#!/bin/bash
#
# Helper script to generate bunch of labels
# Copyright (C) 2020 by di0x7c5
#

#
# FZB File
#
FILENAME_FZP=EdW_Description.fzb

#
# Whole alphabet to generate
#
ALPHABET=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)

#
# A - Short Label
# B - Long Label
#
NAME_LABEL_A_TOP="EdW_Label_A_Top"
NAME_LABEL_A_BOTTOM="EdW_Label_A_Bottom"
NAME_LABEL_B_TOP="EdW_Label_B_Top"
NAME_LABEL_B_BOTTOM="EdW_Label_B_Bottom"

DESC_LABEL_A_TOP="Label short top"
DESC_LABEL_A_BOTTOM="Label short bottom"
DESC_LABEL_B_TOP="Label long top"
DESC_LABEL_B_BOTTOM="Label long bottom"

FILENAME_CHARACTER_3x3_SVG="EdW_Character_3x3"
FILENAME_PINNR="EdW_IC_PinNr"

function pinnr_svg {
    local NR=$1

cat << EOF
<?xml version='1.0' encoding='UTF-8' standalone='no'?>
<svg xmlns:svg='http://www.w3.org/2000/svg' xmlns='http://www.w3.org/2000/svg' version='1.2' baseProfile='tiny' x='0in' y='0in' width='0.10in' height='0.10in' viewBox='0 0 10 10'>
<g id='schematic'>
<text class='text' font-family='Arial' font-size='7' x='5' y='8' fill='#000000' stroke='#000000' stroke-width='0.216' text-anchor='middle'>${NR}</text>
<circle class='pin' id='connector0pin' connectorname='0' cx='0' cy='0' r='0.0001' stroke='none' fill='none' />
<rect class='terminal' id='connector0terminal' x='0' y='0' width='0.0001' height='0.0001' fill='none' stroke='none' />
</g>
</svg>
EOF
}

function pinnr_fzp {
    local NR=$1

cat << EOF
<?xml version="1.0" encoding="UTF-8"?>
<module fritzingVersion="0.9.3" moduleId="${FILENAME_PINNR}_${NR}_Id">
    <version>1</version>
    <author>di0x7c5</author>
    <title>${NR}</title>
    <label>_</label>
    <date>2021-02-17</date>
    <tags>
        <tag>EdW</tag>
    </tags>

    <description>IC pin number ${NR}</description>

    <properties>
        <property name="family">Description</property>
    </properties>

    <views>
        <iconView>
            <layers image="schematic/${FILENAME_PINNR}_${NR}.svg">
                <layer layerId="icon" />
            </layers>
        </iconView>
        <schematicView>
            <layers image="schematic/${FILENAME_PINNR}_${NR}.svg">
                <layer layerId="schematic" />
            </layers>
        </schematicView>
    </views>

    <connectors>
        <connector id="connector0" name="Pin 0" type="male">
            <description>Pin 0</description>
            <views>
                <schematicView>
                    <p layer="schematic" svgId="connector0pin" terminalId="connector0terminal" />
                </schematicView>
            </views>
        </connector>
    </connectors>
</module>
EOF
}

function label_fzp {
    local NAME=$1
    local DESC=$2

cat << EOF
<?xml version="1.0" encoding="UTF-8"?>
<module fritzingVersion="0.9.3" moduleId="${NAME}_Id">
    <version>1</version>
    <author>di0x7c5</author>
    <title>${DESC}</title>
    <label>_</label>
    <date>2020-12-01</date>
    <tags>
        <tag>EdW</tag>
    </tags>

    <description>${DESC}</description>

    <properties>
        <property name="family">Description</property>
    </properties>

    <views>
        <iconView>
            <layers image="schematic/${NAME}.svg">
                <layer layerId="icon" />
            </layers>
        </iconView>
        <schematicView>
            <layers image="schematic/${NAME}.svg">
                <layer layerId="schematic" />
            </layers>
        </schematicView>
    </views>

    <connectors>
        <connector id="connector0" name="Pin 0" type="male">
            <description>Pin 0</description>
            <views>
                <schematicView>
                    <p layer="schematic" svgId="connector0pin" terminalId="connector0terminal" />
                </schematicView>
            </views>
        </connector>
    </connectors>
</module>
EOF
}

function character_fzp {
    label_fzp "${FILENAME_CHARACTER_3x3_SVG}_$1" "Character $1"
}

function label_a_top_fzp {
    label_fzp "${NAME_LABEL_A_TOP}_$1" "${DESC_LABEL_A_TOP}"
}

function label_a_bottom_fzp {
    label_fzp "${NAME_LABEL_A_BOTTOM}_$1" "${DESC_LABEL_A_BOTTOM}"
}

function label_b_top_fzp {
    label_fzp "${NAME_LABEL_B_TOP}_$1" "${DESC_LABEL_B_TOP}"
}

function label_b_bottom_fzp {
    label_fzp "${NAME_LABEL_B_BOTTOM}_$1" "${DESC_LABEL_B_BOTTOM}"
}

function label_a_top_svg {
    local TEXT=$1

cat << EOF
<?xml version='1.0' encoding='UTF-8' standalone='no'?>
<svg xmlns:svg='http://www.w3.org/2000/svg' xmlns='http://www.w3.org/2000/svg' version='1.2' baseProfile='tiny' x='0in' y='0in' width='0.30in' height='0.25in' viewBox='0 0 30 25'> 
<g id='schematic'>
<path class='other' d='M5 20 L10 10 H25' fill='none' stroke='#ed1c24' stroke-width='0.971875' stroke-linecap="square" />
<text class='text' font-family='Arial' font-size='9.7' x='15' y='8' fill='#ed1c24' stroke='#ed1c24' stroke-width='0.5' text-anchor='begin'>${TEXT}</text>
<circle class='pin' id='connector0pin' connectorname='0' cx='5' cy='20' r='1' stroke='none' fill='none' />
<rect class='terminal' id='connector0terminal' x='5' y='20' width='0.0001' height='0.0001' fill='none' stroke='none' />
</g>
</svg>
EOF
}

function label_a_bottom_svg {
    local TEXT=$1

cat << EOF
<?xml version='1.0' encoding='UTF-8' standalone='no'?>
<svg xmlns:svg='http://www.w3.org/2000/svg' xmlns='http://www.w3.org/2000/svg' version='1.2' baseProfile='tiny' x='0in' y='0in' width='0.30in' height='0.20in' viewBox='0 0 30 20'> 
<g id='schematic'>
<path class='other' d='M5 5 L10 15 H25' fill='none' stroke='#ed1c24' stroke-width='0.971875' stroke-linecap="square" />
<text class='text' font-family='Arial' font-size='9.7' x='15' y='12.5' fill='#ed1c24' stroke='#ed1c24' stroke-width='0.5' text-anchor='begin'>${TEXT}</text>
<circle class='pin' id='connector0pin' connectorname='0' cx='5' cy='5' r='1' stroke='none' fill='none' />
<rect class='terminal' id='connector0terminal' x='5' y='5' width='0.0001' height='0.0001' fill='none' stroke='none' />
</g>
</svg>
EOF
}

function label_b_top_svg {
    local TEXT=$1

cat << EOF
<?xml version='1.0' encoding='UTF-8' standalone='no'?>
<svg xmlns:svg='http://www.w3.org/2000/svg' xmlns='http://www.w3.org/2000/svg' version='1.2' baseProfile='tiny' x='0in' y='0in' width='0.35in' height='0.25in' viewBox='0 0 35 25'>
<g id='schematic'>
<path class='other' d='M5 10 H20 L30 20' fill='none' stroke='#ed1c24' stroke-width='0.971875' stroke-linecap="square" />
<text class='text' font-family='Arial' font-size='9.7' x='7' y='7' fill='#ed1c24' stroke='#ed1c24' stroke-width='0.5' text-anchor='begin'>${TEXT}</text>
<circle class='pin' id='connector0pin' connectorname='0' cx='30' cy='20' r='1' stroke='none' fill='none' />
<rect class='terminal' id='connector0terminal' x='30' y='20' width='0.0001' height='0.0001' fill='none' stroke='none' />
</g>
</svg>
EOF
}

function label_b_bottom_svg {
    local TEXT=$1

cat << EOF
<?xml version='1.0' encoding='UTF-8' standalone='no'?>
<svg xmlns:svg='http://www.w3.org/2000/svg' xmlns='http://www.w3.org/2000/svg' version='1.2' baseProfile='tiny' x='0in' y='0in' width='0.35in' height='0.20in' viewBox='0 0 35 20'>
<g id='schematic'>
<path class='other' d='M5 15 H20 L30 5' fill='none' stroke='#ed1c24' stroke-width='0.971875' stroke-linecap="square" />
<text class='text' font-family='Arial' font-size='9.7' x='7' y='12.5' fill='#ed1c24' stroke='#ed1c24' stroke-width='0.5' text-anchor='begin'>${TEXT}</text>
<circle class='pin' id='connector0pin' connectorname='0' cx='30' cy='5' r='1' stroke='none' fill='none' />
<rect class='terminal' id='connector0terminal' x='30' y='5' width='0.0001' height='0.0001' fill='none' stroke='none' />
</g>
</svg>
EOF
}

function fzp_spacer {
    local DESC=$1

cat << EOF
        <instance moduleIdRef="__spacer__" path="${DESC}">
            <views>
                <iconView layer="icon">
                    <geometry z="-1" x="-1" y="-1"></geometry>
                </iconView>
            </views>
        </instance>

EOF
}

function fzp_instance {
    local ID=$1

cat << EOF
        <instance moduleIdRef="${ID}_Id" path="${ID}.fzp">
            <views>
                <iconView layer="icon">
                    <geometry z="-1" x="-1" y="-1"></geometry>
                </iconView>
            </views>
        </instance>

EOF
}

#
# Characters
#
function character_svg {
    local CHARACTER=$1

cat << EOF
<?xml version='1.0' encoding='UTF-8' standalone='no'?>
<svg xmlns:svg='http://www.w3.org/2000/svg' xmlns='http://www.w3.org/2000/svg' version='1.2' baseProfile='tiny' x='0in' y='0in' width='0.15in' height='0.15in' viewBox='0 0 15 15'> 
<g id='schematic'>
<text class='text' font-family='Arial' font-size='9.986444' x='7.5' y='11' fill='#ed1c24' stroke='#ed1c24' stroke-width='0.5' text-anchor='middle'>${CHARACTER}</text>
<circle class='pin' id='connector0pin' connectorname='0' cx='0' cy='0' r='0.0001' stroke='none' fill='none' />
<rect class='terminal' id='connector0terminal' x='0' y='0' width='0.0001' height='0.0001' fill='none' stroke='none' />
</g>
</svg>
EOF
}

# Remove generated file and create a new one
rm -f ${FILENAME_FZP}

#
# Generate Pin Numbers
#
for X in $(seq 28); do
    fzp_instance ${FILENAME_PINNR}_${X} >> ${FILENAME_FZP}
    pinnr_fzp $X > ${FILENAME_PINNR}_${X}.fzp
    pinnr_svg $X > ${FILENAME_PINNR}_${X}.svg
done

#
# Generate Characters
#
fzp_spacer "Characters 3x3" >> ${FILENAME_FZP}
for X in ${ALPHABET[@]}; do
    fzp_instance ${FILENAME_CHARACTER_3x3_SVG}_${X} >> ${FILENAME_FZP}
    character_fzp ${X} > ${FILENAME_CHARACTER_3x3_SVG}_${X}.fzp
    character_svg ${X} > ${FILENAME_CHARACTER_3x3_SVG}_${X}.svg
done

#
# Generate Labels
#
fzp_spacer "Labels short top" >> ${FILENAME_FZP}
for X in ${ALPHABET[@]}; do
    # Short Top
    fzp_instance ${NAME_LABEL_A_TOP}_$X >> ${FILENAME_FZP}
    label_a_top_fzp $X > ${NAME_LABEL_A_TOP}_$X.fzp
    label_a_top_svg $X > ${NAME_LABEL_A_TOP}_$X.svg
done

fzp_spacer "Labels short bottom" >> ${FILENAME_FZP}
for X in ${ALPHABET[@]}; do
    # Short Bottom
    fzp_instance ${NAME_LABEL_A_BOTTOM}_$X >> ${FILENAME_FZP}
    label_a_bottom_fzp $X > ${NAME_LABEL_A_BOTTOM}_$X.fzp
    label_a_bottom_svg $X > ${NAME_LABEL_A_BOTTOM}_$X.svg
done

fzp_spacer "Labels long top" >> ${FILENAME_FZP}
for X in ${ALPHABET[@]}; do
    # Long Top
    fzp_instance ${NAME_LABEL_B_TOP}_$X >> ${FILENAME_FZP}
    label_b_top_fzp $X > ${NAME_LABEL_B_TOP}_$X.fzp
    label_b_top_svg $X > ${NAME_LABEL_B_TOP}_$X.svg
done

fzp_spacer "Labels long bottom" >> ${FILENAME_FZP}
for X in ${ALPHABET[@]}; do
    # Long Bottom
    fzp_instance ${NAME_LABEL_B_BOTTOM}_$X >> ${FILENAME_FZP}
    label_b_bottom_fzp $X > ${NAME_LABEL_B_BOTTOM}_$X.fzp
    label_b_bottom_svg $X > ${NAME_LABEL_B_BOTTOM}_$X.svg
done
