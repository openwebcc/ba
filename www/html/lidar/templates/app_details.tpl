<!DOCTYPE html>
<html>
<title>$APP_lasfile details / LiDAR-Repository Geographie Innsbruck</title>
<link rel="stylesheet" href="$APP_root/styles.css" />

<main>
  <h1>LiDAR-Repository Geographie Innsbruck</h1>
  <p>
    <strong>Datei $APP_val_ptype:$APP_val_pname:$APP_val_cdate:$APP_val_cname $APP_val_fname ($APP_val_kb KB)</strong>
  </p>

  <p>
  <strong>Download</strong>: 
  <a href="$APP_root/restricted/download/lasfile?gid=$APP_val_gid">LAS-Datei</a>
  <span style="display:$APP_trajectory_link_display"> | <a href="$APP_root/restricted/download/trajectory?gid=$APP_val_gid">Trajektorie</a></span>
  </p>

  <h3>Metadatenblatt</h3>
<pre>
$APP_lasinfo
<strong>Quelle</strong>: lasinfo -i $APP_lasfile -compute_density -repair -stdout
</pre>

  <h3>JSON-Attribute der Datenbank</h3>
<pre>
$APP_jsondata

<strong>Quelle</strong>: Spalte info in Datenbankview view_lidar_meta
</pre>

<p style="text-align:right;font-size:0.9em;font-style:italic;"><a href="https://github.com/openwebcc/ba">GitHub-Repository</a>
</main>
