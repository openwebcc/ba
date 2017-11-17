#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
# download rawdata for Sentinel-2 tiles from Amazon S3 (http://sentinel-pds.s3-website.eu-central-1.amazonaws.com/)
# create additional RGB-, NDVI-, or NDSI-image as well if requested
#

import os
import re
import sys
import shutil
import argparse

import pymongo
from pymongo import MongoClient

try:
    from mod_python import apache
    from mod_python.util import redirect
except:
    pass

sys.path.append('/home/institut/rawdata/www/lib')
import Laser.base
import Laser.Util.web
from Sat.sentinel2_aws import AWS

def _link_scene(req,base,dbh,aws,attr):
    """ link scene data """

    # ensure tile-directory
    source = "%s/%s" % (aws.get_basedir(),attr['tile'])
    target = "%s/sentinel2/%s" % (base.get_download_dir(),attr['tile'])
    tile_dir = base.ensure_directory(target)
    _log_files(req,dbh,base.get_user(),source,target)

    # link all metadata and previews for this tile
    for subdir in ('metadata','preview'):
        source = "%s/%s/%s" % (aws.get_basedir(),attr['tile'],subdir)
        target = "%s/%s" % (tile_dir,subdir)
        _log_files(req,dbh,base.get_user(),source,target)
        if not os.path.exists(target):
            os.system('ln -s %s %s' % (source,target) )

    # link scene data subdirectory
    source = "%s/%s/%s" % (aws.get_basedir(),attr['tile'],attr['scene'])
    target = "%s/%s" % (tile_dir,attr['scene'])
    if not os.path.exists(target):
        os.system('ln -s %s %s' % (source,target) )
        _log_files(req,dbh,base.get_user(),source,target)


def _download_rawdata(req,base,dbh,aws,attr):
    """ get rawdata for scene """
    download = {
        'dir_root' : [],
        'dir_qi' : []
    }

    # build list of links to download separated in root directory and qi directory
    req.write("PLEASE WAIT: getting list of files to download ...\n")
    for url in aws.parse_bucket(attr['year'],attr['month'],attr['day'],attr['num']):
        if re.search(r'^tiles',url):
            download['dir_root'].append("%s/%s" % (aws.get_download_url(),url) )
    for url in aws.parse_bucket(attr['year'],attr['month'],attr['day'],attr['num'],'qi'):
            download['dir_qi'].append("%s/%s" % (aws.get_download_url(),url) )

    # download files via wget
    for dirname in ('dir_root','dir_qi'):
        # store list with URLs for wget
        wget_url_list = "%s/%s_%s.urls" % (aws.get_tmpdir(),attr['scene'],dirname)
        with open(wget_url_list, 'w') as f:
            f.write("%s\n" % '\n'.join(download[dirname]))

        # give status feedback
        if dirname == 'dir_root':
            req.write("PLEASE WAIT: downloading rawdata images and metadata ...\n")
        else:
            req.write("PLEASE WAIT: downloading rawdata quality indicator masks ...\n")

        # get the files
        os.system("wget -q --wait=1 --random-wait -i %s -P %s" % (wget_url_list,attr[dirname]))

    # give feedback that files have been download
    req.write("\nDOWNLOAD OK: files have been downloaded to rawdata repository <strong>sat/sentinel2/%s/%s</strong>\n\n" % (
        attr['tile'],attr['scene'])
    )

    # store download status in MongoDB
    conn = MongoClient('localhost', 27017)
    mdb = conn.sentinel2
    mdb.aws_tileInfo.update({ "_scene" : attr['scene'] },{ "$set" : { "_downloaded" : True } })
    conn.close()

    # link scene data
    _link_scene(req,base,dbh,aws,attr)


def _convert_jpeg_to_tif(req,aws,attr,band):
    """ convert JPEG2000 image to temporary TIF file """
    jp2 = "%s/%s/%s/%s.jp2" % (aws.get_basedir(),attr['tile'],attr['scene'],band )
    tif = "%s/%s_%s.tif" % (aws.get_tmpdir(),attr['scene'],band)
    if not os.path.exists(tif):
        cmd = "%s/gdal_translate %s %s -scale 0 32768 0 32768" % (aws.get_gdalbindir(),jp2,tif)
        req.write("PLEASE WAIT: executing '%s' ...\n" % cmd)
        os.system(cmd)

