#!/bin/csh -fx

#
# Migration for 3.41 (TR 7119)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
#load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup

date | tee -a  ${LOG}

########################################

# TR 6915

${newmgddbschema}/view/HMD_Summary_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/HMD_Summary_View_create.object | tee -a ${LOG}
${newmgddbperms}/public/view/HMD_Summary_View_grant.object | tee -a ${LOG}

date | tee -a  ${LOG}

