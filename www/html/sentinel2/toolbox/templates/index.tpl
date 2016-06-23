<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Sentinel-2 Metadata Toolbox: $APP_scene (Geographie Innsbruck)</title>
  <link rel="stylesheet" href="$APP_root/styles.css" />
</head>

<main>
  <h1><a href="http://geographie.uibk.ac.at/data/sentinel2/index.py/index">Sentinel-2 Metadaten</a></h1>
  <h2>Toolbox $APP_scene</h2>
  <img src="$APP_root/images/$APP_scene.jpg" alt="Preview" />

  <div class="toolbox">
    <form method="GET" action="/data/sentinel2/toolbox/index.py/download">
    <fieldset>
      <p><input type="submit" value="Rohdaten für diese Szene Downloaden &gt;&gt;"></p>
      <input type="checkbox" name="image" value="rgb"> zusätzlich ein RGB-Bild erzeugen (B04,B03,B02)<br>
      <input type="checkbox" name="image" value="ndvi"> zusätzlich ein NDVI-Bild erzeugen ((B08-B04)/(B08+B04))<br>
      <input type="checkbox" name="image" value="ndsi"> zusätzlich ein NDSI-Bild erzeugen ((B03-B11)/(B03+B11))<br>
      <input type="hidden" name="scene" value="$APP_scene">
    </fieldset>
    </form>

  <p><a href="$APP_root/index.py/preview?scene=$APP_scene">Details zur Szene anzeigen</a></p>

  </div>

  <p class="link_github"><a href="https://github.com/openwebcc/ba">GitHub-Repository</a></p>

</main>
