#!/bin/csh -fx

# clean up indexes
#

setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#setenv MGICONFIG /usr/local/mgi/test/mgiconfig
#source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG

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


