#!/bin/csh -fx

#
# MRK_Location_Cache
#

cd `dirname $0` && source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /lindon/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

${MGI_DBUTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.42" | tee -a ${LOG}
${MGI_DBUTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-4-2-1" | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- logical DB (TR10819) ---"

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update ACC_ActualDB 
set url = 'http://www.ncbi.nlm.nih.gov/gene/@@@@' 
where _LogicalDB_key in (55,59)
go

EOSQL

date | tee -a ${LOG}
echo "--- tables ---"

${MGD_DBSCHEMADIR}/table/MRK_Location_Cache_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/MRK_Location_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/MRK_Location_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/MRK_Location_Cache_bind.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MGI_Organism_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MGI_Organism_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/MRK_reloadLocation_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_reloadLocation_create.object | tee -a ${LOG}

${SNPBE_DBSCHEMADIR}/table/MRK_Location_Cache_drop.object | tee -a ${LOG}
${SNPBE_DBSCHEMADIR}/table/MRK_Location_Cache_create.object | tee -a ${LOG}
${SNPBE_DBSCHEMADIR}/index/MRK_Location_Cache_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---"
#${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
${SNPBE_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

