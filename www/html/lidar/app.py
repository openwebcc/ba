#! /usr/bin/python2
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

from subprocess import Popen
from subprocess import PIPE

sys.path.append('/home/institut/rawdata/www/lib')
import Laser.base
import Laser.Util.web

APP_ROOT = '/data/lidar'
LEAFLET_root = '/data/lib'
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
                   FROM laser.view_lidar_meta
                   WHERE ptype = 'als'
                   GROUP BY ptype,pname,cdate,cname,srid,sensor
                   ORDER BY ptype,pname,cdate
                   """)
    for row in dbh.fetchall():
        cid = util.create_cid(row['ptype'],row['pname'],row['cdate'],row['cname'])
        row['cname'] = '<a href="%s/app.py/rawdata?cid=%s">%s</a>' % (APP_ROOT,cid,row['cname'])
        row['srid'] = '<a href="http://spatialreference.org/ref/epsg/%s/">%s</a>' % (row['srid'],row['srid'])
        row['sensor'] = '-' if re.search('LAStools',row['sensor']) else row['sensor']

        # format numbers with locale
        for col in ['mb','points','density']:
            row[col] = tpl.format_with_locale(row[col])

        tpl.append_to_term('APP_tableRows', "<tr><td>%s</td></tr>" % '</td><td>'.join([str(v) for v in row]) )

    # fill template terms
    tpl.add_term('APP_root',APP_ROOT)

    # finish
    dbh.close()
    return tpl.resolve_template('/home/institut/www/html/data/lidar/templates/app_index.tpl')

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
                   FROM laser.view_lidar_meta
                   WHERE ptype=%s AND pname=%s AND cdate=%s AND cname=%s
                   GROUP BY ptype,pname,cdate,cname,srid,sensor""",
                    (ptype,pname,cdate,cname)
                )
    for row in dbh.fetchall():
        # set values for template terms
        for col in 'ptype,pname,cdate,cname,srid,sensor,files,mb,points,density'.split(','):
            if type(row[col]) == str or col == 'srid':
                tpl.add_term('APP_val_%s' % col, row[col])
            else:
                tpl.add_term('APP_val_%s' % col, tpl.format_with_locale(row[col]))

    # query campaign date(s)
    cdates = []
    dbh.execute("""SELECT info->>'file_year' AS year,info->>'file_doy' AS doy
                   FROM laser.view_lidar_meta
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
    dbh.execute("""SELECT gid,fname,round(fsize/1000/1000,1) AS mb FROM laser.view_lidar_meta
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
    tpl.add_term('LEAFLET_root',LEAFLET_root)
    tpl.add_term('APP_cid',cid)

    # finish
    dbh.close()
    return tpl.resolve_template('/home/institut/www/html/data/lidar/templates/app_rawdata.tpl')


def details(req, gid=None):
    """ show details for LASFile """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req)

    # get details data
    dbh.execute("""SELECT gid,ptype,pname,cdate,cname,fname,round(fsize/1000,0) AS kb,info
                    FROM laser.view_lidar_meta WHERE gid=%s""", (gid,))
    for row in dbh.fetchall():
        for col in 'gid,ptype,pname,cdate,cname,fname,kb,info'.split(','):
            tpl.add_term('APP_val_%s' % col, row[col])

        # show JSON notation
        tpl.add_term('APP_jsondata', simplejson.dumps(row['info'],sort_keys=True, indent=4 * ' ') )

        # show content of LASInfo files
        info_txt = '/home/rawdata/%s/%s/%s_%s/meta/%s' % (row['ptype'],row['pname'],row['cdate'],row['cname'],row['fname'])
        if os.path.exists("%s.info.txt" % info_txt):
            with open("%s.info.txt" % info_txt) as f:
                tpl.add_term('APP_lasinfo', f.read())
        tpl.add_term('APP_lasfile', row['fname'])

        # hide trajectory download link if no trajectory is present
        if os.path.exists("%s.traj.txt" % info_txt):
            tpl.add_term('APP_trajectory_link_display','inline')
        else:
            tpl.add_term('APP_trajectory_link_display','none')

    # fill template terms
    tpl.add_term('APP_root',APP_ROOT)

    # finish
    dbh.close()
    return tpl.resolve_template('/home/institut/www/html/data/lidar/templates/app_details.tpl')


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
                   FROM laser.view_lidar_meta WHERE ptype=%s AND pname=%s AND cdate=%s AND cname=%s
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
