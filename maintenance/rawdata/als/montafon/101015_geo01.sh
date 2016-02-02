#!/bin/bash
#
# Datenmigration: Befliegung Montafon 13.10.2010, 14.10.2010 und 15.10.2010
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/montafon/101015_geo01/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/montafon/101015_geo01
cp -avu /mnt/netappa/Rohdaten/Montafon/Topscan/Laserpunkte/*-1010*.all.gz ./asc/
cp -avu /mnt/netappa/Rohdaten/Montafon/Topscan/Metadaten/1010*.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/Montafon/Topscan/Uebersicht/Montafon.* ./bet/
cp -avu /mnt/netappa/Rohdaten/Montafon/Topscan/Projektbericht/11-UIA-B05-Abschlussbericht.pdf ./doc/report.pdf


# ASCII Rohdaten bereinigen
cd /home/laser/rawdata/als/montafon/101015_geo01/asc
rename -f 's/\.all\.gz$/.ala.gz/' *.all.gz
for GZ in `ls *.gz`
do
    ALA=`echo $GZ | sed s/\.gz$//`
    echo "strip32 and clean $ALA ..."
    zcat $GZ | awk '{gsub(/^32/,"",$2); print}' - > $ALA

done
rm -f *.ala.gz

# nach LAS konvertieren
txt2las -i /home/laser/rawdata/als/montafon/101015_geo01/asc/*.ala \
        -odir /home/laser/rawdata/als/montafon/101015_geo01/las \
        -parse txyzirn \
        -reoffset 0 0 0 \
        -rescale 0.01 0.01 0.01 \
        -epsg 25832 \
        -set_system_identifier "ALTM Gemini"

# Jahr und Tag im Jahr setzen
cd /home/laser/rawdata/als/montafon/101015_geo01/las
find . -name "*101013*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 288 2010 \;
find . -name "*101014*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 289 2010 \;
find . -name "*101015*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 290 2010 \;

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/montafon/101015_geo01/bet -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done