def _create_rgb_image(req,base,dbh,aws,attr):
    """ create RGB-image for this scene """
    if not os.path.exists(attr['img_rgb']):
        req.write("PLEASE WAIT: creating RGB-image ...\n")

        # handle outputdir and existing content
        if not os.path.exists(attr['dir_derived']):
            os.mkdir(attr['dir_derived'])
        else:
            os.system("rm -f %s/rgb_*" % attr['dir_derived'] )

        # convert JP2 bands to temporary TIFs
        for band in ('B02','B03','B04'):
            _convert_jpeg_to_tif(req,aws,attr,band)

        # run command
        cmd = "%s/gdal_merge.py -q -seperate -pct %s/%s_B04.tif %s/%s_B03.tif %s/%s_B02.tif -of HFA -o %s" % (
            aws.get_gdalbindir(),
            aws.get_tmpdir(),attr['scene'],
            aws.get_tmpdir(),attr['scene'],
            aws.get_tmpdir(),attr['scene'],
            attr['img_rgb']
        )
        req.write("PLEASE WAIT: executing '%s' ...\n" % cmd)
        os.system(cmd)

        # give feedback
        req.write("CREATION OK: created RGB-image <strong>%s</strong>\n\n" % (attr['img_rgb']) )
    else:
        req.write('INFO: subscribed to RGB-image of scene %s' % attr['scene'])

    # log image for user
    target = "%s/sentinel2/%s/%s/derived/rgb_%s.img" % (base.get_download_dir(),attr['tile'],attr['scene'],attr['scene'])
    _log_files(req,dbh,base.get_user(),attr['img_rgb'],target)


def _create_ndvi_image(req,base,dbh,aws,attr):
    """ create NDVI-image for this scene """
    if not os.path.exists(attr['img_ndvi']):
        req.write("PLEASE WAIT: creating NDVI-image ...\n")

        # handle outputdir and existing content
        if not os.path.exists(attr['dir_derived']):
            os.mkdir(attr['dir_derived'])
        else:
            os.system("rm -f %s/ndvi_*" % attr['dir_derived'] )

        # convert JP2 bands to temporary TIFs
        for band in ('B04','B08'):
            _convert_jpeg_to_tif(req,aws,attr,band)

        # run command
        cmd = '%s/gdal_calc.py --format=HFA --type=Float32 -A %s/%s_B08.tif -B %s/%s_B04.tif --calc="(A.astype(float)-B.astype(float))/(A.astype(float)+B.astype(float))" --outfile=%s' % (
            aws.get_gdalbindir(),
            aws.get_tmpdir(),attr['scene'],
            aws.get_tmpdir(),attr['scene'],
            attr['img_ndvi']
        )
        req.write("PLEASE WAIT: executing '%s' ...\n" % cmd)
        os.system(cmd)

        # give feedback
        req.write("CREATION OK: created NDVI-image <strong>%s</strong>\n\n" % (attr['img_ndvi']) )
    else:
        req.write('INFO: subscribed to NDVI-image of scene %s' % attr['scene'])

    # log image for user
    target = "%s/sentinel2/%s/%s/derived/ndvi_%s.img" % (base.get_download_dir(),attr['tile'],attr['scene'],attr['scene'])
    _log_files(req,dbh,base.get_user(),attr['img_ndvi'],target)


def _create_ndsi_image(req,base,dbh,aws,attr):
    """ create NDSI-image for this scene 
        see https://sentinel.esa.int/web/sentinel/technical-guides/sentinel-2-msi/level-2a/algorithm
    """
    if not os.path.exists(attr['img_ndsi']):
        req.write("PLEASE WAIT: creating NDSI-image ...\n")

        # handle outputdir and existing content
        if not os.path.exists(attr['dir_derived']):
            os.mkdir(attr['dir_derived'])
        else:
            os.system("rm -f %s/ndsi_*" % attr['dir_derived'] )

        # convert JP2 bands to temporary TIFs
        # NOTE: B13 has resolution 20m and will be automatically resampled to 10m resolution
        for band in ('B03','B11'):
            _convert_jpeg_to_tif(req,aws,attr,band)

        # resample B11 to 10 meters resolution
        if not os.path.exists('%s/%s_B11_10m.tif' % (aws.get_tmpdir(),attr['scene'])):
            cmd = '%s/gdalwarp -q -overwrite %s/%s_B11.tif %s/%s_B11_10m.tif -r near -tr 10 10' % (
                aws.get_gdalbindir(),
                aws.get_tmpdir(),attr['scene'],
                aws.get_tmpdir(),attr['scene']
            )
            req.write("PLEASE WAIT: executing '%s' ...\n" % cmd)
            os.system(cmd)

        # run command
        cmd = '%s/gdal_calc.py --format=HFA --type=Float32 -A %s/%s_B03.tif -B %s/%s_B11_10m.tif --calc="(A.astype(float)-B.astype(float))/(A.astype(float)+B.astype(float))" --outfile=%s' % (
            aws.get_gdalbindir(),
            aws.get_tmpdir(),attr['scene'],
            aws.get_tmpdir(),attr['scene'],
            attr['img_ndsi']
        )
        req.write("PLEASE WAIT: executing '%s' ...\n" % cmd)
        os.system(cmd)

        # give feedback
        req.write("CREATION OK: created NDSI-image <strong>%s</strong>\n\n" % (attr['img_ndsi']) )
    else:
        req.write('INFO: subscribed to NDSI-image of scene %s' % attr['scene'])

    # log image for user
    target = "%s/sentinel2/%s/%s/derived/ndsi_%s.img" % (base.get_download_dir(),attr['tile'],attr['scene'],attr['scene'])
    _log_files(req,dbh,base.get_user(),attr['img_ndsi'],target)


