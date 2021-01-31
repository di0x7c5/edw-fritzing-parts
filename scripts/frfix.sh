#!/bin/bash
#
# Fix known errors in exported SVG files
# Copyright (C) 2019 by di0x7c5
#

if [ $# -eq 0 ]
then
  exit 1
fi

if [ ! -f "$1" ]
then
  echo "Error: File \"$1\" doesn't exist!"
  exit 1
fi

if [[ ! $1 =~ \.svg$ ]]
then
  echo "Error: File \"$1\" is not SVG!"
  exit 1
fi

sed -i 's/#404040/#000000/g' $1
sed -i 's/DroidSans/Arial/g' $1

