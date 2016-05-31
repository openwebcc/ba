#!/bin/bash
#
# Datenmigration: TLS Kampagne Schmirntal - Messung 3, 22.10.2012
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/tls/schmirntal/121022_obern03/{asc,las,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/tls/schmirntal/121022_obern03
cp -avu /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/Messung_3_REG_Merge.txt ./asc/
cp -avu /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/readme.txt ./doc/

# convert to LAS
txt2las -i /home/laser/rawdata/tls/schmirntal/121022_obern03/asc/*.txt \
        -odir /home/laser/rawdata/tls/schmirntal/121022_obern03/las \
        -iparse xyzisssss \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 32632 \
        -set_file_creation 296 2012 \
        -set_system_identifier "Optech ILRIS 3D"

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/121022_schmirn /home/laser/rawdata/tls/schmirntal/121022_obern03/raw

# Registrierung Jan Wührer übernehmen
mkdir /home/laser/rawdata/tls/schmirntal/121022_obern03/raw/registriert_wuehrer
cp -a /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/readme.txt /home/laser/rawdata/tls/schmirntal/121022_obern03/raw/registriert_wuehrer/
mv /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/*3*.* /home/laser/rawdata/tls/schmirntal/121022_obern03/raw/registriert_wuehrer/
