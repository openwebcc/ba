<!DOCTYPE html>
<html>
<head>
    <title>$APP_cid / LiDAR-Repository Geographie Innsbruck</title>
    <link rel="stylesheet" href="$APP_root/styles.css" />

    <link rel="stylesheet" href="$LEAFLET_root/Leaflet/leaflet.css" />
    <script src="$LEAFLET_root/Leaflet/leaflet.js"></script>

    <link rel="stylesheet" href="$LEAFLET_root/Leaflet.draw/leaflet.draw.css" />
    <script src="$LEAFLET_root/Leaflet.draw/leaflet.draw.js"></script>

    <!-- load geometries -->
    <script src='$LEAFLET_root/Leaflet.omnivore/leaflet-omnivore.js'></script>

    <script>
    window.onload = function () {
        // set up map tile layer for OSM and geoland
        var osm = {
            basemap : L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: "&copy; <a href='http://openstreetmap.org/copyright'>OpenStreetMap</a> contributors",
                maxZoom: 18
            })
        };
        var geoland = { // http://www.basemap.at/wmts/1.0.0/WMTSCapabilities.xml
            geolandbasemap : L.tileLayer("//{s}.wien.gv.at/basemap/geolandbasemap/normal/google3857/{z}/{y}/{x}.png", {
                subdomains : ['maps', 'maps1', 'maps2', 'maps3', 'maps4'],
                attribution : '<a href="http://www.basemap.at/" target="_blank">basemap.at</a>, <a href="http://creative commons.org/licenses/by/3.0/at/deed.de" target="_blank">CC-BY 3.0</a>'
            }),
            bmapoverlay : L.tileLayer("//{s}.wien.gv.at/basemap/bmapoverlay/normal/google3857/{z}/{y}/{x}.png", {
                subdomains : ['maps', 'maps1', 'maps2', 'maps3', 'maps4'],
                attribution : '<a href="http://www.basemap.at/" target="_blank">basemap.at</a>, <a href="http://creative commons.org/licenses/by/3.0/at/deed.de" target="_blank">CC-BY 3.0</a>'
            }),
            bmapgrau : L.tileLayer("//{s}.wien.gv.at/basemap/bmapgrau/normal/google3857/{z}/{y}/{x}.png", {
                subdomains : ['maps', 'maps1', 'maps2', 'maps3', 'maps4'],
                attribution : '<a href="http://www.basemap.at/" target="_blank">basemap.at</a>, <a href="http://creative commons.org/licenses/by/3.0/at/deed.de" target="_blank">CC-BY 3.0</a>'
            }),
            bmaphidpi : L.tileLayer("//{s}.wien.gv.at/basemap/bmaphidpi/normal/google3857/{z}/{y}/{x}.jpeg", {
                subdomains : ['maps', 'maps1', 'maps2', 'maps3', 'maps4'],
                attribution : '<a href="http://www.basemap.at/" target="_blank">basemap.at</a>, <a href="http://creative commons.org/licenses/by/3.0/at/deed.de" target="_blank">CC-BY 3.0</a>'
            }),
            bmaporthofoto30cm : L.tileLayer("//{s}.wien.gv.at/basemap/bmaporthofoto30cm/normal/google3857/{z}/{y}/{x}.jpeg", {
                subdomains : ['maps', 'maps1', 'maps2', 'maps3', 'maps4'],
                attribution : '<a href="http://www.basemap.at/" target="_blank">basemap.at</a>, <a href="http://creative commons.org/licenses/by/3.0/at/deed.de" target="_blank">CC-BY 3.0</a>'
            })
        };
        var bozen = { // http://www.provinz.bz.it/informatik/kartografie/Geoportal.asp
            basemap : L.tileLayer("http://sdi.provinz.bz.it/geoserver/gwc/service/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&Layer=WMTS_BASEMAP_APB-PAB&Style=default&Format=image/png8&TileMatrixSet=GoogleMapsCompatible&TileMatrix=GoogleMapsCompatible:{z}&TileRow={y}&TileCol={x}", {
                attribution : '<a href="http://www.provinz.bz.it/informatik/kartografie/Geoportal.asp">Autonome Provinz Bozen - Südtirol | Abteilung Informationstechnik</a>'
            }),
            of2011 : L.tileLayer("http://sdi.provinz.bz.it/geoserver/gwc/service/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&Layer=WMTS_OF2011_APB-PAB&Style=default&Format=image/png8&TileMatrixSet=GoogleMapsCompatible&TileMatrix=GoogleMapsCompatible:{z}&TileRow={y}&TileCol={x}", {
                attribution : '<a href="http://www.provinz.bz.it/informatik/kartografie/Geoportal.asp">Autonome Provinz Bozen - Südtirol | Abteilung Informationstechnik</a>'
            })
        };
        var norway = {  // http://kartverket.no/kart/gratis-kartdata/wms-tjenester/
            statkart : L.tileLayer('http://opencache.statkart.no/gatekeeper/gk/gk.open_gmaps?layers=topo2&zoom={z}&x={x}&y={y}', {
                attribution: '&copy; <a href="http://kartverket.no/">Kartverket</a>'
            }),
            statkartgray : L.tileLayer('http://opencache.statkart.no/gatekeeper/gk/gk.open_gmaps?layers=topo2graatone&zoom={z}&x={x}&y={y}', {
                attribution: '&copy; <a href="http://kartverket.no/">Kartverket</a>'
            })
        };

        //map = new L.Map('map', {layers: [osm.basemap], center: new L.LatLng(46.8, 10.77), zoom: 13}),
        map = new L.Map('map', {layers: [osm.basemap]});
        drawnItems = L.featureGroup().addTo(map);

        var activateSubmitButton = function (id, hide) {
            if (hide) {
                document.getElementById(id).geom.value = "";
                document.getElementById(id).style.display = "none";
            } else {
                document.getElementById(id).geom.value = JSON.stringify(drawnItems.toGeoJSON().features[0].geometry);
                document.getElementById(id).style.display = "inline";
            }
        };
        var deactivateSubmitButton = function (id) {
            // call activate function with hide set to true
            activateSubmitButton(id,true);
        };

        map.addControl(new L.Control.Draw({
            draw : {
                polygon : {
                    shapeOptions: {
                        color: 'lime'
                    }
                },
                rectangle : {
                    shapeOptions: {
                        color: 'lime'
                    }
                },
                circle : false,
                polyline : false,
                marker : false
            },
            edit: { featureGroup: drawnItems }
        }));

        // clear existing layer geometry prior to digitizing
        map.on('draw:drawstart', function (evt) {
            drawnItems.clearLayers();
        });

        map.on('draw:created', function(event) {
            var layer = event.layer;
            sw = layer.getBounds().getSouthWest();
            ne = layer.getBounds().getNorthEast();

            drawnItems.addLayer(layer);

            // activate download buttons
            activateSubmitButton('APP_download_points');
            activateSubmitButton('APP_download_strips');
        });

        map.on('draw:deletestop', function (evt) {
            // deactivate download buttons
            deactivateSubmitButton('APP_download_points');
            deactivateSubmitButton('APP_download_strips');
        });

        var lasFiles = L.geoJson(null, {
            onEachFeature: function (feature, layer) {
                var popup = []
                popup.push('<h3>' + feature.properties.fname + '</h3>');
                popup.push('<ul>');
                popup.push('<li>Anzahl Punkte: ' + feature.properties.points + '</li>');
                popup.push('<li>Dateigröße (MB): ' + feature.properties.fsize + '</li>');
                popup.push('</ul>')
                popup.push('<p>');
                popup.push('<a href="$APP_root/app.py/details?gid=' + feature.properties.gid + '">Metadaten anzeigen</a><br/>');
                popup.push('<a href="$APP_root/restricted/download/lasfile?gid=' + feature.properties.gid + '">Download LAS-Datei</a><br/>');
                // add link to trajectory download if available
                if (feature.properties.has_traj == true) {
                    popup.push('<a href="$APP_root/restricted/download/trajectory?gid=' + feature.properties.gid + '">Download originale Flugtrajektorie</a><br/>');
                }
                popup.push('</p>')
                layer.bindPopup(popup.join(''));
            }
        });
        var geojson_layer = omnivore.geojson('$APP_root/app.py/geom?cid=$APP_cid',null, lasFiles).on(
            'ready', function() {
                // look at campaign
                map.fitBounds(geojson_layer.getBounds());
            }).addTo(map)

        // provide layer navigation
        L.control.layers({
            "OpenStreetMap": osm.basemap,
            "Geoland Basemap" : geoland.geolandbasemap,
            //"Geoland Basemap Overlay" : geoland.bmapoverlay,
            "Geoland Basemap Grau": geoland.bmapgrau,
            //"Geoland Basemap High DPI" : geoland.bmaphidpi,
            "Geoland Basemap Orthofoto" : geoland.bmaporthofoto30cm,
            "Südtirol Grundkarte" : bozen.basemap,
            "Südtirol Orthofoto" : bozen.of2011,
            "Norwegian Mapping Authority" : norway.statkart,
            "Norwegian Mapping Authority grau" : norway.statkartgray

        }, {
            "Flugstreifen": lasFiles
        }).addTo(map);

        // add scale bar
        L.control.scale({'imperial' : false}).addTo(map);

        // upload area of interest in GeoJSON format
        document.getElementById("uploadAOI").onchange = function () {
            var reader, js_obj;
            reader = new FileReader();
            reader.onload = function(evt) {
                try {
                    // convert GeoJSON-string to Javascript object
                    js_obj = JSON.parse(evt.target.result);

                    // add it to the layer of draw items
                    drawnItems.addLayer(L.geoJSON(js_obj, {
                        'style' : function () {
                            return {color: 'lime'};
                        }
                    }).getLayers()[0]);

                    // look at AOI
                    map.fitBounds(drawnItems.getBounds());

                    // activate download buttons
                    activateSubmitButton('APP_download_points');
                    activateSubmitButton('APP_download_strips');

                } catch (err) {
                    alert('ERROR: ' + err);
                }
            };
            // read GeoJSON file
            reader.readAsText(this.files[0]);
        };
    };
    </script>

