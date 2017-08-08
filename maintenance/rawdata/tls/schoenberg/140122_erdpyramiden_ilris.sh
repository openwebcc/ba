#!/bin/bash
#
# Datenmigration: TLS Kampagne Erdpyramiden Schönberg - Messung ILRIS, 22.10.2014
#

# Ordnerstruktur erstellen
mkdir -pv /home/rawdata/tls/schoenberg/140122_erdpyramiden_ilris/{asc,las,doc,meta}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/140122_erdpyramiden_schoenberg_ilris /home/rawdata/tls/schoenberg/140122_erdpyramiden_ilris/raw

