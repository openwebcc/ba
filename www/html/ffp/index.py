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

sys.path.append('/home/laser/rawdata/www/lib')
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

    # set common attributes
    tpl.add_term('APP_dataset', config.get_dataset_title(dataset))
    tpl.add_term('APP_ctype', ctype.upper() )
    tpl.add_term('APP_ftype', ftype.upper() )
    tpl.add_term('APP_pname', pname.capitalize())
    tpl.add_term('APP_fpath', "%s/%s/%s" % (pname,dataset,ctype) )

    # get geometry of tiles
    dbh.execute("""SELECT id,fname,fsize,fdate,tile,geom FROM view_ffp_tiles
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
    tpl.add_term('LEAFLET_root', config.get_leaflet_root())
    return tpl.resolve_template('/home/institut/www/html/data/ffp/templates/index_tiles.tpl')

