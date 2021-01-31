#!/bin/bash
#
# Generate SVG and FZP from IC file
# Copyright (C) 2019 by di0x7c5
#

FRITZING_VERSION="0.9.3"

declare -a FZP
declare -a SVG
declare -a DSC

# EdW Color Palette
EDW_COLOR_YELLOW="#fffad2"
EDW_COLOR_BLUE="#d4edfc"
EDW_COLOR_PINK="#fadceb"
EDW_COLOR_VIOLET="#d2cde8"
EDW_COLOR_GREEN="#d7e9cf"
EDW_COLOR_BROWN="#e1dad8"

# Output folder for svg and fzp
OUT=$(pwd)

# Flags
FLAG_GEN_SVG="y"
FLAG_GEN_FZP="y"

# Global variables contains the last pin position for each edge
DSC_LAST_L=0
DSC_LAST_R=0
DSC_LAST_T=0
DSC_LAST_B=0

function fzp {
    FZP+=("$@")
}

function svg {
    SVG+=("$@")
}

function dsc {
    DSC+=("$@")
}

function generate_fzp {
    for L in "${FZP[@]}"; do echo "$L"; done
}

function generate_svg {
    for L in "${SVG[@]}"; do echo "$L"; done
}

# Handsome wrapper for bc - an arbitrary precision calculator language
function calc {
    SCALE=4 && [ $# -gt 1 ] && SCALE="$1" && shift
    echo "scale=$SCALE; $@" | bc
}

function dsc_edge {
    echo $1
}

function dsc_type {
    echo $2
}

function dsc_pos {
    if [ "${3:0:1}" == "+" -o "${3:0:1}" == "-" ]; then
        case $1 in
            "R"|"r") echo $(calc ${DSC_LAST_R}${3}) ;;
            "L"|"l") echo $(calc ${DSC_LAST_L}${3}) ;;
            "T"|"t") echo $(calc ${DSC_LAST_T}${3}) ;;
            "B"|"b") echo $(calc ${DSC_LAST_B}${3}) ;;
        esac
    else
        echo $3
    fi
}

function dsc_num {
    echo $4
}

function dsc_description {
    shift 4
    echo $@
}

function process_attribute {
    case $1 in
    ".version")
        shift
        IC_VERSION=$@
        ;;
    ".author")
        shift
        IC_AUTHOR=$@
        ;;
    ".date")
        shift
        IC_DATE=$@
        ;;
    ".partnumber")
        shift
        IC_PARTNUMBER=$@
        ;;
    ".title")
        shift
        IC_TITLE=$@
        ;;
    ".label")
        shift
        IC_LABEL=$@
        ;;
    ".id")
        shift
        IC_ID=$@
        ;;
    ".description")
        shift
        IC_DESCRIPTION=$@
        ;;
    ".width")
        shift
        IC_WIDTH=$@
        ;;
    ".height")
        shift
        IC_HEIGHT=$@
        ;;
    ".tint")
        shift
        IC_TINT=$@

        # NOTE: Maybe do below as associative array?
        [ "$IC_TINT" == "YELLOW" ] && IC_TINT=$EDW_COLOR_YELLOW
        [ "$IC_TINT" == "BLUE" ] && IC_TINT=$EDW_COLOR_BLUE
        [ "$IC_TINT" == "PINK" ] && IC_TINT=$EDW_COLOR_PINK
        [ "$IC_TINT" == "VIOLET" ] && IC_TINT=$EDW_COLOR_VIOLET
        [ "$IC_TINT" == "GREEN" ] && IC_TINT=$EDW_COLOR_GREEN
        [ "$IC_TINT" == "BROWN" ] && IC_TINT=$EDW_COLOR_BROWN

        if [ ! "${IC_TINT:0:1}" == "#" ]
        then
            icwarning "Tint color unknown or malformed: \"$IC_TINT\". Using default."
            icwarning "Supported colors: YELLOW, BLUE, PINK, VIOLET, GREEN, BROWN."
            unset IC_TINT
        fi
        ;;
    ".nopinnr")
        IC_NOPINNR="y"
        ;;
    *)
        # Do nothing
        ;;
    esac
}

# Used when .width param is not specified.
function guess_width {
    # FIXME: For now, it's just constant.
    # Add later better guessing base in pin description list.
    IC_WIDTH="11"
}

