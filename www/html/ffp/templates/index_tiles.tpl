<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>FFP-Repository Tiles, $APP_title</title>
    <link rel="stylesheet" href="$APP_root/styles.css" />

    <link rel="stylesheet" href="/data/lib/Leaflet-0.7/leaflet.css" />
    <script src="/data/lib/Leaflet-0.7/leaflet.js"></script>

    <script src="/data/lib/Leaflet.draw/leaflet.draw.js"></script>
    <link rel="stylesheet" href="/data/lib/Leaflet.draw/leaflet.draw.css" />

    <script>
        fill_agreement = function (opts) {
            if (opts.id && opts.path) {
                document.forms.userdata.geom.value = '';
                document.forms.userdata.id.value = opts.id;
                document.forms.userdata.tiles.value = opts.path;
            } else if (opts.geom) {
                document.forms.userdata.id.value = '';
                document.forms.userdata.geom.value = opts.geom;

                // compose textarea content
                document.forms.userdata.tiles.value = document.getElementById('dataset_title').innerHTML;
                document.forms.userdata.tiles.value += '\n';
                document.forms.userdata.tiles.value += 'AOI=';
                document.forms.userdata.tiles.value += opts.geom;
            } else {
                // nothing else for now;
            }

            // show license agreement
            document.getElementById("agreement").style.display = 'block';
        };

        window.onload = function () {
            // helper function to convert bytes to mb
            var bytes_to_mb = function (bytes) {
                return Math.round((bytes / (1024.0 *1024.0)) * 10.0) / 10.0;
            };

            // define available tilesets
            tileSets = {
                kartetirol_summer : L.tileLayer("http://wmts.kartetirol.at/wmts/gdi_base_summer/GoogleMapsCompatible/{z}/{x}/{y}.jpeg80", {
                    attribution: '<a href="http://www.kartetirol.at/">www.kartetirol.at</a>'
                }),
                kartetirol_winter : L.tileLayer("http://wmts.kartetirol.at/wmts/gdi_winter/GoogleMapsCompatible/{z}/{x}/{y}.png", {
                    attribution: '<a href="http://www.kartetirol.at/">www.kartetirol.at</a>'
                }),
                kartetirol_ortho : L.tileLayer("http://wmts.kartetirol.at/wmts/gdi_ortho/GoogleMapsCompatible/{z}/{x}/{y}.jpg", {
                    attribution: '<a href="http://www.kartetirol.at/">www.kartetirol.at</a>'
                }),
                kartetirol_anno : L.tileLayer("http://wmts.kartetirol.at/wmts/gdi_nomenklatur/GoogleMapsCompatible/{z}/{x}/{y}.png8", {
                    attribution: '<a href="http://www.kartetirol.at/">www.kartetirol.at</a>'
                }),
                geoland_basemap : L.tileLayer("https://{s}.wien.gv.at/basemap/geolandbasemap/normal/google3857/{z}/{y}/{x}.png", {
                    subdomains : ['maps', 'maps1', 'maps2', 'maps3', 'maps4'],
                    attribution : '<a href="http://www.basemap.at/">basemap.at</a>'
                }),
                geoland_overlay : L.tileLayer("https://{s}.wien.gv.at/basemap/bmapoverlay/normal/google3857/{z}/{y}/{x}.png", {
                    subdomains : ['maps', 'maps1', 'maps2', 'maps3', 'maps4'],
                    attribution : '<a href="http://www.basemap.at/">basemap.at</a>'
                }),
                geoland_grau : L.tileLayer("https://{s}.wien.gv.at/basemap/bmapgrau/normal/google3857/{z}/{y}/{x}.png", {
                    subdomains : ['maps', 'maps1', 'maps2', 'maps3', 'maps4'],
                    attribution : '<a href="http://www.basemap.at/">basemap.at</a>'
                }),
                geoland_hidpi : L.tileLayer("https://{s}.wien.gv.at/basemap/bmaphidpi/normal/google3857/{z}/{y}/{x}.jpeg", {
                    subdomains : ['maps', 'maps1', 'maps2', 'maps3', 'maps4'],
                    attribution : '<a href="http://www.basemap.at/">basemap.at</a>'
                }),
                geoland_orthofoto30cm : L.tileLayer("https://{s}.wien.gv.at/basemap/bmaporthofoto30cm/normal/google3857/{z}/{y}/{x}.jpeg", {
                    subdomains : ['maps', 'maps1', 'maps2', 'maps3', 'maps4'],
                    attribution : '<a href="http://www.basemap.at/">basemap.at</a>'
                })
            };

            // create layergroups for tirol basemap
            layerGroupsTirol = {
                summer : L.layerGroup([tileSets.kartetirol_summer,tileSets.kartetirol_anno]),
                winter : L.layerGroup([tileSets.kartetirol_winter,tileSets.kartetirol_anno])
            };

            // add overviewmap of tirol
            var map = L.map('mapdiv', {
                center : [47.17894130869805,11.448673903942108],
                zoom : 9,
                layers : layerGroupsTirol.summer
            });

            // add layer for digitized geometry, preset with geometry if any
            var drawnItems = new L.FeatureGroup();

            // add draw control for polygons and rectangles with edit option
            drawControl = new L.Control.Draw({
                draw : {
                    polygon : true,
                    rectangle : true,
                    polyline : false,
                    circle : false,
                    marker : false

                },
                edit : {
                    featureGroup: drawnItems
                }
            });
            map.addControl(drawControl);

            // clear existing layer geometry prior to digitizing
            map.on('draw:drawstart', function (evt) {
                drawnItems.clearLayers();
            });

            // add geometry and store GeoJSON representation of the digitized polygon
            map.on('draw:created', function (evt) {
                // add geometry
                drawnItems.addLayer(evt.layer);

                // store GeoJSON representation of the digitized polygon
                fill_agreement({geom:JSON.stringify(drawnItems.toGeoJSON().features[0].geometry)});
            });

             // store GeoJSON representation of the edited polygon
             map.on('draw:editstop', function (evt) {
                fill_agreement({geom:JSON.stringify(drawnItems.toGeoJSON().features[0].geometry)});
             });

             // store edited polygon
             map.on('draw:deletestop', function (evt) {
                // reset geometry
                document.forms.userdata.geom = '';
             });

            // add tiles
            geomTiles = new L.GeoJSON($APP_geom, {
                onEachFeature: function (feature, layer) {
                    var location = feature.properties.fpath + '/' + feature.properties.fname;
                    var popup = []
                    popup.push('<h3>Kachel ' + feature.properties.tile + '</h3>');
                    popup.push('<ul>');
                    popup.push('<li>Filename: ' + feature.properties.fname + '</li>');
                    popup.push('<li>Verzeichnis: ' + feature.properties.fpath + '</li>');
                    popup.push('<li>Dateigröße (MB): ' + bytes_to_mb(feature.properties.fsize) + '</li>');
                    if (feature.properties.fdate) {
                        popup.push('<li>Aufnahmezeitpunkt: ' + feature.properties.fdate + '</li>');
                    }
                    popup.push('</ul>')
                    popup.push('<p>');
                    popup.push('<a href="#" onclick="fill_agreement({id:' + feature.properties.id + ',path:\'' + location + '\'});return false;">Download Daten</a><br/>');
                    popup.push('</p>')
                    layer.bindPopup(popup.join(''));
                }
            }).addTo(map);;

            map.fitBounds(geomTiles.getBounds())

            // provide layer navigation
            L.control.layers({
                "Karte Tirol (Sommer)": layerGroupsTirol.summer,
                "Karte Tirol (Winter)" : layerGroupsTirol.winter,
                "Karte Tirol (Orthofoto)" : tileSets.kartetirol_ortho,
                "Geoland Basemap": tileSets.geoland_basemap,
                "Geoland Basemap Grau": tileSets.geoland_grau,
                "Geoland Basemap Orthofoto" : tileSets.geoland_orthofoto30cm
            }, {
                "Geometrie Kacheln": geomTiles
            }).addTo(map);

            // add scale bar
            L.control.scale({'imperial' : false}).addTo(map);


        };
    </script>
  </head>

  <main>
  <h2>FFP-Repository <span id="dataset_title">$APP_title</span></h2>

  <div id="mapdiv" style="width:990px;height:600px;"></div>

  <section id="agreement">
    <div class="pane">
        <header>
            <img src="$APP_root/icons/logo_land.png" alt="Logo Land Tirol"/>
            <div style="float:right;text-align:right;">
                <p>Amt der Tiroler Landesregierung</p>
                <p><strong>Geoinformation</strong></p>
                <p><a href="mailto:geoinformation@tirol.gv.at">geoinformation@tirol.gv.at</a></p>
            </div>
        </header>

        <p>Das Land Tirol stellt Ihnen für Ihre Bachelorarbeit, Masterarbeit, Diplomarbeit, Dissertation, Seminararbeit, Projektarbeit, Lehrtätigkeit oder Forschungstätigkeit Geodaten zur Verfügung.
        </p>
        <p>Die erhaltenen Geodaten dürfen nur für den angegebenen, universitären Zweck verwendet werden. Die Weitergabe an Dritte ist grundsätzlich nicht gestattet, eine Ausnahme bildet die Weitergabe durch den Lehrveranstaltungsleiter innerhalb einer Lehrveranstaltung zur Erfüllung des Lehrveranstaltungsziels. Bei sämtlichen Veröffentlichungen von Darstellungen der Geodaten, auch von Folgeprodukten, muss das Urheberrecht des Landes Tirol angeführt werden (© Land Tirol).
        </p>

        <form name="userdata" method="POST" action="$APP_root/restricted/download">
        <fieldset>
        <legend><strong>Angaben zur Datennutzung</strong></legend>

        <p>
        <label for="person">Name und Adresse des/r Datennutzer/s</label>
        <textarea name="person" rows="4" cols="60"></textarea>
        </p>

        <p>
        <label for="project">Titel der Arbeit, Projektbezeichnung, Lehrveranstaltungsname</label>
        <textarea name="project" rows="4" cols="60"></textarea>
        </p>

        <p>
        <label for="tiles">Erhaltene Datensätze</label>
        <textarea name="tiles" rows="4" cols="60"></textarea>
        </p>

        <p>
        <input type="checkbox" name="confirmed"> Ich bestätige hiermit, dass ich die <a href="$APP_root/pdf/nutzungsbestimmungen.pdf">Nutzungsbestimmungen für Geodaten</a> des Landes Tirol gelesen habe und einhalten werde.
        </p>

        <input type="hidden" name="id" value="">
        <input type="hidden" name="geom" value="">
        <input type="hidden" name="pname" value="$VAL_pname">
        <input type="hidden" name="cdate" value="$VAL_cdate">
        <input type="hidden" name="cname" value="$VAL_cname">
        <input type="hidden" name="ftype" value="$VAL_ftype">

        <p style="text-align:right;">
            <input type="button" value="Abbrechen" onclick="document.getElementById('agreement').style.display='none'">
            <input type="submit" value="Nutzungsvereinbarung abschicken &gt;&gt;" >
        </p>

        </fieldset>
        </form>

    </div>
  </section>

  </main>

</html>
