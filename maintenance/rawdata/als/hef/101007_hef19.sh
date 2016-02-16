#!/bin/bash
#
# Datenmigration: Befliegung Hintereisferner 07.10.2010, 08.10.2010, 09.10.2010, 10.10.2010, 11.10.2010 und 12.10.2010
#                 Daten stammen aus der Befliegung musicals/101007_kaunertal01

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/hef/101007_hef19/{asc,las,bet,doc,meta}

# Trajektorien und Dokumentation kopieren
cd /home/laser/rawdata/als/hef/101007_hef19
cp -avu /home/laser/rawdata/als/musicals/101007_kaunertal01/bet/*.bet ./bet/
cp -avu /home/laser/rawdata/als/musicals/101007_kaunertal01/doc/*.pdf ./doc/report.pdf

#
# Rohdaten aus der Befliegung musicals/101007_kaunertal01 extrahieren
#

# Schritt 1: Extent des HEF-Projektpolygons ermitteln
OGR_EXT=`ogrinfo /home/laser/rawdata/maintenance/rawdata/als/hef/util/hef_projectpolygon.shp hef_projectpolygon | grep Extent`
KEEP_XY=`echo $OGR_EXT | sed -e 's/[a-zA-Z:,\(\)\-]//g'`

# Schritt 2: Flugstreifen der musicals Befliegung am Extent des HEF-Projektpolygons klippen
mkdir /tmp/hef19
cd /home/laser/rawdata/als/musicals/101007_kaunertal01/las
las2las -i *.las -odir /tmp/hef19 -olas -keep_xy $KEEP_XY

# Schritt 3: leere Flugstreifen löschen
find /tmp/hef19 -size -350c -exec rm -f {} \;

# Schritt 4: Flugstreifen am Projektpolygon klippen
find /tmp/hef19 -name "*.las" -exec python /home/laser/rawdata/maintenance/scripts/als/clip_lasfile.py \
    --lasfile {} \
    --wktpoly /home/laser/rawdata/maintenance/rawdata/als/hef/util/hef_projectpolygon.wkt \
    --outdir /home/laser/rawdata/als/hef/101007_hef19/las/ \;

# Schritt 5: system identifier, generating software setzen und kopierten LAS-header aktualisieren
cd /home/laser/rawdata/als/hef/101007_hef19/las/
for LAS in `ls *.las`
do
    lasinfo -i $LAS -set_system_identifier "ALTM Gemini" -set_generating_software "OptechLMS" -repair > /dev/null 2>&1
done

# Schritt 6: leere Flugstreifen löschen
find /home/laser/rawdata/als/hef/101007_hef19/las -size -350c -exec rm -f {} \;

# clean up
rm -rf /tmp/hef19/
