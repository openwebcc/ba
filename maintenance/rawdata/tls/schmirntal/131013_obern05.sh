#!/bin/bash
#
# Datenmigration: TLS Kampagne Schmirntal - Messung 5, 13.10.2013
#

# Ordnerstruktur erstellen
mkdir -pv /home/rawdata/tls/schmirntal/131013_obern05/{asc,las,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/rawdata/tls/schmirntal/131013_obern05
cp -avu /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/Messung_5_REG_Merge.txt ./asc/
cp -avu /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/readme.txt ./doc/

# convert to LAS
txt2las -i /home/rawdata/tls/schmirntal/131013_obern05/asc/*.txt \
        -odir /home/rawdata/tls/schmirntal/131013_obern05/las \
        -iparse xyzisssss \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 32632 \
        -set_file_creation 286 2013 \
        -set_system_identifier "Optech ILRIS 3D"

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/131031_schmirntal /home/rawdata/tls/schmirntal/131013_obern05/raw

# Registrierung Jan Wührer übernehmen
mkdir /home/rawdata/tls/schmirntal/131013_obern05/raw/registriert_wuehrer
cp -a /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/readme.txt /home/rawdata/tls/schmirntal/131013_obern05/raw/registriert_wuehrer/
mv /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/*5*.* /home/rawdata/tls/schmirntal/131013_obern05/raw/registriert_wuehrer/
