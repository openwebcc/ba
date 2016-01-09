#! /usr/bin/python
# -*- coding: utf-8 -*-
#
# LiDAR data application
#

import sys
import re
import os
import datetime
import simplejson

from mod_python import apache

sys.path.append('/home/klaus/private/ba/www/lib')
import Laser.base
import Laser.Util.web

APP_ROOT = '/lidar'
SIMPLIFY_DEG = '0.0001'

def index(req):
    """ provide startpage with table for all campaigns """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    # populate table data
    dbh.execute("""SELECT ptype,pname,cdate,cname,count(fname) AS lasfiles,
                   round(sum(fsize)/1000/1000,0) AS mb,sum(points) AS points,round(avg(density),2) AS density,
                   srid,sensor
                   FROM view_meta
                   GROUP BY ptype,pname,cdate,cname,srid,sensor
                   ORDER BY ptype,pname,cdate
                   """)
    for row in dbh.fetchall():
        cid = util.create_cid(row['ptype'],row['pname'],row['cdate'],row['cname'])
        row['cname'] = '<a href="%s/app.py/rawdata?cid=%s">%s</a>' % (APP_ROOT,cid,row['cname'])
        row['srid'] = '<a href="http://spatialreference.org/ref/epsg/%s/">%s</a>' % (row['srid'],row['srid'])
        row['sensor'] = '-' if re.search('LAStools',row['sensor']) else row['sensor']
        tpl.append_to_term('APP_tableRows', "<tr><td>%s</td></tr>" % '</td><td>'.join([str(v) for v in row[1:]]) )

    # fill template terms
    tpl.add_term('APP_root',APP_ROOT)

    # finish
    dbh.close()
    return tpl.resolve_template('/home/institut/www/html/lidar/templates/app_index.tpl')

def rawdata(req, cid=None):
    """ rawdata browser, allow to download LAS files for a given campaign by trajectory or hull """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    # split up campaign ID
    [ptype,pname,cdate,cname] = util.parse_cid(cid)

    # query basic data
    dbh.execute("""SELECT ptype,pname,cdate,cname,srid,sensor,
                   count(fname) AS files, round(sum(fsize)/1000/1000,0) AS mb,
                   sum(points) AS points,round(avg(density),2) AS density
                   FROM view_meta
                   WHERE ptype=%s AND pname=%s AND cdate=%s AND cname=%s
                   GROUP BY ptype,pname,cdate,cname,srid,sensor""",
                    (ptype,pname,cdate,cname)
                )
    for row in dbh.fetchall():
        # set values for template terms
        for col in 'ptype,pname,cdate,cname,srid,sensor,files,mb,points,density'.split(','):
            tpl.add_term('APP_val_%s' % col, row[col])

    # query campaign date(s)
    cdates = []
    dbh.execute("""SELECT info->>'file_year' AS year,info->>'file_doy' AS doy
                   FROM view_meta
                   WHERE ptype=%s AND pname=%s AND cdate=%s AND cname=%s
                   GROUP BY ptype,pname,cdate,cname,year,doy
                   ORDER BY year,doy""",
                    (ptype,pname,cdate,cname)
                )
    for row in dbh.fetchall():
        cdates.append(datetime.datetime.strptime('%s %s' % (row['year'],row['doy']), '%Y %j').strftime('%d.%m'))
        tpl.add_term('APP_val_year', row['year'])
    tpl.add_term('APP_val_cdates', ', '.join(cdates))

    # query LAS-files
    dbh.execute("""SELECT gid,fname,round(fsize/1000/1000,1) AS mb FROM view_meta
                   WHERE ptype=%s AND pname=%s AND cdate=%s AND cname=%s
                   ORDER BY fname""",
                    (ptype,pname,cdate,cname)
                )
    for row in dbh.fetchall():
        tpl.append_to_term('APP_pulldown_files','<option value="%s">%s</option>' % (
            row['gid'],row['fname']
        ))

    # check for flight report
    rpath = "%s/doc/report.pdf" % util.path_to_campaign(cid)
    if os.path.exists(rpath):
        tpl.add_term('APP_report',' | <a href="%s/app.py/report?cid=%s">Flugbericht (PDF)</a>' % (
            APP_ROOT,util.create_cid(ptype,pname,cdate,cname)
        ))

    # fill template terms
    tpl.add_term('APP_root',APP_ROOT)
    tpl.add_term('APP_cid',cid)

    # finish
    dbh.close()
    return tpl.resolve_template('/home/institut/www/html/lidar/templates/app_rawdata.tpl')


def details(req, gid=None):
    """ show details for LASFile """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req)

    # get details data
    dbh.execute("""SELECT gid,ptype,pname,cdate,cname,fname,fsize,points,info,srid,datum,sensor,area,density,hull,traj,
                    ST_AsGeoJSON(ST_Simplify(traj,%s),7) AS wkt_traj,
                    ST_AsGeoJSON(ST_Simplify(hull,%s),7) AS wkt_hull
                    FROM view_meta WHERE gid=%s""", (SIMPLIFY_DEG,SIMPLIFY_DEG,gid))
    for row in dbh.fetchall():
        for col in 'gid,ptype,pname,cdate,cname,fname,fsize,points,info,srid,datum,sensor,area,density,hull,traj'.split(','):
            tpl.append_to_term('APP_metadata', "%s=%s\n" % (col,row[col]) )

        # show JSON notation
        json = simplejson.loads(row['info'])
        tpl.add_term('APP_jsondata', simplejson.dumps(json,sort_keys=True, indent=4 * ' ') )

        # show content of LASInfo files
        info_txt = '/home/laser/rawdata/%s/%s/%s_%s/meta/%s' % (row['ptype'],row['pname'],row['cdate'],row['cname'],row['fname'])
        if os.path.exists("%s.info.txt" % info_txt):
            with open("%s.info.txt" % info_txt) as f:
                tpl.add_term('APP_lasinfo', f.read())
        tpl.add_term('APP_lasfile', row['fname'])

        # show WKT geoemtries
        tpl.add_term('APP_simplify_deg', '%s' % SIMPLIFY_DEG)
        if row['hull']:
            tpl.add_term('APP_wkt_hull', row['wkt_hull'])
        if row['traj']:
            tpl.add_term('APP_wkt_traj', row['wkt_traj'])

    # fill template terms
    tpl.add_term('APP_root',APP_ROOT)

    # finish
    dbh.close()
    return tpl.resolve_template('/home/institut/www/html/lidar/templates/app_details.tpl')


