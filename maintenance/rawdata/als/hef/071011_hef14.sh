#!/bin/bash
#
# Hintereisferner, 11.10.2007
#

BASE=/home/laser/rawdata/als/hef/071011_hef14

cd $BASE/raw/bad/ala
for GZ in `ls *.ala.gz`
do
    FNAME=`echo $GZ | sed s/.ala.gz//`

    # set paths to files
    ALA=`echo $BASE/raw/str/ala/$FNAME.ala`
    LAS=`echo $BASE/las/$FNAME.las`

    # temporarily uncompress .ala.gz file and remove leading 32 from x-coordinates
    echo "creating $ALA.tmp (temporary) ..."
    gunzip -c $GZ | awk '{gsub(/^32/,"",$2); print}' > $ALA.tmp

    # clean return number syntax in .ala file with a python script
    echo "cleaning $ALA ..."
    python /home/laser/rawdata/maintenance/rawdata/als/hef/071011_hef14_fix_ala.py --ala=$ALA.tmp --out=$ALA

    # remove temporarily uncompressed .ala.gz file
    rm $ALA.tmp

    echo "creating $LAS ..."

    # convert to LAS
    txt2las -i $ALA \
            -o $LAS \
            -iparse txyzirn \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 25832 \
            -set_file_creation 284 2007 \
            -set_system_identifier "ALTM 3100"

    # create lasindex
    lasindex -i $LAS 2>>/dev/null

    # compress .ala file
    echo "creating $ALA.gz ..."
    gzip -f $ALA

done

# copy cleaned trajectories
cd $BASE/raw/str/bet
for BET in `ls *.bet`
do
    echo "creating $BASE/bet/$BET ..."
    cat $BET | awk '{gsub(/^32/,"",$2); print}' > $BASE/bet/$BET
done
