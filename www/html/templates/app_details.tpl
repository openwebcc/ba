<!DOCTYPE html>
<html>
<title>$APP_lasfile details / LiDAR data browser Geographie Innsbruck</title>

<h3>SELECT * FROM view_meta</h3>
<pre>
$APP_metadata
</pre>

<h3>JSON struktur view_meta.attr</h3>
<pre>
$APP_jsondata
</pre>

<h3>lasinfo -i $APP_lasfile -compute_density -repair -stdout</h3>
<pre>
$APP_lasinfo
</pre>


<h3>WKT Trajektorie  - ST_AsGeoJSON(ST_Simplify(traj,$APP_simplify_deg),7)</h3>
<p>
$APP_wkt_traj
</p>

<h3>WKT konkave Hülle  - ST_AsGeoJSON(ST_Simplify(hull,$APP_simplify_deg),7)</h3>
<p>
$APP_wkt_hull
</p>
