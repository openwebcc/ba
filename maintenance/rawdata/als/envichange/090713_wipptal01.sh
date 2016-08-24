#!/bin/bash
#
# Wipptal (Envichange) 13.7.2009, 14.7.2009
#
# Note: projection is unsure as data seems to be shifted to the west a bit
#       without translating x-coordinates by 600000 strips end up in centre of france ...
#

BASE=/home/laser/rawdata/als/envichange/090713_wipptal01

# migrate LAS files
cd $BASE/raw/str/las
for LAS in `ls *.las`
do
    echo "creating $BASE/las/$LAS ..."

    # remove offset and scale x,y,z
    las2las -i $LAS \
            -o $BASE/las/$LAS \
            -translate_x 600000 \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01

    # set system identifier and generating software to original values
    lasinfo -i $BASE/las/$LAS \
            -set_system_identifier "ALTM 3100" > /dev/null 2>&1

    # create lasindex
    lasindex -i $BASE/las/$LAS 2>>/dev/null

done

# set day of year and year
cd $BASE/las
find . -name "*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 194 2009 \;
find . -name "*Str_2[5678]*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 195 2009 \;
