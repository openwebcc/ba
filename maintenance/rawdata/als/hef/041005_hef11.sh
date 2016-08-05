#!/bin/bash
#
# Hintereisferner, 05.04.2010
#

BASE=/home/laser/rawdata/als/hef/041005_hef11

# create cleaned .alf and .all files
for EXT in `echo "alf all"`
do
    cd $BASE/raw/str/$EXT
    for GZ in `ls *.$EXT.gz`
    do
        TMP=`echo $BASE/raw/$GZ | sed s/.$EXT.gz/.$EXT/`
        gunzip -c $GZ | awk '{gsub(/^32/,"",$2); print}' > $TMP
        echo "creating $TMP ..."
    done
done

# merge .alf and .all files with a python script
cd $BASE/raw/
for ALF in `ls *.alf`
do
    ALL=`echo $BASE/raw/$ALF | sed s/.alf/.all/`
    ALA=`echo $BASE/raw/$ALF | sed s/.alf/.ala/`
    LAS=`echo $BASE/las/$ALF | sed s/.alf/.las/`

    sh /home/laser/rawdata/maintenance/rawdata/als/hef/fix_merge_alf_all.sh $BASE/raw/$ALF

    # clean up temporary files
    rm $ALF
    rm $ALL

    echo "creating $LAS ..."

    # convert to LAS
    txt2las -i $ALA \
            -o $LAS \
            -iparse txyzirn \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 25832 \
            -set_file_creation 279 2004 \
            -set_system_identifier "ALTM 2050"

    # create lasindex
    lasindex -i $LAS 2>>/dev/null

done

# copy cleaned trajectories
cd $BASE/raw/str/bet
for BET in `ls *.bet`
do
    echo "creating $BASE/bet/$BET ..."
    cat $BET | awk '{gsub(/^32/,"",$2); print}' > $BASE/bet/$BET
done
