#!/bin/csh -fx

#
# triggers:  from 161 ==> 
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

echo "--- triggers/view ---"

cat - <<EOSQL | ${MGI_DBUTILS}/bin/doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

truncate table MGI_AttributeHistory
go

drop view MGI_Set_CloneLibrary_View
go

drop trigger ACC_LogicalDB_Update
go

drop trigger BIB_Refs_Update
go

drop trigger GXD_Genotype_Update
go

drop trigger GXD_StructureClosure_Insert
go

drop trigger GXD_StructureClosure_Update
go

drop trigger MGI_Translation_InsUpd
go

drop trigger MLD_Expt_Marker_Insert
go

drop trigger MLD_Expts_Update
go

drop trigger MLD_FISH_Insert
go

drop trigger MLD_FISH_Update
go

drop trigger MLD_Hybrid_Insert
go

drop trigger MLD_Hybrid_Update
go

drop trigger MLD_InSitu_Insert
go

drop trigger MLD_InSitu_Update
go

drop trigger SEQ_Sequence_Insert
go

drop trigger SEQ_Sequence_Update
go

checkpoint
go

quit

EOSQL

echo "--- trigger ---"

${MGD_DBSCHEMADIR}/trigger/trigger_drop.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/trigger_create.csh | tee -a ${LOG}

echo "--- procedure ---"

${MGD_DBSCHEMADIR}/procedure/SEQ_deleteByCreatedBy_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_deleteByCreatedBy_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---"
#${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

