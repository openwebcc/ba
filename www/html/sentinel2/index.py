#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
# display Sentinel-2 metadata
#

import re
import os
import sys
import simplejson
import PyRSS2Gen

from datetime import datetime

import pymongo
from pymongo import MongoClient

from mod_python import apache
from mod_python.util import redirect

sys.path.append('/home/laser/rawdata/www/lib')
import Laser.base
import Laser.Util.web
from Sat.sentinel2_aws import AWS

def index(req,lastn='15'):
    """ provide startpage with search mask """
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    # init AWS module
    aws = AWS()

    conn = MongoClient('localhost', 27017)
    mdb = conn.sentinel2

    # get tile descriptions
    tile_description = {}
    for rec in mdb.aws_tilesMonitored.find():
       tile_description[rec['tile']] = rec['description']

    # build aggregate query pipeline for available tiles along with counts
    query_aggregate = [{
        "$group": {
            "_id": {
                "tile" : "$_name",
            },
            "count": {
                "$sum": 1
            }
        }
    },{
        "$sort" : {
            "_id" : 1
        }
    }]

    # build pulldown menu, preselect home-scene
    for rec in mdb.aws_tileInfo.aggregate(query_aggregate):
        selected = " selected" if rec['_id']['tile'] == '32TPT' else ''
        desc = ""
        if rec['_id']['tile'] in tile_description:
            desc = tile_description[rec['_id']['tile']]
        tpl.append_to_term('APP_tilesOptions', '<option value="%s" %s>%s - %s (%s)</option>' % (
            rec['_id']['tile'],selected,rec['_id']['tile'],desc,rec['count']
        ))

    # get last 10 scenes and link them
    for rec in mdb.aws_tileInfo.find().limit(int(lastn)).sort([ ('_date', -1)]):
        col = "gray"
        if rec['cloudyPixelPercentage'] <= 20 and rec['dataCoveragePercentage'] >= 90:
            col = "green"
        tpl.append_to_term('APP_lastN', """<li>%s | <a href="/data/sentinel2/index.py/preview?scene=%s">%s %s</a> | <span style="color:%s">cloudy=%s%%, data=%s%%</span></li>""" % (
            rec['_date'],
            rec['_scene'],
            rec['_name'],tile_description[rec['_name']],
            col,rec['cloudyPixelPercentage'],rec['dataCoveragePercentage']
        ))
    tpl.add_term('APP_lastNValue', lastn)

    # finish
    conn.close()
    tpl.add_term('APP_root', aws.get_app_root())
    return tpl.resolve_template('/home/institut/www/html/data/sentinel2/templates/index.tpl')

