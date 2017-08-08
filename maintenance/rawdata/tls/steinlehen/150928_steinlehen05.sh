#!/bin/bash
#
# Datenmigration: TLS Kampagne Steinlehen - Messung 5, 28.09.2015
#

# Ordnerstruktur erstellen
mkdir -pv /home/rawdata/tls/steinlehen/150928_steinlehen05/{asc,las,doc,meta,raw}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/14xxxx_steinlehnen/2015_09_28_Steinlehnen.riproject /home/rawdata/tls/steinlehen/150928_steinlehen05/raw/

