#!/usr/bin/python
#
# create RGB and NDVI images from Sentinel-2 bands in JPEG2000 format
# Usage: python create_rgb_ndvi.py -h
#

import sys
import os
import re

sys.path.append('/home/laser/rawdata/www/lib')
from Sat.sentinel import Util

# set defaults
DEFAULT_REBUILD = False
DEFAULT_QUIET = False
SCHMIRN_TILE = 'T32TPT'
SCHMIRN_EXTENT = '688505 5213239 701216 5225950'

def filename_matches_tile(fname=None,tiles=None):
    """ return True if filename contains any of the wanted tiles, False otherwise """
    matches = False
    for tile in tiles.split(','):
        if re.search(tile,fname):
            matches = True
            break
    return matches

def cleanup_tmp_images():
    """ remove temporary images if any """
    for band in ('B02','B03','B04','B08'):
        if os.path.exists("/tmp/%s.tif" % band):
            os.system("rm -f /tmp/%s.tif*" % band)

def convert_jpeg_to_tmp_tif(jpeg=None, band=None, epsg=None, quiet=None):
    """ convert JPEG2000 image to temporary ERDAS imagine file """
    arg_quiet = ''
    if not quiet:
        print "creating /tmp/%s.tif ..." % band
    else:
        arg_quiet = '-q'

    os.system("gdal_translate %s %s /tmp/%s.tif -scale 0 32768 0 32768 -a_srs EPSG:%s" % (
        arg_quiet,jpeg,band,epsg
    ))

def create_schmirn_quicklook(src_img=None, quiet=None):
    """ create quicklook image for schmirntal project """
    if src_img and re.search(SCHMIRN_TILE,src_img):
        out_img = re.sub('.img$','.tif',src_img)
        out_img = re.sub('/img/','/img/schmirn_',out_img)

        arg_quiet = ''
        if not quiet:
            print "creating %s ..." % out_img
        else:
            arg_quiet = '-q'
        os.system('rm -f %s' % out_img)
        os.system('gdalwarp %s -te %s %s %s' % (arg_quiet,SCHMIRN_EXTENT,src_img,out_img) )