# Used when .height param is not specified.
# The guess may be inappropriate, so let me know about it.
# Algorithm: Find the highest pin position for edge L and R, and add +2
function guess_height {
    icwarning "Param \".height\" was not specified in \".ic\" manifest."
    icwarning "  Trying to guess the proper height but this may not be a proper value. Check the generated output."
    GUESS=0

    for ENTRY in "${DSC[@]}"
    do
        PIN_EDGE=$(dsc_edge $ENTRY)
        PIN_POS=$(dsc_pos $ENTRY)

        if [ "$PIN_EDGE" == "L" ] || [ "$PIN_EDGE" == "R" ]
        then
            [ "${PIN_POS:0:1}" != "+" ] && [ $GUESS -lt $PIN_POS ] && GUESS=$PIN_POS
        fi
    done

    # Check the last pin pos
    # TODO: It may not be true that the last pin is the oldest one ...
    [ $GUESS -lt $DSC_LAST_L ] && GUESS=$DSC_LAST_L
    [ $GUESS -lt $DSC_LAST_R ] && GUESS=$DSC_LAST_R

    ((GUESS++))
    ((GUESS++))

    # And the winner is ...
    icwarning "  Height guessed as $GUESS. Do I win?"
    IC_HEIGHT="$GUESS"
}

function print_usage {
    echo "Usage: $(basename $0) [FILE]"
    echo "Convert .ic files to .svg and .fzp".
}

function icwarning {
    echo "Warning: $@";
}

function icerror {
    echo "Error: $@";
    exit 0;
}

function parse_command_line {
    # Check if file exist and it's truly file
    [ $# -eq 0 ] && icerror "No input arguments found"

    while [ $# -gt 0 ]
    do
        case "$1" in
        -o|--out)
            OUT="$2"
            shift 2
            ;;
        --fzp-only)
            unset FLAG_GEN_SVG
            shift
            ;;
        --svg-only)
            unset FLAG_GEN_FZP
            shift
            ;;
        --fzp-out)
            OUT_FZP_PATH="$2"
            shift 2
            ;;
        --svg-out)
            OUT_SVG_PATH="$2"
            shift 2
            ;;
        *)
            IC_FILE_PATH="$1"
            shift
            ;;
        esac
    done
}

# First things first
parse_command_line $@

# Check if output directory exist
[ -d $OUT ] || icerror "Output directory desn't exist \"$OUT\""

# Check if passed file (if any) exist
[ -n $IC_FILE_PATH ] || icerror "Input file did not specified, exiting."
[ -f $IC_FILE_PATH ] || icerror "File \"$IC_FILE_PATH\" not found"

# Sanity check, cannot use '--svg-only' and '--fzp-only' together
[ -z "$FLAG_GEN_FZP" ] && [ -z "$FLAG_GEN_SVG" ] && \
    icerror "You can't use '--svg-only' and '--fzp-only' at the same time."

# Prepare the output folder for FZP
[ -z "$OUT_FZP_PATH" ] && OUT_FZP_PATH=$OUT/fzp
[ -d $OUT_FZP_PATH ] || mkdir -p $OUT_FZP_PATH

# Prepare the output folder for SVG
[ -z "$OUT_SVG_PATH" ] && OUT_SVG_PATH=$OUT/svg
[ -d $OUT_SVG_PATH ] || mkdir -p $OUT_SVG_PATH

# Basename in this script is the file name without extension
IC_FILE_BASENAME=$(echo $(basename $IC_FILE_PATH) | sed 's/\.ic$//g')

# Read all pin descriptions
while read LINE; do
    # Ommit empty lines
    [ -z "$LINE" ] && continue

    case "${LINE[@]:0:1}" in
    ".")
        process_attribute $LINE
        ;;
    "#")
        # Comment, do nothing
        ;;
    "L" | "R" | "T" | "t" | "B" | "b")
        dsc "$LINE"
        ;;
    *)
        icwarning "I do not undestand this: ${LINE}"
        ;;
    esac
done < $IC_FILE_PATH

# Check some mandatory fields
[ -z "$IC_TITLE" ] && icerror ".title param is missed! Exiting.";
[ -z "$IC_DESCRIPTION" ] && icerror ".description param is missed! Exiting.";

# If no version specified, set 0
[ -z "$IC_VERSION" ] && IC_VERSION="0"

# If no author specified, let's assume script did it
[ -z "$IC_AUTHOR" ] && IC_AUTHOR="icgen"

