#!/bin/sh
#
# Datenmigration: Befliegung VOGIS 2011
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/vogis/111018_vb11/{asc,las,bet,doc,meta}

# Rohdaten im .las und .laz Format kopieren
cd /home/laser/rawdata/als/vogis/111018_vb11/las
cp -avu /mnt/netappa/Rohdaten/vorarlberg_neu_2011/Gelaendemodelle/Lidarpunkte/Kacheln/*.la[sz] .

# Datum auf letztes gefundenes Datum in den Rohdaten der 1. Lieferung setzen (siehe /mnt/netappa/Rohdaten/VoGIS_2011/laz/)
lasinfo -i *.laz -no_check -quiet -set_file_creation 291 2011
lasinfo -i *.las -no_check -quiet -set_file_creation 291 2011

