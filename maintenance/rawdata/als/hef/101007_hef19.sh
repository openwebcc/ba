#!/bin/bash
#
# Hintereisferner 07.10.2010, 08.10.2010, 09.10.2010, 10.10.2010, 11.10.2010 und 12.10.2010
# data is extracted from musicals/101007_kaunertal01

BASE=/home/laser/rawdata/als/hef/101007_hef19
BASE_MUSICALS=/home/laser/rawdata/als/musicals/101007_kaunertal01
TMPDIR=/tmp/hef19

# copy trajectories and documentation
cp -avu $BASE_MUSICALS/bet/*.bet $BASE/bet/
cp -avu $BASE_MUSICALS/doc/report.pdf $BASE/doc/report.pdf

# get extent of HEF project polygon
OGR_EXT=`ogrinfo /home/laser/rawdata/maintenance/util/aoi/hef_25832.geojson OGRGeoJSON -so | grep Extent`
KEEP_XY=`echo $OGR_EXT | sed -e 's/[a-zA-Z:,\(\)\-]//g'`

# clip data of musicals campaign on extent of HEF project extent
mkdir $TMPDIR
cd $BASE_MUSICALS/las
for LAS in `ls *.las`
do
    # clip on HEF extent
    echo "clipping $LAS on extent ..."
    las2las -i $BASE_MUSICALS/las/$LAS -odir $TMPDIR -olas -keep_xy $KEEP_XY

    # remove empty clipping result indicated by filesize less than 350
    if [ $(wc -c <"$TMPDIR/$LAS") -le 350 ]; then
        echo "    no points found within extent"
    else
        # clip on HEF project polygon and stor
        echo "clipping $LAS on project polygon ..."
        python /home/laser/rawdata/maintenance/scripts/als/clip_lasfile.py \
            --lasfile $TMPDIR/$LAS \
            --wktpoly /home/laser/rawdata/maintenance/util/aoi/hef_25832.wkt \
            --outdir $BASE/las

        # remove temporary file
        rm -f $TMPDIR/$LAS

        # correct systm LAS attributes
        lasinfo -i $BASE/las/$LAS -set_system_identifier "ALTM Gemini" -set_generating_software "OptechLMS" -repair > /dev/null 2>&1

        # create lasindex
        lasindex -i $BASE/las/$LAS 2>>/dev/null

    fi
done

# remove empty data strips as results of clipping on project polygon
find $BASE/las -size -350c -exec rm -f {} \;

# remove temporary directory
rm -rf $TMPDIR/

