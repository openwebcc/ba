#!/usr/bin/python
#
# utility library
#
# lasinfo: parser library that parses LASFILE.info.txt files
#          created by: lasinfo -i LASFILE -o ../meta/LASFILE.info.txt -compute_density -repair
# rawdata: helpers to clean up ASCII rawdata
#

import os
import re
import simplejson

from gps import gps_week_from_doy

class lasinfo:
    def __init__(self):
        """ setup new LASInfo parser """
        self.meta = {}

        # define methods to use when parsing metadata
        self.attr_methods = {
            # search pattern     attribute key    func to call
            'file signature' : ['File Signature','set_signature'],
            'file source ID' : ['File Source ID','set_int'],
            'global_encoding' : ['Global Encoding','set_int'],
            'project ID GUID data 1-4' : ['Project ID - GUID data','set_str'],
            'version major.minor' : ['Version','set_version'],
            'system identifier' : ['System Identifier','set_system_identifier'],
            'generating software' : ['Generating Software','set_str'],
            'file creation day/year' : ['File Creation','set_creation'],
            'header size' : ['Header Size','set_int'],
            'offset to point data' : ['Offset to point data','set_int'],
            'number var. length records' : ['Number of Variable Length Records','set_int'],
            'point data format' : ['Point Data Record Format','set_int'],
            'point data record length' : ['Point Data Record Length','set_int'],
            'number of point records' : ['Legacy Number of point records','set_int'],
            'number of points by return' : ['Legacy Number of points by return','set_returns'],
            'scale factor x y z' : ['Scale factor','set_xyz'],
            'offset x y z' : ['Offset','set_xyz'],
            'min x y z' : ['Min','set_xyz'],
            'max x y z' : ['Max','set_xyz'],
            'start of waveform data packet record' : ['Start of Waveform Data Packet Record','set_int'],
            'start of first extended variable length record' : ['Start of first Extended Variable Length Record','set_int'],
            'number of extended_variable length records' : ['Number of Extended Variable Length Records','set_int'],
            'extended number of point records' : ['Number of point records','set_int'],
            'extended number of points by return' : ['Number of points by return','set_returns'],
            'overview over number of returns of given pulse' : ['returns_of_given_pulse','ignore'],
            'covered area in square meters/kilometers' : ['area','set_area'],
            'covered area in square units/kilounits' : ['area','set_area'],
            'point density' : ['density','set_density'],
            'spacing' : ['spacing','set_spacing'],
            'number of first returns' : ['first_returns','ignore'],
            'number of intermediate returns' : ['intermediate_returns','ignore'],
            'number of last returns' : ['last_returns','ignore'],
            'number of single returns' : ['single_returns','ignore'],
            'overview over extended number of returns of given pulse' : ['extended_number_of_returns','ignore'],
            'minimum and maximum for all LAS point record entries' : ['min_max','set_min_max'],
            'histogram of classification of points' : ['class_histo','set_class_histo'],
            'WARNING' : ['warning','ignore'],
            'moretocomemaybe' : ['xxx','ignore'],
        }

    def read(self, fpath):
        """ read file containing output of lasinfo and collect metadata """
        with open(fpath) as f:
            # set filename and size of corresponding .las file
            lasname = re.sub(r'/meta/(.*).info.txt',r'/las/\1',fpath)
            if os.path.exists(lasname):
                self.meta['file_name'] = lasname
                self.meta['file_size'] = os.path.getsize(lasname)
            else:
                raise NameError('%s does not exist' % lasname)

            # set filenpaths to corresponding metafiles .info.txt, .hull.wkt, .traj.wkt if any
            metafiles = {
                'info' : fpath,
                'hull' : re.sub('.info.txt','.hull.wkt',fpath),
                'traj' : re.sub('.info.txt','.traj.wkt',fpath)
            }
            for ftype in metafiles:
                if os.path.exists(metafiles[ftype]):
                    if not 'metafiles' in self.meta:
                        self.meta['metafiles'] = {}
                    self.meta['metafiles'][ftype] = metafiles[ftype]

            # extract metadata from .info file
            section = None
            for line in f.readlines():
                # set section if needed and skip lines if needed
                if re.search('reporting all LAS header entries',line):
                    section = 'HEADER'
                    continue
                elif re.search(r'^variable length header', line):
                    section = 'HEADER_VAR'
                    continue
                elif re.search(r'^reporting minimum and maximum for all LAS point record entries', line):
                    section = 'MINMAX'
                    continue
                elif re.search(r'^histogram of classification of points', line):
                    section = 'HISTO'
                    continue
                elif re.search(r'^histogram of extended classification of points', line):
                    section = 'HISTO_EXT'
                    continue
                elif re.search(r'^LASzip compression', line) or re.search(r'^LAStiling', line):
                    section = None
                    continue
                elif re.search(r'flagged as synthetic', line) or re.search(r'flagged as keypoints', line) or re.search(r'flagged as withheld', line):
                    section = None
                    continue
                else:
                    # what else?
                    pass

                # reset section unless leading blanks are present in current line
                if section and not re.search(r'^ +',line):
                    section = None

                if section == 'HEADER':
                    # split up trimmed line on colon+blank
                    [key,val] = self.strip_whitespace(line).split(': ')
                    # set header attribute with corresponding key and method
                    getattr(self, self.attr_methods[key][1])(
                        self.attr_methods[key][0],
                        val
                    )

                elif section == 'HEADER_VAR':
                    # extract SRID and projection name if available
                    self.set_srid_proj(line)

                elif section == 'MINMAX':
                    # set min/max for point record entries
                    self.set_min_max(line)

                elif section in ('HISTO','HISTO_EXT'):
                    # set classification histogram value, name and point count
                    self.set_class_histo(line)

                else:
                    parts = self.strip_whitespace(line).split(': ')
                    if parts[0] in self.attr_methods:
                        # set attribute with corresponding key and method
                        getattr(self, self.attr_methods[parts[0]][1])(
                            self.attr_methods[parts[0]][0],
                            parts[1]
                        )
                    elif parts[0] in [
                        'bounding box is correct.',
                        'number of point records in header is correct.',
                        'number of points by return in header is correct.',
                        'extended number of point records in header is correct.',
                        'extended number of points by return in header is correct.'
                    ]:
                        # ignore positive info from -repair
                        continue
                    elif parts[0] == 'bounding box was repaired.':
                        # tell user to re-run lasinfo as header has been updated and content in .info might not be correct anymore
                        print "RE-RUN sh /home/klaus/private/ba/tools/get_lasinfo.sh %s rebuild" % self.meta['file']['las']
                    else:
                        pass
                        print "TODO", parts, '(%s)' % f.name

    def has_wkt_geometry(self,ftype=None):
        """ return True if WKT geometry is present, false otherwise """
        if 'metafiles' in self.meta and ftype in self.meta['metafiles']:
            return True
        else:
            return False

    def get_wkt_geometry(self,ftype=None):
        """ read WKT geometry for hull or trajectory if any """
        wkt = ''
        if self.has_wkt_geometry(ftype):
            with open(self.meta['metafiles'][ftype]) as f:
                wkt = f.read()
        return wkt.rstrip()

    def as_json(self,obj=None,pretty=False):
        """ return object as JSON """
        if pretty:
            return simplejson.dumps(obj,sort_keys=True, indent=4 * ' ')
        else:
            return simplejson.dumps(obj)

    def strip_whitespace(self, val=None):
        """ remove leading, trailing whitespace and replace successive blanks with one blank """
        if type(val) == str:
            return re.sub(r' +',' ',val.lstrip().rstrip())
        else:
            return val

    def ignore(self,key,val):
        """ ignore this attribute """
        pass

    def warning(self,key,val):
        """ display warnings """
        print "WARNING: %s=%s" % (key,val)

    def set_str(self,key,val):
        """ set value as string """
        self.meta[key] = str(val)

    def set_int(self,key,val):
        """ set value as integer """
        self.meta[key] = int(val)

    def set_signature(self,key,val):
        """ set file signature as string """
        self.meta[key] = val.lstrip("'").rstrip("'")

    def set_system_identifier(self,key,val):
        self.meta[key] = val.lstrip("'").rstrip("'")

    def set_version(self,key,val):
        """ set major and minor version """
        major,minor = [str(v) for v in val.split('.')]
        self.meta['Version Major'] = major
        self.meta['Version Minor'] = minor

    def set_creation(self,key,val):
        """ set file creation day/year """
        doy,year = [int(v) for v in val.split('/')]
        self.meta['File Creation Day of Year'] = doy
        self.meta['File Creation Year'] = year

        # compute GPS-week as well
        self.meta['creation_gpsweek'] = gps_week_from_doy(doy,year)

    def set_returns(self,key,val):
        """ set number of points by return as list with five entries exactly """
        pts = [int(v) for v in val.split(' ')]
        if key == 'Legacy Number of points by return':
            if len(pts) < 5:
                # fill with zeros
                for n in range(0,5-len(pts)):
                    pts.append(0)
            self.meta['Legacy Number of points by return'] = pts[:5]
        elif key == 'Number of points by return':
            if len(pts) < 15:
                # fill with zeros
                for n in range(0,15-len(pts)):
                    pts.append(0)
            self.meta['Number of points by return'] = pts[:15]
        else:
            pass

    def set_xyz(self,key,val):
        """ set x y z values as floats """
        arr = [float(v) for v in val.split(' ')]
        if key == 'Scale factor':
            self.meta['X scale factor'] = arr[0]
            self.meta['Y scale factor'] = arr[1]
            self.meta['Z scale factor'] = arr[2]
        elif key == 'Offset':
            self.meta['X offset'] = arr[0]
            self.meta['Y offset'] = arr[1]
            self.meta['Z offset'] = arr[2]
        elif key == 'Min':
            self.meta['Min X'] = arr[0]
            self.meta['Min Y'] = arr[1]
            self.meta['Min Z'] = arr[2]
        elif key == 'Max':
            self.meta['Max X'] = arr[0]
            self.meta['Max Y'] = arr[1]
            self.meta['Max Z'] = arr[2]
        else:
            pass

    def set_srid_proj(self,line):
        """ set SRID and projection name if available """
        if re.search('ProjectedCSTypeGeoKey',line):
            srid,info = (re.sub(r'^key.*value_offset (\d+) - ProjectedCSTypeGeoKey: (.*)$',r'\1;\2',self.strip_whitespace(line))).split(';')
            self.meta['projection_srid'] = int(srid)
            self.meta['projection_info'] = info

    def set_min_max(self,line):
        """ set min, max values for attribute """
        for k in ('minimum','maximum'):
            if not k in self.meta:
                self.meta[k] = {}

        # isolate attribute name, min and max from line
        parts = self.strip_whitespace(line).split(' ')
        attr = ' '.join(parts[:-2])
        if attr in ('X','Y','Z'):
            # skip unscaled X,Y,Z values and assign regular min / max values instead that have been extracted before
            self.meta['minimum'][attr.lower()] = self.meta['Min %s' % attr]
            self.meta['maximum'][attr.lower()] = self.meta['Max %s' % attr]
            return

        self.meta['minimum'][attr] = float(parts[-2])
        self.meta['maximum'][attr] = float(parts[-1])

    def set_class_histo(self,line):
        """ return classification histogram value, name and point count """
        if not 'class_histo' in self.meta:
            self.meta['class_histo'] = {}

        parts = self.strip_whitespace(line).split(' ')
        class_value = int(re.sub(r'[\(\)]','',parts[-1]))
        class_name = ' '.join(parts[1:-1])
        num_points = int(parts[0])
        self.meta['class_histo'][class_value] = {
            'name' : class_name,
            'points' : num_points
        }

    def set_area(self,key,val):
        """ return covered area in square meters/kilometers """
        m2,km2 = [float(v) for v in val.split('/')]
        self.meta['area_m2'] = float(m2)
        self.meta['area_km2'] = float(km2)

    def set_density(self,key,val):
        """ return estimated point density for all returns and last returns per square meter """
        all_r,last_r = (re.sub(r'all returns ([^ ]+) last only ([^ ]+) \(per square .*\)$',r'\1;\2',self.strip_whitespace(val))).split(';')
        self.meta['density_per_m2_all'] = float(all_r)
        self.meta['density_per_m2_last'] = float(last_r)

    def set_spacing(self,key,val):
        """ get spacing for all returns and last returns in meters """
        all_r,last_r = (re.sub(r'all returns ([^ ]+) last only ([^ ]+) \(in .*\)$',r'\1;\2',self.strip_whitespace(val))).split(';')
        self.meta['spacing_in_m_all'] = float(all_r)
        self.meta['spacing_in_m_last'] = float(last_r)

    # check if metadata has been collected
    def has_metadata(self):
        """ return True if file signature has been set to 'LASF' as required by specification, False otherwise """
        return ('File Signature' in self.meta and self.meta['File Signature'] == 'LASF')

    def get_points(self):
        """ get number of points from regular or legacy number of points """
        if 'Number of point records' in self.meta and self.meta['Number of point records'] != 0:
            return self.meta['Number of point records']
        elif 'Legacy Number of point records' in self.meta and self.meta['Legacy Number of point records'] != 0:
            return self.meta['Legacy Number of point records']
        else:
            return 0

    def get_points_by_return(self):
        """ get number of points by return from regular or legacy number of points by return """
        if 'Number of points by return' in self.meta:
            return self.meta['Number of points by return']
        elif 'Legacy Number of points by return' in self.meta:
            return self.meta['Legacy Number of points by return']
        else:
            return []

    def get_attr(self,attrname,attrtype):
        """ safely return meatdata attribute """
        if not attrname in self.meta:
            if attrtype == list:
                return []
            elif attrtype == dict:
                return {}
            else:
                return None
        else:
            return self.meta[attrname]

    def get_metadata(self,json=False,pretty=False):
        """ return metadata collect during parsing """
        if json:
            return self.as_json(self.meta,pretty)
        else:
            return self.meta

    def get_db_metadata(self,pretty=False):
        """ return subset of metadata for database """

        return {
            'file_name' : self.get_attr('file_name',str).split('/')[-1],
            'file_size' : self.get_attr('file_size',str),
            'file_year' : self.get_attr('File Creation Year',int),
            'file_doy' : self.get_attr('File Creation Day of Year',int),
            'file_gpsweek' : self.get_attr('creation_gpsweek',int),
            'srid' : self.get_attr('projection_srid',int),
            'projection' : self.get_attr('projection_info',str),
            'points' : self.get_points(),
            'points_by_return' : self.get_points_by_return(),
            'minimum' : self.get_attr('minimum',list),
            'maximum' : self.get_attr('maximum',list),
            'histogram' : self.get_attr('class_histo',dict),
            'point_area' : self.get_attr('area_m2',float),
            'point_density' : self.get_attr('density_per_m2_all',float),
            'point_spacing' : self.get_attr('spacing_in_m_all',float),
            'point_format' : self.get_attr('Point Data Record Format',int),
            'system_identifier' : self.get_attr('System Identifier',str),
            'global_encoding' : self.get_attr('Global Encoding',int),
        }


