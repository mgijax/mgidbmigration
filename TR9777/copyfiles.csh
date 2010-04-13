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
echo 'rcp uniprotmus.dat for uniprotload files from shire' | tee -a ${LOG}
cd /data/seqdbs/blast/uniprot.build
rcp hobbiton:/data/seqdbs/blast/uniprot.build/uniprotmus.dat .

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
