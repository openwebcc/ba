#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Sentinel-2 AWS metadata application helper library
#

import re
import os
import sys
import requests
import shutil
import codecs
import simplejson

from datetime import datetime
from xml.dom.minidom import parseString

import pymongo
from pymongo import MongoClient

class RecordSet:
    """ helper for bundling together a few named data items ...
        see http://docs.python.org/tutorial/classes.html#odds-and-ends
    """
    pass

class AWS:
    """ AWS module """
    def __init__(self,quiet=True):
        """ define settings """
        self.quiet = quiet
        self.app_root = '/data/sentinel2'
        self.dir_rawdata = '/home/laser/rawdata/sat/sentinel2'
        self.dir_webimages = '/home/laser/rawdata/www/html/sentinel2/images'
        self.url_download = 'http://sentinel-s2-l1c.s3.amazonaws.com'
        self.url_browse = 'http://sentinel-s2-l1c.s3-website.eu-central-1.amazonaws.com/#'
        self.files_metadata = ('preview.jpg','productInfo.json','tileInfo.json','metadata.xml','qi/MSK_CLOUDS_B00.gml')
        self.derived_image_prefixes = ('rgb','ndvi','ndsi')
        self.scene_attributes = None

    def connect_db(self):
        """ connect to MongoDB database"""
        self.conn = MongoClient('localhost', 27017)
        self.mdb = self.conn.sentinel2

    def close_db(self):
        """ close MongoDB database connection """
        if self.conn:
            self.conn.close()

    def get_app_root(self):
        """ return URI to web base directory for the application """
        return self.app_root

    def get_basedir(self):
        """ return base directory for metadata """
        return self.dir_rawdata

    def get_browse_url(self):
        """ return AWS baseurl for browsing files """
        return self.url_browse

    def get_download_url(self):
        """ return AWS download url for downloading files """
        return self.url_download

    def get_metadata_filenames(self):
        """ return names for metadata files to include in downloads """
        return self.files_metadata

    def get_derived_image_prefixes(self):
        """ return tuple with known prefixes for derivable images """
        return self.derived_image_prefixes

    def set_tile(self,tile=None):
        """ set tile components of current tile """
        self.tile = RecordSet()
        self.tile.name = tile
        self.tile.utm_zone = tile[:2]
        self.tile.latitude_band = tile[2:3]
        self.tile.grid_square = tile[3:5]
        self.tile.dir_rawdata = "%s/%s" % (self.dir_rawdata,tile)
        self.tile.url_bucket = "%s/?delimiter=/&prefix=tiles/%s/%s/%s" % (
            self.url_download,
            self.tile.utm_zone,
            self.tile.latitude_band,
            self.tile.grid_square
        )

    def set_scene(self,scene=None):
        """ set scene attributes """
        s = {}

        s['scene'] = scene

        # split up path components, remove trailing zeros from month and day
        (s['tile'],s['year'],s['month'],s['day'],s['num']) = scene.split("_")
        s['month'] = s['month'].lstrip('0')
        s['day']   = s['day'].lstrip('0')

        # split up MGRS grid components
        (s['utm_zone'],s['latitude_band'],s['grid_square']) = (s['tile'][:2],s['tile'][2:3],s['tile'][3:5])

        # set paths to directories
        s['dir_root']    = "%s/%s/%s" % (self.get_basedir(),s['tile'],scene)
        s['dir_qi']      = "%s/%s/%s/qi" % (self.get_basedir(),s['tile'],scene)
        s['dir_derived'] = "%s/%s/%s/derived" % (self.get_basedir(),s['tile'],scene)

        # set paths to known derivable images and check for existance
        for prefix in self.derived_image_prefixes:
            s['img_%s' % prefix] = "%s/%s_%s.img" % (s['dir_derived'],prefix,scene)
            if os.path.exists(s['img_%s' % prefix]):
                s['has_%s' % prefix] = True
            else:
                s['has_%s' % prefix] = False

        # set tile
        self.set_tile(s['tile'])

        # set bucket URL
        s['url_bucket'] = "%s/?delimiter=/&prefix=tiles/%s/%s/%s" % (
            self.url_download,s['utm_zone'],s['latitude_band'],s['grid_square']
        )

        self.scene_attributes = s

    def get_scene_attributes(self):
        """ return attributes for current scene """
        return self.scene_attributes

    def is_valid_scene_name(self,scene):
        """ test if scene name is valid (e.g. 32TPT_2016_05_22_0) """
        return re.search(r'^\d{2}[A-Z]{3}_\d{4}_\d{2}_\d{2}_\d{1}$',str(scene))

    def tile_exists(self):
        """ return True if a data directory for the tile exists, False otherwise """
        return os.path.exists(self.tile.dir_rawdata)

    def create_tiledir(self):
        """ create skeleton of data directory for the given tile """
        if not self.tile_exists():
            os.mkdir("%s" % self.tile.dir_rawdata)
            os.mkdir("%s/preview" % self.tile.dir_rawdata)
            os.mkdir("%s/metadata" % self.tile.dir_rawdata)

    @classmethod
    def __parse_bucket_values(cls,content):
        """ return list with values of CommonPrefixes/Prefixes and Key nodes """
        values = []
        dom = parseString(content)
        for cp in dom.getElementsByTagName("CommonPrefixes"):
            for p in cp.getElementsByTagName("Prefix"):
                values.append(p.firstChild.nodeValue.split('/')[-2])
        for k in dom.getElementsByTagName("Key"):
            values.append(k.firstChild.nodeValue)
        return values

    @classmethod
    def __tiles_path(cls,utm_zone,latitude_band,grid_square,rec):
        """ return URL-path to tiles directory
            this is also the primary key for entries in collection aws_tileInfo
            OUTPUT: tiles/32/T/NT/2016/6/14/0
        """
        return "tiles/%s/%s/%s/%s/%s/%s/%s" % (
            utm_zone,latitude_band,grid_square,rec['year'],rec['month'],rec['day'],rec['scene']
        )

    @classmethod
    def __tiles_scene(cls,path):
        """ return scene name for tiles suited for use in local filenames
            pad single digits in month and day with leading 0
            INPUT:  tiles/32/T/NT/2016/6/14/0
            OUTPUT: 32TNT_2016_6_14_0
        """
        parts = path.split('/')
        return "%s_%s_%s_%s_%s" % (
            "".join(parts[1:4]),
            parts[4],
            (parts[5] if len(parts[5]) == 2 else '0%s' % parts[5]),
            (parts[6] if len(parts[6]) == 2 else '0%s' % parts[6]),
            parts[7],
        )

    def parse_bucket(self, year=None, month=None, day=None, num=None, subdir=None):
        """ parse available values for XML ListBucketResult """
        url = None
        values = []
        if year and month and day and num and subdir:
            url = "%s/%s/%s/%s/%s/%s/" % (self.tile.url_bucket,year,month,day,num,subdir)
        elif year and month and day and num:
            url = "%s/%s/%s/%s/%s/" % (self.tile.url_bucket,year,month,day,num)
        elif year and month and day:
            url = "%s/%s/%s/%s/" % (self.tile.url_bucket,year,month,day)
        elif year and month:
            url = "%s/%s/%s/" % (self.tile.url_bucket,year,month)
        elif year:
            url = "%s/%s/" % (self.tile.url_bucket,year)
        else:
            url = "%s/" % (self.tile.url_bucket)

        if not self.quiet:
            print "getting %s ... " % url
        r = requests.get(url)
        if r.status_code == 200:
            values = self.__parse_bucket_values(r.content)

        return values

    def store_file(self, rec=None, overwrite=False):
        """ download file from AWS and store it """
        tiles_path = self.__tiles_path(self.tile.utm_zone,self.tile.latitude_band,self.tile.grid_square,rec)
        tiles_scene = self.__tiles_scene(tiles_path)

        url = "%s/%s/%s" % (self.url_download,tiles_path,rec['fname'])

        # download and store preview image or text metadata
        if rec['fname'] == 'preview.jpg':
            # store image in rawdata area and webspace
            path = "%s/preview/%s_%s" % (self.tile.dir_rawdata,tiles_scene,rec['fname'])
            if os.path.exists(path) and not overwrite:
                if not self.quiet:
                    print "Skipping existing file %s ..." % path
            else:
                if not self.quiet:
                    print "Downloading %s ..." % path
                r = requests.get(url, stream=True)
                if r.status_code == 200:
                    with open(path, 'w') as o:
                        shutil.copyfileobj(r.raw, o)

                # copy preview to web as well
                print "Downloading http://geographie.uibk.ac.at/data/sentinel2/images/%s.jpg ..." % tiles_scene
                path_web = "%s/%s.jpg" % (self.dir_webimages,tiles_scene)
                shutil.copyfile(path,path_web)

        elif rec['fname'] in ('productInfo.json','tileInfo.json','metadata.xml'):
            # store ASCII metadata
            path = "%s/metadata/%s_%s" % (self.tile.dir_rawdata,tiles_scene,rec['fname'])
            if os.path.exists(path) and not overwrite:
                if not self.quiet:
                    print "Skipping existing file %s ..." % path
            else:
                if not self.quiet:
                    print "Downloading %s ..." % path
                r = requests.get(url)
                if r.status_code == 200:
                    with codecs.open(path,'wb','UTF-8') as o:
                        o.write(r.text)

                    # store JSON-metadata for tile in MongoDB
                    if rec['fname'] == "tileInfo.json":
                        # parse JSON-metadata and add custom fields
                        jsondata = simplejson.loads(r.text)
                        jsondata['_name'] = rec['tile']
                        jsondata['_scene'] = tiles_scene
                        jsondata['_downloaded'] = False
                        jsondata['_date'] = datetime.strptime(
                            re.sub(r'\.[0-9]+Z$','Z',jsondata['timestamp']),    # "2016-06-14T10:32:31.727Z"
                            '%Y-%m-%dT%H:%M:%SZ'
                        )

                        # (RE)INSERT
                        self.mdb.aws_tileInfo.remove({'path' : tiles_path})
                        self.mdb.aws_tileInfo.insert(jsondata)

        elif rec['fname'] == 'qi/MSK_CLOUDS_B00.gml':
            # store cloud coverage GML file
            path = "%s/metadata/%s_%s" % (self.tile.dir_rawdata,tiles_scene,re.sub('qi/','',rec['fname']))
            if os.path.exists(path) and not overwrite:
                if not self.quiet:
                    print "Skipping existing file %s ..." % path
            else:
                if not self.quiet:
                    print "Downloading %s ..." % path
                r = requests.get(url)
                if r.status_code == 200:
                    with codecs.open(path,'wb','UTF-8') as o:
                        o.write(r.text)
        else:
            # nothing else for now
            pass
