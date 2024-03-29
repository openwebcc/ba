#!/bin/bash
#
# Datenmigration: TLS Kampagne Schmirntal - Messung 4, 23.05.2013
#

# Ordnerstruktur erstellen
mkdir -pv /home/rawdata/tls/schmirntal/130523_obern04/{asc,las,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/rawdata/tls/schmirntal/130523_obern04
cp -avu /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/Messung_4_REG_Merge.txt ./asc/
cp -avu /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/readme.txt ./doc/

# convert to LAS
txt2las -i /home/rawdata/tls/schmirntal/130523_obern04/asc/*.txt \
        -odir /home/rawdata/tls/schmirntal/130523_obern04/las \
        -iparse xyzisssss \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 32632 \
        -set_file_creation 143 2013 \
        -set_system_identifier "Optech ILRIS 3D"

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/130523_schmirn /home/rawdata/tls/schmirntal/130523_obern04/raw

# Registrierung Jan Wührer übernehmen
mkdir /home/rawdata/tls/schmirntal/130523_obern04/raw/registriert_wuehrer
cp -a /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/readme.txt /home/rawdata/tls/schmirntal/130523_obern04/raw/registriert_wuehrer/
mv /mnt/netappa/Laser/tls/daten/2011-2013_schmirntal_registiriert/*4*.* /home/rawdata/tls/schmirntal/130523_obern04/raw/registriert_wuehrer/
