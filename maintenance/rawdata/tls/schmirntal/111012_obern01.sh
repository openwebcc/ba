#!/bin/bash
#
# Datenmigration: TLS Kampagne Schmirntal - Messung 1, 12.10.2011
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/tls/schmirntal/111012_obern01/{asc,las,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/tls/schmirntal/111012_obern01
cp -avu /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/Messung_1_REG_Merge.txt ./asc/
cp -avu /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/readme.txt ./doc/
cp -avu /mnt/netappa/Laser/tls/daten/111012_schmirn_obern/Messaufbau_TLS_Schmirn.jpg ./doc/

# convert to LAS
txt2las -i /home/laser/rawdata/tls/schmirntal/111012_obern01/asc/*.txt \
        -odir /home/laser/rawdata/tls/schmirntal/111012_obern01/las \
        -iparse xyzisssss \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 32632 \
        -set_file_creation 285 2011 \
        -set_system_identifier "Optech ILRIS 3D"

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/111012_schmirn_obern /home/laser/rawdata/tls/schmirntal/111012_obern01/raw
