#!/bin/bash
#
# Datenmigration: Befliegung Hintereisferner, 12.08.2003
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/hef/030812_hef09/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/hef/030812_hef09
cp -avu /mnt/netappa/Rohdaten/hef/hef09_030812/str/ala/*.ala ./asc/
cp -avu /mnt/netappa/Rohdaten/hef/hef09_030812/str/H_030812.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/hef09_030812/str/H_030812.dgn ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/TopScanBefliegungsbericht_HEF2001bis2003.pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen und nach LAS konvertieren
cd /home/laser/rawdata/als/hef/030812_hef09/asc/
for ALA in `ls *.ala`
do
    echo "strip32 and clean $ALA ..."
    awk '{gsub(/^32/,"",$2); print}' $ALA > $ALA.tmp
    mv $ALA.tmp $ALA

    LAS=`echo $ALA | sed s/\.[^\.]*$/.las/`
    echo "creating ../las/$LAS ..."
    txt2las -i $ALA \
            -o ../las/$LAS \
            -parse txyzirn \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 25832 \
            -set_file_creation 224 2003 \
            -set_system_identifier "ALTM 2050"
done

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/hef/030812_hef09/bet/ -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
