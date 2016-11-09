#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
# download data from Forschungsfestplatte
#

import sys

sys.path.append('/home/laser/rawdata/www/lib')
import Laser.base
import FFP.util


def index(req,id=None,geom=None,**kwargs):
    """ store license agreement and link data to donwload directory """
    (base,dbh,tpl) = Laser.base.impl().init(req)
    config = FFP.util.Config()

    if id:
        return 'linking %s ...' % id
    elif geom:
        return 'linking %s ...' % geom
    else:
        return "Invalid script call"
