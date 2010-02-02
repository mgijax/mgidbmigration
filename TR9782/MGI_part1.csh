#!/bin/csh -fx

# Migration for TR9782 -- Spring 2010 maintenance release
# (part 1 - addition of new structures)

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

${UTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.33" | tee -a ${LOG}
${UTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-3-3-0" | tee -a ${LOG}

cd ${CWD}

###---------------------###
###--- add new table ---###
###---------------------###

date | tee -a ${LOG}
echo "--- Creating new table" | tee -a ${LOG}

# create table, add default values for columns, & add indexes, keys, triggers

${SCHEMA}/table/SEQ_Sequence_Assoc_create.object | tee -a ${LOG}
${SCHEMA}/default/SEQ_Sequence_Assoc_bind.object | tee -a ${LOG}
${SCHEMA}/index/SEQ_Sequence_Assoc_create.object | tee -a ${LOG}
${SCHEMA}/key/SEQ_Sequence_Assoc_create.object | tee -a ${LOG}
${SCHEMA}/trigger/SEQ_Sequence_Assoc_create.object | tee -a ${LOG}

# grant permissions on new table

${PERMS}/public/table/SEQ_Sequence_Assoc_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/SEQ_Sequence_Assoc_grant.object | tee -a ${LOG}

###-------------------------------------------------###
###--- revisions to existing database components ---###
###-------------------------------------------------###

date | tee -a ${LOG}
echo "--- Foreign key additions" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

sp_foreignkey SEQ_Sequence_Assoc, MGI_User, _CreatedBy_key
go
sp_foreignkey SEQ_Sequence_Assoc, MGI_User, _ModifiedBy_key
go
sp_foreignkey SEQ_Sequence_Assoc, SEQ_Sequence, _Sequence_key_1
go
sp_foreignkey SEQ_Sequence_Assoc, SEQ_Sequence, _Sequence_key_2
go
sp_foreignkey SEQ_Sequence_Assoc, VOC_Term, _Qualifier_key
go
EOSQL

date | tee -a ${LOG}
echo "--- Trigger revisions" | tee -a ${LOG}

${SCHEMA}/trigger/SEQ_Sequence_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/SEQ_Sequence_create.object | tee -a ${LOG}
${SCHEMA}/trigger/VOC_Term_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/VOC_Term_create.object | tee -a ${LOG}

###-----------------------------------###
###--- add new biotype translation ---###
###-----------------------------------###
date | tee -a ${LOG}
echo "--- Running biotype translation load" | tee -a ${LOG}

${TRANSLATIONLOAD}/translationload.csh /mgi/all/wts_projects/9300/9305/biotype_translationload/input/biotypes.config | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
