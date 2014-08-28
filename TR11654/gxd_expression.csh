#!/bin/csh -fx

#
# TR11756/GXD_Expression
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

sp_rename GXD_Expression, GXD_Expression_Old
go

EOSQL

${MGD_DBSCHEMADIR}/table/GXD_Expression_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

insert into GXD_Expression
select _Expression_key,
       _Assay_key,
        _Refs_key,
        _AssayType_key,
        _Genotype_key,
        _Marker_key,
        _Structure_key,
        null,
        expressed,
        age,
        ageMin,
        ageMax,
        isRecombinase,
        isForGXD,
        hasImage,
        creation_date,
        modification_date 
from GXD_Expression_Old
go

EOSQL
date | tee -a ${LOG}

date | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/GXD_Expression_bind.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/GXD_Expression_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Expression_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/BIB_Refs_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_AssayType_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Assay_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Genotype_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_AssayType_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Assay_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Genotype_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Structure_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/GXD_loadCacheAll_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_loadCacheAll_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_loadCacheByAssay_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_loadCacheByAssay_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_loadCacheByRef_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_loadCacheByRef_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MGI_resetAgeMinMax_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MGI_resetAgeMinMax_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/PRB_getStrainByReference_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/PRB_getStrainByReference_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/PRB_getStrainReferences_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/PRB_getStrainReferences_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

exec GXD_loadCacheAll
go

EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

select g._GelLane_key, g._Structure_key, ea.accID, ea._Object_key
from GXD_GelLaneStructure g, ACC_Accession sa, MGI_EMAPS_Mapping e, ACC_Accession ea
where g._Structure_key = sa._Object_key
and sa._LogicalDB_key = 1 
and sa._MGIType_key = 38 
and sa.accID = e.accID 
and e.emapsID = ea.accID 
and ea._MGIType_key = 13 
and ea.accID = 'EMAPS:1603915'
and g._GelLane_key = 151728

select g._Result_key, g._Structure_key, ea.accID, ea._Object_key
from GXD_ISResultStructure g, ACC_Accession sa, MGI_EMAPS_Mapping e, ACC_Accession ea
where g._Structure_key = sa._Object_key
and sa._LogicalDB_key = 1 
and sa._MGIType_key = 38 
and sa.accID = e.accID 
and e.emapsID = ea.accID 
and ea._MGIType_key = 13 
and ea.accID = 'EMAPS:1603915'

select g._GelLane_key, g._Structure_key
from GXD_GelLaneStructure g
where not exists (select 1 from ACC_Accession sa, MGI_EMAPS_Mapping e, ACC_Accession ea
where g._Structure_key = sa._Object_key
and sa._LogicalDB_key = 1 
and sa._MGIType_key = 38 
and sa.accID = e.accID 
and e.emapsID = ea.accID 
and ea._MGIType_key = 13 
)

select g._Result_key, g._Structure_key
from GXD_ISResultStructure g
where not exists (select 1 from ACC_Accession sa, MGI_EMAPS_Mapping e, ACC_Accession ea
where g._Structure_key = sa._Object_key
and sa._LogicalDB_key = 1 
and sa._MGIType_key = 38 
and sa.accID = e.accID 
and e.emapsID = ea.accID 
and ea._MGIType_key = 13 
)

select g._GelLane_key, g._Structure_key, ea.accID, ea._Object_key
from GXD_GelLaneStructure g
      LEFT OUTER JOIN ACC_Accession sa on (g._Structure_key = sa._Object_key 
              and sa._LogicalDB_key = 1
              and sa._MGIType_key = 38)
      LEFT OUTER JOIN MGI_EMAPS_Mapping e on (sa.accID = e.accID)
      LEFT OUTER JOIN ACC_Accession ea on (sa.accID = e.accID
              and e.emapsID = ea.accID
              and ea._MGIType_key = 13
              )
where g._GelLane_key = 151728

