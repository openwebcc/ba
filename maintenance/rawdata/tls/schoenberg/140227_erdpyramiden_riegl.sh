#!/bin/bash
#
# Datenmigration: TLS Kampagne Erdpyramiden Schönberg - Messung RIEGL, 27.02.2014
#

# Ordnerstruktur erstellen
mkdir -pv /home/rawdata/tls/schoenberg/140227_erdpyramiden_riegl/{asc,las,doc,meta}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/140227_erdpyramiden_schoenberg_riegl /home/rawdata/tls/schoenberg/140227_erdpyramiden_riegl/raw


