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
    <fieldset>
      $APP_buttons
      <form method="GET" action="$APP_sceneButtonAction">
      <p>
        <input type="hidden" name="scene" value="$APP_scene">
        <input type="hidden" name="image" value="$APP_sceneButtonImages">
        <input type="submit" value="$APP_sceneButtonLabel" class="$APP_sceneButtonClass">
      </p>
      </form>
    </fieldset>

    <p><a href="$APP_root/index.py/preview?scene=$APP_scene">Details zur Szene anzeigen</a></p>

  <pre>
Datenzugang über Netzlaufwerk verbinden
PFAD: \\geo1\download\$APP_user\sentinel2
USER: geo1\$APP_user
PASS: *******
</pre>

  </div>

  <p class="link_github"><a href="https://github.com/openwebcc/ba">GitHub-Repository</a></p>

</main>
