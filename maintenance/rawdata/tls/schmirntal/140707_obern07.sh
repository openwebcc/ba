#!/bin/bash
#
# Datenmigration: TLS Kampagne Schmirntal - Messung 7, 07.07.2014
#

# Ordnerstruktur erstellen
mkdir -pv /home/rawdata/tls/schmirntal/140707_obern07/{asc,las,doc,meta}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/140707_schmirn /home/rawdata/tls/schmirntal/140707_obern07/raw
