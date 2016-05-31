#!/bin/bash
#
# Datenmigration: TLS Kampagne Steinlehen - Messung 2, 28.11.2014
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/tls/steinlehen/141128_steinlehen02/{asc,las,doc,meta,raw}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/14xxxx_steinlehnen/2014-11-28.001.riproject /home/laser/rawdata/tls/steinlehen/141128_steinlehen02/raw/

mv /mnt/netappa/Laser/tls/daten/14xxxx_steinlehnen/tls01_octree.las /home/laser/rawdata/tls/steinlehen/141128_steinlehen02/raw/
mv /mnt/netappa/Laser/tls/daten/14xxxx_steinlehnen/tls02_octree.las /home/laser/rawdata/tls/steinlehen/141128_steinlehen02/raw/
mv /mnt/netappa/Laser/tls/daten/14xxxx_steinlehnen/tls02_wide_octree.las /home/laser/rawdata/tls/steinlehen/141128_steinlehen02/raw/
