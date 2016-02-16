#!/usr/bin/python
#
# parse metadata and import it to PostgreSQL
# Usage: python import_meta.py --help
#

import re
import os
import sys
import argparse


sys.path.append('/home/laser/rawdata/www/lib')
import Laser.base
import Laser.Util.las

if __name__ == '__main__':
    """ parse metadata and import it to PostgreSQL """

    import argparse
    parser = argparse.ArgumentParser(description='parse metadata and import to PostgreSQL')
    parser.add_argument('--startdir',dest='startdir', default='/home/laser/rawdata', help='path to starting directory')
    args = parser.parse_args()

    args.startdir = args.startdir.rstrip('/')

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req=None,user='intranet')

    # clean up all content for now, set start of gid sequence, finetune later
    dbh.execute("DELETE FROM meta")
    dbh.execute("SELECT SETVAL('meta_gid_seq',1001)")

    for dirpath, dirnames, filenames in os.walk(args.startdir):
        if re.search('solartirol',dirpath):
            # skip solartirol for now
            continue

        if len(dirpath.split('/')) == 6:
            print "importing %s ..." % dirpath

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

            # define project type, campaign name and date from directory path (e.g. /home/laser/rawdata/als/hef/011011_hef01/meta)
            parts = dirpath.split("/")
            cdate = parts[-2].split("_")[0]             # 011011
            cname = '_'.join(parts[-2].split("_")[1:])  # hef01 or even suedtirol_2005_2006
            pname = parts[-3]                           # hef
            ptype = parts[-4]                           # als

            # INSERT metadata
            dbh.execute("INSERT INTO meta (ptype,pname,cname,cdate,fname,fsize,points,srid,info) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING gid", (
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
                    print "WARNING: lasfile with gid=%s has empty hull geometry" % last_gid
                else:
                    dbh.execute("UPDATE meta SET hull=ST_GeomFromText('%s') WHERE gid=%s" % (parser.get_wkt_geometry('hull'),last_gid) )
            if parser.has_wkt_geometry('traj'):
                dbh.execute("UPDATE meta SET traj=ST_GeomFromText('%s') WHERE gid=%s" % (parser.get_wkt_geometry('traj'),last_gid) )

    # add missing SRID to vogis data (http://spatialreference.org/ref/epsg/mgi-austria-gk-west/)
    dbh.execute("UPDATE meta SET srid=31254 WHERE pname='vogis'")

    # control gid of first strip Hintereisferner 2001 for direct access to examples in thesis
    dbh.execute("UPDATE meta SET gid=1000 WHERE gid IN (SELECT gid FROM meta WHERE cdate='011011' ORDER BY fname LIMIT 1)")

    # finish
    dbh.close()

