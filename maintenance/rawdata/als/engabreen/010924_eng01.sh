#!/bin/sh
#
# Datenmigration: Befliegung Engabreen 24.9.2001
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/engabreen/010924_eng01/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/engabreen/010924_eng01
cp -avu /mnt/netappa/Rohdaten/engabreen/Befliegung_24092001/data/*.* ./asc/
cp -avu /mnt/netappa/Rohdaten/engabreen/Befliegung_24092001/readme.txt ./doc/

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/engabreen/010924_eng01/asc/*.all \
        -odir /home/laser/rawdata/als/engabreen/010924_eng01/las \
        -parse xyzi \
        -epsg 32633 \
        -set_file_creation 267 2001 \
        -set_system_identifier "ALTM 1225"