# If no label specified, use U as default
[ -z "$IC_LABEL" ] && IC_LABEL="U"

# If date was not specified then stamp today
[ -z "$IC_DATE" ] && IC_DATE="$(date +%Y-%m-%d)"

# If no fill color specified, use default one
[ -z "$IC_TINT" ] && IC_TINT="${EDW_COLOR_YELLOW}"

# If no ID specified, use base filename and append Id
[ -z "$IC_ID" ] && IC_ID="${IC_FILE_BASENAME}_Id"

# If width is not specified, try to guess it
[ -z "$IC_WIDTH" ] && guess_width

# If height is not specified, try to guess it base on description
# WARNING: This will work only in simple cases. So print notice also.
[ -z "$IC_HEIGHT" ] && guess_height

# If parnumber is not specified use title
[ -z "$IC_PARTNUMBER" ] && IC_PARTNUMBER="$IC_TITLE"

# If partnumber is "generic" for more than one part, do not add it to fzp
[ "$IC_PARTNUMBER" == "generic" ] && unset IC_PARTNUMBER

# -----------------------------------------------------------------------------
# FZP
# -----------------------------------------------------------------------------
fzp "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
fzp "<module fritzingVersion=\"${FRITZING_VERSION}\" moduleId=\"${IC_ID}\">"
fzp "    <version>${IC_VERSION}</version>"
fzp "    <author>${IC_AUTHOR}</author>"
fzp "    <title>${IC_TITLE}</title>"
fzp "    <label>${IC_LABEL}</label>"
fzp "    <date>${IC_DATE}</date>"
fzp "    <tags>"
fzp "        <tag>EdW</tag>"
fzp "    </tags>"
fzp ""
fzp "    <description>${IC_DESCRIPTION}</description>"
fzp ""
fzp "    <properties>"
fzp "        <property name=\"family\">Common</property>"
[ -n "$IC_PARTNUMBER" ] && fzp "        <property name=\"part number\">${IC_PARTNUMBER}</property>"
fzp "    </properties>"
fzp ""
fzp "    <views>"
fzp "        <iconView>"
fzp "            <layers image=\"schematic/${IC_FILE_BASENAME}.svg\">"
fzp "                <layer layerId=\"icon\" />"
fzp "            </layers>"
fzp "        </iconView>"
fzp "        <schematicView>"
fzp "            <layers image=\"schematic/${IC_FILE_BASENAME}.svg\">"
fzp "                <layer layerId=\"schematic\" />"
fzp "            </layers>"
fzp "        </schematicView>"
fzp "    </views>"
fzp ""
fzp "    <connectors>"

for ENTRY in "${DSC[@]}"; do
    PIN_NUM=$(dsc_num $ENTRY)
    PIN_DESCRIPTION=$(dsc_description $ENTRY)

    fzp "        <connector id=\"connector${PIN_NUM}\" name=\"Pin ${PIN_NUM}\" type=\"male\">"
    fzp "            <description>${PIN_DESCRIPTION}</description>"
    fzp "            <views>"
    fzp "                <schematicView>"
    fzp "                    <p layer=\"schematic\" svgId=\"connector${PIN_NUM}pin\" terminalId=\"connector${PIN_NUM}terminal\" />"
    fzp "                </schematicView>"
    fzp "            </views>"
    fzp "        </connector>"
done

fzp "    </connectors>"
fzp "</module>"

[ -n "$FLAG_GEN_FZP" ] && generate_fzp > ${OUT_FZP_PATH}/${IC_FILE_BASENAME}.fzp

