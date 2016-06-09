#!/bin/bash
#
# Datenmigration: Befliegung Engabreen 29.6.2003
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/engabreen/030629_eng04/{asc,las,doc,meta,prod}

# Rohdaten und Dokumentation migrieren
cd /home/laser/rawdata/als/engabreen/030629_eng04
mv -v /mnt/netappa/Rohdaten/engabreen/Befliegung_062003/data/*.* ./asc/
mv -v /mnt/netappa/Rohdaten/engabreen/Befliegung_29062003/CIR_Bilddaten.tar.gz ./prod/

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/engabreen/030629_eng04/asc/*.all \
        -odir /home/laser/rawdata/als/engabreen/030629_eng04/las \
        -parse xyzi \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 32633 \
        -set_file_creation 180 2003 \
        -set_system_identifier "ALTM 2033"
