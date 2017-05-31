# LiDAR-Repository Geographie Innsbruck

## Weblink
[http://geo1.uibk.ac.at/data/lidar/](http://geo1.uibk.ac.at/data/lidar/)


## Features
* Tabelle aller Befliegungen mit Metadaten als Zugang zum Karteninterface
* Karteninterface mit:
    * Hintergrundkarten OSM, basemap.at, Südtirol, Norwegen
    * Geometrie der Flugstreifen, Kacheln
    * Metadatenanzeige der Flugstreifen, Kacheln
        * Details aus `lasinfo`
        * JSON-Attribute der Datenbank
        * Downloadmöglichkeit Flugstreifen, Kachel, Trajektorie
    * Befliegungsbericht (PDF) sofern vorhanden
    * Festlegung der AOI (area of interest) über:
        * Digitalisieren  Rechteck, Polygon
        * Upload GeoJSON mit EPSG:4326
* Downloadmöglichkeiten:
    * einzelne Streifen und Kacheln durch Klick auf Geometrie
    * Laserpunkte im Hüllrechteck der AOI
    * Streifen, Kacheln die die AOI schneiden
    * Trajektorie sofern vorhanden über die Metadatenanzeige
* Benutzervalidierung beim Download über Apache Server
* Ergebnisse im Downloadbereich durch Softlinks bereitgestellt
* Datenzugang Downloadbereich nach Validierung über Samba Server

## Datenbestand (31.Mai 2017)
* 1,8 TB ALS-Daten
* 340 GB TLS-Daten (noch nicht im Karteninterface integriert)
* ~25000 Dateien im Rohdatenbereich
* Dateiformate: .las, .laz, .txt

## Kontakt
[klaus.foerster@uibk.ac.at](mailto:klaus.foerster@uibk.ac.at)
