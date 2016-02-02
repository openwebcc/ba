#!/bin/bash
#
# Datenmigration: Befliegung Inneres Reichenkar, Schrankar, 07.10.2010
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/c4austria/101007_innreich_schrank/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/c4austria/101007_innreich_schrank/
cp -avu /mnt/netappa/Rohdaten/P7160_012_043_C4AUSTRIA/Topscan2010/all/*.all ./asc/
cp -avu /mnt/netappa/Rohdaten/P7160_012_043_C4AUSTRIA/Topscan2010/Bet/101007_2_221.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/P7160_012_043_C4AUSTRIA/Topscan2010/Dgn/Blockgletscher.* ./bet
cp -avu /mnt/netappa/Rohdaten/P7160_012_043_C4AUSTRIA/Topscan2010/10-UIA-B01-Abschlussbericht.pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen
cd /home/laser/rawdata/als/c4austria/101007_innreich_schrank/asc
rename -f 's/\.all$/.ala/' *.all
for ALA in `ls *.ala`
do
    echo "strip32 and clean $ALA ..."
    awk '{gsub(/^32/,"",$1); print}' $ALA > $ALA.tmp
    mv $ALA.tmp $ALA

done

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/c4austria/101007_innreich_schrank/asc/*.ala \
        -odir /home/laser/rawdata/als/c4austria/101007_innreich_schrank/las \
        -parse txyzirn \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 25832 \
        -set_file_creation 280 2010 \
        -set_system_identifier "ALTM Gemini"

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/c4austria/101007_innreich_schrank/bet -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
