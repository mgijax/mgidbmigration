#!/bin/csh -f

#
# Migration for: RADAR
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'RADAR Migration...' | tee -a ${LOG}

#load_db.csh ${DBSERVER} ${RADARDB} /shire/sybase/radar.backup
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${RADARDB} ${RADARSCHEMA_TAG} | tee -a ${LOG}

${newradardbschema}/table/TXT_create.logical | tee -a ${LOG}
${newradardbschema}/default/TXT_bind.logical | tee -a ${LOG}
${newradardbschema}/index/TXT_create.logical | tee -a ${LOG}
${newradardbschema}/key/TXT_create.logical | tee -a ${LOG}
${newradardbschema}/trigger/TXT_create.logical | tee -a ${LOG}
${newradardbschema}/procedure/TXT_create.logical | tee -a ${LOG}
${newradardbperms}/public/table/TXT_grant.logical | tee -a ${LOG}
${newradardbperms}/public/procedure/TXT_grant.logical | tee -a ${LOG}

${newradardbschema}/table/VOC_create.logical | tee -a ${LOG}
${newradardbschema}/index/VOC_create.logical | tee -a ${LOG}
${newradardbschema}/key/VOC_create.logical | tee -a ${LOG}
${newradardbperms}/public/table/VOC_grant.logical | tee -a ${LOG}

date >> ${LOG}