# -----------------------------------------------------------------------------
# SVG
# -----------------------------------------------------------------------------
function svg_generate_pin_normal {
    local PIN_EDGE=$(dsc_edge $@)
    local PIN_POS=$(dsc_pos $@)
    local PIN_NUM=$(dsc_num $@)
    local PIN_DESC=$(dsc_description $@)

    case $PIN_EDGE in
    "L")
        local X="10.0"
        local Y=$(calc 10.0+${PIN_POS}*${SVG_CELL})

        local PIN_X1=$X
        local PIN_Y1=$Y
        local PIN_X2="0.0"
        local PIN_Y2=$Y
        local DSC_X=$(calc ${X}+${SVG_INTERIOR_PADDING})
        local DSC_Y=$(calc ${Y}+2.0)
        local DSC_ANCHOR="begin"
        local DSC_ROTATE=0
        local NUM_X=$(calc ${X}-2*${SVG_CELL})
        local NUM_Y=$(calc ${Y}-2*${SVG_ATOM})
        local NUM_ANCHOR="begin"
        ;;
    "R")
        local X=$(calc ${SVG_VIEWBOX_WIDTH}-10.0)
        local Y=$(calc ${PIN_POS}*${SVG_CELL}+10.0)

        local PIN_X1=$X
        local PIN_Y1=$Y
        local PIN_X2=$SVG_VIEWBOX_WIDTH
        local PIN_Y2=$Y
        local DSC_X=$(calc ${X}-${SVG_INTERIOR_PADDING})
        local DSC_Y=$(calc ${Y}+2.0)
        local DSC_ANCHOR="end"
        local DSC_ROTATE=0
        local NUM_X=$(calc ${X}+2*${SVG_CELL})
        local NUM_Y=$(calc ${Y}-2*${SVG_ATOM})
        local NUM_ANCHOR="end"
        ;;
    "T" | "t")
        local X=$(calc 10.0+${PIN_POS}*${SVG_CELL})
        local Y="10.0"

        local PIN_X1=$X
        local PIN_Y1=$Y
        local PIN_X2=$X
        local PIN_Y2="0.0"
        local NUM_X=$(calc $X-2*${SVG_ATOM})
        local NUM_Y=$(calc $Y-3*${SVG_ATOM})
        local NUM_ANCHOR="end"

        if [ "$PIN_EDGE" == "T" ]; then
            local DSC_X=$X
            local DSC_Y=$(calc $Y+2.0*${SVG_INTERIOR_PADDING})
            local DSC_ANCHOR="middle"
            local DSC_ROTATE=0
        else
            local DSC_X=$(calc $X+2.5*${SVG_ATOM})
            local DSC_Y=$(calc $Y+1.25*${SVG_INTERIOR_PADDING})
            local DSC_ANCHOR="end"
            local DSC_ROTATE=270
        fi
        ;;
    "B" | "b")
        local X=$(calc 10.0+${PIN_POS}*${SVG_CELL})
        local Y=$(calc ${SVG_VIEWBOX_HEIGHT}-10.0)

        local PIN_X1=$X
        local PIN_Y1=$Y
        local PIN_X2=$X
        local PIN_Y2=$SVG_VIEWBOX_HEIGHT
        local NUM_X=$(calc $X-2*${SVG_ATOM})
        local NUM_Y=$(calc $SVG_VIEWBOX_HEIGHT-2*${SVG_ATOM})
        local NUM_ANCHOR="end"

        if [ "$PIN_EDGE" == "B" ]; then
            local DSC_X=$X
            local DSC_Y=$(calc $Y-${SVG_INTERIOR_PADDING})
            local DSC_ANCHOR="middle"
            local DSC_ROTATE=0
        else
            local DSC_X=$(calc $X+2.5*${SVG_ATOM})
            local DSC_Y=$(calc $Y-${SVG_INTERIOR_PADDING})
            local DSC_ANCHOR="begin"
            local DSC_ROTATE=270
        fi
        ;;
    *)
        # Do nothing ...
        ;;
    esac

    svg "<line class='pin' id='connector${PIN_NUM}pin' connectorname='Pin ${PIN_NUM}' x1='${PIN_X1}' y1='${PIN_Y1}' x2='${PIN_X2}' y2='${PIN_Y2}' stroke='#000000' stroke-width='${SVG_PIN_STROKE_WIDTH}' />"
    svg "<rect class='terminal' id='connector${PIN_NUM}terminal' x='${PIN_X2}' y='${PIN_Y2}' width='0.0001' height='0.0001' stroke='none' stroke-width='0' fill='none' />"
    [ $DSC_ROTATE -eq 0 ] || svg "<g transform='rotate(${DSC_ROTATE} ${DSC_X} ${DSC_Y})'>"
    svg "<text class='text' font-family='${SVG_FONT_FAMILY}' font-size='${SVG_DESC_FONT_SIZE}' x='${DSC_X}' y='${DSC_Y}' fill='#000000' text-anchor='${DSC_ANCHOR}'>${PIN_DESC}</text>"
    [ $DSC_ROTATE -eq 0 ] || svg "</g>"
    [ -z "$IC_NOPINNR" ] && svg "<text class='text' font-family='${SVG_FONT_FAMILY}' font-size='${SVG_PINNUM_FONT_SIZE}' x='${NUM_X}' y='${NUM_Y}' fill='#000000' stroke='#000000' stroke-width='0.216' text-anchor='${NUM_ANCHOR}'>${PIN_NUM}</text>"
}

