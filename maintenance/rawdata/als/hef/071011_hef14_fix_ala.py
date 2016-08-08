#!/usr/bin/python
#
# fix incorrect syntax for echoes in .ala files of 071011_hef14
#

import re
import os
import sys

sys.path.append('/home/laser/rawdata/www/lib')
from Laser.Util import las

if __name__ == '__main__':
    """ fix incorrect return number and number of returns for given pulse syntax """
    import argparse
    parser = argparse.ArgumentParser(description='fix incorrect syntax for echoes in .ala files')
    parser.add_argument('--ala', dest='ala', required=True, help='path to input .ala file')
    parser.add_argument('--out', dest='out', required=True, help='path to cleaned output file')
    args = parser.parse_args()

    # init utility library
    util = las.rawdata()

    # open output file
    o = open(args.out,'w')

    # loop through input file, read pairs of line and clean up
    with open(args.ala) as f:
        prev_line = None
        curr_line = None
        for line in f:
            if not prev_line:
                prev_line = util.parse_line(line)
                continue
            else:
                curr_line = util.parse_line(line)

                # alter previous and current line in one turn if gpstimes are the same
                if prev_line[0] == curr_line[0]:
                    # set return numbers of previous echo
                    prev_line[-2] = '1'
                    prev_line[-1] = '2'

                    # set return numbers of current echo
                    curr_line[-2] = '2'
                    curr_line[-1] = '2'

                    # write out both lines
                    o.write('%s\n' % ' '.join(prev_line))
                    o.write('%s\n' % ' '.join(curr_line))

                    # set previous line to None
                    prev_line = None
                    continue
                else:
                    # write previous line with 1 1 as no second echo is present
                    prev_line[-2] = '1'
                    prev_line[-1] = '1'
                    o.write('%s\n' % ' '.join(prev_line))

                # assign current line as next previous line
                prev_line = curr_line[:]

    # write last record from loop if any
    if prev_line:
        o.write('%s\n' % ' '.join(prev_line))


    # create log file
    with open("%s.txt" % args.out, "w") as log:
        log.write("the corresponding file was created with %s\n" % __file__)
        log.write("it contains fixed return numbers for first and second returns\n")
        log.write("\n")
        log.write("input file with incorrect return numbers: %s\n" % re.sub("raw/str/ala","raw/bad/ala",args.ala[:-4]) )
        log.write("output file with correct return numbers:  %s\n" % args.out)
        log.write("\n")

    # close cleaned output file
    o.close()
