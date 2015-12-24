#!/bin/sh
#
# Datenmigration: Befliegung Hintereisferner, 09.01.2002
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/hef/020109_hef02/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/hef/020109_hef02
cp -avu /mnt/netappa/Rohdaten/hef/hef02_020109/kach/all/*.all ./asc/
cp -avu /mnt/netappa/Rohdaten/hef/TopScanBefliegungsbericht_HEF2001bis2003.pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen und nach LAS konvertieren
cd /home/laser/rawdata/als/hef/020109_hef02/asc/
for ALL in `ls *.all`
do
    echo "strip32 and clean $ALL ..."
    awk '{gsub(/^32/,"",$1); print}' $ALL > $ALL.tmp
    mv $ALL.tmp $ALL

    LAS=`echo $ALL | sed s/\.[^\.]*$/.las/`
    echo "creating ../las/$LAS ..."
    txt2las -i $ALL \
            -o ../las/$LAS \
            -parse xyzi \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 25832 \
            -set_file_creation 9 2002 \
            -set_system_identifier "ALTM 1225"
done
