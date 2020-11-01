#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# basic module
#

import os
import Laser.db
import Laser.template

class impl:
    def __init__(self):
        """ init base class """
        self.req = None
        self.dbh = None
        self.tpl = None
        self.commandline = False
        #self.download_base = '/home/laser/rawdata/download'
        self.download_base = '/home/institut/rawdata/download'

    def init(self, req=None, mimetype='text/html', dbname='institut', user='web'):
        """ initialize laser application """

        # set request
        self.req = req

        # set mimetype for request if any
        if self.req:
            if not type(self.req) == file:
                self.req.content_type = mimetype
            else:
                self.commandline = True

        # init new database connection
        self.dbh = Laser.db.impl(self)
        self.dbh.connect(dbname=dbname, user=user)

        # init new templating class
        self.tpl = Laser.template.impl(self)

        return (self, self.dbh, self.tpl)

    def get_user(self):
        """ return logged in apache2 user if any, anonymous otherwise """
        if not self.commandline and self.req and self.req.user:
            return self.req.user
        else:
            if self.commandline:
                return 'klaus'
            else:
                return 'anonymous'

    def get_download_dir(self):
        """ return absolute path to download directory of logged in user """
        return "%s/%s" % (self.download_base,self.get_user())

    def ensure_directory(self,dirpath):
        """ make sure that a requested directory exists, create it if it is absent """
        if not os.path.exists(dirpath):
            try:
                os.makedirs(dirpath)
            except:
                return None

        return dirpath