def _log_files(req,dbh,user_id,source,target):
    """ log files for user """
    dbh.execute("DELETE FROM sentinel2_files WHERE user_id=%s AND source=%s AND target=%s", (user_id,source,target) )
    dbh.execute("""INSERT INTO sentinel2_files (user_id,source,target,tstamp) VALUES (%s,%s,%s,NOW())""", (
        user_id,source,target
    ))

def _unlog_files(req,dbh,user_id,source=None,target=None):
    """ remove files for user """
    if source:
        dbh.execute("DELETE FROM sentinel2_files WHERE user_id=%s AND source ~ %s", (user_id,source) )
    elif target:
        dbh.execute("DELETE FROM sentinel2_files WHERE user_id=%s AND target ~ %s", (user_id,target) )
    else:
        pass

def _log_task(req,base,dbh,task,scene):
    """ log toolbox action """
    dbh.execute("INSERT INTO sentinel2_log (user_id,task,scene,tstamp) VALUES (%s,%s,%s,NOW())", (
        base.get_user(),task,scene
    ))

def index(req, scene=None):
    """ provide start page for toolbox """
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    if not scene:
        return "Error: no scene provided"

    # init AWS module
    aws = AWS()
    aws.set_scene(scene)
    attr = aws.get_scene_attributes()

    # get owners of scene
    acl = {}
    user_id = base.get_user()
    scene_files = []
    dbh.execute("SELECT user_id,target FROM sentinel2_files WHERE target ~ %s", (attr['scene'],) )
    for row in dbh.fetchall():
        if not row['user_id'] in acl:
            acl[row['user_id']] = {
                'rgb' : False,
                'ndvi' : False,
                'ndsi' : False,
                'scene' : False
            }

        # check images
        for img in ('rgb','ndvi','ndsi'):
            if re.search('derived/%s' % img, row['target']):
                acl[row['user_id']][img] = True
                if not img in scene_files:
                    scene_files.append(img)

        # check scene
        if re.search(r'%s$' % attr['scene'], row['target']):
            acl[row['user_id']]['scene'] = True
            if not 'scene' in scene_files:
                scene_files.append('scene')

    # set template terms
    tpl.add_term('APP_root', aws.get_app_root())
    tpl.add_term('APP_scene', scene)
    tpl.add_term('APP_user', base.get_user() )

    # decide what to do
    if not 'scene' in scene_files:
        # show download form
        return tpl.resolve_template('/home/institut/www/html/data/sentinel2/toolbox/templates/index.tpl')

    else:
        # build buttons for derivates if any
        for img in aws.get_derived_image_prefixes():
            # hide image creation buttons until scene is subscribed
            display = 'block'
            if not user_id in acl or (user_id in acl and not acl[user_id]['scene']):
                display = 'none'

            # set button properties
            if not img in scene_files:
                action = "/data/sentinel2/toolbox/index.py/process"
                submit = "%s-Bild erzeugen &gt;&gt;" % img.upper()
                cls = "button_add"
            else:
                if user_id in acl and acl[user_id][img]:
                    action = "/data/sentinel2/toolbox/index.py/remove"
                    if len(acl.keys()) == 1:
                        submit = u"%s-Bild löschen &gt;&gt;" % img.upper()
                        cls = "button_remove"
                    else:
                        submit = "%s-Bild vorhanden --&gt; unsubscribe" % img.upper()
                        cls = "button_unsubscribe"
                else:
                    action = "/data/sentinel2/toolbox/index.py/process"
                    submit = "%s-Bild vorhanden --&gt;subscribe" % img.upper()
                    cls = "button_add"

            tpl.append_to_term("APP_buttons",u"""
                <div style="display:%s">
                    <form method="GET" action="%s">
                    <input type="hidden" name="scene" value="%s">
                    <input type="hidden" name="image" value="%s">
                    <input type="submit" value="%s" class="%s">
                    </form><br>
                </div>""" % (
                    display,action,scene,img,submit,cls
            ))

        if 'scene' in scene_files:
            # set label for scene remove button
            if not user_id in acl:
                tpl.add_term('APP_sceneButtonAction', '/data/sentinel2/toolbox/index.py/download')
                tpl.add_term('APP_sceneButtonImages', '')
                tpl.add_term('APP_sceneButtonLabel', 'Szene vorhanden --&gt; subscribe')
                tpl.add_term('APP_sceneButtonClass', 'button_add')
            else:
                if acl[user_id]['scene'] and len(acl.keys()) == 1:
                    tpl.add_term('APP_sceneButtonAction', '/data/sentinel2/toolbox/index.py/remove')
                    tpl.add_term('APP_sceneButtonImages', 'all')
                    tpl.add_term('APP_sceneButtonLabel', u'Gesamte Szene mit allen Daten löschen &gt;&gt;')
                    tpl.add_term('APP_sceneButtonClass', 'button_remove')
                else:
                    tpl.add_term('APP_sceneButtonAction', '/data/sentinel2/toolbox/index.py/remove')
                    tpl.add_term('APP_sceneButtonImages', 'all')
                    tpl.add_term('APP_sceneButtonLabel', u'Szene vorhanden --&gt; unsubscribe')
                    tpl.add_term('APP_sceneButtonClass', 'button_unsubscribe')

        return tpl.resolve_template('/home/institut/www/html/data/sentinel2/toolbox/templates/index_edit.tpl')

