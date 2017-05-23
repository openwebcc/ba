#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
# initialize a new tile for the Sentinel-2 metadata monitoring application
# set a short tile description and get all available scenes from AWS
#

import os
import sys
import argparse
import shutil

import pymongo
from pymongo import MongoClient

sys.path.append('/home/laser/rawdata/www/lib')
from Sat.sentinel2_aws import AWS

if __name__ == '__main__':
    """ initialize a new tile for the Sentinel-2 metadata monitoring application """

    # parse commandline arguments
    parser = argparse.ArgumentParser(description='initialize a new tile for the Sentinel-2 metadata monitoring application')
    parser.add_argument('--tile', dest='tile', required=True, help='MGRS tilename to find scenes for (e.g. 32TPT)')
    parser.add_argument('--description', dest='description', required=True, help='short tile description (e.g. "Alpen - Tirol West")')
    parser.add_argument('--overwrite', dest='overwrite', action="store_true", help='force overwriting of existing metadata')
    parser.add_argument('--quiet', dest='quiet', action="store_true", default=False, help='run quietly')
    args = parser.parse_args()

    # init AWS library
    aws = AWS(args.quiet)
    aws.set_tile(args.tile)

    # (re)add MongoDB tile description
    conn = MongoClient('localhost', 27017)
    mdb = conn.sentinel2
    mdb.aws_tilesMonitored.remove({'tile' : args.tile})
    mdb.aws_tilesMonitored.insert({'tile' : args.tile,'description' : args.description})
    if not args.quiet:
        print "UPDATE sentinel2.aws_tilesMonitored OK"
    conn.close()

    # remove existing content if needed
    if os.path.exists("%s/%s" % (aws.get_basedir(),args.tile)):
        if args.overwrite:
            # remove existing content
            if not args.quiet:
                print "removing %s/%s" % (aws.get_basedir(),args.tile)
            shutil.rmtree("%s/%s" % (aws.get_basedir(),args.tile))
        else:
            print "WARNING: tile %s already exists. Use --overwrite to force rebuilding" % args.tile
            sys.exit()

    # get metadata for all available scenes
    os.system("/usr/bin/python %s/02_aws_get_metadata.py --tiles=%s --rebuild %s" % (
        os.path.dirname(os.path.realpath(__file__)),
        args.tile,
        ('--quiet' if args.quiet else '')
    ))

    # set directory rights to allow downloads triggered from web-application
    os.system("chown www-data:root %s/%s" % (aws.get_basedir(),args.tile))