def preview(req,tile=None, datefrom=None, dateto=None, cloudcoverage=None, datacoverage=None, usecoverage=None, downloaded=None, scene=None, rss=None):
    """ show scenes for a given tile matching query options """
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    # bail out if neither tile(s) nor dates are specified
    if not tile and not datefrom and not dateto and not scene:
        return "Error: you have to specify either a tile, a date or a scene to find"

    # connect to mongoDB
    conn = MongoClient('localhost', 27017)
    mdb = conn.sentinel2

    # init AWS helper library
    aws = AWS()

    # init tile descriptions
    tile_description = {}

    # prepare query and query info
    query_what = []
    query_info = []

    # build SQL-query for tile(s)
    if tile:
        tiles = tile[0:] if type(tile) == list else [tile]
        query_what.append({ '_name' : { "$in" : tiles } })
        query_info.append('Kacheln %s' % ', '.join(tiles))

        # get tile descriptions for tiles in question
        for rec in mdb.aws_tilesMonitored.find({ 'tile' : { "$in" : tiles } }):
            tile_description[rec['tile']] = rec['description']

    else:
        # get all tile descriptions
        for rec in mdb.aws_tilesMonitored.find():
            tile_description[rec['tile']] = rec['description']

    # build SQL-query for dates
    if datefrom or dateto:
        if datefrom and not dateto:
            # set start and end date to that day
            d1 = datetime.strptime("%sT00:00:00Z" % datefrom, '%Y-%m-%dT%H:%M:%SZ')
            d2 = datetime.strptime("%sT23:59:59Z" % datefrom, '%Y-%m-%dT%H:%M:%SZ')
            query_info.append('Datum %s' % datefrom)
        elif dateto and not datefrom:
            # set start and end date to that day
            d1 = datetime.strptime("%sT00:00:00Z" % dateto, '%Y-%m-%dT%H:%M:%SZ')
            d2 = datetime.strptime("%sT23:59:59Z" % dateto, '%Y-%m-%dT%H:%M:%SZ')
            query_info.append('Datum %s' % dateto)
        else:
            # set start and end date accordingly
            d1 = datetime.strptime("%sT00:00:00Z" % datefrom, '%Y-%m-%dT%H:%M:%SZ')
            d2 = datetime.strptime("%sT00:00:00Z" % dateto, '%Y-%m-%dT%H:%M:%SZ')
            query_info.append('Zeitraum %s bis %s' % (datefrom,dateto) )

        # append date to query
        query_what.append({ '_date' : {
            "$gte" : d1,
            "$lte" : d2
        }})

    # build SQL-query for cloudcoverage and datacoverage
    if cloudcoverage and usecoverage:
        query_what.append({ 'cloudyPixelPercentage' : {
            "$lte" : int(cloudcoverage) if re.search(r'^[0-9]+$',cloudcoverage) else 100
        }})
        query_info.append(u"Bewölkung &lt;= %s%%" % cloudcoverage)

    if datacoverage and usecoverage:
        query_what.append({'dataCoveragePercentage' : {
            "$gte" : int(datacoverage) if re.search(r'^[0-9]+$',datacoverage) else 0
        }})
        query_info.append("Datenbestand &gt;= %s%%" % datacoverage)

    # build SQL-query for downloaded yes/no switch
    if downloaded:
        query_what.append({'_downloaded' : True})
        query_info.append("nur vorhandene Szenen")

    # build SQL-query for the scene if a single scene is requested
    if scene:
        query_what.append({'_scene' : scene})
        query_info = ["Szene %s" % scene] 

    # define sorting
    query_sort = [
        ('_date',-1),
        ('_scene',1)
    ]

    # prepare RSS feed
    rss_items = []
    rss_last_build_date = None

    # get scenes matching query and display scene details
    for rec in mdb.aws_tileInfo.find({ "$and" : query_what }).sort(query_sort):
        # link to toolbox and mark downloaded scenes
        if rec['_downloaded']:
            link_toolbox = """<a href="%s/toolbox/index?scene=%s">%s</a>""" % (
                aws.get_app_root(),rec['_scene'],rec['_scene']
            )
            class_preview = " class='downloaded'"
        else:
            link_toolbox = """%s (<a href="%s/toolbox/index?scene=%s">Download</a>)""" % (
                rec['_scene'],aws.get_app_root(),rec['_scene']
            )
            class_preview = ""

        if not rss:
            # provide scene details
            tpl.append_to_term('APP_previews',"""
                <div class="preview">
                  <h3>%s<br/>%s %s</h3>
                  <figure>
                    <img src="%s/images/%s.jpg" alt="preview" %s>
                    <figcaption>
                      <table>
                      <tr>
                        <td>Datenbestand: </td>
                        <td><meter min="0" max="100" value="%s"></meter></td>
                        <td>%s%%</td>
                      </tr>
                      <tr>
                        <td>Wolkenfrei: </td>
                        <td><meter min="0" max="100" value="%s"></meter></td>
                        <td>%s%%</td>
                      </tr>
                      <tr>
                        <td>Metadaten: </td>
                        <td colspan="2" style="font-size:0.9em;">
                          <a href="%s/index.py/metadata?scene=%s&amp;filename=tileInfo.json">tileInfo.json</a>
                          | <a href="%s/index.py/metadata?scene=%s&amp;filename=productInfo.json">productInfo.json</a><br/>
                          <a href="%s/index.py/metadata?scene=%s&amp;filename=metadata.xml">metadata.xml</a>
                          | <a href="%s/index.py/metadata?scene=%s&amp;filename=qi/MSK_CLOUDS_B00.gml">MSK_CLOUDS.gml</a>
                        </td>
                      </tr>
                      <tr>
                        <td>Quelle:</td>
                        <td colspan="2"><a href="%s%s/">%s</a></td>
                      </tr>
                      <tr>
                        <td>Toolbox:</td>
                        <td colspan="2">%s</td>
                      </tr>
                      </table>
                    </figcaption>
                  </figure>
                </div>\n""" % (
                    rec['_date'],rec['_scene'][:5],tile_description[rec['_scene'][:5]],
                    aws.get_app_root(),rec['_scene'],class_preview,
                    rec['dataCoveragePercentage'],
                    rec['dataCoveragePercentage'],
                    (100.0-rec['cloudyPixelPercentage']),
                    (100.0-rec['cloudyPixelPercentage']),
                    aws.get_app_root(),rec['_scene'],
                    aws.get_app_root(),rec['_scene'],
                    aws.get_app_root(),rec['_scene'],
                    aws.get_app_root(),rec['_scene'],
                    aws.get_browse_url(),rec['path'],rec['path'],
                    link_toolbox
            ))
        else:
            # provide RSS-feed for given query
            if not rss_last_build_date:
                rss_last_build_date = rec['_date']

            # append item
            rss_items.append(
                PyRSS2Gen.RSSItem(
                    title = "%s %s (%s)" % (rec['_scene'][:5],rec['_date'],tile_description[rec['_scene'][:5]]),
                    link = "http://geographie.uibk.ac.at%s/index.py/preview?scene=%s" % (aws.get_app_root(),rec['_scene']),
                    description = "Scene %s (cloudy=%s%%, data=%s%%)" % (rec['_scene'],rec['cloudyPixelPercentage'],rec['dataCoveragePercentage']),
                    guid = PyRSS2Gen.Guid("%s/index.py/preview?scene=%s" % (aws.get_app_root(),rec['_scene'])),
                    pubDate = rec['_date']
                )
            )

    # say goodbye to db
    conn.close()

    # finish
    if not rss:
        tpl.add_term('APP_root', aws.get_app_root())
        tpl.add_term('APP_query_info', '; '.join(query_info))
        tpl.add_term('APP_query_args', re.sub('&','&amp;',req.args))
        return tpl.resolve_template('/home/institut/www/html/data/sentinel2/templates/index_preview.tpl')
    else:
        feed = PyRSS2Gen.RSS2(
            title = "Sentinel-2 Metadaten Geographie Innsbruck feed",
            link = "http://geographie.uibk.ac.at%s/index.py" % aws.get_app_root(),
            description = "Sentinel-2 Metadaten (%s)" % ", ".join(query_info),
            lastBuildDate = rss_last_build_date,
            items = rss_items
        )
        req.content_type = "application/rss+xml"
        return feed.to_xml()


