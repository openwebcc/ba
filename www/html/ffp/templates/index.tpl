<!DOCTYPE html>
<html>
<title>FFP-Repository Geographie Innsbruck</title>
<link rel="stylesheet" href="$APP_root/styles.css" />

<main>
<h1>FFP-Repository Geographie Innsbruck</h1>

<form method="GET" action="/data/ffp/index/tiles/">

    <select name="dataset">
        <option value="090930_gesamt">Gesamtbefliegung 2006 - 2009</option>
    </select>

    <select name="pname">
        <option value="m28">M28</option>
        <option value="m31">M31</option>
    </select>

    <p>
        <div class="ftype_dataset"><input type="radio" name="ctype" value="dom" checked> DOM</div>
        <select name="dom_ftype" class="ftype_pulldown">
            <option value="xyz" selected>*.xyz.gz</option>
            <option value="asc">*.asc.gz</option>
            <option value="tif">*.tif</option>
        </select>
    </p>
    <p>
        <div class="ftype_dataset"><input type="radio" name="ctype" value="dgm"> DGM</div>
        <select name="dgm_ftype" class="ftype_pulldown">
            <option value="xyz" selected>*.xyz.gz</option>
            <option value="asc">*.asc.gz</option>
            <option value="tif">*.tif</option>
        </select>
    </p>
    <p>
        <div class="ftype_dataset"><input type="radio" name="ctype" value="iso"> ISO</div>
        <select name="iso_ftype" selected class="ftype_pulldown">
            <option value="dxf" selected>*.dxf.gz</option>
        </select>
    </p>
    <p>
        <div class="ftype_dataset"><input type="radio" name="ctype" value="oph"> OPH</div>
        <select name="oph_ftype" selected class="ftype_pulldown">
            <option value="jpg" selected>*.jpg</option>
        </select>
    </p>

    <input type="submit" value="Karte anzeigen &gt;&gt;">

</form>


