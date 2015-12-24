#!/usr/bin/python
#
# clean up merged .alf and .all files
#

import os
import re
import sys

sys.path.append('/home/klaus/private/ba/www/lib')
import Laser

def lines_are_identical(curr=None,prev=None):
    """ compare two lines omitting helper column 2 with return 1|2 and last two composed return columns and return True if they are identical, False otherwise """
    c = curr[0:-2]
    p = prev[0:-2]
    del c[1]
    del p[1]
    return c == p

def lines_are_supposed_to_be_identical(curr=None,prev=None):
    """ return true if time and intesity are equal and differences of x, y, z do differ below 10 centimeters only """
    max_diff = 1.0
    if curr[4] == prev[4]:
        if abs(float(curr[1])-float(prev[1])) < max_diff:
            if abs(float(curr[2])-float(prev[2])) < max_diff:
                if abs(float(curr[3])-float(prev[3])) < max_diff:
                    return True
    return False

def clean_alf_all(ipath,opath):
    """ clean up joined .alf and .all files """
    prev_line = None
    curr_line = None
    lnum = 0

    util = Laser.Util()

    #print "cleaning %s ..." % ipath
    stats = {
        'almost_duplicated' : 0,
        'duplicated' : 0,
        'kept' : 0
    }
    o = open(opath,'w')
    with open(ipath) as f:
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
                        stats['duplicated'] += 1
                    elif lines_are_supposed_to_be_identical(curr_line,prev_line):
                        # keep last echo
                        curr_line[-2] = '1'
                        curr_line[-1] = '1'
                        o.write('%s\n' % ' '.join(curr_line))
                        stats['almost_duplicated'] += 1
                    else:
                        o.write('%s\n' % ' '.join(prev_line))
                        o.write('%s\n' % ' '.join(curr_line))
                        stats['kept'] += 1

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
                    elif prev_line[1] == '2':
                        # well, this reveals an error in .all files containing a second echo when no corresponding first echo is found in the .alf file
                        # leave it as is for now ... an error
                        # counts for first and last echoes in PDF reports thus should be accurate in merged .ala files as well
                        prev_line[-2] = '2'
                        prev_line[-1] = '2'

                    # remove helper column for sorting containig 1 for .alf and 2 for .all files
                    del prev_line[1]

                    # write out previous echo
                    o.write('%s\n' % ' '.join(prev_line))

                # assign current line as next previous line and continue
                prev_line = curr_line[:]

    # write last record from loop if any
    if prev_line:
        # remove helper column for sorting containig 1 for .alf and 2 for .all files
        del prev_line[1]

        # write out ...
        o.write('%s\n' % ' '.join(prev_line))

    # notify of duplicated entries
    if stats['duplicated'] > 0:
        print "NOTE: skipped %s duplicated, %s almost duplicated 2nd echoes, kept %s 2nd echoes" % (stats['duplicated'],stats['almost_duplicated'],stats['kept'])

    # close output file
    o.close()
    #print "created %s" % opath

if __name__ == '__main__':

    import argparse
    parser = argparse.ArgumentParser(description='clean up merged .alf and .all files')
    parser.add_argument('-i',dest='ipath', required=True, help='input filename containing joined .alf and .all files')
    parser.add_argument('-o',dest='opath', required=True, help='output filename containing cleaned content')
    args = parser.parse_args()

    clean_alf_all(args.ipath,args.opath)
