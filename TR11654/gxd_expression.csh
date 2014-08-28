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

-- for testing
update GXD_GelLane set
_Genotype_key = -1, _GelRNAType_key = -1, _GelControl_key = 1,
sex = 'Not Specified', age = 'postnatal', ageMin = 21.010000, ageMax = 1846.000000
where _GelLane_key = 151728
go

EOSQL
date | tee -a ${LOG}

date | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/GXD_Expression_bind.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/GXD_Expression_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Expression_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Expression_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/BIB_Refs_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/BIB_Refs_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_AssayType_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_AssayType_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Assay_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Assay_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Genotype_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Genotype_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a ${LOG}
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
exit 0

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

--MGI:3765895

delete from GXD_Expression where _Assay_key = 29767
go

-- should return 0
select * from GXD_Expression where _Assay_key = 29767
go

exec GXD_loadCacheAll
go

-- should return 6
select * from GXD_Expression where _Assay_key = 29767
go

-- should return 2; 7069's _emaps_key is null
select _Structure_key, _emaps_key from GXD_Expression where _Assay_key = 29767
and _Structure_key in (7040, 7069)
go

EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