class rawdata:
    def __init__(self, req=None):
        """ helpers to clean up ASCII rawdata """
        self.known_attrs = {
            't' : 'gpstime',
            'x' : 'x coordinate',
            'y' : 'y coordinate',
            'z' : 'z coordinate',
            'i' : 'intensity',
            'n' : 'number of returns of given pulse',
            'r' : 'number of return',
            'c' : 'classification',
            'u' : 'user data',
            'p' : 'point source ID',
            'a' : 'scan angle',
            'e' : 'edge of flight line flag',
            'd' : 'direction of scan flag',
            'R' : 'red channel of RGB color',
            'G' : 'green channel of RGB color',
            'B' : 'blue channel of RGB color',
            's' : 'skip number'
        }
        self.req = req

    def strip_whitespace(self, val=None):
        """ remove leading, trailing whitespace and replace successive blanks with one blank """
        if type(val) == str:
            return re.sub(r' +',' ',val.lstrip().rstrip())
        else:
            return val

    def strip_utm32(self, val=None):
        """ strip trailing 32 from UTM  str, int or float x-coordinates """
        if type(val) == str:
            return val[2:]
        elif type(val) in (float, int):
            return val - 32000000
        else:
            return val

    def parse_line(self, line=None, pattern=None):
        """ split up line on blank and create list or dictionary with params by name """

        # split up cleaned line on blank
        row = self.strip_whitespace(line).split(' ')

        # safely assign attributes when requested
        if pattern:
            # init return dictionary
            rec = {}

            # split up pattern
            attrs = list(pattern)

            # bail out if number of attributes does not match number of columns
            if not len(row) == len(attrs):
                raise ValueError('Number of columns and attributes in pattern do not match. Got %s, expected %s.\nline=%s\npattern=%s' % (
                    len(attrs),
                    len(row),
                    self.strip_whitespace(line),
                    pattern
            ))

            # assign attributes
            for i in range(0,len(row)):
                if not attrs[i] in self.known_attrs:
                    raise ValueError('%s is not a valid attribute abreviation.' % attrs[i])
                else:
                    # handle skip flag
                    if attrs[i] == 's':
                        continue
                    else:
                        rec[attrs[i]] = row[i]
            return rec
        else:
            return row

