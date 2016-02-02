#!/bin/bash
#
# Datenmigration: Befliegung Hintereisferner, 04.10.2011
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/hef/111004_hef21/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/hef/111004_hef21
cp -avu /mnt/netappa/Rohdaten/hef/hef21_111004/str/all/*.all ./asc/
cp -avu /mnt/netappa/Rohdaten/hef/hef21_111004/str/Bet/111004_2_169.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/hef21_111004/str/Dgn/Hintereisferner.dgn ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/hef21_111004/str/Dgn/Hintereisferner.dxf ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/hef21_111004/str/11-UIA-B02-Abschlussbericht.pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen und nach LAS konvertieren
cd /home/laser/rawdata/als/hef/111004_hef21/asc/
rename -f 's/\.all$/.ala/' *.all
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
            -set_file_creation 277 2011 \
            -set_system_identifier "ALTM 3100"
done

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/hef/111004_hef21/bet/ -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