def download(req, scene=None, image=None, quiet=True):
    """ downlaod rawdata for the given tile and create optional RGB, NDVI images """
    (base,dbh,tpl) = Laser.base.impl().init(req)

    if not type(req) == file:
        req.content_type = "text/html"

    if not scene:
        return "Error: no scene to download specified"

    # set additional images to create if any
    images = []
    if image:
        if type(image) == str:
            images = [image]
        else:
            images = image[0:]

    # init AWS module
    aws = AWS(quiet)
    aws.set_scene(scene)
    attr = aws.get_scene_attributes()

    # connect to database for logging
    dbh.connect(user='intranet')

    # download rawdata
    req.write('<pre>')

    # download or subscribe to data
    if not os.path.exists(attr['dir_root']):
        # download rawdata
        _download_rawdata(req,base,dbh,aws,attr)
        _log_task(req,base,dbh,'download',attr['scene'])
    else:
        if not images:
            # add to scenes of user
            _link_scene(req,base,dbh,aws,attr)
            req.write("INFO: subscribed to scene %s" % attr['scene'])

    # create additional RGB-image if requested
    if 'rgb' in images:
        _create_rgb_image(req,base,dbh,aws,attr)
        _log_task(req,base,dbh,'create RGB',attr['scene'])

    # create additional NDVI-image if requested
    if 'ndvi' in images:
        _create_ndvi_image(req,base,dbh,aws,attr)
        _log_task(req,base,dbh,'create NDVI',attr['scene'])

    # create additional NDSI-image if requested
    if 'ndsi' in images:
        _create_ndsi_image(req,base,dbh,aws,attr)
        _log_task(req,base,dbh,'create NDSI',attr['scene'])

    dbh.close()

    # redirect to toolbox page
    return '\n</pre><p><a href="/data/sentinel2/toolbox/index?scene=%s">continue to toolbox &gt;&gt;</p>' % scene

def process(req, scene=None, image=None, quiet=True):
    """ create a derived image """
    if not scene:
        return "Error: no scene to create image specified"

    # trigger image creation
    return download(req,scene,image)


