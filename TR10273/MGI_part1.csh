#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (part 1 - migration of existing data into new structures)

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    #load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /lindon/sybase/mgd.backup | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/scrum-dog/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

sp_rename GXD_AllelePair, GXD_AllelePair_Old
go

EOSQL

${MGD_DBSCHEMADIR}/table/GXD_AllelePair_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/GXD_AllelePair_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

insert into GXD_AllelePair
select _AllelePair_key, _Genotype_key, _Allele_key_1, _Allele_key_2, _Marker_key, null, null,
_PairState_key, _Compound_key, sequenceNum, _CreatedBy_key, _ModifiedBy_key,
creation_date, modification_date
from GXD_AllelePair_Old
go

select count(*) from GXD_AllelePair_Old
go

select count(*) from GXD_AllelePair
go

-- just until we start using a new backup file
update MGI_User set name = 'High Throughput MP Load', login = 'htmpload' where _User_key = 1524
go
delete from MGI_User where _User_key = 1527
go


EOSQL

${MGD_DBSCHEMADIR}/index/GXD_AllelePair_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/GXD_AllelePair_bind.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ALL_Marker_Assoc_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ALL_Marker_Assoc_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_AllelePair_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_AllelePair_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Genotype_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Genotype_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MRK_Marker_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/key/ALL_CellLine_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/ALL_CellLine_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_AllelePair_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_AllelePair_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Genotype_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Genotype_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/view/GXD_AllelePair_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/GXD_AllelePair_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/GXD_Genotype_Summary_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/GXD_Genotype_Summary_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/BIB_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/BIB_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/BIB_Summary_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/BIB_Summary_View_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/GXD_checkDuplicateGenotype_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_checkDuplicateGenotype_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/VOC_Cache_MP_Alleles_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/VOC_Cache_MP_Alleles_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/VOC_Cache_OMIM_Alleles_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/VOC_Cache_OMIM_Alleles_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

