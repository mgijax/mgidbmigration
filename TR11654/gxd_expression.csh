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

select count(*) from GXD_Expression
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

echo "--- begin : keys/triggers/sp" | tee -a ${LOG}
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

${MGD_DBSCHEMADIR}/trigger/GXD_AssayType_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_AssayType_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Assay_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Assay_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Genotype_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Genotype_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Structure_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Structure_create.object | tee -a ${LOG}

# only drop/create the sp needed to complete the migration
# all of the sps will be re-created as part of the full migration
${MGD_DBSCHEMADIR}/procedure/GXD_loadCacheByAssay_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_loadCacheByAssay_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_loadCacheAll_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_loadCacheAll_create.object | tee -a ${LOG}
echo "--- end : keys/triggers/sp" | tee -a ${LOG}

echo "--- begin : update EMAPS ids" | tee -a ${LOG}
date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update GXD_Expression
set _emaps_key = ea._Object_key
  from GXD_Expression g, ACC_Accession sa, MGI_EMAPS_Mapping e, ACC_Accession ea
    where g._Structure_key = sa._Object_key
              and sa._LogicalDB_key = 1
              and sa._MGIType_key = 38
              and sa.accID = e.accID
              and e.emapsID = ea.accID
              and ea._MGIType_key = 13
go

-- should be 0 (none)
select * from GXD_Expression where _emaps_key is null
go

EOSQL

date | tee -a ${LOG}
echo "--- end : update EMAPS ids" | tee -a ${LOG}

echo "--- Run A Test" | tee -a ${LOG}
date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

-- TEST USING : MGI:3765895/'T-B-'
-- stage28:B-lymphocyte is a structure with no EMAPS id
-- it should appear in the cache with _emaps_key = null

update GXD_GelLane set
_Genotype_key = -1, _GelRNAType_key = -1, _GelControl_key = 1,
sex = 'Not Specified', age = 'postnatal', ageMin = 21.010000, ageMax = 1846.000000
where _GelLane_key = 151728
go

-- should return 4
select * from GXD_Expression where _Assay_key = 29767
go

exec GXD_loadCacheByAssay 29767
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