function svg_generate_pin_negation {
    local PIN_EDGE=$(dsc_edge $@)
    local PIN_POS=$(dsc_pos $@)
    local PIN_NUM=$(dsc_num $@)
    local PIN_DESC=$(dsc_description $@)

    case $PIN_EDGE in
    "L")
        local X="10.0"
        local Y=$(calc 10.0+${PIN_POS}*${SVG_CELL})

        local PIN_X1=$X
        local PIN_Y1=$Y
        local PIN_X2="0.0"
        local PIN_Y2=$Y
        local CX=$(calc ${X}-3*${SVG_ATOM})
        local CY=$Y
        local DSC_X=$(calc ${X}+${SVG_INTERIOR_PADDING})
        local DSC_Y=$(calc ${Y}+2.0)
        local DSC_ANCHOR="begin"
        local DSC_ROTATE=0
        local NUM_X="0.0"
        local NUM_Y=$(calc ${Y}-3.0*${SVG_ATOM})
        local NUM_ANCHOR="begin"
        ;;
    "R")
        local X=$(calc ${SVG_VIEWBOX_WIDTH}-10.0)
        local Y=$(calc 10.0+${PIN_POS}*${SVG_CELL})

        local PIN_X1=$X
        local PIN_Y1=$Y
        local PIN_X2=$SVG_VIEWBOX_WIDTH
        local PIN_Y2=$Y
        local CX=$(calc ${X}+3*${SVG_ATOM})
        local CY=$Y
        local DSC_X=$(calc ${X}-${SVG_INTERIOR_PADDING})
        local DSC_Y=$(calc ${Y}+2.0)
        local DSC_ANCHOR="end"
        local DSC_ROTATE=0
        local NUM_X=$(calc ${X}+2*${SVG_CELL})
        local NUM_Y=$(calc ${Y}-3.0*${SVG_ATOM})
        local NUM_ANCHOR="end"
        ;;
    "T" | "t")
        local X=$(calc 10.0+${PIN_POS}*${SVG_CELL})
        local Y="10.0"

        local PIN_X1=$X
        local PIN_Y1=$Y
        local PIN_X2=$X
        local PIN_Y2="0.0"
        local CX=$X
        local CY=$(calc ${Y}-3*${SVG_ATOM})
        local NUM_X=$(calc $X-3*${SVG_ATOM})
        local NUM_Y=$(calc $Y-4*${SVG_ATOM})
        local NUM_ANCHOR="end"

        if [ "$PIN_EDGE" == "T" ]; then
            local DSC_X=$X
            local DSC_Y=$(calc $Y+2.0*${SVG_INTERIOR_PADDING})
            local DSC_ANCHOR="middle"
            local DSC_ROTATE=0
        else
            local DSC_X=$(calc $X+2.5*${SVG_ATOM})
            local DSC_Y=$(calc $Y+1.25*${SVG_INTERIOR_PADDING})
            local DSC_ANCHOR="end"
            local DSC_ROTATE=270
        fi
        ;;
    "B" | "b")
        # TODO
        ;;
    *)
        # Do nothing ...
        ;;
    esac

    svg "<line class='pin' id='connector${PIN_NUM}pin' connectorname='Pin ${PIN_NUM}' x1='${PIN_X1}' y1='${PIN_Y1}' x2='${PIN_X2}' y2='${PIN_Y2}' stroke='#000000' stroke-width='${SVG_PIN_STROKE_WIDTH}' />"
    svg "<rect class='terminal' id='connector${PIN_NUM}terminal' x='${PIN_X2}' y='${PIN_Y2}' width='0.0001' height='0.0001' stroke='none' stroke-width='0' fill='none' />"
    svg "<circle class='other' cx='${CX}' cy='${CY}' r='1.75' stroke='black' stroke-width='1.44' fill='white' />"
    [ $DSC_ROTATE -eq 0 ] || svg "<g transform='rotate(${DSC_ROTATE} ${DSC_X} ${DSC_Y})'>"
    svg "<text class='text' font-family='${SVG_FONT_FAMILY}' font-size='${SVG_DESC_FONT_SIZE}' x='${DSC_X}' y='${DSC_Y}' fill='#000000' text-anchor='${DSC_ANCHOR}'>${PIN_DESC}</text>"
    [ $DSC_ROTATE -eq 0 ] || svg "</g>"
    [ -z "$IC_NOPINNR" ] && svg "<text class='text' font-family='${SVG_FONT_FAMILY}' font-size='${SVG_PINNUM_FONT_SIZE}' x='${NUM_X}' y='${NUM_Y}' fill='#000000' stroke='#000000' stroke-width='0.216' text-anchor='${NUM_ANCHOR}'>${PIN_NUM}</text>"
}

