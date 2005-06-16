#!/bin/csh -f

#
# Migration for 3.3 (OMIM, Images)
#
# Defaults:       6
# Procedures:   122
# Rules:          5
# Triggers:     156
# User Tables:  181
# Views:        228

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup
#load_db.csh ${DBSERVER} ${DBNAME} /extra2/sybase/mgd322.backup

# update schema tag
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

# 3.22 stuff
${newmgddbschema}/procedure/ALL_processAlleleCombination_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/ALL_processAlleleCombination_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/ALL_convertAllele_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/ALL_convertAllele_create.object | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/ALL_convertAllele_grant.object | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/ALL_processAlleleCombination_grant.object | tee -a ${LOG}

# 3.3 stuff

./loadVoc.csh | tee -a ${LOG}
./mgiomim.csh | tee -a ${LOG}
./mgiimage.csh | tee -a ${LOG}

${newmgddbschema}/key/IMG_drop.logical | tee -a ${LOG}
${newmgddbschema}/key/IMG_create.logical | tee -a ${LOG}
${newmgddbschema}/key/ACC_MGIType_drop.object | tee -a ${LOG}
${newmgddbschema}/key/ACC_MGIType_create.object | tee -a ${LOG}
${newmgddbschema}/key/MGI_User_drop.object | tee -a ${LOG}
${newmgddbschema}/key/MGI_User_create.object | tee -a ${LOG}
${newmgddbschema}/key/VOC_Term_drop.object | tee -a ${LOG}
${newmgddbschema}/key/VOC_Term_create.object | tee -a ${LOG}

${newmgddbperms}/public/view/perm_grant.csh | tee -a ${LOG}
${newmgddbperms}/public/table/IMG_grant.logical | tee -a ${LOG}
${newmgddbperms}/public/table/MRK_grant.logical | tee -a ${LOG}

${newmgddbperms}/curatorial/table/IMG_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/MRK_grant.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/IMG_grant.logical | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

drop table IMG_Image_Old
go

drop table IMG_ImageNote
go

quit

EOSQL

date | tee -a  ${LOG}
