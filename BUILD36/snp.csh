#!/bin/csh -f

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a  ${LOG}


#
# drop old SNP_ConsensusSnp_Marker table
# 
${oldsnpdbschema}/table/SNP_ConsensusSnp_Marker_drop.object | tee -a  ${LOG}

#
# create new SNP_ConsensusSnp_Marker table, key, index
#
${SNPBE_DBSCHEMADIR}/table/SNP_ConsensusSnp_Marker_create.object | tee -a  ${LOG}
${SNPBE_DBSCHEMADIR}/key/SNP_ConsensusSnp_Marker_create.object | tee -a  ${LOG}
${SNPBE_DBSCHEMADIR}/index/SNP_ConsensusSnp_Marker_create.object | tee -a  ${LOG}

#
# set public permissions
#
${SNPBE_DBPERMSDIR}/public/table/SNP_ConsensusSnp_Marker_grant.object | tee -a  ${LOG}

date | tee -a  ${LOG}
