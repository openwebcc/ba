#!/usr/bin/python
#
# GPS time conversion utilities
# credits to https://github.com/skymoo/lalsuite/blob/master/glue/glue/gpstime.py
#

import time
from math import floor
from datetime import datetime

def gps_week_from_date(year=None, month=None, day=None, leap_secs=14):
    """ return gpsweek for a given date - simplified https://github.com/skymoo/lalsuite/blob/master/glue/glue/gpstime.py gpsFromUTC """
    t0 = time.mktime((1980, 1, 6, 0, 0, 0, -1, -1, 0))
    t1 = time.mktime((int(year), int(month), int(day), 12, 0, 0, -1, -1, 0)) + leap_secs   
    return int(floor((t1-t0)/(86400*7)))

def gps_week_from_doy(doy=None, year=None):
    """ return gps week for the given day of year """
    d = datetime.strptime('%s %s' % (year,doy), '%Y %j')
    return gps_week_from_date(d.year,d.month,d.day)

def timestamp_from_gps(week=None, secs=None, leap_secs=14):
    """ return timestamp from GPS week and GPS seconds of week - simplified https://github.com/skymoo/lalsuite/blob/master/glue/glue/gpstime.py UTCFromGps """
    t0 = time.mktime((1980, 1, 6, 0, 0, 0, -1, -1, 0)) - time.timezone
    t1 = t0 + (week * (86400 * 7)) + secs - leap_secs
    return time.strftime('%Y-%m-%d %H:%M:%S',time.gmtime(t1))

