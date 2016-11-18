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
            '151025_dsr' : [
                'opt_dom_ftype_asc',
                'opt_dgm_ftype_asc',
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
<h1>FFP-Repository Geographie Innsbruck</h1>

<form method="GET" action="/data/ffp/index/tiles/">

    <select name="dataset">
        <option value="090930_gesamt">Gesamtbefliegung 2006 - 2009 (1m)</option>
        <option value="151025_dsr">Befliegung Dauersiedlungsraum 2013 - 2015 (50cm)</option>
    </select>

    <select name="pname">
        <option value="m28">M28</option>
        <option value="m31">M31</option>
    </select>

    <p>
        <div class="ftype_dataset" id="radio_ctype_dom"><input type="radio" name="ctype" value="dom" checked> DOM</div>
        <select name="dom_ftype" class="ftype_pulldown" id="select_dom_ftype">
            <option id="opt_dom_ftype_xyz" value="xyz" selected>*.xyz.gz</option>
            <option id="opt_dom_ftype_asc" value="asc">*.asc.gz</option>
            <option id="opt_dom_ftype_tif" value="tif">*.tif</option>
        </select>
    </p>
    <p>
        <div class="ftype_dataset" id="radio_ctype_dgm"><input type="radio" name="ctype" value="dgm"> DGM</div>
        <select name="dgm_ftype" class="ftype_pulldown" id="select_dgm_ftype">
            <option id="opt_dgm_ftype_xyz" value="xyz" selected>*.xyz.gz</option>
            <option id="opt_dgm_ftype_asc" value="asc">*.asc.gz</option>
            <option id="opt_dgm_ftype_tif" value="tif">*.tif</option>
        </select>
    </p>
    <p>
        <div class="ftype_dataset" id="radio_ctype_iso"><input type="radio" name="ctype" value="iso"> ISO</div>
        <select name="iso_ftype" selected class="ftype_pulldown" id="select_iso_ftype">
            <option id="opt_iso_ftype_dxf" value="dxf" selected>*.dxf.gz</option>
        </select>
    </p>
    <p>
        <div class="ftype_dataset" id="radio_ctype_oph"><input type="radio" name="ctype" value="oph"> OPH</div>
        <select name="oph_ftype" selected class="ftype_pulldown" id="select_oph_ftype">
            <option id="opt_oph_ftype_jpg" value="jpg" selected>*.jpg</option>
        </select>
    </p>

    <input type="submit" value="Karte anzeigen &gt;&gt;">

</form>


