#!/bin/csh -f

#
# Migration for 3.22 (TR 6840)
#
# Defaults:       6
# Procedures:   122
# Rules:          5
# Triggers:     156
# User Tables:  180
# Views:        226

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
#load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup

# update schema tag
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

${newmgddbschema}/procedure/ALL_processAlleleCombination_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/ALL_processAlleleCombination_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/ALL_convertAllele_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/ALL_convertAllele_create.object | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/ALL_convertAllele_grant.object | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/ALL_processAlleleCombination_grant.object | tee -a ${LOG}

date | tee -a  ${LOG}
