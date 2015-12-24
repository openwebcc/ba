#!/bin/sh
#
# Datenmigration: Befliegung Hintereisferner, 11.10.2007
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/hef/071011_hef14/{asc,las,bet,doc,meta,fix}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/hef/071011_hef14
cp -avu /mnt/netappa/Rohdaten/hef/hef14_071011/str/ala/*.ala ./fix/
cp -avu /mnt/netappa/Rohdaten/hef/hef14_071011/str/H_071011.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/hef14_071011/str/h_071011.dgn ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/hef14_071011/Befliegungsbericht_11102007.pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen und 
cd /home/laser/rawdata/als/hef/071011_hef14/fix
for ALA in `ls *.ala`
do
    echo "strip32 and clean $ALA ..."
    awk '{gsub(/^32/,"",$2); print}' $ALA > $ALA.tmp
    mv $ALA.tmp $ALA

done

# Bereinigen von .ala
# .ala Files haben fast alle 2 2 bei Echo, vereinzelt auch 1 2 und nie 1 1 
# auf den CDs gibt es keine .ala files, allerdings auch keine .alf und .all files mit Zeitstempeln
# Datenherkunft kann damit nicht eindeutig gekärt werden
#
python /home/klaus/private/ba/maintenance/rawdata/hef/fix_ala_hef14.py
rename -f 's/\.ala$/.ala.org/' *.ala

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/hef/071011_hef14/asc/*.ala \
        -odir /home/laser/rawdata/als/hef/071011_hef14/las \
        -iparse txyzirn \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 25832 \
        -set_file_creation 284 2007 \
        -set_system_identifier "ALTM 3100"

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/hef/071011_hef14/bet/ -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
