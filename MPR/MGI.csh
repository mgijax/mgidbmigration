#!/bin/csh -f

#
# Migration for TR 6520
#
# Defaults:       6
# Procedures:   114
# Rules:          5
# Triggers:     166
# User Tables:  189
# Views:        215

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup

# update schema tag
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

./loadVoc.csh | tee -a ${LOG}
./mgimlc.csh | tee -a ${LOG}
./mgistrain.csh | tee -a ${LOG}
./mgiperm.csh | tee -a ${LOG}

date | tee -a  ${LOG}
