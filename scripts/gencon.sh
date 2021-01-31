#!/bin/bash
#
# Helper script to generate bunch of connectors
# Copyright (C) 2019 by di0x7c5
#

function gencon {
    echo "        <connector id=\"connector$1\" name=\"$1\" type=\"male\">"
    echo "            <description>Pin $1</description>"
    echo "            <views>"
    echo "                <schematicView>"
    echo "                    <p layer=\"schematic\" svgId=\"connector$1pin\" terminalId=\"connector$1terminal\" />"
    echo "                </schematicView>"
    echo "            </views>"
    echo "        </connector>"
}

for NUM in $(seq 0 $1); do gencon $NUM; done
