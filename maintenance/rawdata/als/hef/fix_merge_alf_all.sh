#!/bin/sh
#
# join .alf and .all files for hef11, hef12 and hef13
#
# Usage: sh fix_merge_alf_all.sh ALFFILE
# Batch: find /home/laser/rawdata/als/hef/041005_hef11/fix -name "*.alf" -exec sh /home/laser/rawdata/maintenance/rawdata/als/hef/fix_merge_alf_all.sh {} \;
#

if [ -z "$1" ]; then 
    echo "Usage: sh fix_merge_alf_all.sh ALFFILE"
    exit
else
    if [ ! -f "$1" ]; then
        echo "$1 is not a valid .alf file"
        exit
    fi
fi

# define file paths
ALF=`echo $1`
ALL=`echo $1 | sed s/.alf/.all/`
ALA=`echo $1 | sed s/.alf/.ala/`

# check for existance of corresponding .all file
if [ ! -f "$ALL" ]; then
    echo "ERROR: no corresponding .all file found for $ALF"
    exit
fi

# start merging
echo "creating $ALA ..."

# add echo numbers as new column after GPS-time
awk '$1 = $1 FS "1"' $ALF > $ALF.tmp
awk '$1 = $1 FS "2"' $ALL > $ALL.tmp

# merge files and sort them by GPS-time, echo number
cat $ALF.tmp $ALL.tmp | sort > $ALA.tmp

# parse merged file, add return number and number of returns for given pulse
python /home/laser/rawdata/maintenance/rawdata/als/hef/fix_merge_alf_all_cleanup.py -i $ALA.tmp -o $ALA

# clean up temporary files
rm -f $ALF.tmp
rm -f $ALL.tmp
rm -f $ALA.tmp
