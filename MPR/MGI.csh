#!/bin/csh -f

#
# Migration for TR 6520
#
# Defaults:       6
# Procedures:   121
# Rules:          5
# Triggers:     156
# User Tables:  183
# Views:        226

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
#load_db.csh ${DBSERVER} mgd_wi2 /extra2/sybase/mgi3.2.backup
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup

# update schema tag
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

drop index MGI_Note.idx_Object_MGI_Note_key
go

quit

EOSQL

./loadVoc.csh | tee -a ${LOG}
./mgivoc.csh | tee -a ${LOG}
./mgiallele.csh | tee -a ${LOG}
./mgiallelepair.csh | tee -a ${LOG}
./mgiassociation.csh | tee -a ${LOG}
./mgiheader.csh | tee -a ${LOG}
./mgiref.csh | tee -a ${LOG}

${newmgddbschema}/reconfig.csh | tee -a ${LOG}
${newmgddbperms}/all_revoke.csh | tee -a ${LOG}
${newmgddbperms}/all_grant.csh | tee -a ${LOG}

./unmigratedAlleleState.py | tee -a ${LOG}
./allelecombination.csh | tee -a ${LOG}
./genotypeorder.csh | tee -a ${LOG}
./mutantescell.csh | tee -a ${LOG}
./mpannotations.csh | tee -a ${LOG}
./splitNotes.py | tee -a ${LOG}
./convertNotes.py | tee -a ${LOG}

${ALLLABELLOAD}/alllabel.sh | tee -a ${LOG}
${MRKREFLOAD}/mrkref.sh | tee -a ${LOG}
${VOCLOAD}/runDAGIncLoad.sh MP.config | tee -a ${LOG}

#
# for testing purposes only
./loadtestcellline.py

#
# not needed anymore; headers are loaded via VOCLOAD
#./vocheader.csh | tee -a ${LOG}
#

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

drop table VOC_Synonym
go

drop view ALL_Reference_View
go

drop view ALL_Reference_Additional_View
go

drop view ALL_Reference_Molecular_View
go

drop view ALL_Reference_Original_View
go

drop view ALL_Note_View
go

drop view ALL_Note_General_View
go

drop view ALL_Note_Molecular_View
go

drop view ALL_Note_Nomenclature_View
go

drop view ALL_Note_Promoter_View
go

drop view ALL_Synonym_View
go

drop view ALL_Type_Summary_View
go

drop procedure ALL_updateReference
go

drop procedure GXD_loadGenoCacheAll
go

drop procedure GXD_loadGenoCacheByGenotype
go

EOSQL

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

drop table ALL_Allele_Old
go

drop table ALL_CellLine_Old
go

drop table GXD_AllelePair_Old
go

drop table GXD_AlleleGenotype_Old
go

exec MGI_Table_Column_Cleanup
go

EOSQL

#./mgiradar.csh | tee -a ${LOG}

date | tee -a  ${LOG}
