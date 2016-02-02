#!/bin/bash
#
# Datenmigration: TLS Kampagne Schmirntal - Messung 2, 02.05.2012
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/tls/schmirntal/120502_obern02/{asc,las,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/tls/schmirntal/120502_obern02
cp -avu /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/Messung_2_REG_Merge.txt ./asc/
cp -avu /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/readme.txt ./doc/

# convert to LAS
txt2las -i /home/laser/rawdata/tls/schmirntal/120502_obern02/asc/*.txt \
        -odir /home/laser/rawdata/tls/schmirntal/120502_obern02/las \
        -iparse xyzisssss \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 32632 \
        -set_file_creation 123 2012 \
        -set_system_identifier "Optech ILRIS 3D"
