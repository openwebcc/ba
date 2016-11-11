<!DOCTYPE html>
<html>
<title>FFP-Repository Download sucessful, Geographie Innsbruck</title>
<link rel="stylesheet" href="$APP_root/styles.css" />
<style>
.ftype_pulldown {
    position: absolute;
    left: 100px;
}
</style>

<main>
<h1>FFP-Repository Geographie Innsbruck</h1>
<h2>Download erfolgreich!</h2>
<p>$APP_tiles $APP_tiles_label im Downloadbereich bereitgestellt (~$APP_download_size MB)</p>

<h3>Zugang zu den Daten</h3>
<ul>
    <li>Windows:
<pre>
Netzlaufwerk verbinden
\\geo1\download\ffp\$APP_subdir
User: geo1\$APP_user
Pass: *******
</pre>
    </li>
    <li>Linux:
<pre>
# mount
mkdir /tmp/$APP_subdir
sudo mount -t cifs -o username=$APP_user,passwd=******* //geo1.uibk.ac.at/download/ffp/$APP_subdir /tmp/$APP_subdir

# umount
sudo umount /tmp/$APP_subdir
rmdir /tmp/$APP_subdir

</pre>
    </li>
</ul>

<h3>Verfügbarkeit</h3>
<p>Die bereitgestellten Daten werden in $APP_hours_available Stunden automatisch wieder gelöscht.</p>

<hr/>

<p><a href="/data/ffp/">zur FFP-Repository Startseite &gt;&gt;</a></p>