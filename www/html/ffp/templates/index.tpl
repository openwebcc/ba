<!DOCTYPE html>
<html>
<title>FFP-Repository Geographie Innsbruck</title>
<link rel="stylesheet" href="$APP_root/styles.css" />
<script>

window.onload = function () {
    // deactivate settings according to data availability
    document.forms[0].dataset.onchange = function (evt) {
        var deactivate, dataset, i, nodes;

        deactivate = {
            '101012_gletscher' : [
                'select_m31',
                'opt_dom_ftype_xyz',
                'opt_dom_ftype_tif',
                'opt_dgm_ftype_xyz',
                'opt_dgm_ftype_tif',
                'opt_iso_ftype_dxf',
                'opt_oph_ftype_jpg',
                'radio_ctype_iso',
                'radio_ctype_oph',
                'select_iso_ftype',
                'select_oph_ftype',
            ],
            '101013_oetztal' : [
                'select_m31',
                'opt_dom_ftype_xyz',
                'opt_dom_ftype_tif',
                'opt_dgm_ftype_xyz',
                'opt_dgm_ftype_tif',
                'opt_iso_ftype_dxf',
                'opt_oph_ftype_jpg',
                'radio_ctype_iso',
                'radio_ctype_oph',
                'select_iso_ftype',
                'select_oph_ftype',
            ],
            '151025_dsr' : [
                'opt_iso_ftype_dxf',
                'opt_oph_ftype_jpg',
                'radio_ctype_iso',
                'radio_ctype_oph',
                'select_iso_ftype',
                'select_oph_ftype',
            ]
        };

        // show all nodes
        nodes = document.forms[0].querySelectorAll('div,select,option');
        for (i = 0; i < nodes.length; i += 1) {
            if (nodes.item(i).style.pointerEvents === "none") {
                nodes.item(i).style.opacity = "1.0";
                nodes.item(i).style.pointerEvents = "auto";
            }
        }

        // hide nodes if needed
        dataset = evt.target.options[evt.target.options.selectedIndex].value;
        if (deactivate.hasOwnProperty(dataset)) {
            for (i = 0; i < deactivate[dataset].length; i += 1) {
                document.getElementById(deactivate[dataset][i]).style.opacity = "0.2";
                document.getElementById(deactivate[dataset][i]).style.pointerEvents = "none";
            }
        }
    };
};

</script>
<main>
<img src="$APP_root/icons/logo_land.png" alt="Logo Land Tirol" style="float:right;"/>
<h1>FFP-Repository Geographie Innsbruck</h1>

<form method="GET" action="/data/ffp/index/tiles/">

    <select name="dataset">
        <option value="090930_gesamt">Gesamtbefliegung 2006 - 2009 (1m)</option>
        <option value="101012_gletscher">Aktualisierung Gletscher 2010 (1m)</option>
        <option value="101013_oetztal">Aktualisierung Ötztal 2010 (1m)</option>
        <option value="151025_dsr">Befliegung Dauersiedlungsraum 2013 - 2015 (50cm)</option>
    </select>

    <select name="pname">
        <option value="m28" id="select_m28">M28</option>
        <option value="m31" id="select_m31">M31</option>
    </select>

    <br />
    <div class="ftype_dataset" id="radio_ctype_dom"><input type="radio" name="ctype" value="dom" checked> DOM</div>
    <select name="dom_ftype" class="ftype_pulldown" id="select_dom_ftype">
        <option id="opt_dom_ftype_xyz" value="xyz" selected>*.xyz.gz</option>
        <option id="opt_dom_ftype_asc" value="asc">*.asc.gz</option>
        <option id="opt_dom_ftype_tif" value="tif">*.tif</option>
    </select>

    <br />
    <div class="ftype_dataset" id="radio_ctype_dgm"><input type="radio" name="ctype" value="dgm"> DGM</div>
    <select name="dgm_ftype" class="ftype_pulldown" id="select_dgm_ftype">
        <option id="opt_dgm_ftype_xyz" value="xyz" selected>*.xyz.gz</option>
        <option id="opt_dgm_ftype_asc" value="asc">*.asc.gz</option>
        <option id="opt_dgm_ftype_tif" value="tif">*.tif</option>
    </select>

    <br />
    <div class="ftype_dataset" id="radio_ctype_iso"><input type="radio" name="ctype" value="iso"> ISO</div>
    <select name="iso_ftype" selected class="ftype_pulldown" id="select_iso_ftype">
        <option id="opt_iso_ftype_dxf" value="dxf" selected>*.dxf.gz</option>
    </select>

    <br />
    <div class="ftype_dataset" id="radio_ctype_oph"><input type="radio" name="ctype" value="oph"> OPH</div>
    <select name="oph_ftype" selected class="ftype_pulldown" id="select_oph_ftype">
        <option id="opt_oph_ftype_jpg" value="jpg" selected>*.jpg</option>
    </select>

    <input type="submit" value="Karte anzeigen &gt;&gt;">

</form>

<h3>Dokumente</h3>
<ul>
    <li><a href="$APP_root/pdf/datenverfuegbarkeit_elsner_20170403.pdf">Datenverfügbarkeit</a> (Bernhard Elsner, 3.4.2017)</li>
    <li><a href="$APP_root/pdf/2006_2009_uebersicht_ALS_M28.pdf">Befliegung 2006-2009 - ALS Blattschnitt (M28) (PDF)</a></li>
    <li><a href="$APP_root/pdf/2006_2009_uebersicht_ALS_M31.pdf">Befliegung 2006-2009 - ALS Blattschnitt (M31) (PDF)</a></li>
    <li><a href="$APP_root/pdf/2006_2009_uebersicht_OPH_M28.pdf">Befliegung 2006-2009 - OPH Blattschnitt (M28) (PDF)</a></li>
    <li><a href="$APP_root/pdf/2006_2009_uebersicht_OPH_M31.pdf">Befliegung 2006-2009 - OPH Blattschnitt (M31) (PDF)</a></li>
    <li><a href="$APP_root/pdf/2010_aktualisierung_uebersicht.pdf">Aktualisierung 2010: Übersicht (PDF)</a></li>
    <li><a href="$APP_root/pdf/2010_aktualisierung_10-TopScanUIA-B02-Abschlussbericht.pdf">Aktualisierung 2010: Abschlussbericht (PDF)</a></li>
    <li><a href="$APP_root/pdf/2010_aktualisierung_2009_AVT_alpS-Tirol_LS-Param01.pdf">Aktualisierung 2010: Scanparameter (PDF)</a></li>
</ul>

<h3>Links</h3>
<ul>
    <li><a href="https://www.tirol.gv.at/sicherheit/geoinformation/geodaten/laserscandaten/">Laserscandaten@Abteilung Geoinformation</a></li>
    <li><a href="https://portal.tirol.gv.at/LBAWeb/luftbilduebersicht.show">Laser- &amp; Luftbildatlas Tirol</a></li>
</ul>

<p style="text-align:right;font-size:0.9em;font-style:italic;"><a href="https://github.com/openwebcc/ba">GitHub-Repository</a>
