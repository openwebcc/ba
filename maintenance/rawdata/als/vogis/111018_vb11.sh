#!/bin/bash
#
# Datenmigration: Befliegung VOGIS 2011
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/vogis/111018_vb11/{doc,las,meta,prod}

# Rohdaten im .laz Format migrieren
cd /home/laser/rawdata/als/vogis/111018_vb11/las
mv -v /mnt/netappa/Rohdaten/vorarlberg_neu_2011/Gelaendemodelle/Lidarpunkte/Kacheln/*.la[zx] .

# Datum auf letztes gefundenes Datum in den Rohdaten der 1. Lieferung setzen (18.10.2011)
lasinfo -i *.laz -no_check -quiet -set_file_creation 291 2011

# abgeleitete Produkte archivieren
cd /home/laser/rawdata/als/vogis/111018_vb11/prod
mv -v /mnt/netappa/Rohdaten/vorarlberg_neu_2011/Gelaendemodelle/Differenzhoehenmodelle .
mv -v /mnt/netappa/Rohdaten/vorarlberg_neu_2011/Gelaendemodelle/Hoehenmodelle .
mv -v /mnt/netappa/Rohdaten/vorarlberg_neu_2011/Gelaendemodelle/Hoehenschichten .
mv -v /mnt/netappa/Rohdaten/vorarlberg_neu_2011/Gelaendemodelle/nDOM .
mv -v /mnt/netappa/Rohdaten/vorarlberg_neu_2011/Gelaendemodelle/Schummerung .

# Blatschnitte archivieren
cd /home/laser/rawdata/als/vogis/111018_vb11/doc
mv -v /mnt/netappa/Rohdaten/vorarlberg_neu_2011/bls_1t .
mv -v /mnt/netappa/Rohdaten/vorarlberg_neu_2011/bls_5t .
