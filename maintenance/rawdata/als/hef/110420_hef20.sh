#!/bin/bash
#
# Datenmigration: Befliegung Hintereisferner 20.04.2011, 21.04.2011, 22.04.2011 und 23.04.2011
#                 Daten stammen aus der Befliegung musicals/110420_kaunertal02

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/hef/110420_hef20/{asc,las,bet,doc,meta}

# Trajektorien und Dokumentation kopieren
cd /home/laser/rawdata/als/hef/110420_hef20
cp -avu /home/laser/rawdata/als/musicals/110420_kaunertal02/bet/*.bet ./bet/
cp -avu /home/laser/rawdata/als/musicals/110420_kaunertal02/doc/*.pdf ./doc/report.pdf

#
# Rohdaten aus der Befliegung musicals/110420_kaunertal02 extrahieren
#

# Schritt 1: Extent des HEF-Projektpolygons ermitteln
OGR_EXT=`ogrinfo /home/klaus/private/ba/maintenance/rawdata/als/hef/util/hef_projectpolygon.shp hef_projectpolygon | grep Extent`
KEEP_XY=`echo $OGR_EXT | sed -e 's/[a-zA-Z:,\(\)\-]//g'`

# Schritt 2: Flugstreifen der musicals Befliegung am Extent des HEF-Projektpolygons klippen
mkdir /tmp/hef20
cd /home/laser/rawdata/als/musicals/110420_kaunertal02/las
las2las -i *.las -odir /tmp/hef20 -olas -keep_xy $KEEP_XY

# Schritt 3: leere Flugstreifen löschen
find /tmp/hef20 -size -350c -exec rm -f {} \;

# Schritt 4: Flugstreifen am Projektpolygon klippen
find /tmp/hef20 -name "*.las" -exec python /home/klaus/private/ba/tools/clip_lasfile.py \
    --lasfile {} \
    --wktpoly /home/klaus/private/ba/maintenance/rawdata/als/hef/util/hef_projectpolygon.wkt \
    --outdir /home/laser/rawdata/als/hef/110420_hef20/las/ \;

# Schritt 5: system identifier, generating software setzen und kopierten LAS-header aktualisieren
cd /home/laser/rawdata/als/hef/110420_hef20/las/
for LAS in `ls *.las`
do
    lasinfo -i $LAS -set_system_identifier "ALTM Gemini" -set_generating_software "OptechLMS" -repair > /dev/null 2>&1
done

# Schritt 6: leere Flugstreifen löschen
find /home/laser/rawdata/als/hef/110420_hef20/las -size -350c -exec rm -f {} \;

# clean up
rm -rf /tmp/hef20/
