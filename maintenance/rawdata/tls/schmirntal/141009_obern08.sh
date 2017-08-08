#!/bin/bash
#
# Datenmigration: TLS Kampagne Schmirntal - Messung 8, 09.10.2014
#

# Ordnerstruktur erstellen
mkdir -pv /home/rawdata/tls/schmirntal/141009_obern08/{asc,las,doc,meta}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/141009_schmirntal /home/rawdata/tls/schmirntal/141009_obern08/raw
