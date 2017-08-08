#!/usr/bin/python
#
# extract original and generalized flight paths for individual LAS files from corresponding trajectory file(s)
#
# Usage: python get_trajectories.py --help
#
# Batch: find /home/rawdata/als/hef -type d -name bet -exec python /home/institut/rawdata/maintenance/scripts/als/get_trajectories.py --mindist 100 --trajdir {} \;
# Batch: find /home/rawdata/als/hef -type d -name bet -exec python /home/institut/rawdata/maintenance/scripts/als/get_trajectories.py --mindist 100 --trajdir {}  --rebuild \;

import re
import os
import sys

from datetime import datetime
from math import sqrt

sys.path.append('/home/institut/rawdata/www/lib')
import Laser.Util.las

CSV_PATH = '/home/institut/rawdata/maintenance/scripts/als/logs/get_trajectories.csv'

def get_files(trajdir=None,infofile=None,rebuild=None):
    """ walk through project directory and find .info.txt and .bet files """
    files = {
        'bet' : [],
        'info' : [],
    }
    proj_dir = re.sub(r'/bet$','',trajdir)
    for dirpath, dirnames, filenames in os.walk(proj_dir):
        for fname in filenames:
            fpath = os.path.join(os.path.abspath(dirpath),fname)
            if re.search('.info.txt',fpath):
                if infofile and not re.search(infofile,fpath):
                    continue
                las_name = fpath.split('/')[-1][:-9]
                traj_path = "%s/%s.traj.txt" % (dirpath,las_name)
                wkt_path = "%s/%s.traj.wkt" % (dirpath,las_name)

                if os.path.exists(traj_path) and not args.rebuild:
                    print "ignoring %s ..." % traj_path
                else:
                    files['info'].append({
                        'info_path' : fpath,
                        'traj_path' : traj_path,
                        'wkt_path' : wkt_path,
                    })
            elif fname[-4:] == '.bet':
                if not re.search('/raw/',fpath):
                    files['bet'].append(fpath)
            else:
                pass

    return files

def get_bet_times(files=None,has_header=True):
    """ extract minimum and maximum gpstime for each trajectory """
    times = {}
    for betfile in files['bet']:
        print "parsing GPS-times in %s ..." % betfile
        times[betfile] = {
            'min_time' : None,
            'max_time' : None
        }
        with open(betfile) as f:
            for line in f:
                if not times[betfile]['min_time']:
                    # init min/max gpstime
                    times[betfile]['min_time'] = (86400 * 7) + 1
                    times[betfile]['max_time'] = -1

                    # skip header if present
                    if has_header:
                        continue

                # record min/max gpstime
                row = util.parse_line(line)
                t = float(row[0])
                if t < times[betfile]['min_time']:
                    times[betfile]['min_time'] = t
                if t > times[betfile]['max_time']:
                    times[betfile]['max_time'] = t

    return  times

def distance(pt1,pt2):
    """ return distance of two points """
    return sqrt((pt2['x'] - pt1['x'])**2 + (pt2['y'] - pt1['y'])**2 )

