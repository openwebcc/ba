#!/bin/bash
#
# Kaunertal 20.04.2011, 21.04.2011, 22.04.2011 und 23.04.2011
#

BASE=/home/laser/rawdata/als/musicals/110420_kaunertal02
BASE_MUSICALS=/mnt/netappa/Rohdaten/P7160_MUSICALS/2011/Laserpunkte/Utm

# copy trajectories and documentation
cp -avu $BASE_MUSICALS/../../Flugpfade/1104*.bet $BASE/raw/str/bet/
cp -avu $BASE_MUSICALS/../../TopScanBefliegungsbericht_MUSICALS_2011.pdf $BASE/doc/report.pdf

# fix missing LAS files that could not be restored from external disk
for FNAME in `echo L0117-1-110421_1_221_Kaunertal2011_UTM L0118-1-110421_1_221_Kaunertal2011_UTM`
do
    echo "creating missing $BASE_MUSICALS/Las/$FNAME.las ..."

    # reorder columns first as GPS-time is located in column four and expected in column one in .alf and .all files; remove leading 32 as well
    cat $BASE_MUSICALS/First/$FNAME.alf | awk '{gsub(/^32/,"",$1);print $4 " " $1 " " $2 " " $3 " " $5}' > /tmp/$FNAME.alf
    cat $BASE_MUSICALS/Last/$FNAME.all | awk '{gsub(/^32/,"",$1);print $4 " " $1 " " $2 " " $3 " " $5}' > /tmp/$FNAME.all

    # merge .alf and .all file
    python /home/laser/rawdata/maintenance/scripts/als/merge_first_last.py \
        --dist=0.0 \
        --first=/tmp/$FNAME.alf \
        --last=/tmp/$FNAME.all \
        --out=$BASE_MUSICALS/Las/$FNAME.las

    # remove temporary files
    rm /tmp/$FNAME.*

done

# migrate LAS files
cd $BASE_MUSICALS/Las
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
    lasindex -i $LAS 2>>/dev/null

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
