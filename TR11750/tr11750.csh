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

#/usr/local/mgi/live/dbutils/mgd/mgddbschema/objectCounter.sh | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a ${LOG}

use $MGD_DBNAME
go

drop procedure MGI_createReferenceSet
go

drop procedure MGI_createRestrictedMolSegSet
go

drop procedure MGI_createRestrictedSeqSet
go

--
-- 1003 IMAGE                                              
-- 1004 NIA                                                
-- 1005 RIKEN                                              
-- 1006 RPCI-23                                            
-- 1007 RPCI-24                                            
-- 1008 RIKEN (FANTOM)         
-- 1042 IMSR Providers                                     
-- 1046 Load References                                    
-- 1047 Personal References                                
-- 1048 GenBank References                                 
-- 1049 Book References                                    
-- 1050 Submission References                              
-- 1051 Curatorial References           

select * from MGI_Set 
where _Set_key >= 1046 or _Set_key <= 1008 or _Set_key in (1042)
go

delete from MGI_Set
where _Set_key >= 1046 or _Set_key <= 1008 or _Set_key in (1042)
go

EOSQL
date | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/trigger/trigger_drop.csh | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/trigger/trigger_create.csh | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/procedure/procedure_drop.csh | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/procedure/procedure_create.csh | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/view/view_drop.csh | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/view/view_create.csh | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/key/key_drop.csh | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/key/key_create.csh | tee -a ${LOG}

#${MGI_DBUTILS}/bin/updateSchemaDoc.csh ${MGD_DBSERVER} ${MGD_DBNAME} | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

date | tee -a ${LOG}