function svg_generate_pin_clock {
    local PIN_EDGE=$(dsc_edge $@)
    local PIN_POS=$(dsc_pos $@)
    local PIN_NUM=$(dsc_num $@)
    local PIN_DESC=$(dsc_description $@)

    case $PIN_EDGE in
    "L")
        local X="10.0"
        local Y=`calc "10.0+${PIN_POS}*${SVG_CELL}"`

        local PIN_X1=$X
        local PIN_Y1=$Y
        local PIN_X2="0.0"
        local PIN_Y2=$Y
        local CLK_X1=$X
        local CLK_Y1=`calc "${Y}-3*${SVG_ATOM}"`
        local CLK_X2=`calc "${X}+5*${SVG_ATOM}"`
        local CLK_Y2=$Y
        local CLK_X3=$X
        local CLK_Y3=`calc "${Y}+3*${SVG_ATOM}"`
        local DSC_X=`calc "${X}+${SVG_INTERIOR_PADDING}+2*${SVG_ATOM}"`
        local DSC_Y=`calc "${Y}+2.0"`
        local DSC_ANCHOR="begin"
        local DSC_ROTATE=0
        local NUM_X=`calc "${X}-2*${SVG_CELL}"`
        local NUM_Y=`calc "${Y}-2*${SVG_ATOM}"`
        local NUM_ANCHOR="begin"
        ;;
    "R")
        local X=`calc "${SVG_VIEWBOX_WIDTH}-10.0"`
        local Y=`calc "10.0+${PIN_POS}*${SVG_CELL}"`

        local PIN_X1=$X
        local PIN_Y1=$Y
        local PIN_X2=$SVG_VIEWBOX_WIDTH
        local PIN_Y2=$Y
        local CLK_X1=$X
        local CLK_Y1=`calc "${Y}-3*${SVG_ATOM}"`
        local CLK_X2=`calc "${X}-5*${SVG_ATOM}"`
        local CLK_Y2=$Y
        local CLK_X3=$X
        local CLK_Y3=`calc "${Y}+3*${SVG_ATOM}"`
        local DSC_X=`calc "${X}-${SVG_INTERIOR_PADDING}-2*${SVG_ATOM}"`
        local DSC_Y=`calc "${Y}+2.0"`
        local DSC_ANCHOR="end"
        local DSC_ROTATE=0
        local NUM_X=`calc "${X}+2*${SVG_CELL}"`
        local NUM_Y=`calc "${Y}-2*${SVG_ATOM}"`
        local NUM_ANCHOR="end"
        ;;
    "T")
        # TODO
        ;;
    "B")
        # TODO
        ;;
    *)
        # Do nothing ...
        ;;
    esac

    svg "<line class='pin' id='connector${PIN_NUM}pin' connectorname='Pin ${PIN_NUM}' x1='${PIN_X1}' y1='${PIN_Y1}' x2='${PIN_X2}' y2='${PIN_Y2}' stroke='#000000' stroke-width='${SVG_PIN_STROKE_WIDTH}' />"
    svg "<rect class='terminal' id='connector${PIN_NUM}terminal' x='${PIN_X2}' y='${PIN_Y2}' width='0.0001' height='0.0001' stroke='none' stroke-width='0' fill='none' />"
    svg "<line class='other' x1='$CLK_X1' y1='$CLK_Y1' x2='$CLK_X2' y2='$CLK_Y2' stroke='#000000' stroke-width='1.0' stroke-linecap='round' />"
    svg "<line class='other' x1='$CLK_X2' y1='$CLK_Y2' x2='$CLK_X3' y2='$CLK_Y3' stroke='#000000' stroke-width='1.0' stroke-linecap='round' />"
    [ $DSC_ROTATE -eq 0 ] || svg "<g transform='rotate(${DSC_ROTATE} ${DSC_X} ${DSC_Y})'>"
    svg "<text class='text' font-family='${SVG_FONT_FAMILY}' font-size='${SVG_DESC_FONT_SIZE}' x='${DSC_X}' y='${DSC_Y}' fill='#000000' text-anchor='${DSC_ANCHOR}'>${PIN_DESC}</text>"
    [ $DSC_ROTATE -eq 0 ] || svg "</g>"
    [ -z "$IC_NOPINNR" ] && svg "<text class='text' font-family='${SVG_FONT_FAMILY}' font-size='${SVG_PINNUM_FONT_SIZE}' x='${NUM_X}' y='${NUM_Y}' fill='#000000' stroke='#000000' stroke-width='0.216' text-anchor='${NUM_ANCHOR}'>${PIN_NUM}</text>"
}

