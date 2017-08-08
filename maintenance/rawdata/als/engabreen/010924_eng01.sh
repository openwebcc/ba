#!/bin/bash
#
# Engabreen 24.9.2001
#

BASE=/home/rawdata/als/engabreen/010924_eng01

# convert to LAS
cd $BASE/raw/str/all
for GZ in `ls *.all.gz`
do
    FNAME=`echo $GZ | sed s/.all.gz//`
    TMP=`echo $BASE/raw/str/all/$FNAME.all`
    LAS=`echo $BASE/las/$FNAME.las`

    echo "creating $LAS ..."

    zcat $GZ > $TMP
    txt2las -i $TMP \
            -o $LAS \
            -parse xyzi \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 32633 \
            -set_file_creation 267 2001 \
            -set_system_identifier "ALTM 1225"

    # create lasindex
    lasindex -i $LAS 2>>/dev/null

    rm -f $TMP
done
