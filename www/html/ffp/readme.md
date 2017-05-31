# FFP-Repository Geographie Innsbruck

## Weblink
* [http://geo1.uibk.ac.at/data/ffp/](http://geo1.uibk.ac.at/data/ffp/)
* [https://github.com/openwebcc/ba](https://github.com/openwebcc/ba)


## Features
* Startseite mit Auswahlmaske, Dokumenten & Links
    * Befliegungen jeweils M28 und M31
        * Gesamtbefliegung 2006 - 2009 (1m)
        * Aktualisierung Gletscher 2010 (1m)
        * Aktualisierung Ötztal 2010 (1m)
        * Befliegung Dauersiedlungsraum 2013 - 2015 (50cm)
    * Oberflächenmodel (DOM) nach Verfügbarkeit
    * Geländemodel (DGM) nach Verfügbarkeit
    * Höhenlinien nach Verfügbarkeit
    * Orthophoto nach Verfügbarkeit (nur visuell)
* Karteninterface
    * Hintergrundkarten Tiris Grundkarte, basemap.at
    * Geometrie der Kacheln mit Popup Metadaten und Downloadlink
    * Festlegung der AOI (area of interest) über:
        * Digitalisieren  Rechteck, Polygon
        * Upload GeoJSON mit EPSG:4326
        * Klick auf AOI startet Datendownload
    * Eingabemaske Lizenzvereinbarung vor dem Datendownload
        * Name und Adresse des/r Datennutzer/s
        * Titel der Arbeit, Projektbezeichnung, Lehrveranstaltungsname
        * Erhaltene Datensätze (vor ausgefüllt Dateiname oder AOI)
        * Checkbox Nutzungsbestimmung
        * Speicherung in der Datenbank zur Weitergabe an Land Tirol
* Benutzervalidierung beim Download über Apache Server
* Ergebnisse im Downloadbereich durch Softlinks bereitgestellt
* Datenzugang Downloadbereich nach Validierung über Samba Server

## Datenbestand (31.Mai 2017)
* 630 GB Daten
* ~40000 Dateien im Rohdatenbereich
* Dateiformate: .xyz.gz, .asc.gz, .tif, .jpg, dxf.gz

## Kontakt
[klaus.foerster@uibk.ac.at](mailto:klaus.foerster@uibk.ac.at)
