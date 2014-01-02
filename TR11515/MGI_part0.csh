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
./MGI_collections.csh | tee -a ${LOG}
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
drop table MGI_VocAssociation
go
drop table MGI_VocAssociationType
go
delete from VOC_Term where _Vocab_key in (40,41)
go
delete from VOC_Vocab where _Vocab_key in (40,41)
go

drop table ALL_Allele_Old
go

exec MGI_Table_Column_Cleanup
go

EOSQL
date | tee -a ${LOG}

#
# due to drop of MGI_VocAssociation and vocab 40,41
#
${MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Vocab_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Vocab_create.object | tee -a ${LOG}

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
${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletypeTests.csh
date | tee -a ${LOG}

#
# run some qc/public reports after migration
# use *after* report changes
# comment out when running release it-self
#
date | tee -a ${LOG}
./runreports-after.csh | tee -a ${LOG}
date | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

