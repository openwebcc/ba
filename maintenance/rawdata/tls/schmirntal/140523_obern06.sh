#!/bin/bash
#
# Datenmigration: TLS Kampagne Schmirntal - Messung 6, 23.05.2014
#

# Ordnerstruktur erstellen
mkdir -pv /home/rawdata/tls/schmirntal/140523_obern06/{asc,las,doc,meta}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/140523_schmirntal /home/rawdata/tls/schmirntal/140523_obern06/raw
