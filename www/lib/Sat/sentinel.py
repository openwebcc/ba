#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# sentinel utility library
#

import os
import sys

class Util:
    """ utilities to handle Sentinel-2 data """
    def __init__(self, base=None):
        """ init new utility object """
        self.satdir = '/home/rawdata/sat/sentinel2'

    def parse_product(self,fname=None):
        """ parse product components from title of a .SAFE file. The name looks like:
            S2A_OPER_PRD_MSIL1C_PDMC_20150818T101516_R022_V20150813T102406_20150813T102406.SAFE
            see Sentinel-2_User_Handbook.pdf, page 57ff for naming convention
        """
        product = {
            'mission_id' : fname[0:3],
            'file_class' : fname[4:8],
            'file_type' : fname[9:19],
        }

        # parse instance identifier according to level
        if product['file_type'] == 'PRD_USER2A':
            print "ERROR: parsing of Level-2 SAFE-filenames not yet implemented"
            sys.exit()
        else:
            # this is a Level-1 instance identifier
            product['level'] = 1
            product['instance_id'] = fname[20:78]
            product['sensing_start'] = fname[47:62]
            product['sensing_end'] = fname[63:78]

        # return product dictionary
        return product

    def parse_granule(self,fname=None,level=1):
        """ parse product components from name of a JP2 tile. The name looks like:
            S2A_OPER_MSI_L1C_TL_MTI__20150813T201603_A000734_T33TUN_B01.jp2
            see Sentinel-2_User_Handbook.pdf, page 59ff for naming convention
            TODO: unresolved component 'A000734' could not be found in the handbook
        """
        granule = {}
        if level == 1:
            granule['spacecraft'] = fname[0:3]
            granule['routine'] = fname[4:8]
            granule['instrument'] = fname[9:12]
            granule['level'] = fname[13:16]
            granule['granule'] = fname[17:19]
            granule['processing_center'] = fname[20:24]
            granule['sensing_time'] = fname[25:40]
            granule['unresolved_1'] = fname[41:48]
            granule['tilename'] = fname[49:55]
            granule['band'] = fname[56:59]
            granule['zone'] = fname[50:52]
        else:
            print "ERROR: parsing of Level-2 JP2-filenames not yet implemented"
            sys.exit()

        return granule

    def set_subdir(self, product=None, region=None, quiet=False):
        """ set project subdirectory from product date and region, create it if it doesn't exist """

        subdir = {
            'name' : '%s_%s' % (product['sensing_start'][2:8],region),
            'path' : '%s/%s_%s' % (self.satdir,product['sensing_start'][2:8],region),
        }

        # create new subdirectory if it doesn't exist
        if not os.path.exists(subdir['path']):
            if not quiet:
                print "NOTICE: creating %s ..." % subdir['path']
            os.mkdir(subdir['path'])

        # create common dirs as well if needed
        for dirname in ('img','jpeg','meta'):
            if not os.path.exists("%s/%s" % (subdir['path'],dirname)):
                if not quiet:
                    print "NOTICE: creating %s/%s ..." % (subdir['path'],dirname)
                os.mkdir("%s/%s" % (subdir['path'],dirname))

        return subdir

    def get_epsg_code(self, zone=None):
        """ return EPSG-code for given zone
            TODO: implement real parsing - for now it does not parse tilenames like T32TNT ...
        """
        epsg_codes = {
            '31' : 32631,
            '32' : 32632,
            '33' : 32633,
        }

        if not zone in epsg_codes:
            print "ERROR: no EPSG-code available for zone %s." % zone
            sys.exit()

        return epsg_codes[zone]

    def get_satdir(self):
        """ return path to sat directory """
        return self.satdir

