#!/bin/bash
#
# Engabreen 23.8.2002
#

BASE=/home/rawdata/als/engabreen/020823_eng03

# convert to LAS
cd $BASE/raw/kach/all
for GZ in `ls *.all.gz`
do
    FNAME=`echo $GZ | sed s/.all.gz//`
    TMP=`echo $BASE/raw/kach/all/$FNAME.all`
    LAS=`echo $BASE/las/$FNAME.las`

    echo "creating $LAS ..."

    zcat $GZ > $TMP
    txt2las -i $TMP \
            -o $LAS \
            -parse xyzi \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 32633 \
            -set_file_creation 235 2002 \
            -set_system_identifier "ALTM 1225"

    # create lasindex
    lasindex -i $LAS 2>>/dev/null

    rm -f $TMP
done
