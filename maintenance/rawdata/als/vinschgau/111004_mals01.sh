#!/bin/sh
#
# Datenmigration: Befliegung Mals, 4.10.2011
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/vinschgau/111004_mals01/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/vinschgau/111004_mals01
cp -avu /mnt/netappa/Rohdaten/P7160_028_011_MALS/Topscan_2011/Mals/All/*.all ./asc/
cp -avu /mnt/netappa/Rohdaten/P7160_028_011_MALS/Topscan_2011/Mals/Schnals/*.all ./asc/
cp -avu /mnt/netappa/Rohdaten/P7160_028_011_MALS/Topscan_2011/Mals/Bet/111004_1_169.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/P7160_028_011_MALS/Topscan_2011/Mals/Dgn/* ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/hef21_111004/str/Bet/111004_2_169.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/P7160_028_011_MALS/Topscan_2011/Mals/11-UIA-B03-Abschlussbericht.pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen
cd /home/laser/rawdata/als/vinschgau/111004_mals01/asc
rename -f 's/\.all$/.ala/' *.all
for ALA in `ls *.ala`
do
    echo "strip32 and clean $ALA ..."
    awk '{gsub(/^32/,"",$2); print}' $ALA > $ALA.tmp
    mv $ALA.tmp $ALA

done

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/vinschgau/111004_mals01/asc/*.ala \
        -odir /home/laser/rawdata/als/vinschgau/111004_mals01/las \
        -parse txyzirn \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 25832 \
        -set_file_creation 277 2011 \
        -set_system_identifier "ALTM Gemini"

# strip 32 from .bet file(s)
for BET in `find /home/laser/rawdata/als/vinschgau/111004_mals01/bet/ -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
