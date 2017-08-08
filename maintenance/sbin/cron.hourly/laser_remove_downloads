#!/bin/sh
#
# clean up temporary files and softlinks for download applications
#

# remove all LiDAR download subdirectories that are older than 24 hours
find /home/laser/rawdata/download -mindepth 3 -maxdepth 3 -wholename "*lidar*" -mmin +1440 -type d -exec rm -rf {} \;

# remove all FFP download subdirectories that are older than 48 hours
find /home/laser/rawdata/download -mindepth 3 -maxdepth 3 -wholename "*ffp*" -mmin +2880 -type d -exec rm -rf {} \;

# remove all download softlinks for sentinel2 metadata  that are older than 24 hours
find /home/institut/rawdata/www/html/sentinel2/metatmp -maxdepth 1 -mmin +1440 -not -type d -exec rm -f {} \;

# remove all temporary files from /home/laser/rawdata/sat/sentinel2/tmp that are older than 24 hours
find /home/rawdata/sat/sentinel2/tmp -maxdepth 1 -mmin +1440 -not -type d -exec rm -f {} \;


