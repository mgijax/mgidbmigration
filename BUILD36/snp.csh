#!/bin/csh -fx

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a  ${LOG}


#
# nardol DEV1_SNP..snp drop/create SNP_ConsensusSnp_Marker table, create
# indexes. There is a new set of indexes on this table 
# 
${BE_SERVER_SCHEMADIR}/table/SNP_ConsensusSnp_Marker_drop.object | tee -a  ${LOG}

${BE_SERVER_SCHEMADIR}/table/SNP_ConsensusSnp_Marker_create.object | tee -a  ${LOG}
${BE_SERVER_SCHEMADIR}/key/SNP_ConsensusSnp_Marker_create.object | tee -a  ${LOG}
${BE_SERVER_SCHEMADIR}/index/SNP_ConsensusSnp_Marker_create.object | tee -a  ${LOG}

# set public permissions
${BE_SERVER_PERMSDIR}/public/table/SNP_ConsensusSnp_Marker_grant.object | tee -a  ${LOG}

#
# nardol DEV1_SNP..snp drop/create MRK_Location_Cache table, create indexes.
# We have added _Marker_Type_key and index
#
${BE_SERVER_SCHEMADIR}/table/MRK_Location_Cache_drop.object | tee -a ${LOG}

${BE_SERVER_SCHEMADIR}/table/MRK_Location_Cache_create.object | tee -a ${LOG}
${BE_SERVER_SCHEMADIR}/index/MRK_Location_Cache_create.object | tee -a ${LOG}

# set public permissions
${BE_SERVER_PERMSDIR}/public/table/MRK_Location_Cache_grant.object | tee -a  ${LOG}
date | tee -a  ${LOG}
