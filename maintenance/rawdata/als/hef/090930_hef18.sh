#!/bin/sh
#
# Datenmigration: Befliegung Hintereisferner, 30.09.2009
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/hef/090930_hef18/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/hef/090930_hef18
cp -avu /mnt/netappa/Rohdaten/hef/hef18_090930/str/all/*.all ./asc/
cp -avu /mnt/netappa/Rohdaten/hef/hef18_090930/090930_1_169_v2.bet ./bet/

# ASCII Rohdaten bereinigen und nach LAS konvertieren
cd /home/laser/rawdata/als/hef/090930_hef18/asc/
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
            -set_file_creation 273 2009 \
            -set_system_identifier "ALTM 3100"
done

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/hef/090930_hef18/bet/ -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
