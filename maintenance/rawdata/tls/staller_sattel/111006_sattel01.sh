#!/bin/bash
#
# Datenmigration: TLS Kampagne Staller Sattel - Messung 1, 06.10.2011
#

# Ordnerstruktur erstellen
mkdir -pv /home/rawdata/tls/staller_sattel/111006_sattel01/{asc,las,doc,meta}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/111006_staller_sattel /home/rawdata/tls/staller_sattel/111006_sattel01/raw
