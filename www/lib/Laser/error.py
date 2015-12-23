#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# error module
#

def error(err_type, err_details, base=None):
    """ safely handle errors """

    # define error message from type and details
    err_msg = "%s %s" % (err_type, err_details if err_details else '')

    # close open database connection if any
    if base.dbh and base.dbh.connected and not err_type == 'Could not close db-connection':
        base.dbh.close()

    # show error message on commandline or in brwoser
    if not base.req:
        import sys
        print "Error: %s" % err_msg
        sys.exit()
    else:
        from mod_python import apache
        base.req.status = apache.HTTP_INTERNAL_SERVER_ERROR 
        base.req.content_type = "text/html"
        base.req.write("<strong>Error</strong>: %s" % err_msg)
        raise apache.SERVER_RETURN, apache.DONE


