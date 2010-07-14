#!/bin/csh -fx

#
# mirror and rcp files needed for dev builds
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration

# start a new log file for this migration, and add a datestamp
setenv LOG `pwd`/`basename $0`.log.$$
rm -rf ${LOG}
touch ${LOG}

#
# rcp files
#
date | tee -a ${LOG}
echo 'rcp MCV annotation file from hobbiton' | tee -a ${LOG}
cd /data/loads/mgi/mcvload/input
rcp -p hobbiton:/data/mcv/current/MGI_MCV_7.07.10_djr.txt ./mcvload.txt

echo 'copy MVC vocabulary file to MCV vocload input directory'
# This file is owned by Richard as group mgi with group write permissions
cd /data/loads/mgi/vocload/runTimeMCV
cp -p /mgi/all/wts_projects/6800/6839/data/MCV_Vocab.obo .

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
