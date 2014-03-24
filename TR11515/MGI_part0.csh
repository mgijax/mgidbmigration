#!/bin/csh -fx

#
# Migration for TR11515
# (part 0 - load new allele stuff
#
# mgidbmigration
# mgddbschema
# reports_db
# qcreports_db
# mgidbutilities
# mirror_wget
#
# allcacheload - add subtype?
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
#${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/scrum-dog/mgd.postdailybackup

#
# pre-migration counts
#
date | tee -a ${LOG}
/usr/local/mgi/live/dbutils/mgd/mgddbschema/objectCounter.sh | tee -a ${LOG}
date | tee -a ${LOG}

#
# TR11540/removing obsolete stored procedures
#
/mgi/all/wts_projects/11500/11540/tr11540.csh | tee -a ${LOG}

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
# allele collection
#
date | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR11515/allelecollection/alleleCollection.csh | tee -a ${LOG}
date | tee -a ${LOG}

#
# what the allele vocabulary/counts like *before* migration
#
date | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletype-before-SQL.csh
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

delete from ACC_Accession where accid like 'MGD-PMEX-%'
go

delete from MLD_Expts where exptType = 'MAP'
go

drop view MLD_Distance_View
go
drop table MGI_AttributeHistory
go
drop table MLD_PhysMap
go
drop table MLD_Distance
go

drop table ALL_Allele_Old
go

exec MGI_Table_Column_Cleanup
go

update ACC_ActualDB 
set url = 'http://gensat.org/bgem_probe_dump.jsp?probe_id=@@@@' 
where _ActualDB_key = 132
go

EOSQL
date | tee -a ${LOG}

#
# re-fresh
#
${MGD_DBSCHEMADIR}/key/key_drop.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/key_create.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/trigger_drop.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/trigger_create.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/procedure_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/procedure_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/view_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/view_create.object | tee -a ${LOG}

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

#
# final tests (need full permissions
#
date | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletypeTests.csh
date | tee -a ${LOG}

#
# update/run MGI_Statistics
#
${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletype-after-stats.csh | tee -a ${LOG}

#
# run some qc/public reports after migration
# use *after* report changes
# only run for testing; do not run during release
#
date | tee -a ${LOG}
./runreports-after.csh | tee -a ${LOG}
date | tee -a ${LOG}

#
# run sto85/update IMSR/germline
#
${MGI_DBUTILS}/bin/updateIMSRgermline.csh | tee -a ${LOG}
cat ${DATALOADSOUTPUT}/mgi/mgidbutilities/logs/updateIMSRgermline.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

