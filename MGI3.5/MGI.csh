#!/bin/csh -fx

#
# Migration for 3.5 (TR 7062)
#
# Defaults:       6
# Procedures:   107
# Rules:          5
# Triggers:     157
# User Tables:  183
# Views:        212
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

./mgiindex.csh | tee -a ${LOG}
./mgigo.csh | tee -a ${LOG}
./mgiref.csh | tee -a ${LOG}
./mgigxd.csh | tee -a ${LOG}
./mgihmd.csh | tee -a ${LOG}
./mgisnp.csh | tee -a ${LOG}
./updateSuperscripts.py | tee -a ${LOG}

# 1.5 hours
./mgiseqraw.csh | tee -a ${LOG}

./mgiunists.csh | tee -a ${LOG}

# SEQ_Marker_Cache 
./mgiseqmarker.csh | tee -a ${LOG}

# cache tables
${LOCCACHELOAD} | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

update ACC_ActualDB
set name = "UniProt",
url = "http://www.pir.uniprot.org/cgi-bin/upEntry?id=@@@@"
where _ActualDB_key in (19, 45)
go

drop table GXD_Antibody_Old
go

drop table GXD_Antigen_Old
go

drop table VOC_Annot_Old
go

drop table VOC_AnnotType_Old
go

drop table SEQ_Sequence_Old
go

drop table MLD_Marker
go

drop view ACC_ActualDB_Summary_View
go

drop view ACC_Reference_View
go

drop view GXD_AlleleGenotype_View
go

drop view MGI_AttributeHistory_View
go

drop view MGI_Set_CloneSet_View
go

drop view MGI_VocAssociation_View
go

drop view MLD_Hit_View
go

drop view MLD_Marker_View
go

drop view MRK_History_Ref_View
go

drop view NOM_Acc_View
go

drop view PRB_Primer_View
go

drop view PRB_View
go

drop view VOC_AnnotType_View
go

drop view VOC_GOMarker_AnnotType_View
go

drop view VOC_PSGenotype_AnnotType_View
go

drop view WKS_Rosetta_View
go

drop procedure ACC_delete_byObject
go

drop procedure ACC_fetch_byLogical
go

drop procedure ACC_insert_byOrganism
go

drop procedure ACC_resetMax
go

drop procedure ALL_processAlleleCombAll
go

drop procedure ALL_processAlleleCombByAllele
go

drop procedure ALL_processAlleleCombByMarker
go

drop procedure ALL_processAlleleCombination
go

drop procedure BIB_byJnum
go

drop procedure HMD_getOxfordGrid
go

drop procedure MGI_insertNote
go

drop procedure MRK_addChromosome
go

drop procedure SEQ_deleteAllDummy
go

drop procedure SEQ_deriveRepAll
go

drop procedure VOC_setAccIDsPrivateFlag
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

