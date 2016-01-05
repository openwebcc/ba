#!/bin/sh
#
# Datenmigration: Befliegung Südtirol 2005/2006
# Exaktes Datum nicht bekannt. Nach Galos et al. 2015 "Mitte September". Freitag, 16.9.2005 gewählt
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/vinschgau/051001_suedtirol_2005_2006/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/vinschgau/051001_suedtirol_2005_2006
cp -avu /mnt/netappa/Rohdaten/Suedtirol_2005_2006/data/[12456789]*.txt ./asc/
cp -avu /mnt/netappa/Rohdaten/Suedtirol_2005_2006/data/import/3.txt ./asc/
cp -avu /mnt/netappa/Rohdaten/Suedtirol_2005_2006/data/AOI_Zusatz/12.txt ./asc/
cp -avu /mnt/netappa/Rohdaten/Suedtirol_2005_2006/nutzungsbedingungen.odt ./doc/

# nach LAS konvertieren
cd /home/laser/rawdata/als/vinschgau/051001_suedtirol_2005_2006/asc/
for N in `echo 1 2 4 5 6 7 8 9 10 11`
do
    echo "erzeuge ../las/$N.las ..."
    txt2las -i $N.txt \
            -o ../las/$N.las \
            -parse xyzsssss \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -set_file_creation 259 2005 \
            -epsg 25832
done

echo "erzeuge ../las/3.las ..."
txt2las -i 3.txt \
        -o ../las/3.las \
        -parse xyz \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -set_file_creation 259 2005 \
        -epsg 25832

echo "erzeuge ../las/12.las ..."
txt2las -i 12.txt \
        -o ../las/12.las \
        -parse xyzss \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -set_file_creation 259 2005 \
        -epsg 25832
