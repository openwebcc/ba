#!/usr/bin/python
#
# fix incorrect syntax for echoes in .ala files of 071011_hef14/fix
#

import os
import sys

sys.path.append('/home/laser/rawdata/www/lib')
import Laser

if __name__ == '__main__':
    """ fix incorrect return number and number of returns for given pulse syntax """
    util = Laser.Util()
    basedir = '/home/laser/rawdata/als/hef/071011_hef14'


    for fname in os.listdir('%s/fix/' % basedir):
        if not fname[-3:] == 'ala':
            continue

        # define lower case  .ala output file and open it for writing
        oname = ('%s.ala' % fname[:-4]).lower()
        print "creating %s/asc/%s ..." % (basedir,oname)
        o = open('%s/asc/%s' % (basedir,oname),'w')

        # loop through input file and read pairs of line
        with open('%s/fix/%s' % (basedir,fname)) as f:
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

        # close cleaned output file
        o.close()
