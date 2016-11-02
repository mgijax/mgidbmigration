#!/bin/csh -fx

#
# convert 
#	MGI_Organism_MGIType
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

date | tee -a ${LOG}

${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_MGIType_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1
ALTER TABLE MGI_Organism_MGIType RENAME TO MGI_Organism_MGIType_old;
EOSQL

${PG_MGD_DBSCHEMADIR}/table/MGI_Organism_MGIType_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1

INSERT INTO MGI_Organism_MGIType
SELECT _Organism_key, _MGIType_key, 1, _CreatedBy_key, _ModifiedBy_Key, creation_date, modification_date
FROM MGI_Organism_MGIType_old

EOSQL

${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_MGIType_drop.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_MGIType_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_MGIType_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/MGI_Organism_MGIType_create.object | tee -a $LOG || exit 1

# drop the views associated with MGI_Organism_MGIType BEFORE dropping the 'old' table
${PG_MGD_DBSCHEMADIR}/view/MGI_Organism_MGIType_View_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/MGI_Organism_Antigen_View_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/MGI_Organism_Marker_View_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/MGI_Organism_Probe_View_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1
DROP TABLE MGI_Organism_MGIType_old;
EOSQL

# now recreate the views
${PG_MGD_DBSCHEMADIR}/view/MGI_Organism_MGIType_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/MGI_Organism_Antigen_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/MGI_Organism_Marker_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/MGI_Organism_Probe_View_create.object | tee -a $LOG || exit 1

${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1

./organismmgitype.py

date | tee -a ${LOG}

