#!/bin/csh -f

#
# Migration for Assembly Coordinates
#
# updated:  
# Defaults:	  6
# Procedures:	110
# Rules:	  5
# Triggers:	156
# User Tables:	190
# Views:	198
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
load_db.csh ${DBSERVER} ${DBNAME} mgd_3.01.backup

date | tee -a  ${LOG}

########################################

echo "Update MGI DB Info..." | tee -a  ${LOG}
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

# order is important!
./loadVoc.csh | tee -a ${LOG}
./mgiassembly.csh | tee -a ${LOG}

${DBUTILSBINDIR}/dev/reconfig_mgd.csh ${newmgddb} | tee -a ${LOG}

date | tee -a  ${LOG}
