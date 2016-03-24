#!/usr/bin/python
#
# download Sentinel-2 scenes from Sentinels Scientific Data Hub 
# see https://scihub.copernicus.eu/userguide/5APIsAndBatchScripting
# Usage: python download_bands.py -h
#

import os
import re
import sys
import requests
import simplejson

from xml.dom.minidom import parseString
from time import sleep

sys.path.append('/home/laser/rawdata/www/lib')
from Sat.sentinel import Util


# set defaults
DEFAULT_REGION = 'atwest'
DEFAULT_TILES = '32TNT,32TPT'       # all atwest would be '32TNT,32TPT,32TQT,32TNS,32TPS,32TQS'
DEFAULT_BANDS = 'B02,B03,B04,B08'   # all bands would be 'B01,B02,B03,B04,B05,B06,B07,B08,B8A,B09,B10,B11,B12'
DEFAULT_DAYS = 21
DEFAULT_REBUILD = False
DEFAULT_QUIET = False

def get_attribs(entry=None, keytype=None):
    """ return dictionary with key/value pairs for attributes by field type """
    attribs = {}
    if keytype in ('str','int','bool','date','double'):
        if type(entry[keytype]) == list:
            for d in entry[keytype]:
                attribs[d['name']] = d['content']
        elif type(entry[keytype]) == dict:
            attribs[entry[keytype]['name']] = entry[keytype]['content']
        else:
            print "ERROR: unknown keytype-object %s. Please handle it in get_attribs()" % entry[keytype]
    elif keytype in ('link'):
        for lnk in entry[keytype]:
            if not 'link' in attribs:
                attribs['link'] = {}
            if 'rel' in lnk:
                attribs['link_%s' % lnk['rel']] = lnk['href']
            else:
                attribs['link'] = lnk['href']
        pass
    else:
        print "ERROR: unknown keytype %s. Please handle it in get_attribs()" % keytype
        sys.exit()

    return attribs

