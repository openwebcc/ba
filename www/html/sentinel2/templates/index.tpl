<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Sentinel-2 Metadata (Geographie Innsbruck)</title>
  <link rel="stylesheet" href="$APP_root/styles.css" />
</head>

<main>
  <h1>Sentinel-2 Metadaten Geographie Innsbruck</h1>

  <p>Sämtliche Sentinel-2 Daten sind im Netz auf der Seite "<a href="http://sentinel-pds.s3-website.eu-central-1.amazonaws.com/">Sentinel-2 on AWS</a>" frei verfügbar. Die Ablage der Daten erfolgt dort unter anderem nach dem <a href="https://en.wikipedia.org/wiki/Military_grid_reference_system">Military grid system</a>. Dadurch ist es möglich, jede Nacht nach neuen Szenen für festgelegte Kacheln zu suchen und folgende Metadaten zu speichern:</p>

  <ul>
    <li>ein Vorschaubild der Szene (preview.jpg)</li>
    <li>Metadaten zur Kachel und zum Datenprodukt (productInfo.json, tileInfo.json, metadata.xml)</li>
    <li>eine Maske der Wolkenbedeckung (MSK_CLOUDS_B00.gml)</li>
  </ul>
  <p>Über die Metadaten Suche können Szenen nach Kacheln, Zeitraum und Datenqualität gefiltert und in einem weiteren Schritt in den Sentinel-2 Rohdatenbereich downgeloadet werden. Zusätzlich besteht beim Download der Rohdaten (oder zu einem späteren Zeitpunkt) die Möglichkeit, RGB-, NDVI- und NDSI-Bilder automatisiert abzuleiten und gemeinsam mit den Rohdaten abzulegen. Zum Monitoring neuer Szenen nach Gebieten stehen RSS-Feeds zur Verfügung die bei jeder Suche  mitgeliefert werden. Das Downloaden von Szenen sowie das Erstellen und Löschen von Derivaten ist nur für registrierte Benutzer möglich. Für die Aufnahme neuer Kacheln und Zugangsrechte für Institutsmitglieder bitte Klaus Förster kontaktieren. Viel Spaß beim Suchen!</p>

  <h2 class="align_center">Metadaten Suche</h2>

  <div class="search_form">
    <form method="get" action="/data/sentinel2/index.py/preview" oninput="res_c.value=parseInt(cloudcoverage.value);res_d.value=parseInt(datacoverage.value)">

    <fieldset>
      <legend>Kacheln (Mehrfachauswahl möglich)</legend>
      <select name="tile" size="10" multiple>
      <option value="">-- Grid auswählen --</option>
        $APP_tilesOptions
      </select>
    </fieldset>

    <fieldset>
      <legend>Zeitraum</legend>
      von <input type="text" name="datefrom" size="10" placeholder="YYYY-MM-DD" />
      bis <input type="text" name="dateto" size="10" placeholder="YYYY-MM-DD" />
    </fieldset>

    <fieldset>
      <legend>Datenqualität</legend>
      <input type=range name="cloudcoverage" min=0 max=100 value=20 step=5> Bewölkung maximal (<output for="cloudcoverage" name="res_c">20</output>%)<br/>
      <input type=range name="datacoverage" min=0 max=100 value=90 step=5> Datenbestand minimal (<output for="datacoverage" name="res_d">90</output>%)<br/>
      <p><input type="checkbox" name="usecoverage" checked> Qualitätsindikatoren berücksichtigen</p>
    </fieldset>

    <p class="align_right">
      <input type="reset" value="reset" />
      <input type="checkbox" name="downloaded" /> nur downgeloadete
      <input type="submit" value="Szenen anzeigen &gt;&gt;" />
    </p>

    </form>

  </div>

  <h3>Die letzten $APP_lastNValue Szenen</h3>
  <ul>
  $APP_lastN
  </ul>

  <p><a href="/data/sentinel2/index.py/csv">Download Metadaten als CSV</p>

  <p class="link_github"><a href="https://github.com/openwebcc/ba">GitHub-Repository</a></p>

</main>
