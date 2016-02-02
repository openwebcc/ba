#!/bin/bash
#
# Datenmigration: Befliegung Hintereisferner, 08.10.2006
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/hef/061008_hef13/{asc,las,bet,doc,meta,fix}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/hef/061008_hef13
cp -avu /mnt/netappa/Rohdaten/hef/hef13_061008/str/alf/*.alf ./fix/
cp -avu /mnt/netappa/Rohdaten/hef/hef13_061008/str/all/*.all ./fix/
cp -avu /mnt/netappa/Rohdaten/hef/hef13_061008/h_061008.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/hef13_061008/h_061008.dgn ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/hef13_061008/h_061008.dxf ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/hef13_061008/Befliegungsbericht\ Oktober\ 2006\ \(Scan\).pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen
cd /home/laser/rawdata/als/hef/061008_hef13/fix/
rename -f 'y/A-Z/a-z/' *.all
for ALFL in `ls *.al[fl]`
do
    echo "strip32 and clean $ALFL ..."
    awk '{gsub(/^32/,"",$2); print}' $ALFL > $ALFL.tmp
    mv $ALFL.tmp $ALFL

done

# Zusammenspielen von .alf und .all zu .ala
find /home/laser/rawdata/als/hef/061008_hef13/fix -name "*.alf" -exec sh /home/klaus/private/ba/tools/fix_merge_alf_all.sh {} \;

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/hef/061008_hef13/asc/*.ala \
        -odir /home/laser/rawdata/als/hef/061008_hef13/las \
        -iparse txyzirn \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 25832 \
        -set_file_creation 281 2006 \
        -set_system_identifier "ALTM 3100"

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/hef/061008_hef13/bet/ -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
