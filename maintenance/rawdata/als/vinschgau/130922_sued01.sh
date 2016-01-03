#!/bin/sh
#
# Datenmigration: Befliegung Vinschgau Süd, 22.9.2013
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/vinschgau/130922_sued01/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/vinschgau/130922_sued01
cp -avu /mnt/netappa/Rohdaten/P7160_028_012_VINSCHGLAC/Sued/Laserpunkte/*.all ./asc/
cp -avu /mnt/netappa/Rohdaten/P7160_028_012_VINSCHGLAC/Sued/Metadaten/130922_1_221.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/P7160_028_012_VINSCHGLAC/Sued/Metadaten/130922_2_221.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/P7160_028_012_VINSCHGLAC/Sued/Uebersicht/* ./bet/
cp -avu /mnt/netappa/Rohdaten/P7160_028_012_VINSCHGLAC/Report/13-UIA-B02-Abschlussbericht.pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen
cd /home/laser/rawdata/als/vinschgau/130922_sued01/asc
rename -f 's/\.all$/.ala/' *.all
for ALA in `ls *.ala`
do
    echo "strip32 and clean $ALA ..."
    awk '{gsub(/^32/,"",$2); print}' $ALA > $ALA.tmp
    mv $ALA.tmp $ALA
done

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/vinschgau/130922_sued01/asc/*.ala \
        -odir /home/laser/rawdata/als/vinschgau/130922_sued01/las \
        -parse txyzirn \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 25832 \
        -set_file_creation 265 2013 \
        -set_system_identifier "ALTM Gemini"

# strip 32 from .bet file(s)
for BET in `find /home/laser/rawdata/als/vinschgau/130922_sued01/bet/ -name "*.bet"`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
