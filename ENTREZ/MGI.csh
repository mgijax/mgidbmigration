#!/bin/csh -f

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use ${DBNAME}
go

drop table DP_LL
go

drop table DP_LLAcc
go

drop table DP_LLCit
go

drop table DP_LLHomology
go

drop table DP_LLRef
go

drop table WRK_LLBucket0
go

drop table WRK_LLBucket10
go

drop table WRK_LLExcludeLLIDs
go

drop table WRK_LLExcludeNonGenes
go

drop table WRK_LLExcludeSeqIDs
go

drop table WRK_LLHumanDuplicates
go

drop table WRK_LLHumanGDBIDsToAdd
go

drop table WRK_LLHumanLLIDsToAdd
go

drop table WRK_LLHumanMappingUpdates
go

drop table WRK_LLHumanNomenUpdates
go

drop table WRK_LLHumanRefSeqIDsToAdd
go

drop table WRK_LLMGIHumanDuplicates
go

drop table WRK_LLMGIRatDuplicates
go

drop table WRK_LLRatDuplicates
go

drop table WRK_LLRatLLIDsToAdd
go

drop table WRK_LLRatMappingUpdates
go

drop table WRK_LLRatNomenUpdates
go

drop table WRK_LLRatRATMAPIDsToAdd
go

drop table WRK_LLRatRGDIDsToAdd
go

checkpoint
go

quit

EOSQL

#${newradardbschema}/table/DP_EntrezGene_Info_create.object | tee -a ${LOG}
#${newradardbschema}/index/DP_EntrezGene_Info_create.object | tee -a ${LOG}
#${newradardbperms}/public/table/DP_EntrezGene_Info_grant.object | tee -a ${LOG}

#${newradardbschema}/table/DP_EntrezGene_Synonym_create.object | tee -a ${LOG}
#${newradardbschema}/index/DP_EntrezGene_Synonym_create.object | tee -a ${LOG}
#${newradardbperms}/public/table/DP_EntrezGene_Synonym_grant.object | tee -a ${LOG}

#${newradardbschema}/table/DP_EntrezGene_DBXRef_create.object | tee -a ${LOG}
#${newradardbschema}/index/DP_EntrezGene_DBXRef_create.object | tee -a ${LOG}
#${newradardbperms}/public/table/DP_EntrezGene_DBXRef_grant.object | tee -a ${LOG}

#${newradardbschema}/table/DP_EntrezGene_PubMed_create.object | tee -a ${LOG}
#${newradardbschema}/index/DP_EntrezGene_PubMed_create.object | tee -a ${LOG}
#${newradardbperms}/public/table/DP_EntrezGene_PubMed_grant.object | tee -a ${LOG}

#${newradardbschema}/table/DP_EntrezGene_RefSeq_create.object | tee -a ${LOG}
#${newradardbschema}/index/DP_EntrezGene_RefSeq_create.object | tee -a ${LOG}
#${newradardbperms}/public/table/DP_EntrezGene_RefSeq_grant.object | tee -a ${LOG}

${newradardbschema}/table/DP_HomoloGene_create.object | tee -a ${LOG}
${newradardbschema}/index/DP_HomoloGene_create.object | tee -a ${LOG}
${newradardbperms}/public/table/DP_HomoloGene_grant.object | tee -a ${LOG}

${newradardbschema}/table/WRK_EntrezGene_Bucket0_create.object | tee -a ${LOG}
${newradardbschema}/index/WRK_EntrezGene_Bucket0_create.object | tee -a ${LOG}
${newradardbperms}/public/table/WRK_EntrezGene_Bucket0_grant.object | tee -a ${LOG}

${newradardbschema}/table/WRK_EntrezGene_EGSet_create.object | tee -a ${LOG}
${newradardbschema}/index/WRK_EntrezGene_EGSet_create.object | tee -a ${LOG}
${newradardbperms}/public/table/WRK_EntrezGene_EGSet_grant.object | tee -a ${LOG}

${newradardbschema}/table/WRK_EntrezGene_ExcludeA_create.object | tee -a ${LOG}
${newradardbschema}/index/WRK_EntrezGene_ExcludeA_create.object | tee -a ${LOG}
${newradardbperms}/public/table/WRK_EntrezGene_ExcludeA_grant.object | tee -a ${LOG}

${newradardbschema}/table/WRK_EntrezGene_ExcludeB_create.object | tee -a ${LOG}
${newradardbschema}/index/WRK_EntrezGene_ExcludeB_create.object | tee -a ${LOG}
${newradardbperms}/public/table/WRK_EntrezGene_ExcludeB_grant.object | tee -a ${LOG}

${newradardbschema}/table/WRK_EntrezGene_ExcludeC_create.object | tee -a ${LOG}
${newradardbschema}/index/WRK_EntrezGene_ExcludeC_create.object | tee -a ${LOG}
${newradardbperms}/public/table/WRK_EntrezGene_ExcludeC_grant.object | tee -a ${LOG}

${newradardbschema}/table/WRK_EntrezGene_Mapping_create.object | tee -a ${LOG}
${newradardbschema}/index/WRK_EntrezGene_Mapping_create.object | tee -a ${LOG}
${newradardbperms}/public/table/WRK_EntrezGene_Mapping_grant.object | tee -a ${LOG}

${newradardbschema}/table/WRK_EntrezGene_MGISet_create.object | tee -a ${LOG}
${newradardbschema}/index/WRK_EntrezGene_MGISet_create.object | tee -a ${LOG}
${newradardbperms}/public/table/WRK_EntrezGene_MGISet_grant.object | tee -a ${LOG}

${newradardbschema}/table/WRK_EntrezGene_Nomen_create.object | tee -a ${LOG}
${newradardbschema}/index/WRK_EntrezGene_Nomen_create.object | tee -a ${LOG}
${newradardbperms}/public/table/WRK_EntrezGene_Nomen_grant.object | tee -a ${LOG}

date | tee -a  ${LOG}
