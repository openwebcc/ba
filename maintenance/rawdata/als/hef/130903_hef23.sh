#!/bin/sh
#
# Datenmigration: Befliegung Hintereisferner, 03.09.2013
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/hef/130903_hef23/{asc,las,bet,doc,meta}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/hef/130903_hef23
cp -avu /mnt/netappa/Rohdaten/hef/Rofental_2013/Laserpunkte/*.all ./asc/
cp -avu /mnt/netappa/Rohdaten/hef/Rofental_2013/Metadaten/sbet_130903_1_221.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/Rofental_2013/Metadaten/sbet_130904_1_221.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/hef/Rofental_2013/Report/13-UIA-B01-Abschlussbericht.pdf ./doc/report.pdf
cp -avu /mnt/netappa/Rohdaten/hef/Rofental_2013/Uebersicht/Rofental.dgn ./doc/
cp -avu /mnt/netappa/Rohdaten/hef/Rofental_2013/Uebersicht/Rofental.dxf ./doc/
cp -avu /mnt/netappa/Rohdaten/hef/Rofental_2013/Uebersicht/Rofental.pdf ./doc/

# ASCII Rohdaten bereinigen und nach LAS konvertieren
cd /home/laser/rawdata/als/hef/130903_hef23/asc/
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
            -set_system_identifier "ALTM Gemini"
done

# Tag im Jahr und Jahr ergänzen
cd /home/laser/rawdata/als/hef/130903_hef23/las
find . -name "*130903*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 246 2013 \;
find . -name "*130904*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 247 2013 \;

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/hef/130903_hef23/bet/ -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
