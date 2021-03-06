#!/usr/bin/python
#
# parse metadata and import it to PostgreSQL
# Usage: python import_meta.py --help
#

import re
import os
import sys
import argparse


sys.path.append('/home/institut/rawdata/www/lib')
import Laser.base
import Laser.Util.las

if __name__ == '__main__':
    """ parse metadata and import it to PostgreSQL """

    import argparse
    parser = argparse.ArgumentParser(description='parse metadata and import to PostgreSQL')
    parser.add_argument('--startdir',dest='startdir', default='/home/rawdata/als', help='path to starting directory')
    args = parser.parse_args()

    args.startdir = args.startdir.rstrip('/')

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req=None,user='intranet')

    # find metadata directories to process
    for dirpath, dirnames, filenames in os.walk(args.startdir):
        if os.path.basename(dirpath) == 'meta':
            print "importing %s ..." % dirpath
        else:
            continue

        # define project type, campaign name and date from directory path (e.g. /home/rawdata/als/hef/011011_hef01/meta)
        parts = dirpath.split("/")
        cdate = parts[-2].split("_")[0]             # 011011
        cname = '_'.join(parts[-2].split("_")[1:])  # hef01 or even suedtirol_2005_2006
        pname = parts[-3]                           # hef
        ptype = parts[-4]                           # als

        # clean up existing content in db
        dbh.execute("DELETE FROM laser.lidar_meta WHERE ptype=%s AND pname=%s AND cdate=%s AND cname=%s", (
            ptype,pname,cdate,cname
        ))

        # get metadata
        for fname in filenames:
            if not fname[-9:] == '.info.txt':
                continue

            # parse info
            infofile = os.path.join(dirpath, fname)
            parser = Laser.Util.las.lasinfo()
            try:
                parser.read(infofile)
            except ValueError as err:
                print infofile, err
            except NameError as err:
                print infofile, err
            except TypeError as err:
                print infofile, err
            except:
                print infofile
                print "Unexpected error:", sys.exc_info()[0]

            meta = parser.get_db_metadata()

            # INSERT metadata
            dbh.execute("INSERT INTO laser.lidar_meta (ptype,pname,cname,cdate,fname,fsize,points,srid,info) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING gid", (
                ptype,pname,
                cname,cdate,
                meta['file_name'],meta['file_size'],
                meta['points'],
                meta['srid'],
                parser.as_json(meta),
            ))

            # get gid of last inserted row
            last_gid = dbh.fetchone()[0]

            # add geometry for hull and trajectory if any
            if parser.has_wkt_geometry('hull'):
                if parser.get_wkt_geometry('hull') == "":
                    print "WARNING: /home/rawdata/%s/%s/%s_%s/las/%s with gid=%s has empty hull geometry" % (
                        ptype,pname,cdate,cname,fname[:-9],last_gid
                    )
                else:
                    dbh.execute("UPDATE laser.lidar_meta SET hull=ST_GeomFromText('%s') WHERE gid=%s" % (parser.get_wkt_geometry('hull'),last_gid) )
            if parser.has_wkt_geometry('traj'):
                dbh.execute("UPDATE laser.lidar_meta SET traj=ST_GeomFromText('%s') WHERE gid=%s" % (parser.get_wkt_geometry('traj'),last_gid) )

        # add missing SRID to vogis data (http://spatialreference.org/ref/epsg/mgi-austria-gk-west/)
        if pname == 'vogis':
            dbh.execute("UPDATE laser.lidar_meta SET srid=31254 WHERE pname='vogis'")

        # control gid of first strip Hintereisferner 2001 for direct access to examples in thesis
        if pname == 'hef' and cdate == '011011':
            dbh.execute("UPDATE laser.lidar_meta SET gid=1000 WHERE gid IN (SELECT gid FROM laser.lidar_meta WHERE cdate='011011' ORDER BY fname LIMIT 1)")

    # finish
    dbh.close()

