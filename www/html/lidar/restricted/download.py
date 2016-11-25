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

def index(req):
    """ provide empty startpage for now """

    req.content_type = "text/html"
    return "."

def lasfile(req, gid=None):
    """ get lasfile """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    dbh.execute("""SELECT ptype,pname,cdate,cname,fname FROM view_lidar_meta WHERE gid=%s""", (gid,))
    for row in dbh.fetchall():
        cid = util.create_cid(row['ptype'],row['pname'],row['cdate'],row['cname'])
        ipath = '%s/las/%s' % (util.path_to_campaign(cid),row['fname'])
        opath = '%s/%s_%s' % (util.get_download_dir(),util.get_cid_as_prefix(cid),row['fname'])

        # execute command and give feedback
        proc = Popen(['ln', '-s', ipath, opath], stdout=PIPE, stderr=PIPE)
        stdout, stderr = proc.communicate()
        req.write('<h3>Daten im Downloadbereich bereitgestellt</h3>')
        req.write("<pre><strong>Shell-Befehl:</strong>\n\nln -s %s %s</pre><br>" % (ipath,opath))

    # finish
    dbh.close()
    raise apache.SERVER_RETURN, apache.OK


def trajectory(req, gid=None):
    """ get trajectory """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    dbh.execute("""SELECT ptype,pname,cdate,cname,fname FROM view_lidar_meta WHERE gid=%s""", (gid,))
    for row in dbh.fetchall():
        cid = util.create_cid(row['ptype'],row['pname'],row['cdate'],row['cname'])
        ipath = "%s/meta/%s.traj.txt" % (util.path_to_campaign(cid),row['fname'])
        opath = '%s/%s_%s.traj.txt' % (util.get_download_dir(),util.get_cid_as_prefix(cid),row['fname'])

        if os.path.exists(ipath):
            # execute command and give feedback
            proc = Popen(['ln', '-s', ipath, opath], stdout=PIPE, stderr=PIPE)
            stdout, stderr = proc.communicate()
            req.write('<h3>Daten im Downloadbereich bereitgestellt</h3>')
            req.write("<pre><strong>Shell-Befehl:</strong>\n\nln -s %s %s</pre><br>" % (ipath,opath))
        else:
            req.write('<h3>no trajectory file found</h3>')

    # finish
    dbh.close()
    raise apache.SERVER_RETURN, apache.OK


def points(req, cid=None, extent=None):
    """ get points for campaign within extent from strips intersecting extent """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    # split up campaign ID
    [ptype,pname,cdate,cname] = util.parse_cid(cid)

    # get las2las command
    args = util.get_las2las_cmd(cid,extent)

    if type(args) == str:
        # show errors
        req.write('ERROR: %s' % args)
    else:
        req.write('<h3>Daten im Downloadbereich bereitgestellt</h3>')
        req.write('<pre><strong>Shell-Befehl:</strong>\n\n')
        req.write(' '.join(args))

        # execute las2las command
        req.write('\n\nrunning command, please wait ...\n')

        proc = Popen(args, stdout=PIPE, stderr=PIPE)
        stdout, stderr = proc.communicate()

        # show lasfiles involved
        req.write('\n\nLAS-Dateien in %s:\n\n' % args[2])
        for fname in open(args[2]).readlines():
            req.write('%s' % fname)
        req.write('</pre>')

    # finish
    dbh.close()
    raise apache.SERVER_RETURN, apache.OK


def strips(req, cid=None, extent=None):
    """ get strips for campaign intersecting extent """

    # init application
    (base,dbh,tpl) = Laser.base.impl().init(req)
    util = Laser.Util.web.impl(base)

    # split up campaign ID
    [ptype,pname,cdate,cname] = util.parse_cid(cid)

    # get shell commands
    cmds = util.get_lascopy_cmds(cid,extent)

    if type(cmds) == str:
        # show errors
        req.write('ERROR: %s' % cmds)
    else:
        # execute commands and give feedback
        req.write('<h3>Daten im Downloadbereich bereitgestellt</h3>')
        req.write('<pre><strong>Shell-Befehle:</strong>\n\n')
        for args in cmds:
                req.write('%s\n' % ' '.join(args) )
                proc = Popen(args, stdout=PIPE, stderr=PIPE)
                stdout, stderr = proc.communicate()
        req.write('</pre>')

    # finish
    dbh.close()
    raise apache.SERVER_RETURN, apache.OK

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
