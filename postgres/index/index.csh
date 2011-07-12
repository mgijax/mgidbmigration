#!/bin/csh -fx

# clean up indexes
#

cd `dirname $0` && source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}

cat - <<EOSQL | ${MGI_DBUTILS}/bin/doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0

use ${MGD_DBNAME}
go

drop index MGI_Columns.index_table_column
go

drop index MGI_Set.index_Set_key
go

drop index MGI_Set.index_MGIType_key
go

drop index MGI_Set.index_name
go

drop index MGI_SetMember.index_SetMember_key
go

drop index MGI_SetMember.index_SetObject_key
go

drop index MGI_SetMember.index_ObjectSet_key
go

drop index WKS_Rosetta.index_Marker_key
go

drop index WKS_Rosetta.index_Rosetta_key
go

checkpoint
go

quit

EOSQL

echo "--- index ---"
${MGD_DBSCHEMADIR}/index/MGI_Columns_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/MGI_Set_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/MGI_SetMember_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/WKS_Rosetta_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---"
#${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}


