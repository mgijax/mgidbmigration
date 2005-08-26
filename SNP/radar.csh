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

echo "loading radar backup"
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/radar.backup

echo "updating public version and schema version"
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

echo " creating radar table, key, index, default, view"
${newradardbschema}/table/MGI_SNP_create.logical
${newradardbschema}/key/MGI_SNP_create.logical
${newradardbschema}/index/MGI_SNP_create.logical
${newradardbschema}/default/MGI_SNP_bind.logical

echo "creating radar perms"
${newradardbperms}/MGI_SNP_perm_grant.csh
