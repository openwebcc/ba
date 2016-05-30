#!/bin/bash
#
# Datenmigration: TLS Kampagne Schmirntal - Messung 9, 24.06.2015
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/tls/schmirntal/150624_obern09/{asc,las,doc,meta}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/150624_schmirn /home/laser/rawdata/tls/schmirntal/150624_obern09/raw
