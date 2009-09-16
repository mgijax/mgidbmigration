#!/bin/csh -fx

#
# Migration for Cre Promoter - TR9164 -- 4.2x Cre Release
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp
setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}

###----
###--- Add GXD schema changes
###----
./modifyGxdStructure.csh

###----
###--- Make Structure->System associations ---###
###----
###fit into backend; use GXD_TheilerStage._defaultSystem_key
./assocAdSystems.py ${MGD_DBSERVER} ${MGD_DBNAME} ${MGI_DBUSER} ${MGI_DBPASSWORDFILE} ./data/AdSystems.txt | tee -a ${LOG}

###----
###--- load the Cre cache
###----
${ALLCACHELOAD}/allelecrecache.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "Finished migration" | tee -a ${LOG}