if __name__ == '__main__':
    """ extract original flight paths for individual LAS files from corresponding trajectory file(s) """

    import argparse
    parser = argparse.ArgumentParser(description='extract original flight paths for individual LAS files from corresponding trajectory file(s)')
    parser.add_argument('--trajdir',dest='trajdir', required=True, help='input directory containing complete trajectory')
    parser.add_argument('--infofile',dest='infofile', help='create trajectories for the given infofile only')
    parser.add_argument('--mindist',dest='mindist', default=100, help='minimum distance between two successive points in the generalized WKT geometry (in meters)')
    parser.add_argument('--rebuild',dest='rebuild', default=False, action="store_true", help='force rebuilding of all trajectories')
    args = parser.parse_args()

    args.trajdir = args.trajdir.rstrip('/')
    #print "processing %s ..." % args.trajdir

    util = Laser.Util.las.rawdata()

    # check logging
    if not os.path.exists(CSV_PATH):
        with open(CSV_PATH, "w") as f:
            f.write('traj_path;min_time;max_time;coords_traj;coords_wkt;secs_processed\n')

    # log statistics as CSV
    csv = open(CSV_PATH,'a')

    # get filelist for .bet and .info.txt files
    files = get_files(args.trajdir,args.infofile,args.rebuild)
    if len(files['bet']) == 0:
        # no files to process, so stop here
        print "INFO: No trajectory file(s) found in %s" % args.trajdir
        sys.exit(0)
    if len(files['info']) == 0:
        # no files to process, so stop here
        if args.infofile:
            print "INFO: %s file not found for trajectory directory %s" % (args.infofile,args.trajdir)
        else:
            print "INFO: No info.txt file(s) found for trajectory directory %s" % args.trajdir
        sys.exit(0)

    # extract min/max gpstime for each trajectory
    times = get_bet_times(files)

    # extract new trajectory from min/max gpstime and .bet file
    for obj in sorted(files['info']):
        start_time = datetime.now()

        # read info file and get min/max gps time if any
        parser = Laser.Util.las.lasinfo()
        parser.read(obj['info_path'])
        if 'minimum' in parser.meta and 'gps_time' in parser.meta['minimum']:
            min_time = float(parser.meta['minimum']['gps_time'])
            max_time = float(parser.meta['maximum']['gps_time'])

            # prepare extraction of simplified WKT geometry
            last_point = None
            this_point = None
            coords_wkt = []

            # open new trajectory for writing
            traj = open(obj['traj_path'], "w")

            # loop through .bet files and keep corresponding entries in new trajectory file and simplified WKT geom
            cnt_traj = 0
            cnt_wkt = 0
            for betfile in files['bet']:
                header = None

                # skip trajectories whos gpstimes do not overlap with lasfile gpstimes
                if max_time < times[betfile]['min_time'] or min_time > times[betfile]['max_time']:
                    continue

                # process trajectories whos gpstimes overlap with lasfile gpstimes
                print "creating %s ... " % obj['traj_path']
                with open(betfile) as f:
                    #print " looking %s ..." % betfile
                    for line in f:
                        if not header:
                            header = line.lstrip()
                            traj.write(header)
                            continue

                        # split up row and extract time
                        row = util.parse_line(line)
                        t = float(row[0])

                        if t >= min_time and t <= max_time:
                            # write to original trajectory
                            traj.write(line)
                            cnt_traj += 1

                            # write to generalized WKT geometry
                            if not last_point:
                                last_point = { 'x' : float(row[1]), 'y' : float(row[2]) }
                            else:
                                # see if minimum distance is reached
                                this_point = { 'x' : float(row[1]), 'y' : float(row[2]) }
                                if distance(last_point,this_point) >= float(args.mindist):
                                    # add this point to flight path and remember it
                                    coords_wkt.append(this_point)
                                    last_point = this_point
                                else:
                                    # skip this point
                                    pass


            # close trajectory file
            traj.close()

            # remove trajectory file if no points were found
            if cnt_traj == 0:
                os.unlink(obj['traj_path'])
                print "WARNING: %s: no coords found" % obj['traj_path']

            # write generalized trajectory to WKT file
            if len(coords_wkt) > 0:
                # add last point of flight path unless it was added before
                if coords_wkt[-1] != last_point:
                    coords_wkt.append(last_point)

                # create coords of WKT geometry
                line = []
                for pt in coords_wkt:
                    line.append('%s %s' % (pt['x'],pt['y']))

                # write WKT geometry to file
                print "creating %s ... " % obj['wkt_path']
                wkt = open(obj['wkt_path'], "w")
                wkt.write('LINESTRING(%s)\n' % ', '.join(line))
                wkt.close()

                # remember count of coords kept
                cnt_wkt = len(line)

            # log
            secs_processed = (datetime.now() - start_time).total_seconds()
            csv.write('%s;%s;%s;%s;%s;%s\n' % (obj['traj_path'],min_time,max_time,cnt_traj,cnt_wkt,secs_processed))

        else:
            print "WARNING: %s - no GPS-times found" % obj['info_path']

    # close log
    csv.close()
