#!/bin/csh -fx

if ( ${?MGICONFIG} == 0 ) then
       setenv MGICONFIG /usr/local/mgi/scrum-dog2/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

${MGD_DBSCHEMADIR}/table/GXD_Expression_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/table/GXD_Expression_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_Expression_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/default/GXD_Expression_bind.object | tee -a $LOG
${MGD_DBSCHEMADIR}/index/GXD_Expression_create.object | tee -a $LOG


${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

${MGICACHELOAD}/gxdexpression.csh | tee -a ${LOG}

date | tee -a ${LOG}

