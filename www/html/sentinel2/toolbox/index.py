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

sys.path.append('/home/laser/rawdata/www/lib')
import Laser.base
import Laser.Util.web
from Sat.sentinel2_aws import AWS

def _download_rawdata(req,aws,attr):
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


def _convert_jpeg_to_tif(req,aws,attr,band):
    """ convert JPEG2000 image to temporary TIF file """
    jp2 = "%s/%s/%s/%s.jp2" % (aws.get_basedir(),attr['tile'],attr['scene'],band )
    tif = "%s/%s_%s.tif" % (aws.get_tmpdir(),attr['scene'],band)
    if not os.path.exists(tif):
        cmd = "gdal_translate %s %s -scale 0 32768 0 32768" % (jp2,tif)
        req.write("PLEASE WAIT: executing '%s' ...\n" % cmd)
        os.system(cmd)

def _create_rgb_image(req,aws,attr):
    """ create RGB-image for this scene """
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
    cmd = "gdal_merge.py -q -seperate -pct %s/%s_B04.tif %s/%s_B03.tif %s/%s_B02.tif -of HFA -o %s" % (
        aws.get_tmpdir(),attr['scene'],
        aws.get_tmpdir(),attr['scene'],
        aws.get_tmpdir(),attr['scene'],
        attr['img_rgb']
    )
    req.write("PLEASE WAIT: executing '%s' ...\n" % cmd)
    os.system(cmd)

    # give feedback
    req.write("CREATION OK: created RGB-image <strong>%s</strong>\n\n" % (attr['img_rgb']) )


def _create_ndvi_image(req,aws,attr):
    """ create NDVI-image for this scene """
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
    cmd = 'gdal_calc.py --format=HFA -A %s/%s_B08.tif -B %s/%s_B04.tif --calc="(A-B)/(A+B)" --outfile=%s' % (
        aws.get_tmpdir(),attr['scene'],
        aws.get_tmpdir(),attr['scene'],
        attr['img_ndvi']
    )
    req.write("PLEASE WAIT: executing '%s' ...\n" % cmd)
    os.system(cmd)

    # give feedback
    req.write("CREATION OK: created NDVI-image <strong>%s</strong>\n\n" % (attr['img_ndvi']) )


def _create_ndsi_image(req,aws,attr):
    """ create NDSI-image for this scene 
        see https://sentinel.esa.int/web/sentinel/technical-guides/sentinel-2-msi/level-2a/algorithm
    """
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
        cmd = 'gdalwarp -q -overwrite %s/%s_B11.tif %s/%s_B11_10m.tif -r near -tr 10 10' % (
            aws.get_tmpdir(),attr['scene'],
            aws.get_tmpdir(),attr['scene']
        )
        req.write("PLEASE WAIT: executing '%s' ...\n" % cmd)
        os.system(cmd)

    # composite
    cmd = 'gdal_calc.py --format=HFA -A %s/%s_B03.tif -B %s/%s_B11_10m.tif --calc="(A-B)/(A+B)" --outfile=%s' % (
        aws.get_tmpdir(),attr['scene'],
        aws.get_tmpdir(),attr['scene'],
        attr['img_ndsi']
    )
    req.write("PLEASE WAIT: executing '%s' ...\n" % cmd)
    os.system(cmd)

    # give feedback
    req.write("CREATION OK: created NDSI-image <strong>%s</strong>\n\n" % (attr['img_ndsi']) )


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

    # set template terms
    tpl.add_term('APP_root', aws.get_app_root())
    tpl.add_term('APP_scene', scene)

    # build edit buttons for derivates if any
    for prefix in aws.get_derived_image_prefixes():
        if attr['has_%s' % prefix]:
            tpl.append_to_term("APP_buttons",u"""
                <div>
                  <form method="GET" action="/data/sentinel2/toolbox/index.py/remove">
                    <input type="hidden" name="scene" value="%s">
                    <input type="hidden" name="image" value="%s">
                    <input type="submit" value="%s-Bild löschen &gt;&gt;" class="button_remove">
                  </form><br>
                </div>""" % (
                    scene,prefix,prefix.upper()
            ))
        else:
            tpl.append_to_term("APP_buttons",u"""
                <div>
                  <form method="GET" action="/data/sentinel2/toolbox/index.py/process">
                    <input type="hidden" name="scene" value="%s">
                    <input type="hidden" name="image" value="%s">
                    <input type="submit" value="%s-Bild erzeugen &gt;&gt;" class="button_add">
                  </form><br>
                </div>""" % (
                    scene,prefix,prefix.upper()
            ))
    # set template according to task
    if os.path.exists(attr['dir_root']):
        return tpl.resolve_template('/home/institut/www/html/data/sentinel2/toolbox/templates/index_edit.tpl')
    else:
        return tpl.resolve_template('/home/institut/www/html/data/sentinel2/toolbox/templates/index.tpl')

def download(req, scene=None, image=None, quiet=True):
    """ downlaod rawdata for the given tile and create optional RGB, NDVI images """

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

    # download rawdata
    req.write("<h3>Processing %s</h3>" % scene)
    req.write('<pre>')

    if not os.path.exists(attr['dir_root']):
        # download rawdata
       _download_rawdata(req,aws,attr)

    # create additional RGB-image if requested
    if 'rgb' in images:
        _create_rgb_image(req,aws,attr)

    # create additional NDVI-image if requested
    if 'ndvi' in images:
        _create_ndvi_image(req,aws,attr)

    # create additional NDSI-image if requested
    if 'ndsi' in images:
        _create_ndsi_image(req,aws,attr)

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

    # init AWS module
    aws = AWS(quiet)
    aws.set_scene(scene)
    attr = aws.get_scene_attributes()

    if image == 'all':
        if os.path.exists(attr['dir_root']):
            # unset download switch in MongoDB
            conn = MongoClient('localhost', 27017)
            mdb = conn.sentinel2
            mdb.aws_tileInfo.update({ "_scene" : attr['scene'] },{ "$set" : { "_downloaded" : False } })
            conn.close()

            # remove rawdata directory with all derived images
            shutil.rmtree(attr['dir_root'])
    else:
        # remove image if it exists
        if os.path.exists(attr["img_%s" % image]):
            os.remove(attr["img_%s" % image])
        else:
            return "Error: %s-image for this scene does not exist" % image.upper()

    if not type(req) == file:
        # redirect to toolbox
        redirect(req, "/data/sentinel2/toolbox/index?scene=%s" % scene)
    else:
        if image == 'all':
            return "removed all data in %s" % attr['dir_root']
        else:
            return "removed %s" % attr["img_%s" % image]

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
        scene_dir = "/home/laser/rawdata/sat/sentinel2/%s/%s" % (args.scene[:5],args.scene)
        os.system("chown -R www-data:root %s" % scene_dir)

    elif args.remove:
        for img in images:
            print remove(sys.stdout,args.scene,img,args.quiet)
    elif args.remove_all:
        print remove(sys.stdout,args.scene,'all',args.quiet)
