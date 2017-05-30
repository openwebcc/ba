#!/bin/bash
#
# Schmirntal & surrounding area (Land Tirol): 10.08.2008 to 09.09.2008 (29.08.2008 as main date))
#

BASE=/home/laser/rawdata/als/schmirn/080829_land1

# migrate LAS files
cd $BASE/raw/kach/las
for LAS in `ls *.las`
do
    echo "creating $BASE/las/$LAS ..."

    # remove offset and scale x,y,z, set EPSG-code and return numbers
    las2las -i $LAS \
            -o $BASE/las/$LAS \
            -epsg 32632 \
            -set_return_number 1 \
            -set_number_of_returns 1

    # set file creation date
    lasinfo -i $BASE/las/$LAS -set_file_creation 242 2008 > /dev/null 2>&1

    # create lasindex
    lasindex -i $BASE/las/$LAS 2>>/dev/null

done
