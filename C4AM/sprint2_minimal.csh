#!/bin/csh -fx

#
# Sprint 2 : minimal change
#
# This script simply rebuilds MRK_Location_Cache in accordance with new needs
# for sprint 2.  This code is also worked into the sprint1_*.csh scripts, but
# is duplicated here in case we have a sprint 1 database that we want to 
# quickly (2 minutes) convert to sprint 2 without going through a full
# from-production-backup migration (9 hours).

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

#
# Migrate database structures
#
date | tee -a ${LOG}
echo "--- Add column to MRK_Location_Cache" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/table/MRK_Location_Cache_drop.object
${MGD_DBSCHEMADIR}/table/MRK_Location_Cache_create.object

date | tee -a ${LOG}
echo "--- Add indexes to MRK_Location_Cache" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/index/MRK_Location_Cache_create.object

date | tee -a ${LOG}
echo "--- Add primary key for MRK_Location_Cache" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/key/MRK_Location_Cache_create.object

date | tee -a ${LOG}
echo "--- Add foreign key relationships for MRK_Location_Cache" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/key/MGI_Organism_create.object
${MGD_DBSCHEMADIR}/key/MGI_User_create.object
${MGD_DBSCHEMADIR}/key/MRK_Marker_create.object

###--------------------------------------------------------------###
###--- run cache loads       	      	                      ---###
###--------------------------------------------------------------###
echo 'Load Marker Cache tables' | tee -a ${LOG}
${MRKCACHELOAD}/mrklocation.csh

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---"
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
