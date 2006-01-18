#!/bin/csh -f

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}

#
# RADAR database stuff
#

source ${newradardbschema}/Configuration

echo "loading radar backup" | tee -a  ${LOG}
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/radar.backup | tee -a  ${LOG}

echo "updating public version and schema version" | tee -a  ${LOG}
cat - <<EOSQL | doisql.csh $0

use ${DBNAME}
go

update MGI_dbinfo set public_version = "${SCHEMAVERSION}"
go

update MGI_dbinfo set schema_version = "${SCHEMAVERSION}"
go

checkpoint
go

quit

EOSQL

echo " drop/create radar table, key, index, default, view" | tee -a  ${LOG}
${newradardbschema}/table/MGI_SNP_drop.logical | tee -a  ${LOG}
${newradardbschema}/table/MGI_SNP_create.logical | tee -a  ${LOG}
${newradardbschema}/key/MGI_SNP_create.logical | tee -a  ${LOG}
${newradardbschema}/index/MGI_SNP_create.logical | tee -a  ${LOG}
${newradardbschema}/default/MGI_SNP_bind.logical | tee -a  ${LOG}

echo "creating radar perms" | tee -a  ${LOG}
${newradardbperms}/developers/table/MGI_SNP_grant.logical | tee -a  ${LOG}
${newradardbperms}/public/table/MGI_SNP_grant.logical | tee -a  ${LOG}

date | tee -a  ${LOG}
