#!/bin/sh
#
# Datenmigration: Befliegung Sulztalferner, Reichenkar, 11.10.2007
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/c4austria/071011_sulz_reich/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/c4austria/071011_sulz_reich/
cp -avu /mnt/netappa/Rohdaten/P7160_012_043_C4AUSTRIA/reichenkar2007/*.all ./asc/
cp -avu /mnt/netappa/Rohdaten/P7160_012_043_C4AUSTRIA/reichenkar2007/TopScanBefliegungsbericht_SulztalfReichenkar2007.pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen
cd /home/laser/rawdata/als/c4austria/071011_sulz_reich/asc
for ALL in `ls *.all`
do
    echo "strip32 and clean $ALL ..."
    awk '{gsub(/^32/,"",$2); print}' $ALL > $ALL.tmp
    mv $ALL.tmp $ALL

done

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/c4austria/071011_sulz_reich/asc/*.all \
        -odir /home/laser/rawdata/als/c4austria/071011_sulz_reich/las \
        -parse xyzi \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 25832 \
        -set_file_creation 284 2007 \
        -set_system_identifier "ALTM 3100"


# Flugtrajektorie fehlt leider
echo "WARNING: keine Flugtrajektorie vorhanden"