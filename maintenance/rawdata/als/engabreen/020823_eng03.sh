#!/bin/sh
#
# Datenmigration: Befliegung Engabreen 23.8.2002
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/engabreen/020823_eng03/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/engabreen/020823_eng03
cp -avu /mnt/netappa/Rohdaten/engabreen/Befliegung_082002/data/*.* ./asc/
cp -avu /mnt/netappa/Rohdaten/engabreen/Befliegung_082002/readme.txt ./doc/

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/engabreen/020823_eng03/asc/*.all \
        -odir /home/laser/rawdata/als/engabreen/020823_eng03/las \
        -parse xyzi \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 32633 \
        -set_file_creation 235 2002 \
        -set_system_identifier "ALTM 1225"
