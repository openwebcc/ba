#!/bin/sh
#
# Datenmigration: Nachflug Montafon 05.10.2011
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/montafon/111005_geo02/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/montafon/111005_geo02
cp -avu /mnt/netappa/Rohdaten/Montafon/Topscan/Laserpunkte/*-111005*.all.gz ./asc/
cp -avu /mnt/netappa/Rohdaten/Montafon/Topscan/Metadaten/111005*.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/Montafon/Topscan/Uebersicht/Montafon.* ./bet/
cp -avu /mnt/netappa/Rohdaten/Montafon/Topscan/Projektbericht/11-UIA-B05-Abschlussbericht.pdf ./doc/report.pdf


# ASCII Rohdaten bereinigen
cd /home/laser/rawdata/als/montafon/111005_geo02/asc
rename -f 's/\.all\.gz$/.ala.gz/' *.all.gz
for GZ in `ls *.gz`
do
    ALA=`echo $GZ | sed s/\.gz$//`
    echo "strip32 and clean $ALA ..."
    zcat $GZ | awk '{gsub(/^32/,"",$2); print}' - > $ALA

done
rm -f *.ala.gz

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/montafon/111005_geo02/asc/*.ala \
        -odir /home/laser/rawdata/als/montafon/111005_geo02/las \
        -parse txyzirn \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 25832 \
        -set_file_creation 278 2011 \
        -set_system_identifier "ALTM 3100"


# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/montafon/111005_geo02/bet -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
