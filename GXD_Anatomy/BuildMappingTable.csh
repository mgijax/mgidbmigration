#!/bin/csh -fx

#
# Build the new MGI_EMAPS_Mapping table
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

#
# Migrate database structures
#

date | tee -a ${LOG}

echo '---Create table, indexes, keys' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/MGI_EMAPS_Mapping_drop.object
${MGD_DBSCHEMADIR}/table/MGI_EMAPS_Mapping_create.object

${MGD_DBSCHEMADIR}/key/MGI_EMAPS_Mapping_create.object

${MGD_DBSCHEMADIR}/index/MGI_EMAPS_Mapping_create.object

echo '---MGI_EMAPS_Maping' | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/default/MGI_EMAPS_Mapping_unbind.object
${MGD_DBSCHEMADIR}/default/MGI_EMAPS_Mapping_bind.object

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---" | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Update MGI_Tables and MGI_Columns ---" | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

exec MGI_Table_Column_Cleanup
go

EOSQL

date | tee -a ${LOG}
