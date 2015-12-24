#!/bin/sh
#
# Datenmigration: Befliegung Hintereisferner, 07.05.2009
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/hef/090507_hef17/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/hef/090507_hef17
cp -avu /mnt/netappa/Rohdaten/hef/hef17_090507/str/ala/*.ala ./asc/
cp -avu /mnt/netappa/Rohdaten/hef/hef17_090507/str/H_090507.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/hef17_090507/str/H_090507.dgn ./bet/

# ASCII Rohdaten bereinigen und nach LAS konvertieren
cd /home/laser/rawdata/als/hef/090507_hef17/asc/
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
            -set_file_creation 127 2009 \
            -set_system_identifier "ALTM 3100"
done

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/hef/090507_hef17/bet/ -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
