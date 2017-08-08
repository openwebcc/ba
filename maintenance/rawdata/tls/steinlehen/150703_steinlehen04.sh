#!/bin/bash
#
# Datenmigration: TLS Kampagne Steinlehen - Messung 4, 03.07.2015
#

# Ordnerstruktur erstellen
mkdir -pv /home/rawdata/tls/steinlehen/150703_steinlehen04/{asc,las,doc,meta,raw}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/14xxxx_steinlehnen/2015_07_03_steinlehnen.riproject /home/rawdata/tls/steinlehen/150703_steinlehen04/raw/

