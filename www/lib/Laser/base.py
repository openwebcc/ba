#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# basic module
#

import Laser.db
import Laser.template

class impl:
    def __init__(self):
        """ init base class """
        self.req = None
        self.dbh = None
        self.tpl = None

    def init(self, req=None, mimetype='text/html', dbname='geo', user='web'):
        """ initialize laser application """

        # set request
        self.req = req

        # set mimetype for request if any
        if self.req:
            self.req.content_type = mimetype

        # init new database connection
        self.dbh = Laser.db.impl(self)
        self.dbh.connect(dbname=dbname, user=user)

        # init new templating class
        self.tpl = Laser.template.impl(self)

        return (self, self.dbh, self.tpl)
