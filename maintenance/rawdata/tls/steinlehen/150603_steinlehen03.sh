#!/bin/bash
#
# Datenmigration: TLS Kampagne Steinlehen - Messung 3, 03.06.2015
#

# Ordnerstruktur erstellen
mkdir -pv /home/rawdata/tls/steinlehen/150603_steinlehen03/{asc,las,doc,meta,raw}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/14xxxx_steinlehnen/2015-06-03.001.riproject /home/rawdata/tls/steinlehen/150603_steinlehen03/raw/

