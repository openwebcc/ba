#!/bin/bash
#
# Datenmigration: diverse TLS Kampagnen, Einzelprojekte (ohne Metadatenstruktur)
#

# Ordner für Rohdaten erstellen
mkdir -p /home/rawdata/tls/einzelprojekte/060530_analysis_targets
mkdir -p /home/rawdata/tls/einzelprojekte/060630_lambert_test
mkdir -p /home/rawdata/tls/einzelprojekte/060713_zaberbach
mkdir -p /home/rawdata/tls/einzelprojekte/060726_hochjochhospiz
mkdir -p /home/rawdata/tls/einzelprojekte/060928_eisriesenwelt
mkdir -p /home/rawdata/tls/einzelprojekte/070602_dschunglbuch
mkdir -p /home/rawdata/tls/einzelprojekte/081011_tls_halltal
mkdir -p /home/rawdata/tls/einzelprojekte/091013_experiment_ipf
mkdir -p /home/rawdata/tls/einzelprojekte/091013_tls_vorarlberg
mkdir -p /home/rawdata/tls/einzelprojekte/110323_rangetest_ilris
mkdir -p /home/rawdata/tls/einzelprojekte/111110_fotsch
mkdir -p /home/rawdata/tls/einzelprojekte/120919_usb_stick
mkdir -p /home/rawdata/tls/einzelprojekte/120920_mieming
mkdir -p /home/rawdata/tls/einzelprojekte/121003_krumgampen
mkdir -p /home/rawdata/tls/einzelprojekte/130503_adelschlag_tests
mkdir -p /home/rawdata/tls/einzelprojekte/140404_stubai_phenosat
mkdir -p /home/rawdata/tls/einzelprojekte/140804_schrankogel

# Rohdaten verschieben
mv /mnt/netappa/Laser/tls/daten/060530_analysis_targets /home/rawdata/tls/einzelprojekte/060530_analysis_targets/raw
mv /mnt/netappa/Laser/tls/daten/060630_lambertTest /home/rawdata/tls/einzelprojekte/060630_lambert_test/raw
mv /mnt/netappa/Laser/tls/daten/060713_zaberbach /home/rawdata/tls/einzelprojekte/060713_zaberbach/raw
mv /mnt/netappa/Laser/tls/daten/060726_hochjochhospiz /home/rawdata/tls/einzelprojekte/060726_hochjochhospiz/raw
mv /mnt/netappa/Laser/tls/daten/060928_eisriesenwelt /home/rawdata/tls/einzelprojekte/060928_eisriesenwelt/raw
mv /mnt/netappa/Laser/tls/daten/070602_dschunglbuch /home/rawdata/tls/einzelprojekte/070602_dschunglbuch/raw
mv /mnt/netappa/Laser/tls/daten/081011_tls_halltal /home/rawdata/tls/einzelprojekte/081011_tls_halltal/raw
mv /mnt/netappa/Laser/tls/daten/091013_experiment_ipf /home/rawdata/tls/einzelprojekte/091013_experiment_ipf/raw
mv /mnt/netappa/Laser/tls/daten/091013_tls_vorarlberg /home/rawdata/tls/einzelprojekte/091013_tls_vorarlberg/raw
mv /mnt/netappa/Laser/tls/daten/110323_rangetest_ilris /home/rawdata/tls/einzelprojekte/110323_rangetest_ilris/raw
mv /mnt/netappa/Laser/tls/daten/111110_fotsch /home/rawdata/tls/einzelprojekte/111110_fotsch/raw
mv /mnt/netappa/Laser/tls/daten/120919_usb_stick /home/rawdata/tls/einzelprojekte/120919_usb_stick/raw
mv /mnt/netappa/Laser/tls/daten/120920_mieming /home/rawdata/tls/einzelprojekte/120920_mieming/raw
mv /mnt/netappa/Laser/tls/daten/121003_krumgampen /home/rawdata/tls/einzelprojekte/121003_krumgampen/raw
mv /mnt/netappa/Laser/tls/daten/130503_Adelschlag_Tests /home/rawdata/tls/einzelprojekte/130503_adelschlag_tests/raw
mv /mnt/netappa/Laser/tls/daten/140404_stubai_phenosat /home/rawdata/tls/einzelprojekte/140404_stubai_phenosat/raw
mv /mnt/netappa/Laser/tls/daten/140804_schrankogel /home/rawdata/tls/einzelprojekte/140804_schrankogel/raw

