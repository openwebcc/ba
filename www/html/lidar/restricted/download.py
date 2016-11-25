#! /usr/bin/python
# -*- coding: utf-8 -*-
#
# LiDAR data application
#

import sys
import re
import os

from mod_python import apache

from subprocess import Popen
from subprocess import PIPE

sys.path.append('/home/laser/rawdata/www/lib')
import Laser.base
import Laser.Util.web

APP_ROOT = '/data/lidar'

def _log_files(req,dbh,base,files):
    """ log files downloaded by user """
    dbh.execute("INSERT INTO lidar_log (user_id,files) VALUES (%s,%s) RETURNING id", (
        base.get_user(),files
    ))
    return dbh.fetchone()['id']

def index(req):
    """ provide empty startpage for now """
    req.content_type = "text/html"
    return "."

def lasfile(req, gid=None):
    """ get lasfile """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req,user='intranet')
    util = Laser.Util.web.impl(base)

    dbh.execute("""SELECT ptype,pname,cdate,cname,fname FROM view_lidar_meta WHERE gid=%s""", (gid,))
    for row in dbh.fetchall():
        cid = util.create_cid(row['ptype'],row['pname'],row['cdate'],row['cname'])
        ipath = '%s/las/%s' % (util.path_to_campaign(cid),row['fname'])
        opath = '%s/%s_%s' % (util.get_download_dir(),util.get_cid_as_prefix(cid),row['fname'])

        # execute command
        proc = Popen(['ln', '-s', ipath, opath], stdout=PIPE, stderr=PIPE)
        stdout, stderr = proc.communicate()

        # log file
        last_id = _log_files(req,dbh,base,[ipath])

        # fill template terms
        tpl.add_term('APP_subdir',last_id)
        tpl.add_term('APP_files',opath)

    # finish
    dbh.close()
    tpl.add_term('APP_root',APP_ROOT)
    tpl.add_term('APP_user',base.get_user())
    return tpl.resolve_template('/home/institut/www/html/data/lidar/restricted/templates/download.tpl')


def trajectory(req, gid=None):
    """ get trajectory """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req,user='intranet')
    util = Laser.Util.web.impl(base)

    dbh.execute("""SELECT ptype,pname,cdate,cname,fname FROM view_lidar_meta WHERE gid=%s""", (gid,))
    for row in dbh.fetchall():
        cid = util.create_cid(row['ptype'],row['pname'],row['cdate'],row['cname'])
        ipath = "%s/meta/%s.traj.txt" % (util.path_to_campaign(cid),row['fname'])
        opath = '%s/%s_%s.traj.txt' % (util.get_download_dir(),util.get_cid_as_prefix(cid),row['fname'])

        if os.path.exists(ipath):
            # execute command
            proc = Popen(['ln', '-s', ipath, opath], stdout=PIPE, stderr=PIPE)
            stdout, stderr = proc.communicate()

            # log file
            last_id =_log_files(req,dbh,base,[ipath])

            # fill template terms
            tpl.add_term('APP_subdir',last_id)
            tpl.add_term('APP_files',opath)

        else:
            dbh.close()
            return '<h3>ERROR: no trajectory file found</h3>'

    # finish
    dbh.close()
    tpl.add_term('APP_root',APP_ROOT)
    tpl.add_term('APP_user',base.get_user())
    return tpl.resolve_template('/home/institut/www/html/data/lidar/restricted/templates/download.tpl')


def points(req, cid=None, extent=None):
    """ get points for campaign within extent from strips intersecting extent """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req,user='intranet')
    util = Laser.Util.web.impl(base)

    # split up campaign ID
    [ptype,pname,cdate,cname] = util.parse_cid(cid)

    # get las2las command
    args = util.get_las2las_cmd(cid,extent)

    if type(args) == str:
        # show errors
        dbh.close()
        return 'ERROR: %s' % args
    else:
        # prepare file-listings
        files = []
        files_downloaded = [args[-1]]

        # execute las2las command
        proc = Popen(args, stdout=PIPE, stderr=PIPE)
        stdout, stderr = proc.communicate()

        # show lasfiles involved
        for fname in open(args[2]).readlines():
            files.append(fname.rstrip())
            files_downloaded.append('... mit Punkten von %s' % fname.rstrip())

        # log files
        last_id =_log_files(req,dbh,base,files)

        # fill template terms
        tpl.add_term('APP_subdir',last_id)
        tpl.add_term('APP_files','\n'.join(files_downloaded))

    # finish
    dbh.close()
    tpl.add_term('APP_root',APP_ROOT)
    tpl.add_term('APP_user',base.get_user())
    return tpl.resolve_template('/home/institut/www/html/data/lidar/restricted/templates/download.tpl')


def strips(req, cid=None, extent=None):
    """ get strips for campaign intersecting extent """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req,user='intranet')
    util = Laser.Util.web.impl(base)

    # split up campaign ID
    [ptype,pname,cdate,cname] = util.parse_cid(cid)

    # get shell commands
    cmds = util.get_lascopy_cmds(cid,extent)

    if type(cmds) == str:
        # show errors
        dbh.close()
        return 'ERROR: %s' % cmds
    else:
        # prepare file-listings
        files = []
        files_downloaded = []

        # execute commands
        for args in cmds:
            proc = Popen(args, stdout=PIPE, stderr=PIPE)
            stdout, stderr = proc.communicate()

            files.append(args[2])
            files_downloaded.append(args[3])

        # log files
        last_id =_log_files(req,dbh,base,files)

        # fill template terms
        tpl.add_term('APP_subdir',last_id)
        tpl.add_term('APP_files','\n'.join(files_downloaded))

    # finish
    dbh.close()
    tpl.add_term('APP_root',APP_ROOT)
    tpl.add_term('APP_user',base.get_user())
    return tpl.resolve_template('/home/institut/www/html/data/lidar/restricted/templates/download.tpl')

def report(req, cid=None):
    """ get flight report for given campaign if any """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    # se if pdf exists
    cpath = util.path_to_campaign(cid)
    if os.path.exists('%s/doc/report.pdf' % cpath):
        req.content_type = 'application/pdf'
        req.write(open('%s/doc/report.pdf' % cpath).read())
    else:
        req.write('No flight report available')

    # finish
    dbh.close()
    raise apache.SERVER_RETURN, apache.OK
