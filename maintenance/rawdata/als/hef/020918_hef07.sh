#!/bin/bash
#
# Datenmigration: Befliegung Hintereisferner, 18.09.2002
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/hef/020918_hef07/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/hef/020918_hef07
cp -avu /mnt/netappa/Rohdaten/hef/hef07_020918/str/ala/*.ala ./asc/
cp -avu /mnt/netappa/Rohdaten/hef/hef07_020918/str/H_020918.dgn ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/TopScanBefliegungsbericht_HEF2001bis2003.pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen und nach LAS konvertieren
cd /home/laser/rawdata/als/hef/020918_hef07/asc/
for ALA in `ls *.ala`
do
    echo "strip32 and clean $ALA ..."
    awk '{gsub(/^32/,"",$2); print}' $ALA > $ALA.tmp
    mv $ALA.tmp $ALA

    LAS=`echo $ALA | sed s/\.[^\.]*$/.las/`
    echo "creating ../las/$LAS ..."
    txt2las -i $ALA  \
            -o ../las/$LAS  \
            -parse txyzirn  \
            -reoffset 0 0 0  \
            -rescale 0.01 0.01 0.01  \
            -epsg 25832  \
            -set_file_creation 261 2002 \
            -set_system_identifier "ALTM 3033"
done

# eine Trajektorie hat gemischte x-Koordinaten (32N und 33N) - 32N Koordinaten behalten und Originalfile archivieren
cd /home/laser/rawdata/als/hef/020918_hef07/bet/
cp -av /mnt/netappa/Rohdaten/hef/hef07_020918/str/H_020918.bet H_020918.bet.org
head -1 H_020918.bet.org > H_020918.bet
grep '^ *[0-9]*\.[0-9]* * 32' H_020918.bet.org >> H_020918.bet

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/hef/020918_hef07/bet/ -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
