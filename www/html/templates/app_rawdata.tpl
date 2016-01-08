<!DOCTYPE html>
<html>
<head>
    <title>$APP_cid / LiDAR data browser Geographie Innsbruck</title>


    <script src="$APP_root/Leaflet.draw/examples/libs/leaflet-src.js"></script>
    <link rel="stylesheet" href="$APP_root/Leaflet.draw/examples/libs/leaflet.css" />

    <script src="$APP_root/Leaflet.draw/src/Leaflet.draw.js"></script>
    <link rel="stylesheet" href="$APP_root/Leaflet.draw/dist/leaflet.draw.css" />

    <script src="$APP_root/Leaflet.draw/src/Toolbar.js"></script>
    <script src="$APP_root/Leaflet.draw/src/Tooltip.js"></script>

    <script src="$APP_root/Leaflet.draw/src/ext/GeometryUtil.js"></script>
    <script src="$APP_root./Leaflet.draw/src/ext/LatLngUtil.js"></script>
    <script src="$APP_root/Leaflet.draw/src/ext/LineUtil.Intersect.js"></script>
    <script src="$APP_root/Leaflet.draw/src/ext/Polygon.Intersect.js"></script>
    <script src="$APP_root/Leaflet.draw/src/ext/Polyline.Intersect.js"></script>


    <script src="$APP_root/Leaflet.draw/src/draw/DrawToolbar.js"></script>
    <script src="$APP_root/Leaflet.draw/src/draw/handler/Draw.Feature.js"></script>
    <script src="$APP_root/Leaflet.draw/src/draw/handler/Draw.SimpleShape.js"></script>
    <script src="$APP_root/Leaflet.draw/src/draw/handler/Draw.Polyline.js"></script>
    <script src="$APP_root/Leaflet.draw/src/draw/handler/Draw.Circle.js"></script>
    <script src="$APP_root/Leaflet.draw/src/draw/handler/Draw.Marker.js"></script>
    <script src="$APP_root/Leaflet.draw/src/draw/handler/Draw.Polygon.js"></script>
    <script src="$APP_root/Leaflet.draw/src/draw/handler/Draw.Rectangle.js"></script>


    <script src="$APP_root/Leaflet.draw/src/edit/EditToolbar.js"></script>
    <script src="$APP_root/Leaflet.draw/src/edit/handler/EditToolbar.Edit.js"></script>
    <script src="$APP_root/Leaflet.draw/src/edit/handler/EditToolbar.Delete.js"></script>

    <script src="$APP_root/Leaflet.draw/src/Control.Draw.js"></script>

    <script src="$APP_root/Leaflet.draw/src/edit/handler/Edit.Poly.js"></script>
    <script src="$APP_root/Leaflet.draw/src/edit/handler/Edit.SimpleShape.js"></script>
    <script src="$APP_root/Leaflet.draw/src/edit/handler/Edit.Circle.js"></script>
    <script src="$APP_root/Leaflet.draw/src/edit/handler/Edit.Rectangle.js"></script>
    <script src="$APP_root/Leaflet.draw/src/edit/handler/Edit.Marker.js"></script>

    <!-- load geometries -->
    <script src='$APP_root/Leaflet.omnivore/leaflet-omnivore.js'></script>

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
            statkart : L.tileLayer('http://opencache.statkart.no/gatekeeper/gk/gk.open_gmaps?layers=norges_grunnkart&zoom={z}&x={x}&y={y}', {
                attribution: '&copy; <a href="http://kartverket.no/">Kartverket</a>'
            })
        };

        //map = new L.Map('map', {layers: [osm.basemap], center: new L.LatLng(46.8, 10.77), zoom: 13}),
        map = new L.Map('map', {layers: [osm.basemap]});
        drawnItems = L.featureGroup().addTo(map);

        map.addControl(new L.Control.Draw({
            draw : {
                circle : false,
                polygon : false,
                polyline : false,
                marker : false
            },
            edit: { featureGroup: drawnItems }
        }));

        map.on('draw:created', function(event) {
            var layer = event.layer;
            sw = layer.getBounds().getSouthWest();
            ne = layer.getBounds().getNorthEast();

            drawnItems.addLayer(layer);

            document.getElementById('APP_download_points').innerHTML = '<li><a href="$APP_root/app.py/points?cid=$APP_cid;extent=' + sw.lng + ',' + sw.lat + ',' + ne.lng + ',' + ne.lat + '">Download Punkte innerhalb des Rechtecks</a></li>';
            document.getElementById('APP_download_strips').innerHTML = '<li><a href="$APP_root/app.py/strips?cid=$APP_cid;extent=' + sw.lng + ',' + sw.lat + ',' + ne.lng + ',' + ne.lat + '">Download Streifen / Kacheln die das Rechteck schneiden</a></li>';
            document.getElementById('APP_download_points').style.display = "list-item";
            document.getElementById('APP_download_strips').style.display = "list-item";

            // TODO: maybe we will need the code below sometime ... skip it for now ...
            // select lines intersecting the rectangle
            //bounds = layer.getBounds();
            //geojson_layer.eachLayer(function (geom) {
            //    var i,points;
            //    points = geom.getLatLngs();
            //    for (i = 0; i < points.length; i+= 1) {
            //        if (bounds.contains(points[i])) {
            //            geom.setStyle({
            //                color: '#cfc'
            //            });
            //            break;
            //        }
            //    }
            //});
        });

        var lasFiles = L.geoJson(null, {
            // http://leafletjs.com/reference.html#geojson-style
            //style: function(feature) {
            //    // TODO: do we want to display thematic stuff like point density?
            //    return { color: '#f00' };
            //},
            onEachFeature: function (feature, layer) {
                //alert(feature.properties)
                var popup = []
                popup.push('<h3>' + feature.properties.fname + '</h3>');
                popup.push('<ul>');
                popup.push('<li>GID: ' + feature.properties.gid + '</li>');
                popup.push('<li>Anzahl Punkte: ' + feature.properties.points + '</li>');
                popup.push('<li>Filegröße (mb): ' + feature.properties.fsize + '</li>');
                popup.push('</ul>')
                popup.push('<p>');
                popup.push('<a href="$APP_root/app.py/details?gid=' + feature.properties.gid + '">Details anzeigen</a><br/>');
                popup.push('<a href="$APP_root/app.py/lasfile?gid=' + feature.properties.gid + '">Download LAS file</a><br/>');
                // add link to trajectory download if available
                if (feature.properties.has_traj == true) {
                    popup.push('<a href="$APP_root/app.py/trajectory?gid=' + feature.properties.gid + '">Download Flugtrajektorie</a><br/>');
                }
                popup.push('</p>')
                layer.bindPopup(popup.join(''));
            }
        });
        var fitBounds = function () {
            map.fitBounds(geojson_layer)
        };
        var geojson_layer = omnivore.geojson('$APP_root/app.py/geom?cid=$APP_cid',null, lasFiles).on(
            'ready', function() {
                // look at campaign
                fitBounds();
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
            "Norwegian Mapping Authority" : norway.statkart
        }, {
            "Flugstreifen": lasFiles
        }).addTo(map);
    };
    </script>

</head>
<body>
    <div id="map" style="width: 800px; height: 600px; border: 1px solid #ccc"></div>
    <ul>
      $APP_report
      <li id="APP_download_points" style="display:none;"></li>
      <li id="APP_download_strips" style="display:none;"></li>
    </ul>

</body>
</html>
