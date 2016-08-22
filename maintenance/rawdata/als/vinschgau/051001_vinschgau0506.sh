#!/bin/bash
#
# Südtirol 2005/2006
#
# exact date of campaign is not know, according to Galos et al. 2015 it is "mid of september" - choose sat, october 1st 2005 for all files
#

BASE=/home/laser/rawdata/als/vinschgau/051001_vinschgau0506

for SUBDIR in `echo "all xyz"`
do
    cd $BASE/raw/str/$SUBDIR

    for GZ in `ls *.gz`
    do
        TMP=`echo $BASE/raw/$GZ | sed s/.txt.gz/.txt/`
        LAS=`echo $BASE/las/$GZ | sed s/.txt.gz/.las/`

        echo "creating $LAS ..."

        # unpack and remove header
        zcat $GZ | grep -v x > $TMP

        # set -parse argument accordingly
        if test "$GZ" = "3_schnals_teil2.txt.gz"; then
            PARSE=xyz
        elif test "$GZ" = "12_aoi_zusatz.txt.gz"; then
            PARSE=xyzt
        else
            PARSE=xyztrnis
        fi

        # convert to LAS
        txt2las -i $TMP \
                -o $LAS \
                -parse $PARSE \
                -reoffset 0 0 0 \
                -rescale 0.01 0.01 0.01 \
                -set_file_creation 274 2005 \
                -epsg 25832

        # create lasindex
        lasindex -i $LAS 2>>/dev/null

        rm -f $TMP

    done
done
