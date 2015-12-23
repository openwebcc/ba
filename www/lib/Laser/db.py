#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# database module
#

import psycopg2
import psycopg2.extras

from Laser.error import error
from Laser.acl import get_credentials

class impl:
    def __init__(self, base=None):
        """simplified DB-wrapper class that follows parts of the Python Database API Specification v2.0 defined at http://www.python.org/peps/pep-0249.html """
        self.base = base
        self.connected = False

    def connect(self, dbname='geo', user='web'):
        """connect to db as user with password"""
        credentials = get_credentials()

        if user in credentials:
            try:
                # connect
                self.conn = psycopg2.connect("dbname=%s port=5434 user=%s password=%s" % (dbname, user, credentials[user]))
                self.conn.set_isolation_level(0)    # autocommit
                self.curs = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
                self.connected = True

            except StandardError, err:
                error('could not connect to database.', err, self.base)
        else:
            error('invalid user name.', 'user %s unknown' % user, self.base)

    def close(self):
        """close database connection"""
        try:
            self.conn.close()
            self.connected = False
        except StandardError, err:
            error('could not close db-connection.', err, self.base)

    def commit(self):
        """commit changes"""
        try:
            self.conn.commit()
        except StandardError, err:
            error('could not commit changes.', err, self.base)

    def rollback(self):
        """rollback db"""
        try:
            self.conn.commit()
        except StandardError, err:
            error('could not rollback changes.', err, self.base)

    def execute(self,sql, params=None):
        """execute query"""
        if params:
            try:
                self.curs.execute(sql, params)
            except StandardError, err:
                error('could not execute SQL-statement with params=%s.' % str(params), err, self.base)
        else:
            try:
                self.curs.execute(sql)
            except StandardError, err:
                error('could not execute SQL-statement.', err, self.base)

    def executemany(self,sql, namedict=None):
        """execute query from named dictionary"""
        try:
            self.curs.executemany(sql, namedict)
        except StandardError, err:
            error('could not execute SQL-statement with named dictionary %s.' % str(namedict), err, self.base)

    def fetchone(self):
        """fetch one result"""
        try:
            return self.curs.fetchone()
        except StandardError, err:
            error('could not return result set using fetchone.', err, self.base)

    def fetchmany(self,size=1):
        """fetch next set of rows of a result"""
        try:
            return self.curs.fetchmany(size)
        except StandardError, err:
            error('could not return next result set using fetchmany.', err, self.base)

    def fetchall(self):
        """fetch all results"""
        try:
            return self.curs.fetchall()
        except StandardError, err:
            error('could not return result set using fetchall.', err, self.base)

    def rowcount(self):
        """return row-count for last query"""
        try:
            return self.curs.rowcount
        except StandardError, err:
            error('could not return count for rows in last query.', err, self.base)

    def query(self):
        """return body of the last query"""
        try:
            return self.curs.query
        except StandardError, err:
            error('could not return body of the last query.', err, self.base)


