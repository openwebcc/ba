#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
# download data from Forschungsfestplatte
#

import os
import sys

sys.path.append('/home/institut/rawdata/www/lib')
import Laser.base
import FFP.util

def index(req,id=None,geom=None,pname=None,cdate=None,cname=None,ctype=None,ftype=None,fname=None,**kwargs):
    """ store license agreement and link data to download directory """
    (base,dbh,tpl) = Laser.base.impl().init(req)
    config = FFP.util.Config()

    # make sure tiles to link are present
    if not id and not geom:
        return "Invalid script call. No id and no geom specified"

    # make sure user data is present
    if not kwargs.get('person'):
        return "Error: Benutzerdaten nicht ausgefüllt."
    if not kwargs.get('project'):
        return "Error: Projektdaten nicht ausgefüllt."
    if not kwargs.get('confirmed'):
        return "Error: Nutzungsbestimmungen nicht bestätigt."

    # connect to db
    dbh.connect(user='intranet')

    # get ids of tiles to link
    ids = []

    if id:
        # only one tile requested, add it
        ids.append(int(id))
    elif geom:
        # query ids of tiles intersecting geometry
        dbh.execute("""SELECT id FROM view_ffp_tiles WHERE pname=%s AND cdate=%s AND cname=%s AND ctype=%s AND ftype=%s
                        AND ST_Intersects(ST_GeomFromGeoJSON(%s),geom)""", (
            pname,cdate,cname,ctype,ftype,geom
        ))
        for row in dbh.fetchall():
            ids.append(row['id'])
    else:
        # nothing else for now
        pass

    # log agreement and get ID for subdirectory to link tiles to
    dbh.execute("INSERT INTO ffp_agreements (user_id,person,project,pname,cdate,cname,ctype,ftype,fname,geom_json,tiles,tstamp) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,NOW()) RETURNING id", (
        req.user if req.user else 'anonymous',
        kwargs.get('person'),
        kwargs.get('project'),
        pname,cdate,cname,ftype,ctype,
        kwargs.get('tiles').split('/')[-1] if id else None,
        geom if geom else None,
        len(ids),
    ))
    subdir = dbh.fetchone()['id']

    # create download subdirectory
    download_dir = base.ensure_directory('%s/ffp/%s' % (base.get_download_dir(),subdir))

    # create softlinks to tiles
    download_size = 0
    dbh.execute("SELECT pname,cdate,cname,ctype,fname,fsize FROM view_ffp_tiles WHERE id IN %s", (tuple(ids),) )
    for row in dbh.fetchall():
        # take care that worldfiles (.jgw, .tfw) are linked as well
        link_files = [ row['fname'] ]
        if row['fname'][-4:] == '.jpg':
            link_files.append("%s.jgw" % row['fname'][:-4])
        if row['fname'][-4:] == '.tif':
            link_files.append("%s.tfw" % row['fname'][:-4])

        # add flight strips for DGM and DOM if available
        strips_tar_gz = "%s/%s/%s_%s/%s/%s_strips.tar.gz" % (
            config.get_base_dir(),row['pname'],row['cdate'],row['cname'],row['ctype'],row['fname'][:9]
        )
        if row['ctype'] in ['dgm','dom'] and os.path.exists(strips_tar_gz):
            link_files.append("%s_strips.tar.gz" % row['fname'][:9])

        # link
        for fname in link_files:
            os.system("ln -s %s/%s/%s_%s/%s/%s %s/%s_%s_%s_%s" % (
                config.get_base_dir(),
                row['pname'],row['cdate'],row['cname'],row['ctype'],fname,
                download_dir,row['pname'],row['cdate'],row['cname'],fname
            ))

        # add to download_size
        download_size += row['fsize']

    # UPDATE download size in agreement
    download_size = int((download_size/(1000*1000)))
    dbh.execute("UPDATE ffp_agreements SET mb=%s WHERE id=%s" % (download_size,subdir) )

    # finish
    dbh.close()
    tpl.add_term('APP_root', config.get_app_root())
    tpl.add_term('APP_tiles', len(ids))
    tpl.add_term('APP_tiles_label', "Kachel" if len(ids) == 1 else "Kacheln")
    tpl.add_term('APP_subdir', subdir )
    tpl.add_term('APP_download_dir', download_dir )
    tpl.add_term('APP_download_size', download_size )
    tpl.add_term('APP_user',req.user if req.user else 'anonymous')
    tpl.add_term('APP_hours_available',config.get_download_hours_available())

    return tpl.resolve_template('/home/institut/www/html/data/ffp/restricted/templates/download.tpl')