if __name__ == '__main__':
    """ search for new Sentinel-2 images and download them along with metadata """

    import argparse
    parser = argparse.ArgumentParser(description='search for new Sentinel-2 images and download them along with metadata')
    parser.add_argument('--region', dest='region', default=DEFAULT_REGION, help='set region abreviation (default %s)' % DEFAULT_REGION)
    parser.add_argument('--tiles', dest='tiles', default=DEFAULT_TILES, help='comma separated list of tiles to download (default %s)' % DEFAULT_TILES)
    parser.add_argument('--bands', dest='bands', default=DEFAULT_BANDS, help='comma separated list of bands to download (default %s)' % DEFAULT_BANDS)
    parser.add_argument('--days', dest='days', default=DEFAULT_DAYS, help='how many days to look back for new images (default %s)' % DEFAULT_DAYS)
    parser.add_argument('--rebuild', dest='rebuild', default=False, action="store_true", help='force downloading of images')
    parser.add_argument('--quiet', dest='quiet', default=False, action="store_true", help='suppress debug messages')
    args = parser.parse_args()

    # init utility library
    util = Util()

    download_images = {}
    entries = []

    # set geometry for regions
    geom = {
        'atwest' : 'POLYGON((9.53076 46.6515, 9.53076 47.743, 12.9659 47.743, 12.9659 46.6515, 9.53076 46.6515))'
    }

    # bail out if no geometry is available
    if not args.region in geom:
        print "ERROR: No geometry to query found for region %s." % args.region

    # set query
    query = { 'q' : 'ingestionDate:[NOW-%sDAYS TO NOW] AND footprint:"Intersects(%s)"' % (args.days,geom[args.region]),
              'start' : 0,
              'rows' : 1000,
              'format' : 'json',
    }

    # get products for last n days
    req = requests.get("https://scihub.copernicus.eu/s2/api/search", params=query, auth=('guest','guest'), verify=False)
    if not args.quiet:
        print "getting %s ... " % req.url
    if req.status_code == 200:
        json = simplejson.loads(req.text)

        # parse entry or entries
        if type(json['feed']['entry']) == dict:
            entry_list = [ json['feed']['entry'] ]
        else:
            entry_list = json['feed']['entry'][0:]

        for entry in entry_list:
            attribs = {}
            for key in entry:
                if key in ('id','title','summary'):
                    attribs[key] = entry[key]
                elif key in ('str','int','bool','date','double','link'):
                    attribs.update(get_attribs(entry,key))
                else:
                    print "ERROR: unknown keytype %s. Please check." % key

            # append product object to attributes
            attribs['product'] = util.parse_product(attribs['title'])

            # append attributes
            entries.append(attribs)

    else:
        print "ERROR %s: could not fetch %s" % (req.status_code,req.url)

    # get files in product
    for entry in entries:
        # define filename of XML metadata file
        xml_name = re.sub('PRD_MSI','MTD_SAF',entry['filename'])
        xml_name = re.sub('.SAFE','.xml',xml_name)

        # create URL
        xml_url = 'https://scihub.copernicus.eu/s2/odata/v1'
        xml_url += "/Products('%s')" % entry['id']
        xml_url += "/Nodes('%s')" % entry['filename']
        xml_url += "/Nodes('%s')" % xml_name
        xml_url += "/$value"

        # get XML file with available tiles and bands
        req = requests.get(xml_url, auth=('guest','guest'), verify=False)
        if not args.quiet:
            print "getting %s ... " % req.url
        if req.status_code == 200:
            dom = parseString(req.text.encode('utf-8'))
            for granule in dom.getElementsByTagName('Granules'):
                for image in granule.getElementsByTagName('IMAGE_ID'):
                    img_basename = image.firstChild.nodeValue
                    for tile in args.tiles.split(','):
                        for band in args.bands.split(','):
                            if re.search(tile,img_basename) and re.search(band,img_basename):
                                image_url = 'https://scihub.copernicus.eu/s2/odata/v1'
                                image_url += "/Products('%s')" % entry['id']
                                image_url += "/Nodes('%s')" % entry['filename']
                                image_url += "/Nodes('GRANULE')"
                                image_url += "/Nodes('%s')" % granule.getAttribute('granuleIdentifier')
                                image_url += "/Nodes('IMG_DATA')"
                                image_url += "/Nodes('%s.jp2')" % img_basename
                                image_url += "/$value"

                                # set project subdirectory (this will create new directories as needed)
                                entry['subdir'] = util.set_subdir(entry['product'],args.region,args.quiet)

                                # mark image for downloading if needed
                                jpeg_path = "%s/jpeg/%s.jp2" % (entry['subdir']['path'],img_basename)
                                json_path = "%s/meta/%s.json" % (entry['subdir']['path'],img_basename[:-4])
                                xml_path = "%s/meta/%s" % (entry['subdir']['path'],xml_name)
                                if not os.path.exists(jpeg_path) or not os.path.exists(json_path) or args.rebuild:
                                    download_images["%s.jp2" % img_basename] = {
                                        'url' : image_url,
                                        'jpeg_path' : jpeg_path,
                                        'json_path' : json_path,
                                        'json_dump' : simplejson.dumps(entry, sort_keys=True, indent=4 * ' '),
                                        'xml_path' : xml_path,
                                        'xml_dump' : req.text,
                                    }
        else:
            print "WARNING: could not download XML metadata from:\n%s" % req.url

    # get images
    done = 0
    todo = len(download_images.keys())
    for jpeg in sorted(download_images.keys()):
        jpeg_path = download_images[jpeg]['jpeg_path']
        json_path = download_images[jpeg]['json_path']
        xml_path = download_images[jpeg]['xml_path']

        # store JSON metadata
        if not os.path.exists(json_path) or args.rebuild:
            if not args.quiet:
                print "%s: creating %s ... " % (todo,json_path)
                print "%s: creating %s ... " % (todo,xml_path)
            with open(json_path, 'w') as o:
                o.write(download_images[jpeg]['json_dump'])
            with open(xml_path,'w') as o:
                o.write(download_images[jpeg]['xml_dump'].encode('utf-8'))

        # download image
        if not os.path.exists(jpeg_path) or args.rebuild:
            print "INFO: %s: downloading %s ... " % (todo,jpeg_path)
            req_image = requests.get(download_images[jpeg]['url'], auth=('guest','guest'), verify=False)
            with open(jpeg_path, 'wb') as o:
                o.write(req_image.content)

            sleep(2)
            done += 1

        todo -= 1

    # give feedback
    if done > 0:
        if not args.quiet:
            print "\nDownloaded %s new JPEG-images found within the last %s days" % (done,args.days)
    else:
        if not args.quiet:
            print "\nNo new JPEG-images within the last %s days found" % args.days


