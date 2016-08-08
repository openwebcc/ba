#!/usr/bin/python
#
# merge first (.alf) and last (.all) echo files
# filter noise by removing duplicates and points with identical GPS-time and intensity within a minimum 3D-distance
#

import os
import re
import sys

from math import sqrt

sys.path.append('/home/laser/rawdata/www/lib')
from Laser.Util import las

def lines_are_identical(curr=None,prev=None):
    """ compare two lines omitting helper column 2 with return 1|2 and last two composed return columns and return True if they are identical, False otherwise """
    c = curr[0:-2]
    p = prev[0:-2]
    del c[1]
    del p[1]
    return c == p

def lines_are_supposed_to_be_identical(curr=None,prev=None,dist=None):
    """ detect points with identical GPS-time and intensity within a minimum 3D-distance """
    if curr[0] == prev[0]:
        # times are equal, check itensities next
        if curr[4] == prev[4]:
            # intensities are equal, check 3D-distance between points
            x1,y1,z1 = float(prev[1]),float(prev[2]),float(prev[3])
            x2,y2,z2 = float(curr[1]),float(curr[2]),float(curr[3])
            d = sqrt((x1-x2)**2 + (y1-y2)**2 + (z1-z2)**2)
            if d <= dist:
                # points are within minimum distance - classify duplicated
                return True
            else:
                # points are outside minimum distance - classify distinct
                return False
        else:
            # intensities differ - classify distinct in any case
            return False
    else:
        return False

def merge_first_last(first,last,out,dist):
    """ merge first and last echo files """

    # init vars
    prev_line = None
    curr_line = None
    lnum = 0

    stats = {
        'kept_first' : 0,
        'kept_last' : 0,
        'duplicated' : 0,
        'duplicated_distance' : 0,
    }

    # init utility library
    util = las.rawdata()

    # step 1: merge first and last echo files and sort them by GPS-time, first, last echo
    os.system("""awk '$1 = $1 FS "1"' %s > %s.tmp""" % (first,first))
    os.system("""awk '$1 = $1 FS "2"' %s > %s.tmp""" % (last,last))
    os.system("""cat %s.tmp %s.tmp | sort > %s.tmp""" % (first,last,out))

    # step 2: remove duplicates and supposed duplicates from merged file and create final output
    o = open(out,'w')
    with open("%s.tmp" % out) as f:
        for line in f:
            lnum += 1

            if not prev_line:
                prev_line = util.parse_line(line)
                prev_line.extend(['9','9']) # add two new columns that will hold return number and number of returns for given pulse
                continue
            else:
                curr_line = util.parse_line(line)
                curr_line.extend(['9','9']) # add two new columns that will hold return number and number of returns for given pulse

                # alter previous and current line in one turn if gpstimes are the same
                if prev_line[0] == curr_line[0]:
                    # set return number and number of returns of previous echo
                    prev_line[-2] = '1'
                    prev_line[-1] = '2'

                    # set return number and number of returns of current echo
                    curr_line[-2] = '2'
                    curr_line[-1] = '2'

                    # remove helper columns for sorting containig 1 for .alf and 2 for .all files
                    del prev_line[1]
                    del curr_line[1]

                    # write out both echos unless they are identical
                    if lines_are_identical(curr_line,prev_line):
                        prev_line[-1] = '1'
                        o.write('%s\n' % ' '.join(prev_line))
                        stats['kept_first'] += 1
                        stats['duplicated'] += 1
                    elif lines_are_supposed_to_be_identical(curr_line,prev_line,dist):
                        # keep last echo
                        curr_line[-2] = '1'
                        curr_line[-1] = '1'
                        o.write('%s\n' % ' '.join(curr_line))
                        stats['kept_first'] += 1
                        stats['duplicated_distance'] += 1
                    else:
                        o.write('%s\n' % ' '.join(prev_line))
                        o.write('%s\n' % ' '.join(curr_line))
                        stats['kept_first'] += 1
                        stats['kept_last'] += 1

                    # set previous line to NULL
                    prev_line = None

                    # continue with next line
                    continue

                else:
                    # write previous line
                    if prev_line[1] == '1':
                        # there is no second echo, write 1 1
                        prev_line[-2] = '1'
                        prev_line[-1] = '1'
                        stats['kept_first'] += 1
                    elif prev_line[1] == '2':
                        # well, this reveals an error in .all files containing a second echo when no corresponding first echo is found in the .alf file
                        # leave it as is for now ... an error
                        # counts for first and last echoes in PDF reports thus should be accurate in merged .ala files as well
                        prev_line[-2] = '2'
                        prev_line[-1] = '2'
                        stats['kept_last'] += 1

                    # remove helper column for sorting containig 1 for .alf and 2 for .all files
                    del prev_line[1]

                    # write out previous echo
                    o.write('%s\n' % ' '.join(prev_line))

                # assign current line as next previous line and continue
                prev_line = curr_line[:]

    # write last record from loop if any
    if prev_line:
        # remove helper column for sorting containig 1 for .alf and 2 for .all files
        if prev_line[1] == "1":
            stats['kept_first'] += 1
        else:
            stats['kept_last'] += 1

        del prev_line[1]

        # write out ...
        o.write('%s\n' % ' '.join(prev_line))

    # create log file
    with open("%s.txt" % out, "w") as log:
        log.write("the corresponding file was created with %s\n" % __file__)
        log.write("it contains filtered echoes from merged first and last echo files\n")
        log.write("duplicated points and points with identical GPS-time and intensities within a 3D-distance of %s meters have been removed\n" % dist)
        log.write("\n")
        log.write("input file with first echoes:   %s\n" % first)
        log.write("input file with last echoes:    %s\n" % last)
        log.write("output file with merged echoes: %s\n" % out)
        log.write("minimum point distance:         %s meters\n" % dist)
        log.write("\n")
        log.write("kept returns (all, 1, 2):       %s %s %s \n" % (stats['kept_first']+stats['kept_last'],stats['kept_first'],stats['kept_last']) )
        log.write("skipped real duplicates:        %s\n" % stats['duplicated'])
        log.write("skipped distance duplicates:    %s\n" % stats['duplicated_distance'])
        log.write("\n")

    # close output file
    o.close()

    # clean up temporary files
    os.remove("%s.tmp" % first)
    os.remove("%s.tmp" % last)
    os.remove("%s.tmp" % out)


if __name__ == '__main__':

    import argparse
    parser = argparse.ArgumentParser(description='clean up merged .alf and .all files')
    parser.add_argument('--first', dest='first', required=True, help='path to input file containing first echoes to merge')
    parser.add_argument('--last', dest='last', required=True, help='path to input file containing last echoes to merge')
    parser.add_argument('--out', dest='out', required=True, help='path to output file to create with merged echoes')
    parser.add_argument('--dist',dest='dist', default=0.1, help='minimum distance for two points with the same GPS-timestamp to be classified as first and last return (default 0.1 meters')

    args = parser.parse_args()

    # merge files
    merge_first_last(args.first,args.last,args.out,args.dist)
