# Sentinel-2 Metadaten Geographie Innsbruck

## Weblink
* [https://geo1.uibk.ac.at/data/sentinel2/](https://geo1.uibk.ac.at/data/sentinel2/)
* [https://github.com/openwebcc/ba](https://github.com/openwebcc/ba)


## Features
* Startseite mit:
    * Metadatensuche nach:
        * Kacheln im Monitoring nach Military Grid Reference System
        * Zeitraum von / bis
        * Qualitätsindikatoren Bewölkung / Datenbestand
        * bereits downgeloadeten Szenen
    * Liste der letzten 15 Szenen
    * Download Metadaten aller Szenen als CSV
* Suchergebnisseite mit:
    * Vorschau der Szenen mit Link zu den Metadaten
    * Link zur Szene auf Amazon S3
    * Downloadlink für Rohdaten der Szene
    * Toolbox Link für bereits downgeloadete Szenen
    * Download Link zu Produkten im SENTINEL-SAFE-Format bei <a href="http://scihub.copernicus.eu">http://scihub.copernicus.eu</a>
    * RSS-Feed zum Abonnieren der Suche
* Toolboxseite mit:
    * Vorschau der Szene
    * Subscribe / Unsubscribe Button vorhandener Szenen für den aktuellen Benutzer
    * Details zur Szene und zum Datenzugang
    * Buttons zur Generierung von Derivaten RGB, NDVI, NDSI im Erdas Imagine Format (HFA)
* Benutzervalidierung beim Download und Erstellen von Derivaten über Apache Server
* Ergebnisse im Downloadbereich durch Softlinks bereitgestellt
* Datenzugang Downloadbereich nach Validierung über Samba Server

## Aktualisierung der Daten
* Eingabe von Kacheln zum Monitoring durch sysadmin
* automatisierter Download neuer Metadaten beim Monitoring über cron.daily
* Zeitfenster beim Monitoring sieben Tage zurück (Auffangen von Nachlieferungen)
* Speicherbedarf pro Szene
    * Metadaten nächtlich: ~ 700K
    * Rohdaten nach Download: ~ 700 MB
    * Derivat RGB: 695 MB
    * Derivat NDVI: 463 MB
    * Derivat NDSI: 463 MB
    * maximal ~ 2.3 GB wenn alle Produkte vorhanden sind

## Datenbestand (31.Mai 2017)
* 345 GB Metadaten und Derivate
* ~36000 Dateien im Rohdatenbereich
* Dateiformate: .jp2, .json, .gml, .xml, .img
* Statistik

        Kacheln im Monitoring:    22
        Szenen mit Metadaten:   2706
        Szenen downgeloadet:     255
        Derivate RGB:            160
        Derivate NDVI:            94
        Derivate NDSI:            65

## Kontakt
[klaus.foerster@uibk.ac.at](mailto:klaus.foerster@uibk.ac.at)
