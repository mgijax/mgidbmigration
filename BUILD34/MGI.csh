#!/bin/csh -f

#
# Migration for Build 34
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup

########################################

${ENTREZGENELOAD}/mouse/load.csh | tee -a ${LOG}

# after mapping load...
${MRKCACHELOAD}/mrklocation.csh | tee -a ${LOG}
${MRKCACHELOAD}/mrkref.csh | tee -a ${LOG}

date | tee -a  ${LOG}

