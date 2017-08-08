#!/bin/bash
#
# Datenmigration: TLS Kampagne Schmirntal / Reissenschuh - Messung 1, 31.05.2010
#

# Ordnerstruktur erstellen
mkdir -pv /home/rawdata/tls/schmirntal/100531_reissenschuh01/{asc,las,doc,meta}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/160531_reissenschuh /home/rawdata/tls/schmirntal/100531_reissenschuh01/raw
