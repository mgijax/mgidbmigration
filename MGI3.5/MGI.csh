#!/bin/csh -fx

#
# Migration for 3.5 (TR 7062)
#
# Defaults:       6
# Procedures:   123
# Rules:          5
# Triggers:     158
# User Tables:  190
# Views:        230
#

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

./mgigo.csh | tee -a ${LOG}

# 1.5 hours
./mgiseqraw.csh | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

drop table VOC_Annot_Old
go

drop table VOC_AnnotType_Old
go

drop table SEQ_Sequence_Old
go

quit

EOSQL

${newmgddbschema}/reconfig.csh | tee -a ${LOG}
${newmgddbperms}/all_revoke.csh | tee -a ${LOG}
${newmgddbperms}/all_grant.csh | tee -a ${LOG}

${OMIMCACHELOAD} | tee -a ${LOG}

date | tee -a  ${LOG}

