#!/bin/bash
#
# helper script to set directory and file permissions for projects
#

if [ -z "$1" ]; then 
    echo "Usage: sh $0 STARTDIR"
    exit
fi

echo "setting user:group to root:rawdata ..."
chown -R root:rawdata $1

echo "setting directory permissions to 755 ..."
find $1 -type d -exec chmod 755 {} \;

echo "setting file permissions to 640 ..."
find $1 -type f -exec chmod 640 {} \;