def metadata(req,scene=None,filename=None):
    """ show auxilliary metadata files for scenes """

    # init AWS module
    aws = AWS()
    aws.set_scene(scene)
    attr = aws.get_scene_attributes()

    # make sure that name of scene is valid
    if not aws.is_valid_scene_name(scene):
        return "Error: invalid scene requested."

    # make sure that filename is valid
    if not filename in aws.get_metadata_filenames():
        return "Error: invalid filename requested"

    # strip qi/ subdirectory from cloudmask
    filename = re.sub('qi/','',filename)

    # link original file to temporary directory and redirect
    in_path = "%s/%s/metadata/%s_%s" % (aws.get_basedir(),attr['tile'],scene,filename)
    out_path = "/home/institut/www/html/data/sentinel2/metatmp/%s_%s" % (scene,filename)
    out_url = re.sub('/home/institut/www/html','',out_path)

    if os.path.exists(in_path):
        if not os.path.exists(out_path):
            os.symlink(in_path,out_path)
        redirect(req,out_url)
    else:
        return "Error: File %s for scene %s does not exist." % (filename,scene)


def csv(req):
    """ deliver tabular data in CSV format """
    conn = MongoClient('localhost', 27017)
    mdb = conn.sentinel2

    # init AWS helper library
    aws = AWS()

    # get tile descriptions
    tile_description = {}
    for rec in mdb.aws_tilesMonitored.find():
       tile_description[rec['tile']] = rec['description']

    # start table with header
    tab = []
    tab.append('"DATE";"TILE";"REGION";"CLOUDY";"DATA";"LINK"')

    # get data
    for rec in mdb.aws_tileInfo.find().sort("_date",-1):
        tab.append('"%s";"%s";"%s";%s;%s;"%s"' % (
            rec['_date'],
            rec['_name'],
            re.sub('"','""',tile_description[rec['_name']]),
            rec['cloudyPixelPercentage'],
            rec['dataCoveragePercentage'],
            'http://geographie.uibk.ac.at/%s/index/preview?scene=%s' % (aws.get_app_root(),rec['_scene'])
        ))

    # finish
    conn.close()
    req.content_type = "text/csv"
    return '\n'.join(tab)
