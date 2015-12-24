#!/bin/sh
#
# Datenmigration: Befliegung Hintereisferner, 05.04.2010
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/hef/041005_hef11/{asc,las,bet,doc,meta,fix}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/hef/041005_hef11
cp -avu /mnt/netappa/Rohdaten/hef/hef11_041005/str/alf/*.alf ./fix/
cp -avu /mnt/netappa/Rohdaten/hef/hef11_041005/str/all/*.ALL ./fix/
cp -avu /mnt/netappa/Rohdaten/hef/hef11_041005/041005_01.asc ./bet/041005_01.bet
cp -avu /mnt/netappa/Rohdaten/hef/hef11_041005/Befliegungsbericht\ Oktober\ 2004\ \(Scan\).pdf ./doc/report.pdf

# ASCII Rohdaten bereinigen
cd /home/laser/rawdata/als/hef/041005_hef11/fix
rename -f 'y/A-Z/a-z/' *.ALL
for ALFL in `ls *.al[fl]`
do
    echo "strip32 and clean $ALFL ..."
    awk '{gsub(/^32/,"",$2); print}' $ALFL > $ALFL.tmp
    mv $ALFL.tmp $ALFL

done

# Zusammenspielen von .alf und .all zu .ala
find /home/laser/rawdata/als/hef/041005_hef11/fix -name "*.alf" -exec sh /home/klaus/private/ba/tools/fix_merge_alf_all.sh {} \;

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/hef/041005_hef11/asc/*.ala \
        -odir /home/laser/rawdata/als/hef/041005_hef11/las \
        -iparse txyzirn \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 25832 \
        -set_file_creation 279 2004 \
        -set_system_identifier "ALTM 2050"

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/hef/041005_hef11/bet/ -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
