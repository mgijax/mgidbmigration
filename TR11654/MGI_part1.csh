#!/bin/csh -fx

#
# Migration for TR11654
#
# mgidbmigration
# mgddbschema
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
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update MGI_dbinfo set 
        schema_version = '5-1-9', 
        public_version = 'MGI 5.19'
go

EOSQL
date | tee -a ${LOG}

#
# re-set trigger
#
date | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/VOC_Evidence_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/VOC_Evidence_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ACC_Accession_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ACC_Accession_create.object | tee -a ${LOG}

#
# obsolete stored procecures
#

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

drop procedure BIB_isNOGO
go
drop procedure BIB_GO_Exists
go
drop procedure BIB_GXD_Exists
go
drop procedure BIB_HMD_Exists
go
drop procedure BIB_MLC_Exists
go
drop procedure BIB_MLD_Exists
go
drop procedure BIB_NOM_Exists
go
drop procedure BIB_PRB_Exists
go
drop procedure BIB_getYear
go
drop procedure BIB_removeNOGO
go
drop procedure NOM_verifyMarker
go

-- obsolete
drop procedure ALL_associateCellLine
go
drop procedure SEQ_createCoordinate
go
drop procedure HMD_hasHomology
go
drop procedure MRK_MaxOffset
go
drop procedure MRK_MiniMapMarkers
go
drop procedure ACC_verifySequenceAnnotation
go
drop procedure MRK_deleteIMAGESeqAssoc
go
drop procedure MRK_updateIMAGESeqAssoc
go

EOSQL
date | tee -a ${LOG}

#
# re-create procedure
#
${MGD_DBSCHEMADIR}/procedure/procedure_drop.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/procedure_create.csh | tee -a ${LOG}

${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