if __name__ == '__main__':
    """ create RGB and NDVI images from Sentinel-2 bands in JPEG2000 format """

    import argparse
    parser = argparse.ArgumentParser(description='create RGB and NDVI images from Sentinel-2 bands in JPEG2000 format')
    parser.add_argument('--region', dest='region', help='set region abreviation (e.g. atwest)')
    parser.add_argument('--tiles', dest='tiles', help='comma separated list of tiles to process (e.g. 32TNT,32TPT)')
    parser.add_argument('--rgb', dest='rgb', action="store_true", help='create RGB-image')
    parser.add_argument('--ndvi', dest='ndvi', action="store_true", help='create NDVI-image')
    parser.add_argument('--rebuild', dest='rebuild', default=DEFAULT_REBUILD, action="store_true", help='force downloading of images')
    parser.add_argument('--quiet', dest='quiet', default=DEFAULT_QUIET, action="store_true", help='suppress debug messages')
    args = parser.parse_args()

    # init utility library
    util = Util()

    # find JPEG files to process
    jpegs = {}
    tiles = {}

    for dirpath, dirnames, filenames in os.walk(util.get_satdir()):
        if args.region and not re.search(args.region,dirpath):
            continue

        for fname in sorted(filenames):
            if fname[-3:] == 'jp2':
                # take tiles argument into account
                if args.tiles and not filename_matches_tile(fname,args.tiles):
                    continue

                granule = util.parse_granule(fname[:-4])
                img_dir = re.sub(r'jpeg$','img',dirpath)
                img_rgb = os.path.join(img_dir, "rgb_%s.img" % granule['tilename'])
                img_ndvi = os.path.join(img_dir, "ndvi_%s.img" % granule['tilename'])

                if args.rgb and (not os.path.exists(img_rgb) or args.rebuild):
                    #print fname,granule,granule['band']
                    if granule['band'] in ('B02','B03','B04'):
                        if  not img_dir in jpegs:
                            jpegs[img_dir] = {
                                'tiles' : {}
                            }
                        if not granule['tilename'] in jpegs[img_dir]['tiles']:
                            jpegs[img_dir]['tiles'][granule['tilename']] = {
                                'epsg' : util.get_epsg_code(granule['zone']),
                            }
                        jpegs[img_dir]['tiles'][granule['tilename']]['img_rgb'] = img_rgb
                        jpegs[img_dir]['tiles'][granule['tilename']][granule['band']] = os.path.join(dirpath,fname)

                if args.ndvi and (not os.path.exists(img_ndvi) or args.rebuild):
                    if granule['band'] in ('B04','B08'):
                        if  not img_dir in jpegs:
                            jpegs[img_dir] = {
                                'tiles' : {}
                            }
                        if not granule['tilename'] in jpegs[img_dir]['tiles']:
                            jpegs[img_dir]['tiles'][granule['tilename']] = {
                                'epsg' : util.get_epsg_code(granule['zone']),
                            }
                        jpegs[img_dir]['tiles'][granule['tilename']]['img_ndvi'] = img_ndvi
                        jpegs[img_dir]['tiles'][granule['tilename']][granule['band']] = os.path.join(dirpath,fname)


    # create images if all bands are present
    for img_dir in sorted(jpegs.keys()):
        for tile in jpegs[img_dir]['tiles']:
            # remove temporary images if any
            cleanup_tmp_images()

            # set shortcut to tile dictionary
            tile_dict = jpegs[img_dir]['tiles'][tile]

            # give feedback
            if not args.quiet:
                print "creating images for %s %s ..." % (img_dir,tile)

            # pass --quiet to GRASS commands if needed
            pipe_dev_null = ''
            if args.quiet:
                pipe_dev_null = '1>&2 > /dev/null'

            if args.rgb:
                complete = True
                for band in ('B02','B03','B04'):
                    if not band in tile_dict:
                        complete = False
                    else:
                        # convert band to ERDAS-imagine
                        convert_jpeg_to_tmp_tif(tile_dict[band],band,tile_dict['epsg'],args.quiet)
                if complete:
                    print "INFO: creating %s ..." % tile_dict['img_rgb']
                    os.system('rm -f %s' % tile_dict['img_rgb'])   # remove in any case to make sure, that a brand new image is created
                    os.system("gdal_merge.py -seperate -pct /tmp/B04.tif /tmp/B03.tif /tmp/B02.tif -o %s -of HFA -q -v %s" % (tile_dict['img_rgb'],pipe_dev_null))
                    create_schmirn_quicklook(tile_dict['img_rgb'],args.quiet)
                else:
                    print "WARNING: not enough bands for RGB creation in %s ..." % img_dir

            if args.ndvi:
                complete = True
                for band in ('B04','B08'):
                    if not band in tile_dict:
                        complete = False
                    else:
                        # convert band to ERDAS-imagine unless it exists from previous RGB conversion (i.e. B04)
                        if band == 'B04' and os.path.exists('/tmp/B04.tif'):
                            continue
                        convert_jpeg_to_tmp_tif(tile_dict[band],band,tile_dict['epsg'],args.quiet)
                if complete:
                    print "INFO: creating %s ..." % tile_dict['img_ndvi']
                    os.system('rm -f %s' % tile_dict['img_ndvi'])   # remove in any case to make sure, that a brand new image is created
                    os.system('gdal_calc.py --overwrite --format=HFA -A /tmp/B08.tif -B /tmp/B04.tif --outfile=%s --calc="(A-B)/(A+B)" %s' % (tile_dict['img_ndvi'],pipe_dev_null))
                    create_schmirn_quicklook(tile_dict['img_ndvi'],args.quiet)
                else:
                    print "WARNING: not enough bands for NDVI creation in %s ..." % img_dir

    # final cleanup
    cleanup_tmp_images()