</head>

<body>
<main>
  <h1>LiDAR-Repository Geographie Innsbruck</h1>
  <p>
    <strong>Befliegung $APP_val_ptype:$APP_val_pname:$APP_val_cdate:$APP_val_cname</strong> ($APP_val_files Dateien, $APP_val_mb MB)
  </p>

  <table style="width:100%">
    <tr>
      <td>
        <form id="APP_download_points" method="GET" action="$APP_root/restricted/download/points" style="display:none;">
          <input type="hidden" name="cid" value="$APP_cid">
          <input type="hidden" name="geom">
          <input type="submit" value="Download Punkte im Hüllrechteck der Geometrie" />
        </form>
        <form id="APP_download_strips" method="GET" action="$APP_root/restricted/download/strips" style="display:none;">
          <input type="hidden" name="cid" value="$APP_cid">
          <input type="hidden" name="geom">
          <input type="submit" value="Download Streifen die das Rechteck schneiden" />
        </form>
      </td>
      <td style="text-align:right;">
        <form method="GET" action="$APP_root/app.py/details">
        <select name="gid">$APP_pulldown_files</select>
        <input type="submit" value="Metadaten" />
        </form>
      </td>
    </tr>
  </table>

   <div id="map" style="width: 894px; height: 600px; border: 1px solid #ccc;margin:auto;"></div>

<p>
  Laserpunkte: $APP_val_points |
  Punktdichte pro m²: $APP_val_density |
  Sensor: $APP_val_sensor |
  Projektion: <a href="http://spatialreference.org/ref/epsg/$APP_val_srid/">EPSG:$APP_val_srid</a> |
  Flugdatum: $APP_val_cdates $APP_val_year
  $APP_report
</p>
<p>
  Area of interest auswählen: <input type="file" id="uploadAOI"> <span style="font-size:0.85em;">(Format: GeoJSON, EPSG:4326)</span>
</p>

<p style="text-align:right;font-size:0.9em;font-style:italic;"><a href="https://github.com/openwebcc/ba">GitHub-Repository</a>

</main>
</body>
</html>
