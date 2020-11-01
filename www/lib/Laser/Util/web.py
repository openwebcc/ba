#!/usr/bin/python
#
# web related helpers
#

import os
import re

POINTS_LIMIT = pow(2,32) - 1 # maximum number of points for LAS 1.0/1.1/1.2/1.3
RAWDATA_DIR = '/home/rawdata'
#DOWNLOAD_DIR = '/home/laser/rawdata/download'
DOWNLOAD_DIR = '/home/institut/rawdata/download'

class impl:
    def __init__(self, base=None):
        """ init web utility class """
        self.base = base
        self.points = None

    @classmethod
    def box2list(cls, box=None):
        """ return list with coordinates from PostGIS BOX(XMIN YMIN,XMAX YMAX) """
        return [int(round(float(v))) for v in re.sub(r'[ ,]','#',box[4:-2]).split('#')]

    def get_download_dir(self):
        """ return path to download directory with user directory """
        return "%s/%s/lidar" % (DOWNLOAD_DIR,self.base.get_user())

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

    def get_lascopy_cmds(self, cid=None, geom=None, outdir=None):
        """ return commands to link lasfiles of given campaign within geometry """

        # split up campaign ID
        [ptype,pname,cdate,cname] = self.parse_cid(cid)

        cmds = []
        # get list of lasfiles interesecting geometry
        self.base.dbh.execute("""
            SELECT ptype,cdate,fname FROM laser.view_meta
            WHERE ST_Intersects(ST_SetSRID(ST_GeomFromGeoJSON(%s),4326),hull)
            AND ptype=%s AND pname=%s AND cdate=%s AND cname=%s
            ORDER BY fname""", (
                geom,ptype,pname,cdate,cname
            )
        )
        for row in self.base.dbh.fetchall():
            ipath = '%s/%s/%s/%s_%s/las/%s' % (
                RAWDATA_DIR,row['ptype'],pname,row['cdate'],cname,row['fname']
            )
            opath = '%s/%s_%s' % (
                outdir,self.get_cid_as_prefix(cid),row['fname']
            )
            cmds.append(['ln','-s',ipath,opath])

        if len(cmds) == 0:
            return "no lasfiles found that intersect the geometry"
        else:
            return cmds

    def get_las2las_cmd(self, cid=None, geom=None, outdir=None):
        """ return las2las command to clip points from lasfiles intersecting the bbox of the geometry """

        # init vars
        las_files = []
        cnt_points = 0
        box_extent = None
        las_extension = None

        # split up campaign ID
        [ptype,pname,cdate,cname] = self.parse_cid(cid)

        # query lasfiles intersecting geometry and define projected geometry to use in las2las
        self.base.dbh.execute(
            """SELECT ptype,cdate,fname,sum(points) AS points,
                ST_Extent(
                  ST_Transform(
                    ST_SetSRID(ST_GeomFromGeoJSON(%s),4326),
                    srid
                  )
                ) AS box_extent
                FROM laser.view_meta
                WHERE ST_Intersects(ST_SetSRID(ST_GeomFromGeoJSON(%s),4326),hull) AND ptype=%s AND pname=%s AND cdate=%s AND cname=%s
                GROUP BY ptype,cdate,fname
            """, (
                geom,geom,
                ptype,pname,cdate,cname
            )
        )

        # loop through results and fill las2las args
        for row in self.base.dbh.fetchall():
            if len(las_files) == 0:
                # set extension of lasfiles
                las_extension = row['fname'][-3:]

                # define projected extent to keep
                box_extent = [str(v) for v in self.box2list(row['box_extent'])]

            # increment point counter
            cnt_points += row['points']

            # append lasfile to list with lasfiles to take into account
            las_files.append("%s/%s/%s/%s_%s/las/%s" % (RAWDATA_DIR,row['ptype'],pname,row['cdate'],cname,row['fname']) )

        if cnt_points > POINTS_LIMIT:
            return "the point limit of %s points to process for clipping has been execeed, please choose a smaller extent" % POINTS_LIMIT
        elif len(las_files) == 0:
            return "no lasfiles found that intersect the bbox of the geometry"
        else:
            # create list with lasfiles to process
            tpath = '%s/%s_%s_%s_%s_%s.%s.files.txt' % (
                outdir,self.get_cid_as_prefix(cid),box_extent[0],box_extent[1],box_extent[2],box_extent[3],las_extension
            )
            opath = re.sub('.files.txt','',tpath)
            o = open(tpath,'w')
            o.write('%s\n' % '\n'.join(las_files))
            o.close()

            # build las2las command and return it
            return ['las2las',
                    '-lof',tpath,
                    '-keep_xy',box_extent[0],box_extent[1],box_extent[2],box_extent[3],
                    '-merged','-o', opath
            ]
