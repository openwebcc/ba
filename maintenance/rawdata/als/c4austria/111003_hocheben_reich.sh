#!/bin/sh
#
# Datenmigration: Befliegung Hochebenkar, Reichenkar, 03.10.2011
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/c4austria/111003_hocheben_reich/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/c4austria/111003_hocheben_reich/
cp -avu /mnt/netappa/Rohdaten/P7160_012_043_C4AUSTRIA/Topscan2011_32_010/All/*.all ./asc/
cp -avu /mnt/netappa/Rohdaten/P7160_012_043_C4AUSTRIA/Topscan2011_32_010/Bet/111003_2_169.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/P7160_012_043_C4AUSTRIA/Topscan2011_32_010/Dgn/Blockgletscher.* ./bet
cp -avu /mnt/netappa/Rohdaten/P7160_012_043_C4AUSTRIA/Topscan2011_32_010/11-UIA-B01-Abschlussbericht.pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen
cd /home/laser/rawdata/als/c4austria/111003_hocheben_reich/asc
rename -f 's/\.all$/.ala/' *.all
for ALA in `ls *.ala`
do
    echo "strip32 and clean $ALA ..."
    awk '{gsub(/^32/,"",$2); print}' $ALA > $ALA.tmp
    mv $ALA.tmp $ALA

done

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/c4austria/111003_hocheben_reich/asc/*.ala \
        -odir /home/laser/rawdata/als/c4austria/111003_hocheben_reich/las \
        -parse txyzirn \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 25832 \
        -set_file_creation 276 2011 \
        -set_system_identifier "ALTM 3100"

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/c4austria/111003_hocheben_reich/bet -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
