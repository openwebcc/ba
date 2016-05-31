#!/bin/bash
#
# Datenmigration: TLS Kampagne Steinlehen - Messung 1, 11.11.2014
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/tls/steinlehen/141115_steinlehen01/{asc,las,doc,meta,raw}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/14xxxx_steinlehnen/2014-11-15.001.riproject /home/laser/rawdata/tls/steinlehen/141115_steinlehen01/raw/

