#!/usr/bin/python
#
# create RGB and NDVI images from Sentinel-2 bands in JPEG2000 format
# Usage: python create_images.py -h
#

import sys
import os
import re

sys.path.append('/home/laser/rawdata/www/lib')
from Sat.sentinel import Util

# set defaults
DEFAULT_TILES = '32TNT,32TPT'   # all atwest would be '32TNT,32TPT,32TQT,32TNS,32TPS,32TQS'
DEFAULT_RGB = True
DEFAULT_NDVI = True
DEFAULT_REBUILD = False
DEFAULT_QUIET = False

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
        if os.path.exists("/tmp/%s.img" % band):
            os.system("rm -f /tmp/%s.img*" % band)

def convert_jpeg_to_tmp_img(jpeg=None, band=None, epsg=None, quiet=None):
    """ convert JPEG2000 image to temporary ERDAS imagine file """
    arg_quiet = ''
    if not quiet:
        print "creating /tmp/%s.img ..." % band
    else:
        arg_quiet = '-q'

    os.system("gdal_translate %s -of HFA %s /tmp/%s.img -scale 0 32768 0 32768 -a_srs EPSG:%s" % (
        arg_quiet,jpeg,band,epsg
    ))

if __name__ == '__main__':
    """ create RGB and NDVI images from Sentinel-2 bands in JPEG2000 format """

    import argparse
    parser = argparse.ArgumentParser(description='create RGB and NDVI images from Sentinel-2 bands in JPEG2000 format')
    parser.add_argument('--subdir', dest='subdir', help='rebuild images in given campaign subdirectory (e.g. ')
    parser.add_argument('--tiles', dest='tiles', default=DEFAULT_TILES, help='set tiles to process')
    parser.add_argument('--rgb', dest='rgb', default=DEFAULT_RGB, action="store_true", help='create RGB-image')
    parser.add_argument('--ndvi', dest='ndvi', default=DEFAULT_NDVI, action="store_true", help='create NDVI-image')
    parser.add_argument('--rebuild', dest='rebuild', default=DEFAULT_REBUILD, action="store_true", help='force downloading of images')
    parser.add_argument('--quiet', dest='quiet', default=DEFAULT_QUIET, action="store_true", help='suppress debug messages')
    args = parser.parse_args()

    # set rebuild flag if a subdirectory is passed
    if args.subdir:
        args.rebuild = True

    # init utility library
    util = Util()

    # find JPEG files to process
    jpegs = {}
    tiles = {}

    for dirpath, dirnames, filenames in os.walk(util.get_satdir()):
        if args.subdir and not re.search(args.subdir,dirpath):
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
                        convert_jpeg_to_tmp_img(tile_dict[band],band,tile_dict['epsg'],args.quiet)
                if complete:
                    print "INFO: creating %s ..." % tile_dict['img_rgb']
                    os.system("gdal_merge.py -seperate -pct /tmp/B04.img /tmp/B03.img /tmp/B02.img -o %s -q -v %s" % (tile_dict['img_rgb'],pipe_dev_null))
                else:
                    print "WARNING: not enough bands for RGB creation in %s ..." % img_dir

            if args.ndvi:
                complete = True
                for band in ('B04','B08'):
                    if not band in tile_dict:
                        complete = False
                    else:
                        # convert band to ERDAS-imagine unless it exists from previous RGB conversion (i.e. B04)
                        if band == 'B04' and os.path.exists('/tmp/B04.img'):
                            continue
                        convert_jpeg_to_tmp_img(tile_dict[band],band,tile_dict['epsg'],args.quiet)
                if complete:
                    print "INFO: creating %s ..." % tile_dict['img_ndvi']
                    os.system('gdal_calc.py --overwrite -A /tmp/B08.img -B /tmp/B04.img --outfile=%s --calc="(A-B)/(A+B)" %s' % (tile_dict['img_ndvi'],pipe_dev_null))
                else:
                    print "WARNING: not enough bands for NDVI creation in %s ..." % img_dir

    # final cleanup
    cleanup_tmp_images()

