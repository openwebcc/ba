#!/bin/sh
#
# Datenmigration: TLS Kampagne Schmirntal - Messung 4, 23.05.2013
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/tls/schmirntal/130523_obern0/{asc,las,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/tls/schmirntal/130523_obern04
cp -avu /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/Messung_4_REG_Merge.txt ./asc/
cp -avu /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/readme.txt ./doc/

# convert to LAS
txt2las -i /home/laser/rawdata/tls/schmirntal/130523_obern04/asc/*.txt \
        -odir /home/laser/rawdata/tls/schmirntal/130523_obern04/las \
        -iparse xyzisssss \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 32632 \
        -set_file_creation 143 2013 \
        -set_system_identifier "Optech ILRIS 3D"