def geom(req, cid=None):
    """ deliver GeoJSON geometry with attributes """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req, mimetype='application/json')
    util = Laser.Util.web.impl(base)

    # split up campaign ID
    [ptype,pname,cdate,cname] = util.parse_cid(cid)

    # init GEoJSON object
    geojson = {
        "type": "FeatureCollection",
        "crs": {
            "type": "name",
            "properties": {
                "name": "EPSG:4326"
            }
        },
        "features": []
    }

    # query simplified trajectories or hulls
    dbh.execute("""SELECT gid,fname,fsize,points,COALESCE (ST_AsGeoJSON(ST_Simplify(traj,%s),7),ST_AsGeoJSON(ST_Simplify(hull,%s),7)) AS geom,
                   CASE WHEN traj IS NOT NULL THEN TRUE ELSE FAlSE END AS has_traj
                   FROM view_meta WHERE ptype=%s AND pname=%s AND cdate=%s AND cname=%s
                   """, (SIMPLIFY_DEG,SIMPLIFY_DEG,ptype,pname,cdate,cname))
    for row in dbh.fetchall():
        if not row['geom']:
            continue
        geom_json = simplejson.loads(row['geom'])
        geom_json =  {
            "type": "Feature",
            "geometry": simplejson.loads(row['geom']),
            "properties": {
                "gid": row['gid'],
                "fname" : row['fname'],
                "fsize" : round(row['fsize']/1000.0/1000.0,1),
                "points" : row['points'],
                "has_traj" : row['has_traj']
            }
        }
        geojson['features'].append(geom_json)

    # finish
    dbh.close()
    return simplejson.dumps(geojson)


def lasfile(req, gid=None):
    """ get lasfile """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    dbh.execute("""SELECT ptype,pname,cdate,cname,fname FROM view_meta WHERE gid=%s""", (gid,))
    for row in dbh.fetchall():
        cid = util.create_cid(row['ptype'],row['pname'],row['cdate'],row['cname'])
        req.write('<h3>linking the following lasfiles as result:</h3>')
        req.write("ln -s %s/las/%s %s/%s<br>" % (
            util.path_to_campaign(cid),row['fname'],
            util.get_download_dir(),row['fname']
        ))

    # finish
    dbh.close()
    raise apache.SERVER_RETURN, apache.OK


def trajectory(req, gid=None):
    """ get trajectory """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    dbh.execute("""SELECT ptype,pname,cdate,cname,fname FROM view_meta WHERE gid=%s""", (gid,))
    for row in dbh.fetchall():
        cid = util.create_cid(row['ptype'],row['pname'],row['cdate'],row['cname'])
        tpath = "%s/meta/%s.traj.txt" % (
            util.path_to_campaign(cid),row['fname']
        )
        if os.path.exists(tpath):
            req.write('<h3>linking the following trajectoryfile as result:</h3>')
            req.write("ln -s %s %s/%s.traj.txt<br>" % (tpath,util.get_download_dir(),row['fname']) )

    # finish
    dbh.close()
    raise apache.SERVER_RETURN, apache.OK


def points(req, cid=None, extent=None):
    """ get points for campaign within extent from strips intersecting extent """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    # split up campaign ID
    [ptype,pname,cdate,cname] = util.parse_cid(cid)

    # get las2las command
    cmd = util.get_las2las_cmd(cid,extent)

    if cmd[:5] == 'ERROR':
        req.write(cmd)
    else:
        req.write('<h3>command would be:</h3>')
        req.write(cmd)

        # show lasfiles involved
        req.write('<h3>with /tmp/files.txt containing:</h3>')
        for fname in open('/tmp/files.txt').readlines():
            req.write('%s<br/>' % fname)

    # finish
    dbh.close()
    raise apache.SERVER_RETURN, apache.OK


def strips(req, cid=None, extent=None):
    """ get strips for campaign intersecting extent """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    # split up campaign ID
    [ptype,pname,cdate,cname] = util.parse_cid(cid)

    # show ln -s commands for lasfiles involved
    req.write('<h3>linking the following lasfiles as result:</h3>')
    req.write('<br/>'.join(util.get_lascopy_cmds(cid,extent)) )

    # finish
    dbh.close()
    raise apache.SERVER_RETURN, apache.OK

def report(req, cid=None):
    """ get flight report for given campaign if any """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    # se if pdf exists
    cpath = util.path_to_campaign(cid)
    if os.path.exists('%s/doc/report.pdf' % cpath):
        req.content_type = 'application/pdf'
        req.write(open('%s/doc/report.pdf' % cpath).read())
    else:
        req.write('No flight report available')

    # finish
    dbh.close()
    raise apache.SERVER_RETURN, apache.OK
