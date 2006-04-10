#!/bin/csh -fx

# for SNP

cd `dirname $0` && source ./Configuration

source ${newsnpdbschema}/Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${MGIDBUTILSDIR}/bin/updateSchemaVersion.csh ${SNP_DBSERVER} ${SNP_DBNAME} ${SNP_SCHEMA_TAG} | tee -a ${LOG}
${newsnpdbschema}/view/SNP_Summary_View_drop.object | tee -a ${LOG}
${newsnpdbschema}/view/SNP_Summary_View_create.object | tee -a ${LOG}
${newsnpdbperms}/public/view/SNP_Summary_View_grant.object | tee -a ${LOG}

date | tee -a  ${LOG}

