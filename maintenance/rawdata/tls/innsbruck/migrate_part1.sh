#!/bin/bash
#
# Datenmigration: diverse TLS Kampagnen in Innsbruck (ohne Metadatenstruktur)
#

# Ordner für Rohdaten erstellen
mkdir -p /home/rawdata/tls/innsbruck/020127_uibk1
mkdir -p /home/rawdata/tls/innsbruck/060330_dach
mkdir -p /home/rawdata/tls/innsbruck/060508_unibruecke
mkdir -p /home/rawdata/tls/innsbruck/060509_kugel
mkdir -p /home/rawdata/tls/innsbruck/060522_gang_u1
mkdir -p /home/rawdata/tls/innsbruck/070831_univorplatz
mkdir -p /home/rawdata/tls/innsbruck/101007_baum_uni
mkdir -p /home/rawdata/tls/innsbruck/110729_innpromenade
mkdir -p /home/rawdata/tls/innsbruck/111125_office_scan
mkdir -p /home/rawdata/tls/innsbruck/111125_univorplatz
mkdir -p /home/rawdata/tls/innsbruck/121005_baum_uni_leaf_on
mkdir -p /home/rawdata/tls/innsbruck/130719_rotationsplattform_test_uni
mkdir -p /home/rawdata/tls/innsbruck/130805_rotationsplattform_test_uni_2_mit_thermo
mkdir -p /home/rawdata/tls/innsbruck/140228_nordkette_riegl
mkdir -p /home/rawdata/tls/innsbruck/140707_univorplatz_box

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/020127_uibk1 /home/rawdata/tls/innsbruck/020127_uibk1/raw
mv /mnt/netappa/Laser/tls/daten/060330_dach /home/rawdata/tls/innsbruck/060330_dach/raw
mv /mnt/netappa/Laser/tls/daten/060508_unibruecke /home/rawdata/tls/innsbruck/060508_unibruecke/raw
mv /mnt/netappa/Laser/tls/daten/060509_kugel /home/rawdata/tls/innsbruck/060509_kugel/raw
mv /mnt/netappa/Laser/tls/daten/060522_gang_u1 /home/rawdata/tls/innsbruck/060522_gang_u1/raw
mv /mnt/netappa/Laser/tls/daten/070831_univorplatz /home/rawdata/tls/innsbruck/070831_univorplatz/raw
mv /mnt/netappa/Laser/tls/daten/101007_baum_uni /home/rawdata/tls/innsbruck/101007_baum_uni/raw
mv /mnt/netappa/Laser/tls/daten/110729_innpromenade /home/rawdata/tls/innsbruck/110729_innpromenade/raw
mv /mnt/netappa/Laser/tls/daten/111125_office_scan /home/rawdata/tls/innsbruck/111125_office_scan/raw
mv /mnt/netappa/Laser/tls/daten/111125_univorplatz /home/rawdata/tls/innsbruck/111125_univorplatz/raw
mv /mnt/netappa/Laser/tls/daten/121005_BaumUniLeafOn /home/rawdata/tls/innsbruck/121005_baum_uni_leaf_on/raw
mv /mnt/netappa/Laser/tls/daten/130719_rotationsplattform_test_uni /home/rawdata/tls/innsbruck/130719_rotationsplattform_test_uni/raw
mv /mnt/netappa/Laser/tls/daten/130805_rotationsplattform_test_uni_2_mit_thermo /home/rawdata/tls/innsbruck/130805_rotationsplattform_test_uni_2_mit_thermo/raw
mv /mnt/netappa/Laser/tls/daten/140228_nordkette_riegl /home/rawdata/tls/innsbruck/140228_nordkette_riegl/raw
mv /mnt/netappa/Laser/tls/daten/140707_univorplatz_box /home/rawdata/tls/innsbruck/140707_univorplatz_box/raw
