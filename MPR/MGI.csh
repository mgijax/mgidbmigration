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

./mgivoc.csh | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

drop table ALL_Inheritance_Mode
go

drop table ALL_Molecular_Mutation
go

drop table ALL_Status
go

drop table ALL_Type
go

drop table ALL_Note
go

drop table ALL_NoteType
go

drop table ALL_Reference
go

drop table ALL_ReferenceType
go

drop table ALL_Synonym
go

drop view ALL_Reference_View
go

drop view ALL_Note_View
go

drop view ALL_Synonym_View
go

EOSQL

date | tee -a  ${LOG}
