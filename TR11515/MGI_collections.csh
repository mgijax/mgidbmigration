#!/bin/csh -fx

#
# Migration for TR11515/collections only
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

#
# PLEASE READ!
# FOR TESTING ONLY 
# MAKE SURE BOTH ARE TURNED OFF FOR REAL MIGRATION
#
#${MGI_DBUTILS}/bin/load_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /backups/rohan/scrum-dog/radar.backup
#${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/scrum-dog/mgd.backup
${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /lindon/sybase/mgd.backup

#
# pre-migration counts
#
date | tee -a ${LOG}
${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}
date | tee -a ${LOG}

#
# allele collection
#
date | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR11515/allelecollection/alleleCollection.csh | tee -a ${LOG}
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

exec MGI_Table_Column_Cleanup
go

EOSQL
date | tee -a ${LOG}

#
# set permissions & counts
#
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

#
# final tests (need full permissions
#
date | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR11515/allelecollection/allelecollectionTests.csh
date | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

