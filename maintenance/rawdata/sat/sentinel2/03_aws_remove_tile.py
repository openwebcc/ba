#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
# remove all metadata, data and MongoDB description for a given Sentinel-2 tile
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
    """ remove all metadata, data and MongoDB description for a given Sentinel-2 tile """

    # parse commandline arguments
    parser = argparse.ArgumentParser(description='remove all metadata, data and MongoDB description for a given Sentinel-2 tile')
    parser.add_argument('--tile', dest='tile', required=True, help='MGRS tilename(s) to remove (e.g. 32TPT)')
    parser.add_argument('--quiet', dest='quiet', action="store_true", default=False, help='run quietly')
    args = parser.parse_args()

    # init AWS library
    aws = AWS(args.quiet)
    aws.set_tile(args.tile)

    # remove MongoDB tile description and metadata
    conn = MongoClient('localhost', 27017)
    mdb = conn.sentinel2
    mdb.aws_tilesMonitored.remove({'tile' : args.tile})
    mdb.aws_tileInfo.remove({'_name' : args.tile})

    if not args.quiet:
        print "DELETE sentinel2.tilesMonitored OK"
        print "DELETE sentinel2.aws_tileInfo OK"

    conn.close()

    # remove all metadata and data stored in the filesystem
    if os.path.exists("%s/%s" % (aws.get_basedir(),args.tile)):
        # remove existing content
        if not args.quiet:
            print "removing %s/%s" % (aws.get_basedir(),args.tile)
        shutil.rmtree("%s/%s" % (aws.get_basedir(),args.tile))

