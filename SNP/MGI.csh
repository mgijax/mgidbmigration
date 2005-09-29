#!/bin/csh -f

#
# Migration for 3.4 (SNP)
# Defaults: 6
# Procedures: 123   
# Rules: 5
# Triggers: 158
# User Tables: 190
# Views: 230

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}

#
# RADAR database stuff
#

./radar.csh

#
# MGD database stuff
#

echo "turnonbulkcopy" 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

echo "loading backup"
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}

# update schema tag
echo "updatePublicVersion"
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
echo "updateSchemaVersion"
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

date | tee -a  ${LOG}

echo " create mgd table, key, index, default, view"
${newmgddbschema}/table/SNP_create.logical | tee -a ${LOG}
${newmgddbschema}/key/SNP_create.logical | tee -a ${LOG}
${newmgddbschema}/index/SNP_create.logical | tee -a ${LOG}
${newmgddbschema}/default/SNP_bind.logical | tee -a ${LOG}
${newmgddbschema}/view/SNP_Summary_View_create.object | tee -a ${LOG}

${newmgddbschema}/view/BIB_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/BIB_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_NoteType_Genotype_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_NoteType_Genotype_View_create.object | tee -a ${LOG}

echo " create mgd perms"
${newmgddbperms}/public/table/SNP_grant.logical | tee -a ${LOG}
${newmgddbperms}/public/view/SNP_Summary_View_grant.object | tee -a ${LOG}
${newmgddbperms}/public/view/BIB_View_grant.object | tee -a ${LOG}
${newmgddbperms}/public/view/MGI_NoteType_Genotype_View_grant.object | tee -a ${LOG}

echo "PIRSF: human/rat" | tee -a ${LOG}
./mgicache.csh | tee -a ${LOG} | tee -a ${LOG}

echo "HomoloGene" | tee -a ${LOG}
./mgihomologene.csh | tee -a ${LOG}

echo "Journal Vocabulary" | tee -a ${LOG}
./journal.csh | tee -a ${LOG}

#echo "schema reconfig; revoke/grant all"
#${newmgddbschema}/reconfig.csh | tee -a ${LOG}
#${newmgddbperms}/all_revoke.csh | tee -a ${LOG}
#${newmgddbperms}/all_grant.csh | tee -a ${LOG}

#${DBUTILSBINDIR}/updateStatisticsAll.csh ${newmgddbschema} | tee -a ${LOG}

date | tee -a  ${LOG}

