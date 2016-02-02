#!/bin/sh
#
# Datenmigration: Befliegung Kaunertal 07.10.2010, 08.10.2010, 09.10.2010, 10.10.2010, 11.10.2010 und 12.10.2010
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/musicals/101007_kaunertal01/{asc,las,bet,doc,meta,fix}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/musicals/101007_kaunertal01
cp -avu /mnt/netappa/Rohdaten/P7160_MUSICALS/2010/1000-002_nichtkorrigierteDaten/Kaunertal/Flugpfade/*221.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/P7160_MUSICALS/2010/TopScanBefliegungsbericht_MUSICALS_2010.pdf ./doc/report.pdf

# LAS Files migrieren
cd /mnt/netappa/Rohdaten/P7160_MUSICALS/2010/1000-002_nichtkorrigierteDaten/Kaunertal/Laserpunkte_nach_Feingeoreferenzierung/Utm/las
for LAS in `ls *.las`
do
    echo "erzeuge /home/laser/rawdata/als/musicals/101007_kaunertal01/las/$LAS ..."

    # Offset entfernen und x,y,z skalieren
    las2las -i $LAS \
            -o /home/laser/rawdata/als/musicals/101007_kaunertal01/las/$LAS \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01

    # System identifier und generating software wie beim Original setzen
    lasinfo -i /home/laser/rawdata/als/musicals/101007_kaunertal01/las/$LAS \
            -set_system_identifier "ALTM Gemini" \
            -set_generating_software "OptechLMS" > /dev/null 2>&1
done

# Jahr und Tag im Jahr setzen
cd /home/laser/rawdata/als/musicals/101007_kaunertal01/las
find . -name "*101007*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 280 2010 \;
find . -name "*101008*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 281 2010 \;
find . -name "*101009*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 282 2010 \;
find . -name "*101010*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 283 2010 \;
find . -name "*101011*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 284 2010 \;
find . -name "*101012*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 285 2010 \;

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/musicals/101007_kaunertal01/bet -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
