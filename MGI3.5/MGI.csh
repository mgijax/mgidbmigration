#!/bin/csh -fx

#
# Migration for 3.5 (TR 7062)
#
# Defaults:       6
# Procedures:   124
# Rules:          5
# Triggers:     159
# User Tables:  183
# Views:        229
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
# load a backup
load_db.csh ${DBSERVER} ${DBNAME} /extra2/sybase/mgd344.backup

# update schema tag
${MGIDBUTILSDIR}/bin/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
${MGIDBUTILSDIR}/bin/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

./mgigo.csh | tee -a ${LOG}
./mgiref.csh | tee -a ${LOG}

# 1.5 hours
./mgiseqraw.csh | tee -a ${LOG}

# 
./mgiseqmarker.csh | tee -a ${LOG}
./mgiunists.csh | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

update ACC_ActualDB i
set name = "UniProt",
url = 'http://www.pir.uniprot.org/cgi-bin/upEntry?id=@@@@'
where _ActualDB_key in (19, 45)
go

drop table VOC_Annot_Old
go

drop table VOC_AnnotType_Old
go

drop table SEQ_Sequence_Old
go

drop table PRB_Strain_Old
go

exec MGI_Table_Column_Cleanup
go

quit

EOSQL

${newmgddbschema}/reconfig.csh | tee -a ${LOG}
${newmgddbperms}/all_revoke.csh | tee -a ${LOG}
${newmgddbperms}/all_grant.csh | tee -a ${LOG}

${OMIMCACHELOAD} | tee -a ${LOG}

date | tee -a  ${LOG}

