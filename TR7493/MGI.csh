#!/bin/csh -fx

#
# Migration for TR7493 -- gene trap LF
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration
setenv CWD `pwd`	# current working directory
echo ${MGD_DBSERVER}
echo ${MGD_DBNAME}
# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/jsb/tr9267. | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database" | tee -a ${LOG}
endif

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

# number references in comments are to sections of schema doc GeneTrapLF.pdf

${UTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.2" | tee -a ${LOG}
${UTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-2-0-0" | tee -a ${LOG}

###-----------------------------###
###--- load new vocabularies ---###
###-----------------------------###

setenv DB_PARMS "${MGD_DBUSER} ${MGI_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME}"

cd ${CWD}

###----------------------###
###--- add new tables ---###
###----------------------###

date | tee -a ${LOG}
echo "--- Creating new tables" | tee -a ${LOG}

# add new tables - 3.1, 3.2, 3.3, 3.5, 3.6, 3.7, 3.10, 3.11

${SCHEMA}/table/ALL_Cache_create.object | tee -a ${LOG}
${SCHEMA}/table/SEQ_Allele_Assoc_create.object | tee -a ${LOG}
${SCHEMA}/table/SEQ_GeneTrap_create.object | tee -a ${LOG}
${SCHEMA}/table/ALL_CellLine_Derivation_create.object | tee -a ${LOG}

# add defaults for new tables

${SCHEMA}/default/ALL_CellLine_Derivation_bind.object | tee -a ${LOG}
${SCHEMA}/default/SEQ_Allele_Assoc_bind.object | tee -a ${LOG}
${SCHEMA}/default/SEQ_GeneTrap_bind.object | tee -a ${LOG}

# add permissions for new tables

date | tee -a ${LOG}
echo "--- Adding new perms" | tee -a ${LOG}

${PERMS}/public/table/ALL_Cache_grant.object | tee -a ${LOG}
${PERMS}/public/table/SEQ_Allele_Assoc_grant.object | tee -a ${LOG}
${PERMS}/public/table/SEQ_GeneTrap_grant.object | tee -a ${LOG}
${PERMS}/public/table/ALL_CellLine_Derivation_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/ALL_Cache_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/SEQ_Allele_Assoc_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/SEQ_GeneTrap_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/ALL_CellLine_Derivation_grant.object | tee -a ${LOG}

###-----------------------------------###
###--- populate & index new tables ---###
###-----------------------------------###

date | tee -a ${LOG}
echo "--- Populating ALL_Cache" | tee -a ${LOG}

# populate new ALL_Cache cache table

cd ${CWD}
./update_ALL_Cache.csh | tee -a ${LOG}

# population of SEQ_Allele_Assoc is done by the GT data load (sc)
# population of SEQ_GeneTrap is done by the GT data load (sc)

# add indexes for new tables (do this after loading tables so the indexes
# and statistics are up-to-date after we load the data, plus we get better
# performance during the load)

date | tee -a ${LOG}
echo "--- Adding indexes" | tee -a ${LOG}

${SCHEMA}/index/ALL_Cache_create.object | tee -a ${LOG}
${SCHEMA}/index/SEQ_Allele_Assoc_create.object | tee -a ${LOG}
${SCHEMA}/index/SEQ_GeneTrap_create.object | tee -a ${LOG}
${SCHEMA}/index/ALL_CellLine_Derivation_create.object | tee -a ${LOG}

###-------------------------------------------------###
###--- revisions to existing database components ---###
###-------------------------------------------------###

date | tee -a ${LOG}
echo "--- Table revisions" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* make changes to GXD_AlleleGenotype and GXD_AllelePair tables (4.16) */

alter table GXD_AlleleGenotype modify _Marker_key null
alter table GXD_AllelePair modify _Marker_key null
go

/* make changes to PRB_Strain_Marker (3.20) and MRK_OMIM_Cache (3.21) */

alter table PRB_Strain_Marker modify _Marker_key null
alter table MRK_OMIM_Cache modify _Marker_key null
go

/* for tables with columns added or removed (ALL_Allele, ALL_CellLine,
 * GXD_Genotype), we must:
 * 	1. rename the existing versions
 * 	2. create new versions
 * 	3. load data into new versions
 * 	4. drop renamed versions (from 1)
 * 	5. add indexes & keys to new versions
 */

/* rename tables which will have columns added or removed */

sp_rename ALL_Allele, ALL_Allele_Old
go
sp_rename ALL_CellLine, ALL_CellLine_Old
go
sp_rename GXD_Genotype, GXD_Genotype_Old
go
EOSQL

# create new versions of old tables

date | tee -a ${LOG}
echo "--- Adding new versions of old tables" | tee -a ${LOG}

${SCHEMA}/table/ALL_Allele_create.object | tee -a ${LOG}
${SCHEMA}/table/ALL_CellLine_create.object | tee -a ${LOG}
${SCHEMA}/table/GXD_Genotype_create.object | tee -a ${LOG}

# add defaults related to new versions of old tables

date | tee -a ${LOG}
echo "--- Adding defaults to new versions of old tables" | tee -a ${LOG}

${SCHEMA}/default/ALL_CellLine_bind.object | tee -a ${LOG}
${SCHEMA}/default/ALL_Allele_bind.object | tee -a ${LOG}
${SCHEMA}/default/GXD_Genotype_bind.object | tee -a ${LOG}

# drop and re-create triggers on tables which we altered to allow the
# _Marker_key field to be null

date | tee -a ${LOG}
echo "--- Re-creating triggers on existing tables" | tee -a ${LOG}

${SCHEMA}/trigger/GXD_AllelePair_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/GXD_AllelePair_create.object | tee -a ${LOG}

# add keys for new tables (done after existing tables have been modified)

date | tee -a ${LOG}
echo "--- Creating new keys" | tee -a ${LOG}

${SCHEMA}/key/SEQ_Allele_Assoc_create.object | tee -a ${LOG}
${SCHEMA}/key/ALL_CellLine_Derivation_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* populate new GXD_Genotype with 0 as isExtinct default - 3.15 */

insert into GXD_Genotype
select _Genotype_key, _Strain_key, isConditional, 0, note,
	_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
from GXD_Genotype_Old
go

/* populate new ALL_Allele - 3.8 */

insert ALL_Allele
select _Allele_key, _Marker_key, _Strain_key, _Mode_key,
	_Allele_Type_key, _Allele_Status_key, _MutantESCellLine_key,
	symbol, name, nomenSymbol, isWildType,
	_CreatedBy_key, _ModifiedBy_key, _ApprovedBy_key,
	approval_date, creation_date, modification_date
from ALL_Allele_Old
go

/* gather needed controlled vocabulary term keys */

declare @esCellLine integer
select @esCellLine = vt._Term_key
	from VOC_Vocab vv, VOC_Term vt
	where vv.name = "Cell Line Type"
		and vt.term = "Embryonic Stem Cell"
		and vv._Vocab_key = vt._Vocab_key

/* populate new ALL_CellLine - 3.9, 3.12, 3.13, 3.14 */

insert into ALL_CellLine
select _CellLine_key, cellLine, _CellLineType_key = @esCellLine, _Strain_key,
	null, provider, isMutant, 0,
	_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
from ALL_CellLine_Old
go

/* populate ALL_CellLine_Derivation - 3.10, 3.11 */

/* get temp table of derivation-related data:
 * note that we do not need derivations for cases where the mutant cell line
 * and the parental cell line are both unknown
 */

select distinct i = identity(8), _ESCellLine_key, _MutantESCellLine_key,
	_Allele_Type_key, _Allele_Type_key as _DerivationType_key
into #tmp_derivation
from ALL_Allele_Old
where _ESCellLine_key >= 0
	and _MutantESCellLine_key >= 0
go

/* need to update derivation type key using mapping from allele type to the
 * similarly named derivation type
 */

update #tmp_derivation
set t._DerivationType_key = vt2._Term_key
from #tmp_derivation t, VOC_Term vt, VOC_Term vt2, VOC_Vocab vv
where t._Allele_Type_key = vt._Term_key
	and vt.term = vt2.term
	and vt2._Vocab_key = vv._Vocab_key
	and vv.name = "Derivation Type"
go

/* fill new derivation table */

insert ALL_CellLine_Derivation (_Derivation_key, _ParentCellLine_key,
	_DerivationType_key)
select i, _ESCellLine_key, _DerivationType_key
from #tmp_derivation
go

/* update derivation keys in ALL_CellLine to point to new derivations */

update ALL_CellLine
set _Derivation_key = t.i
from ALL_CellLine c, #tmp_derivation t
where c._CellLine_key = t._MutantESCellLine_key
go

/* for unnamed cell lines, copy primary ID into name field - 3.17 */

select count(1) as "null CL before"
from ALL_CellLine
where cellLine = null
go

select c._CellLine_key, a.accID
into #tmp_cellLine
from ALL_CellLine c, ACC_Accession a, ACC_MGIType mt
where c.cellLine = null
	and c._CellLine_key = a._Object_key
	and a.preferred = 1
	and a.private = 0
	and a._MGIType_key = mt._MGIType_key
	and mt.name = "Cell Line"
go

update ALL_CellLine
set cellLine = t.accID
from ALL_CellLine c, #tmp_cellLine t
where c._CellLine_key = t._CellLine_key
go

select count(1) as "null CL after"
from ALL_CellLine
where cellLine = null
go

/* drop old versions of tables */

drop table ALL_Allele_Old
go
drop table ALL_CellLine_Old
go
drop table GXD_Genotype_Old
go
EOSQL

date | tee -a ${LOG}
echo "--- Adding indexes, keys, triggers on re-created tables" | tee -a ${LOG}

# create indexes, keys, and triggers on re-created tables

${SCHEMA}/key/ALL_Allele_create.object | tee -a ${LOG}
${SCHEMA}/key/ALL_CellLine_create.object | tee -a ${LOG}
${SCHEMA}/key/GXD_Genotype_create.object | tee -a ${LOG}
${SCHEMA}/index/ALL_Allele_create.object | tee -a ${LOG}
${SCHEMA}/index/ALL_CellLine_create.object | tee -a ${LOG}
${SCHEMA}/index/GXD_Genotype_create.object | tee -a ${LOG}
${SCHEMA}/trigger/ALL_CellLine_create.object | tee -a ${LOG}
${SCHEMA}/trigger/ALL_Allele_create.object | tee -a ${LOG}
${SCHEMA}/trigger/GXD_Genotype_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding permissions on re-created tables" | tee -a ${LOG}

${PERMS}/public/table/ALL_Allele_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/ALL_Allele_grant.object | tee -a ${LOG}
${PERMS}/public/table/ALL_CellLine_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/ALL_CellLine_grant.object | tee -a ${LOG}
${PERMS}/public/table/GXD_Genotype_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/GXD_Genotype_grant.object | tee -a ${LOG}

###--------------------###
###--- add new view ---###
###--------------------###

date | tee -a ${LOG}
echo "--- Adding new view(s)" | tee -a ${LOG}

# add new view - 4.19 - and its permissions

${SCHEMA}/view/ALL_CellLine_Allele_View_create.object | tee -a ${LOG}
${PERMS}/public/view/ALL_CellLine_Allele_View_grant.object | tee -a ${LOG}

# add other new views and their permissions

${SCHEMA}/view/ALL_Allele_Strain_View_create.object | tee -a ${LOG}
${PERMS}/public/view/ALL_Allele_Strain_View_grant.object | tee -a ${LOG}

${SCHEMA}/view/ALL_CellLine_Strain_View_create.object | tee -a ${LOG}
${PERMS}/public/view/ALL_CellLine_Strain_View_grant.object | tee -a ${LOG}

${SCHEMA}/view/MAP_Feature_View_create.object | tee -a ${LOG}
${PERMS}/public/view/MAP_Feature_View_grant.object | tee -a ${LOG}

# update old views and recreate their permissions

date | tee -a ${LOG}
echo "--- Updating old view(s)" | tee -a ${LOG}

${PERMS}/public/view/GXD_AllelePair_View_revoke.object | tee -a ${LOG}
${SCHEMA}/view/GXD_AllelePair_View_drop.object | tee -a ${LOG}
${SCHEMA}/view/GXD_AllelePair_View_create.object | tee -a ${LOG}
${PERMS}/public/view/GXD_AllelePair_View_grant.object | tee -a ${LOG}

${PERMS}/public/view/MLD_Expt_Marker_View_revoke.object | tee -a ${LOG}
${SCHEMA}/view/MLD_Expt_Marker_View_drop.object | tee -a ${LOG}
${SCHEMA}/view/MLD_Expt_Marker_View_create.object | tee -a ${LOG}
${PERMS}/public/view/MLD_Expt_Marker_View_grant.object | tee -a ${LOG}

${PERMS}/public/view/PRB_RFLV_View_revoke.object | tee -a ${LOG}
${SCHEMA}/view/PRB_RFLV_View_drop.object | tee -a ${LOG}
${SCHEMA}/view/PRB_RFLV_View_create.object | tee -a ${LOG}
${PERMS}/public/view/PRB_RFLV_View_grant.object | tee -a ${LOG}

${PERMS}/public/view/PRB_Strain_Marker_View_revoke.object | tee -a ${LOG}
${SCHEMA}/view/PRB_Strain_Marker_View_drop.object | tee -a ${LOG}
${SCHEMA}/view/PRB_Strain_Marker_View_create.object | tee -a ${LOG}
${PERMS}/public/view/PRB_Strain_Marker_View_grant.object | tee -a ${LOG}

# updating old stored procedures

date | tee -a ${LOG}
echo "--- Updating old procedure(s)" | tee -a ${LOG}

${PERMS}/curatorial/procedure/ALL_mergeWildTypes_revoke.object | tee -a ${LOG}
${SCHEMA}/procedure/ALL_mergeWildTypes_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/ALL_mergeWildTypes_create.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/ALL_mergeWildTypes_grant.object | tee -a ${LOG}

${PERMS}/curatorial/procedure/ALL_insertAllele_revoke.object | tee -a ${LOG}
${SCHEMA}/procedure/ALL_insertAllele_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/ALL_insertAllele_create.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/ALL_insertAllele_grant.object | tee -a ${LOG}

${PERMS}/curatorial/procedure/ALL_convertAllele_revoke.object | tee -a ${LOG}
${SCHEMA}/procedure/ALL_convertAllele_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/ALL_convertAllele_create.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/ALL_convertAllele_grant.object | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

#dump_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/jsb/tr7493.merged. | tee -a ${LOG}
#date | tee -a ${LOG}
#echo "--- Finished database dump" | tee -a ${LOG}
