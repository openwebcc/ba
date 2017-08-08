#!/bin/bash
#
# Datenmigration: TLS Kampagne Schmirntal - Messung 10, 30.10.2015
#

# Ordnerstruktur erstellen
mkdir -pv /home/rawdata/tls/schmirntal/151030_obern10/{asc,las,doc,meta}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/151030_schmirn /home/rawdata/tls/schmirntal/151030_obern10/raw