# SVG constants
SVG_ATOM="1.0"
SVG_CELL="5.0"
SVG_PIN_STROKE_WIDTH="0.971875"
SVG_FONT_FAMILY="Arial"
SVG_DESC_FONT_SIZE="7"
SVG_PINNUM_FONT_SIZE="7"

# Math magic done by bc - An arbitrary precision calculator language
SVG_VIEWBOX_WIDTH=`calc "20.0+${IC_WIDTH}*${SVG_CELL}"`
SVG_VIEWBOX_HEIGHT=`calc "20.0+${IC_HEIGHT}*${SVG_CELL}"`
SVG_WIDTH=`calc 3 "${SVG_VIEWBOX_WIDTH}/100.0"`
SVG_HEIGHT=`calc 3 "${SVG_VIEWBOX_HEIGHT}/100.0"`
SVG_INTERIOR_WIDTH=`calc "${IC_WIDTH}*${SVG_CELL}"`
SVG_INTERIOR_HEIGHT=`calc "${IC_HEIGHT}*${SVG_CELL}"`
SVG_INTERIOR_PADDING="$SVG_CELL"
SVG_INTERIOR_STROKE_WIDTH="1.6"

svg "<?xml version='1.0' encoding='UTF-8' standalone='no'?>"
svg "<svg xmlns:svg='http://www.w3.org/2000/svg' xmlns='http://www.w3.org/2000/svg' version='1.2' baseProfile='tiny' x='0in' y='0in' width='${SVG_WIDTH}in' height='${SVG_HEIGHT}in' viewBox='0 0 $SVG_VIEWBOX_WIDTH $SVG_VIEWBOX_HEIGHT'>"
svg "<g id='schematic'>"
svg "<rect class='interior rect' x='10.0' y='10.0' width='${SVG_INTERIOR_WIDTH}' height='${SVG_INTERIOR_HEIGHT}' rx='0.1' fill='${IC_TINT}' stroke='#000000' stroke-width='${SVG_INTERIOR_STROKE_WIDTH}' stroke-linecap='round' />"

for ENTRY in "${DSC[@]}"; do
    DSC_TYPE=$(dsc_type $ENTRY)
    case $DSC_TYPE in
    '-')
        svg_generate_pin_normal "$ENTRY"
        ;;
    'o')
        svg_generate_pin_negation "$ENTRY"
        ;;
    '>' | '<')
        svg_generate_pin_clock "$ENTRY"
        ;;
    *)
        # Friendly warning, typo?
        icwarning "Unsupported pin type \"${DSC_TYPE}\" in \"${ENTRY}\""
        ;;
    esac

    # Remember the last description position
    DSC_POS=$(dsc_pos $ENTRY)
    case $(dsc_edge $ENTRY) in
        "L"|"l")
            DSC_LAST_L=$DSC_POS
            ;;
        "R"|"r")
            DSC_LAST_R=$DSC_POS
            ;;
        "T"|"t")
            DSC_LAST_T=$DSC_POS
            ;;
        "B"|"b")
            DSC_LAST_B=$DSC_POS
            ;;
        *)
            # Do nothing ...
            ;;
    esac
done

svg "</g>"
svg "</svg>"

[ -n "$FLAG_GEN_SVG" ] && generate_svg > ${OUT_SVG_PATH}/${IC_FILE_BASENAME}.svg

# Happy finish
exit 0
