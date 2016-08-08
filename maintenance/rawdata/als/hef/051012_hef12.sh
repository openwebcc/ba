#!/bin/bash
#
# Hintereisferner, 12.10.2005
#

BASE=/home/laser/rawdata/als/hef/051012_hef12

cd $BASE/raw/str/alf
for GZ in `ls *.alf.gz`
do
    FNAME=`echo $GZ | sed s/.alf.gz//`

    # set paths to files
    ALF=`echo $BASE/raw/str/alf/$FNAME.alf`
    ALL=`echo $BASE/raw/str/all/$FNAME.all`
    ALA=`echo $BASE/raw/str/ala/$FNAME.ala`
    LAS=`echo $BASE/las/$FNAME.las`

    # temporarily uncompress .alf.gz and .all.gz files and remove leading 32 from x-coordinates
    echo "creating $ALF (temporary) ..."
    gunzip -c $BASE/raw/str/alf/$FNAME.alf.gz | awk '{gsub(/^32/,"",$2); print}' > $ALF
    echo "creating $ALL (temporary) ..."
    gunzip -c $BASE/raw/str/all/$FNAME.all.gz | awk '{gsub(/^32/,"",$2); print}' > $ALL

    # merge .alf and .all files with a python script
    echo "creating $ALA (temporary) ..."
    python /home/laser/rawdata/maintenance/scripts/als/merge_first_last.py --dist=0.1 --first=$ALF --last=$ALL --out=$ALA

    # remove temporarily uncompressed .alf.gz and .all.gz files
    rm $ALF
    rm $ALL

    echo "creating $LAS ..."
    # nach LAS konvertieren
    txt2las -i $ALA \
            -o $LAS \
            -iparse txyzirn \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 25832 \
            -set_file_creation 285 2005 \
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
