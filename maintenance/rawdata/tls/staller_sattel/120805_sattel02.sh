#!/bin/bash
#
# Datenmigration: TLS Kampagne Staller Sattel - Messung 2, 05.08.2012
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/tls/staller_sattel/120805_sattel02/{asc,las,doc,meta}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/120805_staller_sattel /home/laser/rawdata/tls/staller_sattel/120805_sattel02/raw

