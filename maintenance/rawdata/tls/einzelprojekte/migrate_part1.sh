#!/bin/bash
#
# Datenmigration: diverse TLS Kampagnen, Einzelprojekte (ohne Metadatenstruktur)
#

# Ordner für Rohdaten erstellen
mkdir -p /home/laser/rawdata/tls/einzelprojekte/060530_analysis_targets/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/060630_lambert_test/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/060713_zaberbach/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/060726_hochjochhospiz/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/060928_eisriesenwelt/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/070602_dschunglbuch/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/081011_tls_halltal/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/091013_experiment_ipf/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/091013_tls_vorarlberg/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/110323_rangetest_ilris/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/111110_fotsch/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/120919_usb_stick/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/120920_mieming/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/121003_krumgampen/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/130503_adelschlag_tests/raw
mkdir -p /home/laser/rawdata/tls/einzelprojekte/140404_stubai_phenosat/raw


# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/060530_analysis_targets /home/laser/rawdata/tls/einzelprojekte/060530_analysis_targets/raw
mv /mnt/netappa/Laser/tls/daten/060630_lambertTest /home/laser/rawdata/tls/einzelprojekte/060630_lambert_test/raw
mv /mnt/netappa/Laser/tls/daten/060713_zaberbach /home/laser/rawdata/tls/einzelprojekte/060713_zaberbach/raw
mv /mnt/netappa/Laser/tls/daten/060726_hochjochhospiz /home/laser/rawdata/tls/einzelprojekte/060726_hochjochhospiz/raw
mv /mnt/netappa/Laser/tls/daten/060928_eisriesenwelt /home/laser/rawdata/tls/einzelprojekte/060928_eisriesenwelt/raw
mv /mnt/netappa/Laser/tls/daten/070602_dschunglbuch /home/laser/rawdata/tls/einzelprojekte/070602_dschunglbuch/raw
mv /mnt/netappa/Laser/tls/daten/081011_tls_halltal /home/laser/rawdata/tls/einzelprojekte/081011_tls_halltal/raw
mv /mnt/netappa/Laser/tls/daten/091013_experiment_ipf /home/laser/rawdata/tls/einzelprojekte/091013_experiment_ipf/raw
mv /mnt/netappa/Laser/tls/daten/091013_tls_vorarlberg /home/laser/rawdata/tls/einzelprojekte/091013_tls_vorarlberg/raw
mv /mnt/netappa/Laser/tls/daten/110323_rangetest_ilris /home/laser/rawdata/tls/einzelprojekte/110323_rangetest_ilris/raw
mv /mnt/netappa/Laser/tls/daten/111110_fotsch /home/laser/rawdata/tls/einzelprojekte/111110_fotsch/raw
mv /mnt/netappa/Laser/tls/daten/120919_usb_stick /home/laser/rawdata/tls/einzelprojekte/120919_usb_stick/raw
mv /mnt/netappa/Laser/tls/daten/120920_mieming /home/laser/rawdata/tls/einzelprojekte/120920_mieming/raw
mv /mnt/netappa/Laser/tls/daten/121003_krumgampen /home/laser/rawdata/tls/einzelprojekte/121003_krumgampen/raw
mv /mnt/netappa/Laser/tls/daten/130503_Adelschlag_Tests /home/laser/rawdata/tls/einzelprojekte/130503_adelschlag_tests/raw
mv /mnt/netappa/Laser/tls/daten/140404_stubai_phenosat /home/laser/rawdata/tls/einzelprojekte/140404_stubai_phenosat/raw
