#!/bin/csh -fx

#
# Migration for TR11515
# (part 0 - load new allele stuff
#
#
# for Dave:
# vocassociationload - obsolete
# exporter
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

#
# pre-migration counts
#
date | tee -a ${LOG}
${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}
date | tee -a ${LOG}

#
# run some qc/public reports using existing reports and existing database
# we don't need to do this for the release-testing
#
#setenv PUBRPTS ${MGI_LIVE}/reports_db-tr11515-BP
#source ${PUBRPTS}/Configuration
#${PUBRPTS}/weekly_postgres/MGI_Mutations.py
#${PUBRPTS}/weekly_sybase/ALL_CellLine_Targeted.py
#${PUBRPTS}/weekly_sybase/MGI_Knockout.py
#cp ${PUBREPORTDIR}/output/MGI_Mutations.html ${PUBREPORTDIR}/output/MGI_Mutations.html.before
#cp ${PUBREPORTDIR}/output/MGI_Mutations.rpt ${PUBREPORTDIR}/output/MGI_Mutations.rpt.before
#cp ${PUBREPORTDIR}/output/ALL_CellLine_Targeted.rpt ${PUBREPORTDIR}/output/ALL_CellLine_Targeted.rpt.before
#cp ${PUBREPORTDIR}/output/MGI_Knockout_Full.rpt ${PUBREPORTDIR}/output/MGI_Knockout_Full.rpt.before
#cp ${PUBREPORTDIR}/output/MGI_Knockout_Full.html ${PUBREPORTDIR}/output/MGI_Knockout_Full.html.before
#cp ${PUBREPORTDIR}/output/MGI_Knockout_NotPublic.rpt ${PUBREPORTDIR}/output/MGI_Knockout_NotPublic.rpt.before
#cp ${PUBREPORTDIR}/output/MGI_Knockout_Public.rpt ${PUBREPORTDIR}/output/MGI_Knockout_Public.rpt.before

#
# update schema-version and public-version
#
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
# what the allele vocabulary/counts like *before* migration
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

--
-- drop obsoleted tables which were used by the front-end only
--
--drop table MGI_VocAssociation
--go
--drop table MGI_VocAssociationType
--go

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
# run cache tables
#
${ALLCACHELOAD}/allelecrecache.csh | tee -a ${LOG}

#
# final tests (need full permissions
#
date | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR11515/allelecollection/allelecollectionTests.csh
${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletypeTests.csh
date | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

