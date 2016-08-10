#!/usr/bin/python
#
# clip a LAS-file on a WKT-polygon
#
# Usage: find /tmp/hef19 -wholename "*/las/*.las" -exec python /home/laser/rawdata/maintenance/scripts/als/clip_lasfile.py --lasfile {} --wktpoly /home/laser/rawdata/maintenance/rawdata/als/hef/util/hef_projectpolygon.wkt --outdir /home/laser/rawdata/als/hef/101007_hef19/las/ \;
#

import os
import time

from shapely.wkt import loads
from shapely.geometry.point import Point
from liblas import file as lasfile

CSV_PATH = '/home/laser/rawdata/maintenance/scripts/als/logs/clip_lasfile.csv'

def read_wkt(fpath=None):
    """ read WKT-polygon and return it as geometry """
    with open(fpath) as f:
        return loads(f.read())


if __name__ == '__main__':
    """ clip LAS-file on WKT-polygon """

    import argparse
    parser = argparse.ArgumentParser(description='clip LAS-file on WKT-polygon')
    parser.add_argument('--lasfile',dest='lasfile', required=True, help='input LAS-file to be clipped')
    parser.add_argument('--wktpoly',dest='wktpoly', required=True, help='WKT-polygon used for clipping')
    parser.add_argument('--outdir',dest='outdir', required=True, help='output directory path')
    args = parser.parse_args()

    # check logging
    if not os.path.exists(CSV_PATH):
        with open(CSV_PATH, "w") as f:
            f.write('infile;outfile;wktpoly;time_start;time_end;points_read;points_kept\n')

    # log statistics as CSV
    csv = open(CSV_PATH,'a')

    # set starttime
    time_start = time.time()

    # get WKT-polygon
    wkt_poly = None
    with open(args.wktpoly) as f:
        wkt_poly = loads(f.read())

    # define file paths
    fpath = args.lasfile
    opath = "%s/%s" % (args.outdir.rstrip('/'),args.lasfile.split('/')[-1])

    # prepare statistics
    points_read = 0
    points_kept = 0

    # open in- and output LAS-file
    f = lasfile.File(fpath,mode='r')
    o = lasfile.File(opath, header=f.header, mode='w')

    # extract points
    #print "processing %s ..." % args.lasfile
    for point in f:
        points_read += 1
        p = Point(point.x, point.y)
        if p.within(wkt_poly) or p.intersects(wkt_poly):
            points_kept += 1
            o.write(point)

    # give feedback and remove empty output file
    o.close()
    f.close()
    if points_kept == 0:
        print "    no points found within WKT-poly"
        os.remove(opath)
    else:
        print "    created %s (kept %s of %s points)" % (opath,points_kept,points_read)

    # log times
    time_end = time.time()
    csv.write('%s;%s;%s;%s;%s;%s;%s\n' % (
        fpath,opath,args.wktpoly,time_start,time_end,points_read,points_kept
    ))
    csv.close()
