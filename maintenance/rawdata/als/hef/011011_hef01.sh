#!/bin/bash
#
# Datenmigration: Befliegung Hintereisferner, 11.10.2011
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/hef/011011_hef01/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/hef/011011_hef01
cp -avu /mnt/netappa/Rohdaten/hef/hef01_011011/str/ala/*.ala ./asc/
cp -avu /mnt/netappa/Rohdaten/hef/hef01_011011/str/H_011011.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/hef01_011011/str/H_011011.dgn ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/*Befliegungsbericht*.pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen und nach LAS konvertieren
cd /home/laser/rawdata/als/hef/011011_hef01/asc/
for ALA in `ls *.ala`
do
    echo "entferne 32 bei x-Koordinaten in $ALA ..."
    awk '{gsub(/^32/,"",$2); print}' $ALA > $ALA.tmp
    mv $ALA.tmp $ALA

    LAS=`echo $ALA | sed s/\.[^\.]*$/.las/`
    echo "konvertiere nach ../las/$LAS ..."
    txt2las -i $ALA \
            -o ../las/$LAS \
            -parse txyzirn \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01 \
            -epsg 25832 \
            -set_file_creation 284 2001 \
            -set_system_identifier "ALTM 1225"
done

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/hef/011011_hef01/bet/ -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.tmp
    mv $BET.tmp $BET
done

