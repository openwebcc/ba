#!/usr/bin/python
#
# get metadata for tiles
#

import os
import re
import sys

sys.path.append('/home/laser/rawdata/www/lib')
import Laser.base


if __name__ == '__main__':
    """ get meta for tiles """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req=None,user='intranet')

    # clean up existing content in database
    dbh.execute("DELETE FROM ffp_meta")

    # set common project type
    ptype = 'ffp'

    # find data
    for dirpath, dirnames, filenames in os.walk('/home/laser/rawdata/ffp'):
        for fname in filenames:
            # split up directory path on slash
            parts_dir = dirpath.split('/')

            if not len(parts_dir) >= 7:
                continue

            # extract attributes from  directory path
            pname = parts_dir[5]
            cdate = parts_dir[6].split('_')[0]
            cname = parts_dir[6].split('_')[1]
            ctype = parts_dir[7]

            # prepare more file attributes
            ftype = None
            fdate = None
            fsize = os.path.getsize(os.path.join(dirpath, fname))

            # split up filename on underscore and period
            parts_file = re.sub('_','.',fname).split('.')

            # set file type and date if any
            data_set, data_type, data_date = None, None, None
            if parts_file[-1] == 'gz':
                ftype = parts_file[-2]
            elif parts_file[-1] == 'tif':
                ftype = parts_file[-1]
            elif parts_file[-1] == 'jpg':
                ftype = parts_file[-1]
                fdate = parts_file[-2]
            elif parts_file[-1] in ['tfw','jgw']:
                # skip worldfiles for now
                continue
            else:
                print "skipping %s ..." % os.path.join(dirpath, fname)
                continue

            # set tile ID
            tile = int(re.sub('-','',parts_file[0]))

            # INSERT record
            dbh.execute("INSERT INTO ffp_meta (ptype,pname,cdate,cname,ctype,fname,ftype,fdate,fsize,tile) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", (
                ptype,pname,cdate,cname,ctype,fname,ftype,fdate,fsize,tile
            ))

    dbh.close()
