#!/bin/bash
#
# Äußeres Hochebenkar, Inneres Reichenkar, Schrankar, Ölgrube,  30.9.2009
#

BASE=/home/laser/rawdata/als/c4austria/090930_hocheben_reich_schrank_oel

# fix date and coordinates of original .las files
cd $BASE/raw/str/las
for ORG in `ls *.las`
do

    TXT=`echo $BASE/raw/$ORG | sed s/.las$/.txt/`
    LAS=`echo $BASE/las/$ORG`

    echo "creating $TXT (temporary) ..."
    las2txt -i $ORG -o $TXT -parse txyzirn -translate_x 600000 -translate_y 5000000 -rescale 0.01 0.01 0.01

    echo "creating $LAS ..."
    txt2las -i $TXT \
            -o $LAS \
            -parse txyzirn \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 32632 \
            -set_file_creation 273 2009 \
            -set_system_identifier "ALTM 3100"

    # create lasindex
    lasindex -i $LAS 2>>/dev/null

    rm -f $TXT

done

# copy cleaned trajectories
cd $BASE/raw/str/bet
for BET in `ls *.bet`
do
    echo "creating $BASE/bet/$BET ..."
    cat $BET | awk '{gsub(/^32/,"",$2); print}' > $BASE/bet/$BET
done
