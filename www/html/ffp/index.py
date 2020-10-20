#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
# download data from Forschungsfestplatte
#

import re
import os
import sys
import simplejson

from datetime import datetime

sys.path.append('/home/institut/rawdata/www/lib')
import Laser.base
import FFP.util


def index(req):
    """ provide startpage with search mask """
    (base,dbh,tpl) = Laser.base.impl().init(req)
    config = FFP.util.Config()

    tpl.add_term('APP_root',config.get_app_root())
    return tpl.resolve_template('/home/institut/www/html/data/ffp/templates/index.tpl')


def tiles(req,dataset='090930_gesamt',pname='m31',ctype='dom',**kwargs):
    """ provide startpage with search mask """
    (base,dbh,tpl) = Laser.base.impl().init(req)
    config = FFP.util.Config()

    # get cdate and cname from dataset
    (cdate,cname) = dataset.split('_')

    # get ftype from pulldown of selected ctype
    ftype = kwargs.get('%s_ftype' % ctype)

    # init GEOJSON-object
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

    # set title
    tpl.add_term('APP_title', "%s (%s/%s/%s)" % (
        config.get_dataset_title(dataset),
        ctype.upper(),
        ftype.upper(),
        pname.capitalize(),
    ))

    # set file path
    tpl.add_term('APP_fpath', "%s/%s/%s" % (pname,dataset,ctype) )

    # set hidden input form values
    tpl.add_term('VAL_pname',pname)
    tpl.add_term('VAL_cdate',dataset.split('_')[0])
    tpl.add_term('VAL_cname',dataset.split('_')[1])
    tpl.add_term('VAL_ctype',ctype)
    tpl.add_term('VAL_ftype',ftype)

    # get geometry of tiles
    dbh.execute("""SELECT id,fname,fsize,fdate,tile,ST_AsGeoJSON(geom) AS geom FROM laser.view_ffp_tiles
                    WHERE pname=%s AND cdate=%s AND cname=%s AND ctype=%s AND ftype=%s
                """, (
        pname,cdate,cname,ctype,ftype
    ))
    for row in dbh.fetchall():
        geom_json = simplejson.loads(row['geom'])
        geom_json =  {
            "type": "Feature",
            "geometry": simplejson.loads(row['geom']),
            "properties": {
                "id": row['id'],
                "fname": row['fname'],
                "fsize": row['fsize'],
                "fdate": row['fdate'],
                "fpath" :tpl.get_term('APP_fpath'),
                "tile": row['tile']
            }
        }
        geojson['features'].append(geom_json)

    tpl.add_term('APP_geom', simplejson.dumps(geojson))
    tpl.add_term('APP_root', config.get_app_root())
    tpl.add_term('APP_leaflet_root', config.get_leaflet_root())
    return tpl.resolve_template('/home/institut/www/html/data/ffp/templates/index_tiles.tpl')

