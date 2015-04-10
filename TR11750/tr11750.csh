#!/bin/csh -fx

if ( ${?MGICONFIG} == 0 ) then
       setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

# COMMENT OUT BEFORE RUNNING ON PRODUCTION
# ${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/scrum-dog/mgd_dog.backup

date | tee -a ${LOG}

/usr/local/mgi/live/dbutils/mgd/mgddbschema/objectCounter.sh | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a ${LOG}

use $MGD_DBNAME
go

drop view MGI_Set_ResMolSeg_View
go

drop view MGI_Set_ResSequence_View
go

drop procedure ACC_reserveMGIBlock
go

drop procedure GXD_ComputePrintNamesFrom
go

drop procedure GXD_SetStructDescPrintName
go

drop procedure GXD_orderGenotypesByUser
go

drop procedure VOC_getGOInferredFrom
go

drop procedure VOC_reorderTerms
go

drop procedure MGI_createReferenceSet
go

drop procedure MGI_createRestrictedMolSegSet
go

drop procedure MGI_createRestrictedSeqSet
go

--
-- most of < 1024 no longer used
-- can be done *after* April 27 when production WI is turned OFF
--
-- keep:
-- 'Actual DB' / 1009
-- 'Clone Collection (all)' / 1021
-- 'IMAGE' / 1003
-- 'NIA' / 1004
-- 'RIKEN' / 1005
-- 'RPCI-23' / 1006
-- 'RPCI-24' / 1007
-- 'RIKEN (FANTOM)' / 1008
--
-- remove:
-- 'GXD Expression Link' / 1046
--

select * from MGI_Set 
where _Set_key not in (1003,1004,1005,1006,1007,1008,1009,1021)
and (_Set_key < 1024 or _Set_key = 1046)
go

delete from MGI_Set
where _Set_key not in (1003,1004,1005,1006,1007,1008,1009,1021)
and (_Set_key < 1024 or _Set_key = 1046)
go

EOSQL
date | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/trigger/trigger_drop.csh | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/trigger/trigger_create.csh | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/procedure/procedure_drop.csh | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/procedure/procedure_create.csh | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/key/key_drop.csh | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/key/key_create.csh | tee -a ${LOG}

${MGI_DBUTILS}/bin/updateSchemaDoc.csh ${MGD_DBSERVER} ${MGD_DBNAME} | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

date | tee -a ${LOG}

