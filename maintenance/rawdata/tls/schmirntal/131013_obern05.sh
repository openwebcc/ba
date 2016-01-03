#!/bin/sh
#
# Datenmigration: TLS Kampagne Schmirntal - Messung 5, 13.10.2013
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/tls/schmirntal/131013_obern05/{asc,las,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/tls/schmirntal/131013_obern05
cp -avu /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/Messung_5_REG_Merge.txt ./asc/
cp -avu /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/readme.txt ./doc/

# convert to LAS
txt2las -i /home/laser/rawdata/tls/schmirntal/131013_obern05/asc/*.txt \
        -odir /home/laser/rawdata/tls/schmirntal/131013_obern05/las \
        -iparse xyzisssss \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 32632 \
        -set_file_creation 286 2013 \
        -set_system_identifier "Optech ILRIS 3D"
