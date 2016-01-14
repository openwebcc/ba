#!/usr/bin/python
#
# web related helpers
#

import os
import re

POINTS_LIMIT = pow(2,32) - 1 # maximum number of points for LAS 1.0/1.1/1.2/1.3
DOWNLOAD_DIR = '/home/laser/download'
RAWDATA_DIR = '/home/laser/rawdata'

class impl:
    def __init__(self, base=None):
        """ init web utility class """
        self.base = base
        self.points = None

    @classmethod
    def extent2wktpoly(cls, ext=None):
        """ create polygon coordinates from extent string 'XMIN,YMIN,XMAX,YMAX' """
        if ext:
            arr = ext.split(',')
            ply = {
                'xmin' : arr[0],
                'ymin' : arr[1],
                'xmax' : arr[2],
                'ymax' : arr[3],
            }
            return "POLYGON((%s %s, %s %s, %s %s, %s %s, %s %s))" % (
                ply['xmin'],ply['ymin'],
                ply['xmin'],ply['ymax'],
                ply['xmax'],ply['ymax'],
                ply['xmax'],ply['ymin'],
                ply['xmin'],ply['ymin'],
            )
        else:
            # return polygon that lies clearly outside
            return "POLYGON((0 0, 2 2, 1 1, 0 0))"

    @classmethod
    def box2list(cls, box=None):
        """ return list with coordinates from PostGIS BOX(XMIN YMIN,XMAX YMAX) """
        return [int(round(float(v))) for v in re.sub(r'[ ,]','#',box[4:-2]).split('#')]

    def get_download_dir(self):
        """ return path to download directory """
        return DOWNLOAD_DIR

    def create_cid(self, ptype='als', pname='hef', cdate='011011', cname='hef01'):
        """ return capaign ID """
        return "%s:%s:%s:%s" % (ptype,pname,cdate,cname)

    def parse_cid(self, cid='als:hef:011011:hef01'):
        """ return components of a capaign ID """
        return cid.split(':')

    def path_to_campaign(self,cid):
        """ return path to campaign extracted from campaign ID """
        return RAWDATA_DIR + "/%s/%s/%s_%s" % tuple(self.parse_cid(cid))

    def get_cid_as_prefix(self, cid, delimiter='_'):
        """ return cid as prefix suited for filenames with underscore as default delimiter"""
        return re.sub(':',delimiter,cid)

    def get_lascopy_cmds(self, cid=None, ext=None):
        """ return copy commands for lasfiles of given campaign within extent """

        # split up campaign ID
        [ptype,pname,cdate,cname] = self.parse_cid(cid)

        cmds = []
        # get list of lasfiles interesecting extent
        self.base.dbh.execute("""
            SELECT ptype,cdate,fname FROM view_meta
            WHERE ST_Intersects(ST_GeomFromText(%s,4326),hull)
            AND ptype=%s AND pname=%s AND cdate=%s AND cname=%s
            ORDER BY fname""", (
                self.extent2wktpoly(ext),
                ptype,pname,cdate,cname
            )
        )
        for row in self.base.dbh.fetchall():
            cmds.append("ln -s %s/%s/%s/%s_%s/las/%s %s/%s_%s" % (
                RAWDATA_DIR,row['ptype'],pname,row['cdate'],cname,row['fname'],
                DOWNLOAD_DIR,re.sub(':','_',str(cid)),row['fname']
            ))

        return cmds

    def get_las2las_cmd(self, cid=None, ext=None):
        """ transform extent in latlng to extent of campaign and return las commandline args """

        # open new list of lasfiles to take into account
        o = open('/tmp/files.txt', 'w')

        # init vars
        cnt_points = 0
        box_extent = None
        las_extension = None
        wkt_extent = self.extent2wktpoly(ext)

        # split up campaign ID
        [ptype,pname,cdate,cname] = self.parse_cid(cid)

        # query lasfiles intersecting extent and define projected extent to use in las2las
        self.base.dbh.execute(
            """SELECT ptype,cdate,fname,sum(points) AS points,
                ST_Extent(
                  ST_Transform(
                    ST_GeomFromText(%s,4326),
                    srid
                  )
                ) AS box_extent
                FROM view_meta
                WHERE ST_Intersects(ST_GeomFromText(%s,4326),hull) AND ptype=%s AND pname=%s AND cdate=%s AND cname=%s
                GROUP BY ptype,cdate,fname
            """, (
                wkt_extent,wkt_extent,
                ptype,pname,cdate,cname
            )
        )
        if self.base.dbh.rowcount() == 0:
            return 'no lasfiles found'

        # loop through results and fill las2las args
        for row in self.base.dbh.fetchall():
            # set extension of lasfiles
            las_extension = row['fname'][-3:]

            # define projected extent to keep
            box_extent = self.box2list(row['box_extent'])

            # increment point counter
            cnt_points += row['points']

            # append lasfile to list with lasfiles to take into account
            o.write("%s/%s/%s/%s_%s/las/%s\n" % (RAWDATA_DIR,row['ptype'],pname,row['cdate'],cname,row['fname']) )

        # close list with lasfiles to take into account
        o.close()

        if cnt_points > POINTS_LIMIT:
            return "ERROR: the point limit of %s points to process for clipping has been execeed, please choose a smaller extent" % POINTS_LIMIT
        else:
            # build las2las command and return it along with point count
            return "las2las -lof /tmp/files.txt -keep_xy %s %s %s %s -merged -o %s/%s_%s_%s_%s_%s.%s # %s points to check" % (
                box_extent[0],box_extent[1],box_extent[2],box_extent[3],
                DOWNLOAD_DIR,re.sub(':','_',str(cid)),
                box_extent[0],box_extent[1],box_extent[2],box_extent[3],
                las_extension,cnt_points
            )
