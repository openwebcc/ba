#!/bin/bash
#
# Datenmigration: Befliegung Hintereisferner, 12.10.2005
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/hef/051012_hef12/{asc,las,bet,doc,meta,fix}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/hef/051012_hef12
cp -avu /mnt/netappa/Rohdaten/hef/hef12_051012/str/alf/*.alf ./fix/
cp -avu /mnt/netappa/Rohdaten/hef/hef12_051012/str/all/*.all ./fix/
cp -avu /mnt/netappa/Rohdaten/hef/hef12_051012/h_051012.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/hef12_051012/Befliegungsbericht\ Oktober\ 2005\ \(Scan\).pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen
cd /home/laser/rawdata/als/hef/051012_hef12/fix/
rename -f 'y/A-Z/a-z/' *.all
for ALFL in `ls *.al[fl]`
do
    echo "strip32 and clean $ALFL ..."
    awk '{gsub(/^32/,"",$2); print}' $ALFL > $ALFL.tmp
    mv $ALFL.tmp $ALFL

done

# Zusammenspielen von .alf und .all zu .ala
find /home/laser/rawdata/als/hef/051012_hef12/fix -name "*.alf" -exec sh /home/klaus/private/ba/tools/fix_merge_alf_all.sh {} \;

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/hef/051012_hef12/asc/*.ala \
        -odir /home/laser/rawdata/als/hef/051012_hef12/las \
        -iparse txyzirn \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 25832 \
        -set_file_creation 285 2005 \
        -set_system_identifier "ALTM 3100"

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/hef/051012_hef12/bet/ -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
