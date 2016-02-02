#!/bin/bash
#
# Datenmigration: Befliegung Kaunertal 20.04.2011, 21.04.2011, 22.04.2011 und 23.04.2011
#

# Ordnerstruktur erstellen
mkdir -pv /home/laser/rawdata/als/musicals/110420_kaunertal02/{asc,las,bet,doc,meta,fix}

# Rohdaten und Dokumentation kopieren
cd /home/laser/rawdata/als/musicals/110420_kaunertal02
cp -avu /mnt/netappa/Rohdaten/P7160_MUSICALS/2011/160-051/Flugpfade/*_221.bet ./bet/
cp -avu /mnt/netappa/Rohdaten/P7160_MUSICALS/2011/TopScanBefliegungsbericht_MUSICALS_2011.pdf ./doc/report.pdf

# LAS Files migrieren
cd /mnt/netappa/Rohdaten/P7160_MUSICALS/2011/Laserpunkte_nach_Feingeoreferenzierung/Utm/Las
for LAS in `ls *.las`
do
    echo "erzeuge /home/laser/rawdata/als/musicals/110420_kaunertal02/las/$LAS ..."

    # Offset entfernen und x,y,z skalieren
    las2las -i $LAS \
            -o /home/laser/rawdata/als/musicals/110420_kaunertal02/las/$LAS \
            -reoffset 0 0 0 \
            -rescale 0.01 0.01 0.01

    # System identifier und generating software wie beim Original setzen
    lasinfo -i /home/laser/rawdata/als/musicals/110420_kaunertal02/las/$LAS \
            -set_system_identifier "ALTM Gemini" \
            -set_generating_software "OptechLMS" > /dev/null 2>&1
done

# Jahr und Tag im Jahr setzen
cd /home/laser/rawdata/als/musicals/110420_kaunertal02/las
find . -name "*110420*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 110 2011 \;
find . -name "*110421*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 111 2011 \;
find . -name "*110422*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 112 2011 \;
find . -name "*110423*.las" -exec lasinfo -i {} -no_check -quiet -set_file_creation 113 2011 \;

# Koordinaten der Trajektorie(n) bereinigen
for BET in `find /home/laser/rawdata/als/musicals/110420_kaunertal02/bet -name *.bet`
do
    echo "entferne 32 bei x-Koordinaten in $BET ..."
    awk '{gsub(/^32/,"",$2);print}' $BET > $BET.xxx
    mv $BET.xxx $BET
done
