<!DOCTYPE html>
<html>
<title>LiDAR-Repository Download sucessful, Geographie Innsbruck</title>
<link rel="stylesheet" href="$APP_root/styles.css" />

<main>
<h1>LiDAR-Repository Geographie Innsbruck</h1>
<h2>Download erfolgreich!</h2>
<pre>
$APP_files
</pre>

<h3>Zugang zu den Daten</h3>
<ul>
    <li>Windows:
<pre>
Netzlaufwerk verbinden
\\geo1\download\$APP_user\lidar\$APP_subdir
User: geo1\$APP_user
Pass: *******
</pre>
    </li>
    <li>Linux:
<pre>
# mount
mkdir /tmp/$APP_subdir
sudo mount -t cifs -o username=$APP_user,passwd=******* //geo1.uibk.ac.at/download/$APP_user/lidar/$APP_subdir /tmp/$APP_subdir

# umount
sudo umount /tmp/$APP_subdir
rmdir /tmp/$APP_subdir

</pre>
    </li>
</ul>

<h3>Verfügbarkeit</h3>
<p>Die bereitgestellten Daten werden in 24 Stunden automatisch wieder gelöscht.</p>

<hr/>

<p><a href="/data/lidar/app/index">zur LiDAR-Repository Startseite &gt;&gt;</a></p>