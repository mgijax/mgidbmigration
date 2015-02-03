#!/bin/csh -fx

#
# make MGI_User.login varchar(50)
#


cd `dirname $0` && source ../Configuration
setenv CWD `pwd`        # current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}
use ${MGD_DBNAME}
go

alter table MGI_User modify login varchar(50)
go

EOSQL

${MGD_DBSCHEMADIR}/procedure/ALL_createWildType_drop.object
${MGD_DBSCHEMADIR}/procedure/ALL_createWildType_create.object
${MGD_DBSCHEMADIR}/procedure/ALL_insertAllele_drop.object
${MGD_DBSCHEMADIR}/procedure/ALL_insertAllele_create.object
${MGD_DBSCHEMADIR}/procedure/ALL_postMP_drop.object
${MGD_DBSCHEMADIR}/procedure/ALL_postMP_create.object
${MGD_DBSCHEMADIR}/procedure/GXD_orderGenotypesByUser_drop.object
${MGD_DBSCHEMADIR}/procedure/GXD_orderGenotypesByUser_create.object
${MGD_DBSCHEMADIR}/procedure/MGI_checkUserRole_drop.object
${MGD_DBSCHEMADIR}/procedure/MGI_checkUserRole_create.object
${MGD_DBSCHEMADIR}/procedure/SEQ_deleteByCreatedBy_drop.object
${MGD_DBSCHEMADIR}/procedure/SEQ_deleteByCreatedBy_create.object
${MGD_DBSCHEMADIR}/procedure/VOC_deleteGOGAFRed_drop.object
${MGD_DBSCHEMADIR}/procedure/VOC_deleteGOGAFRed_create.object

date | tee -a ${LOG}

