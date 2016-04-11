#!/bin/csh -fx

#
# convert 
#	GXD_AssayType
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

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1
ALTER TABLE GXD_AssayType RENAME TO GXD_AssayType_old;
EOSQL

${PG_MGD_DBSCHEMADIR}/table/GXD_AssayType_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1

INSERT INTO GXD_AssayType 
SELECT _AssayType_key, assayType, isRNAAssay, isGelAssay, 1, creation_date, modification_date
FROM GXD_AssayType_old
WHERE assayType = 'Immunohistochemistry';

INSERT INTO GXD_AssayType 
SELECT _AssayType_key, assayType, isRNAAssay, isGelAssay, 2, creation_date, modification_date
FROM GXD_AssayType_old
WHERE assayType = 'RNA in situ';

INSERT INTO GXD_AssayType 
SELECT _AssayType_key, assayType, isRNAAssay, isGelAssay, 3, creation_date, modification_date
FROM GXD_AssayType_old
WHERE assayType = 'In situ reporter (knock in)';

INSERT INTO GXD_AssayType 
SELECT _AssayType_key, assayType, isRNAAssay, isGelAssay, 4, creation_date, modification_date
FROM GXD_AssayType_old
WHERE assayType = 'Northern blot';

INSERT INTO GXD_AssayType 
SELECT _AssayType_key, assayType, isRNAAssay, isGelAssay, 5, creation_date, modification_date
FROM GXD_AssayType_old
WHERE assayType = 'Western blot';

INSERT INTO GXD_AssayType 
SELECT _AssayType_key, assayType, isRNAAssay, isGelAssay, 6, creation_date, modification_date
FROM GXD_AssayType_old
WHERE assayType = 'RT-PCR';

INSERT INTO GXD_AssayType 
SELECT _AssayType_key, assayType, isRNAAssay, isGelAssay, 7, creation_date, modification_date
FROM GXD_AssayType_old
WHERE assayType = 'RNase protection';

INSERT INTO GXD_AssayType 
SELECT _AssayType_key, assayType, isRNAAssay, isGelAssay, 8, creation_date, modification_date
FROM GXD_AssayType_old
WHERE assayType = 'Nuclease S1';

INSERT INTO GXD_AssayType 
SELECT _AssayType_key, assayType, isRNAAssay, isGelAssay, 9, creation_date, modification_date
FROM GXD_AssayType_old
WHERE assayType = 'In situ reporter (transgenic)';

INSERT INTO GXD_AssayType 
SELECT _AssayType_key, assayType, isRNAAssay, isGelAssay, 10, creation_date, modification_date
FROM GXD_AssayType_old
WHERE assayType = 'Recombinase reporter';

INSERT INTO GXD_AssayType 
SELECT _AssayType_key, assayType, isRNAAssay, isGelAssay, 11, creation_date, modification_date
FROM GXD_AssayType_old
WHERE assayType = 'Not Specified';

INSERT INTO GXD_AssayType 
SELECT _AssayType_key, assayType, isRNAAssay, isGelAssay, 12, creation_date, modification_date
FROM GXD_AssayType_old
WHERE assayType = 'Not Applicable';

EOSQL

${PG_MGD_DBSCHEMADIR}/key/GXD_AssayType_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_Assay_View_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_Assay_Summary_View_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_AssayType_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_AssayType_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/GXD_AssayType_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_Assay_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_Assay_Summary_View_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1
DROP TABLE GXD_AssayType_old;
EOSQL

${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1

date | tee -a ${LOG}

