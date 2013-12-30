#!/bin/csh -fx

#
# Migration for TR11423
# (part 0 - load new HDP annotation type & data)
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

# JUST FOR TESTING
#${MGI_DBUTILS}/bin/load_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /backups/rohan/scrum-dog/radar.backup
${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/scrum-dog/mgd.backup

#
# pre-migration counts
#
date | tee -a ${LOG}
${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}
date | tee -a ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update MGI_dbinfo set 
        schema_version = '5-1-8', 
        public_version = 'MGI 5.18'
go

EOSQL
date | tee -a ${LOG}

#
# what the allele types look like *before* migration
#
date | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletype-before-SQL.csh
date | tee -a ${LOG}

#
# allele collection
#
date | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR11515/allelecollection/alleleCollection.csh | tee -a ${LOG}
date | tee -a ${LOG}

#
# allele type
#
date | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletype.csh | tee -a ${LOG}
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

drop table ALL_Allele_Old
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
${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletypeTests.csh
date | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

