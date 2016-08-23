#!/bin/sh
#
# rebuild two missing LAS files that could not be restored from external disk by merging .alf and .all files
#

BASE=/home/laser/rawdata/als/musicals/110420_kaunertal02

for FNAME in `echo L0117-1-110421_1_221_Kaunertal2011_UTM L0118-1-110421_1_221_Kaunertal2011_UTM`
do
    # reorder columns first as GPS-time is located in column four and expected in column one in .alf and .all files; remove leading 32 as well
    echo "creating $BASE/raw/$FNAME.alf (temporary) ..."
    zcat $BASE/raw/str/alf/$FNAME.alf.gz | awk '{gsub(/^32/,"",$1);print $4 " " $1 " " $2 " " $3 " " $5}' > $BASE/raw/$FNAME.alf
    echo "creating $BASE/raw/$FNAME.all (temporary) ..."
    zcat $BASE/raw/str/all/$FNAME.all.gz | awk '{gsub(/^32/,"",$1);print $4 " " $1 " " $2 " " $3 " " $5}' > $BASE/raw/$FNAME.all

    # merge .alf and .all file
    echo "creating $BASE/raw/$FNAME.ala (temporary) ..."
    python /home/laser/rawdata/maintenance/scripts/als/merge_first_last.py \
        --dist=0.0 \
        --first=$BASE/raw/$FNAME.alf \
        --last=$BASE/raw/$FNAME.all \
        --out=$BASE/raw/$FNAME.ala

    # convert to LAS
    echo "creating $BASE/raw/str/las/$FNAME.las ..."
    txt2las -i $BASE/raw/$FNAME.ala \
            -o $BASE/raw/str/las/$FNAME.las \
            -iparse txyzirn \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 32632 \
            -set_file_creation 111 2011 \
            -set_system_identifier "ALTM Gemini"

    # remove temporary files
    rm $BASE/raw/$FNAME.al*

done
