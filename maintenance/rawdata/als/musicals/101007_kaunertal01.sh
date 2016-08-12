#!/bin/bash
#
# Kaunertal 07.10.2010, 08.10.2010, 09.10.2010, 10.10.2010, 11.10.2010 und 12.10.2010
#

BASE=/home/laser/rawdata/als/musicals/101007_kaunertal01
BASE_MUSICALS=/mnt/netappa/Rohdaten/P7160_MUSICALS/2010/

# copy trajectories and documentation
cp -avu $BASE_MUSICALS/Flugpfade/1010*.bet $BASE/raw/str/bet/
cp -avu $BASE_MUSICALS/TopScanBefliegungsbericht_MUSICALS_2010.pdf $BASE/doc/report.pdf

# migrate LAS files
cd $BASE_MUSICALS/Laserpunkte/Utm/Las
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
find . -name "*101007*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 280 2010 \;
find . -name "*101008*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 281 2010 \;
find . -name "*101009*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 282 2010 \;
find . -name "*101010*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 283 2010 \;
find . -name "*101011*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 284 2010 \;
find . -name "*101012*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 285 2010 \;

# copy cleaned trajectories
cd $BASE/raw/str/bet
for BET in `ls *.bet`
do
    echo "creating $BASE/bet/$BET ..."
    cat $BET | awk '{gsub(/^32/,"",$2); print}' > $BASE/bet/$BET
done
