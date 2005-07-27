#!/bin/csh -f

#
# Migration for 3.3 (OMIM, Images)
#
# Defaults:       6
# Procedures:   123
# Rules:          5
# Triggers:     158
# User Tables:  181
# Views:        229

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup

# update schema tag
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

./mgiindex.csh | tee -a ${LOG}
./deleteNotes.py | tee -a ${LOG}
./loadVoc.csh | tee -a ${LOG}
./mgiomim.csh | tee -a ${LOG}
./mgiimage.csh | tee -a ${LOG}
./mgidag.csh | tee -a ${LOG}
./mgicache.csh | tee -a ${LOG}

${newmgddbschema}/procedure/MGI_checkUserRole_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/MGI_checkUserRole_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

drop table IMG_Image_Old
go

drop table IMG_ImageNote
go

quit

EOSQL

${newmgddbschema}/reconfig.csh | tee -a ${LOG}
${newmgddbperms}/all_revoke.csh | tee -a ${LOG}
${newmgddbperms}/all_grant.csh | tee -a ${LOG}

${VOCDAGLOAD} GO.config | tee -a ${LOG}
${VOCDAGLOAD} MP.config | tee -a ${LOG}
${VOCDAGLOAD} MA.config | tee -a ${LOG}
${SEQCACHELOAD}/seqmarker.csh | tee -a ${LOG}
${DBUTILSBINDIR}/updateStatisticsAll.csh ${newmgddbschema} | tee -a ${LOG}

date | tee -a  ${LOG}

