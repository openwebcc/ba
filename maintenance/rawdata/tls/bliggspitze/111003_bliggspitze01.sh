#!/bin/bash
#
# Datenmigration: TLS Kampagne Bliggspitze - Messung 1, 03.10.2011
#

# Ordnerstruktur erstellen
mkdir -pv /home/rawdata/tls/bliggspitze/111003_bliggspitze01/{asc,las,doc,meta}

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/111003_bliggspitze /home/rawdata/tls/bliggspitze/111003_bliggspitze01/raw
