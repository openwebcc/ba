#!/bin/sh
#
# join .alf and .all files for hef11, hef12 and hef13
#
# Usage: sh fix_merge_alf_all.sh ALFFILE
# Batch: find /home/laser/rawdata/als/hef/041005_hef11/fix -name "*.alf" -exec sh /home/klaus/private/ba/tools/fix_merge_alf_all.sh {} \;
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

FNAME=`echo $1 | sed s/\.[^\.]*$//`
if [ ! -f "$FNAME.all" ]; then
    echo "no corresponding .all file found for $1"
    exit
fi

ALA=`echo $FNAME | sed s/fix/asc/`
echo "creating $ALA.ala ..."

# add echo numbers as new column after GPS-time
awk '$1 = $1 FS "1"' $FNAME.alf > $FNAME.alf.tmp
awk '$1 = $1 FS "2"' $FNAME.all >> $FNAME.all.tmp

# merge files and sort them by GPS-time, echo number
cat $FNAME.alf.tmp $FNAME.all.tmp | sort > $FNAME.ala.tmp

# parse merged file, add return number and number of returns for given pulse
python /home/klaus/private/ba/tools/fix_merge_alf_all_cleanup.py -i $FNAME.ala.tmp -o $FNAME.ala

# move .ala file to final destination and clean up temporary files
mv $FNAME.ala $ALA.ala
rm -f *.tmp

