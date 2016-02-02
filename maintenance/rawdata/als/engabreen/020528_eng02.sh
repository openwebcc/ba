#!/bin/bash
#
# Datenmigration: Befliegung Engabreen 28.5.2002
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/engabreen/020528_eng02/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/engabreen/020528_eng02
cp -avu /mnt/netappa/Rohdaten/engabreen/Befliegung_052002/data/*.* ./asc/
cp -avu /mnt/netappa/Rohdaten/engabreen/Befliegung_052002/readme.txt ./doc/

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/engabreen/020528_eng02/asc/*.all \
        -odir /home/laser/rawdata/als/engabreen/020528_eng02/las \
        -parse xyzi \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 32633 \
        -set_file_creation 148 2002 \
        -set_system_identifier "ALTM 1225"
