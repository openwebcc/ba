#!/bin/bash
#
# Hintereisferner 20.04.2011, 21.04.2011, 22.04.2011 und 23.04.2011
# data is extracted from musicals/110420_kaunertal02

BASE=/home/rawdata/als/hef/110420_hef20
BASE_MUSICALS=/home/rawdata/als/musicals/110420_kaunertal02
TMPDIR=/tmp/hef20

# copy trajectories and documentation
cp -avu $BASE_MUSICALS/bet/*.bet $BASE/bet/
cp -avu $BASE_MUSICALS/doc/report.pdf $BASE/doc/report.pdf

# get extent of HEF project polygon
OGR_EXT=`ogrinfo /home/institut/rawdata/maintenance/util/aoi/hef_25832.geojson OGRGeoJSON -so | grep Extent`
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
        python /home/institut/rawdata/maintenance/scripts/als/clip_lasfile.py \
            --lasfile $TMPDIR/$LAS \
            --wktpoly /home/institut/rawdata/maintenance/util/aoi/hef_25832.wkt \
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
