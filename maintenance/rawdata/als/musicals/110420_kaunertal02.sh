#!/bin/bash
#
# Kaunertal 20.04.2011, 21.04.2011, 22.04.2011 und 23.04.2011
#

BASE=/home/rawdata/als/musicals/110420_kaunertal02

# migrate LAS files
cd $BASE/raw/str/las
for LAS in `ls *.las`
do
    echo "creating $BASE/las/$LAS ..."

    # remove offset and scale x,y,z
    las2las -i $LAS \
            -o $BASE/las/$LAS \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01

    # set system identifier and generating software to original values
    lasinfo -i $BASE/las/$LAS \
            -set_system_identifier "ALTM Gemini" \
            -set_generating_software "OptechLMS" > /dev/null 2>&1

    # create lasindex
    lasindex -i $BASE/las/$LAS 2>>/dev/null

done

# set day of year and year
cd $BASE/las
find . -name "*110420*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 110 2011 \;
find . -name "*110421*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 111 2011 \;
find . -name "*110422*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 112 2011 \;
find . -name "*110423*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 113 2011 \;

# copy cleaned trajectories
cd $BASE/raw/str/bet
for BET in `ls *.bet`
do
    echo "creating $BASE/bet/$BET ..."
    cat $BET | awk '{gsub(/^32/,"",$2); print}' > $BASE/bet/$BET
done
