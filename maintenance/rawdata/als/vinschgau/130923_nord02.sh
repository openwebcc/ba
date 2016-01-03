#!/bin/sh
#
# Datenmigration: Befliegung Vinschgau Nord, 23.9.2013
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/vinschgau/130923_nord02/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/vinschgau/130923_nord02
cp -av /mnt/netappa/Rohdaten/P7160_028_012_VINSCHGLAC/Nord/Laserpunkte/zweites_datum/*.all ./asc/
cp -av /mnt/netappa/Rohdaten/P7160_028_012_VINSCHGLAC/Nord/Metadaten/130923_1_221.bet ./bet/
cp -av /mnt/netappa/Rohdaten/P7160_028_012_VINSCHGLAC/Nord/Uebersicht/* ./bet/
cp -av /mnt/netappa/Rohdaten/P7160_028_012_VINSCHGLAC/Report/13-UIA-B02-Abschlussbericht.pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen
cd /home/laser/rawdata/als/vinschgau/130923_nord02/asc
rename -f 's/\.all$/.ala/' *.all
for ALA in `ls *.ala`
do
    echo "strip32 and clean $ALA ..."
    awk '{gsub(/^32/,"",$2); print}' $ALA > $ALA.tmp
    mv $ALA.tmp $ALA
done

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/vinschgau/130923_nord02/asc/*.ala \
        -odir /home/laser/rawdata/als/vinschgau/130923_nord02/las \
        -parse txyzirn \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 25832 \
        -set_file_creation 266 2013 \
        -set_system_identifier "ALTM Gemini"

# strip 32 from .bet file(s)
for BET in `find /home/laser/rawdata/als/vinschgau/130923_nord02/bet/ -name "*.bet"`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
