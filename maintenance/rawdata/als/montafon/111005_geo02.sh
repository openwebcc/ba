#!/bin/bash
#
# Nachflug Montafon 05.10.2011
#

BASE=/home/rawdata/als/montafon/111005_geo02

cd $BASE/raw/str/ala
for GZ in `ls *.all.gz`
do
    TMP=`echo $BASE/raw/$GZ | sed s/.all.gz/.all/`
    LAS=`echo $BASE/las/$GZ | sed s/.all.gz/.las/`

    echo "creating $LAS ..."

    # unpack
    gunzip -c $GZ > $TMP

    # convert to LAS
    txt2las -i $TMP \
            -o $LAS \
            -parse txyzirn \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 25832 \
            -set_file_creation 278 2011 \
            -set_system_identifier "ALTM 3100"

    # create lasindex
    lasindex -i $LAS 2>>/dev/null

    rm -f $TMP
done

# copy trajectories
cp -av $BASE/raw/str/bet/*.bet $BASE/bet/
