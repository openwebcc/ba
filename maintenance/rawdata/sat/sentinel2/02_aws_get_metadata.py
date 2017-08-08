#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
# download metadata for Sentinel-2 tiles from Amazon S3
# http://sentinel-pds.s3-website.eu-central-1.amazonaws.com/
#

import re
import sys
import argparse

from time import sleep
from datetime import date, timedelta

import pymongo
from pymongo import MongoClient

sys.path.append('/home/institut/rawdata/www/lib')
from Sat.sentinel2_aws import AWS

if __name__ == '__main__':
    """ download metadata for Sentinel-2 tiles from Amazon S3 """

    # parse commandline arguments
    parser = argparse.ArgumentParser(description='download metadata for Sentinel-2 tiles from Amazon S3')
    parser.add_argument('--tiles', dest='tiles', help='MGRS tilename(s) to find scenes for (e.g. 32TPT or 32TPT,32TNT for multiple tiles). Leave blank to process all known tiles')
    parser.add_argument('--days', dest='days', default=2, help='find scenes within the last n-days (default=2)')
    parser.add_argument('--overwrite', dest='overwrite', action="store_true", help='force overwriting of existing metadata')
    parser.add_argument('--rebuild', dest='rebuild', action="store_true", help='force rebuilding of metadata for all available scenes')
    parser.add_argument('--quiet', dest='quiet', action="store_true", default=False, help='run quietly (i.e. shows actual downloads only)')
    args = parser.parse_args()

    # init list of tiles and files to store for this run
    tiles = []
    store_files = []

    # set tiles to process
    if not args.tiles:
        # get tiles to process from MongoDB
        conn = MongoClient('localhost', 27017)
        mdb = conn.sentinel2
        for rec in mdb.aws_tilesMonitored.find():
            tiles.append(rec['tile'])
        conn.close()
    else:
        # split tiles on column
        tiles = args.tiles.split(',')

    # sort tiles, why not ;-)
    tiles.sort()

    for tile in tiles:
        # init AWS module for this tile
        aws = AWS(args.quiet)
        aws.set_tile(tile)

        # get all available tiles if none are present yet or forced rebuild is requested
        if not aws.tile_exists() or args.rebuild:
            # create a new tile directory
            aws.create_tiledir()

            # find all scenes for this tile by year, month, day, scene
            years = aws.parse_bucket()
            if len(years) > 0:
                for year in years:
                    months = aws.parse_bucket(year)
                    if len(months) > 0:
                        for month in months:
                            days = aws.parse_bucket(year,month)
                            if len(days) > 0:
                                for day in days:
                                    scenes = aws.parse_bucket(year,month,day)
                                    if len(scenes) > 0:
                                        for scene in scenes:
                                            for fname in (aws.get_metadata_filenames()):
                                                store_files.append({
                                                    'tile' : tile,
                                                    'year' : year,
                                                    'month' : month,
                                                    'day' : day,
                                                    'scene' : scene,
                                                    'fname' : fname,
                                                })
            else:
                print "no data found for tile %s" % tile

        elif args.days:
            # find new scenes within the last n-days
            for n in range(int(args.days),0,-1):
                curday = date.today() - timedelta(days=n)
                (year,month,day) = re.sub('\-0','-',str(curday)).split('-')

                # get metadata files for found scenes
                scenes = aws.parse_bucket(year,month,day)
                if len(scenes) > 0:
                    for scene in scenes:
                        for fname in (aws.get_metadata_filenames()):
                            store_files.append({
                                'tile' : tile,
                                'year' : year,
                                'month' : month,
                                'day' : day,
                                'scene' : scene,
                                'fname' : fname,
                            })
        else:
            print "What else?"

    # store files and metadata for each tile and scene
    if len(store_files) > 0:
        # connect to database
        aws.connect_db()

        # store files and metadata
        for rec in store_files:
            aws.set_tile(rec['tile'])
            aws.store_file(rec,args.overwrite)
            sleep(2)

        # close database connection
        aws.close_db()