def remove(req, scene=None, image=None, quiet=True):
    """ remove rawdata or derived images """
    if not scene:
        return "Error: no scene to remove image(s) specified"

    (base,dbh,tpl) = Laser.base.impl().init(req)

    # connect to database for logging
    dbh.connect(user='intranet')

    # init AWS module
    aws = AWS(quiet)
    aws.set_scene(scene)
    attr = aws.get_scene_attributes()

    # decide what to do
    if image == 'all':
        # remove scene if it exists

        # set path to scene directory softlink
        scene_dir = "%s/sentinel2/%s/%s" % (base.get_download_dir(),attr['tile'],attr['scene'])

        # remove scene if it exists
        if not os.path.exists(attr['dir_root']):
            # no rawdata directory found
            req.write("<pre>ERROR: scene %s does not exist\n</pre>" % attr['scene'] )
        else:
            # get other owners of scene
            owners_notme = []
            dbh.execute("SELECT DISTINCT user_id FROM sentinel2_files WHERE source ~ %s AND user_id != %s", (
                attr['dir_root'],base.get_user()
            ))
            for row in dbh.fetchall():
                owners_notme.append(row['user_id'])

            if len(owners_notme) > 0:
                _log_task(req,base,dbh,'remove',attr['scene'])
                req.write("<pre>INFO: unsubscribed from scene %s</pre>" % (attr['scene']) )
                os.system('rm -f %s' % scene_dir)
            else:
                # unset download switch in MongoDB
                conn = MongoClient('localhost', 27017)
                mdb = conn.sentinel2
                mdb.aws_tileInfo.update({ "_scene" : attr['scene'] },{ "$set" : { "_downloaded" : False } })
                conn.close()

                # remove rawdata directory with all derived images
                shutil.rmtree(attr['dir_root'])
                _log_task(req,base,dbh,'remove',attr['scene'])
                os.system('rm -f %s' % scene_dir)
                req.write("<pre>INFO: removed all data for scene %s ...\n</pre>" % attr['scene'] )

            # remove all scene entries for this user
            _unlog_files(req,dbh,base.get_user(),target=scene_dir)

    else:
        # remove image if it exists
        if not os.path.exists(attr["img_%s" % image]):
            req.write("<pre>ERROR: %s-image for scene %s does not exist\n</pre>" % (image.upper(),attr['scene']) )
        else:
            # get other owners of image
            owners_notme = []
            dbh.execute("SELECT DISTINCT user_id FROM sentinel2_files WHERE source=%s AND user_id != %s", (
                attr["img_%s" % image],base.get_user()
            ))
            for row in dbh.fetchall():
                owners_notme.append(row['user_id'])

            if len(owners_notme) > 0:
                _log_task(req,base,dbh,'remove %s' % image.upper(),attr['scene'])
                req.write("<pre>INFO: unsubscribed from %s-image for scene %s</pre>" % (image.upper(),attr['scene']) )
            else:
                os.remove(attr["img_%s" % image])
                _log_task(req,base,dbh,'remove %s' % image.upper(),attr['scene'])
                req.write("<pre>INFO: removed %s-image for scene %s ...\n</pre>" % (image.upper(),attr['scene']) )

            # remove image entry for this user
            _unlog_files(req,dbh,base.get_user(),source=attr["img_%s" % image])

    # finish
    dbh.close()
    return '<p><a href="/data/sentinel2/toolbox/index?scene=%s">continue to toolbox &gt;&gt;</p>' % attr['scene']


if __name__ == '__main__':
    """ download rawdata for Sentinel-2 tiles from Amazon S3 (commandline access)"""

    # parse commandline arguments
    parser = argparse.ArgumentParser(description='download metadata for Sentinel-2 tiles from Amazon S3')
    parser.add_argument('--scene', dest='scene', required=True, help='scene name to download (e.g. 32TPT_2015_08_26_0)')
    parser.add_argument('--rgb', dest='rgb', action="store_true", default=False, help='create RGB-image (B04,B03,B02)')
    parser.add_argument('--ndvi', dest='ndvi', action="store_true", default=False, help='create NDVI-image ((B08-B04)/(B08+B04))')
    parser.add_argument('--ndsi', dest='ndsi', action="store_true", default=False, help='create NDSI-image ((B03-B11)/(B03+B11))')
    parser.add_argument('--remove', dest='remove', action="store_true", default=False, help='do not download but remove image(s)')
    parser.add_argument('--remove_all', dest='remove_all', action="store_true", default=False, help='dremove all data for this scene')
    parser.add_argument('--quiet', dest='quiet', action="store_true", default=False, help='run quietly (shows actual downloads only)')
    args = parser.parse_args()

    aws = AWS()

    images = []
    if args.rgb:
        images.append('rgb')
    if args.ndvi:
        images.append('ndvi')
    if args.ndsi:
        images.append('ndsi')

    if not args.remove and not args.remove_all:
        # download scene
        print download(sys.stdout,args.scene,images,args.quiet)

        # set ownership of newly created scene directory
        scene_dir = "%s/%s/%s" % (aws.get_basedir(),args.scene[:5],args.scene)
        os.system("chown -R www-data:root %s" % scene_dir)

    elif args.remove:
        for img in images:
            print remove(sys.stdout,args.scene,img,args.quiet)
    elif args.remove_all:
        print remove(sys.stdout,args.scene,'all',args.quiet)
