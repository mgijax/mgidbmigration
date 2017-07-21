#!/bin/csh -fx

#
# add orcids to MGI_User
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

${PG_MGD_DBSCHEMADIR}/key/MGI_UserRole_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MGI_User_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1
ALTER TABLE MGI_User RENAME TO MGI_User_old;
EOSQL

${PG_MGD_DBSCHEMADIR}/table/MGI_User_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1

INSERT INTO MGI_User
SELECT _User_key, _UserType_key, _UserStatus_key, login, name, null, null,
_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
FROM MGI_User_old
;

--31576664 | Alleles & Phenotypes
--31576665 | Expression
--31576666 | Gene Ontology
--31576667 | Tumor
--31576668 | QTL
UPDATE MGI_User SET _Group_key = 31576664 where login in ('smb', 'mnk', 'honda', 'cms', 'monikat', 'wilmil');
UPDATE MGI_User SET _Group_key = 31576665 where login in ('csmith', 'jfinger', 'jx', 'terryh');
UPDATE MGI_User SET _Group_key = 31576666 where login in ('krc', 'hjd', 'dph', 'mmh', 'ln', 'dmitrys');
UPDATE MGI_User SET _Group_key = 31576667 where login in ('dab', 'dmk');
UPDATE MGI_User SET _Group_key = 31576668 where login in ('djr', 'jrecla')

select count(*) from MGI_User;
select count(*) from MGI_User_old;

EOSQL

${PG_MGD_DBSCHEMADIR}/key/MGI_UserRole_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/index/MGI_User_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/MGI_User_create.object | tee -a $LOG || exit 1

#${PG_MGD_DBSCHEMADIR}/procedure/procedure_create.sh | tee -a $LOG || exit 1

#${PG_MGD_DBSCHEMADIR}/view/view_drop.sh | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/view/view_create.sh | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG || exit 1
DROP TABLE MGI_User_old;
EOSQL

date | tee -a ${LOG}

