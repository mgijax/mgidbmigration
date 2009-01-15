#!/bin/csh -fx

#
# Migration for TR7493 -- gene trap LF
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

# number references in comments are to sections of schema doc GeneTrapLF.pdf

${UTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.3" | tee -a ${LOG}
${UTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-3-0-0" | tee -a ${LOG}

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
${SCHEMA}/table/ALL_Marker_Assoc_create.object | tee -a ${LOG}
${SCHEMA}/table/ALL_Allele_CellLine_create.object | tee -a ${LOG}

# add defaults for new tables

${SCHEMA}/default/ALL_CellLine_Derivation_bind.object | tee -a ${LOG}
${SCHEMA}/default/SEQ_Allele_Assoc_bind.object | tee -a ${LOG}
${SCHEMA}/default/SEQ_GeneTrap_bind.object | tee -a ${LOG}
${SCHEMA}/default/ALL_Marker_Assoc_bind.object | tee -a ${LOG}
${SCHEMA}/default/ALL_Allele_CellLine_bind.object | tee -a ${LOG}

# add permissions for new tables

date | tee -a ${LOG}
echo "--- Adding new perms" | tee -a ${LOG}

${PERMS}/public/table/ALL_Cache_grant.object | tee -a ${LOG}
${PERMS}/public/table/SEQ_Allele_Assoc_grant.object | tee -a ${LOG}
${PERMS}/public/table/SEQ_GeneTrap_grant.object | tee -a ${LOG}
${PERMS}/public/table/ALL_CellLine_Derivation_grant.object | tee -a ${LOG}
${PERMS}/public/table/ALL_Allele_CellLine_grant.object | tee -a ${LOG}
${PERMS}/public/table/ALL_Marker_Assoc_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/ALL_Cache_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/SEQ_Allele_Assoc_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/SEQ_GeneTrap_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/ALL_CellLine_Derivation_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/ALL_Allele_CellLine_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/ALL_Marker_Assoc_grant.object | tee -a ${LOG}

###-----------------------------------###
###--- populate & index new tables ---###
###-----------------------------------###

# add indexes for new tables (do this after loading tables so the indexes
# and statistics are up-to-date after we load the data, plus we get better
# performance during the load)

date | tee -a ${LOG}
echo "--- Adding keys" | tee -a ${LOG}

${SCHEMA}/key/ALL_Cache_create.object | tee -a ${LOG}
${SCHEMA}/key/ALL_Allele_CellLine_create.object | tee -a ${LOG}
${SCHEMA}/key/ALL_Marker_Assoc_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding indexes" | tee -a ${LOG}

${SCHEMA}/index/ALL_Cache_create.object | tee -a ${LOG}
${SCHEMA}/index/SEQ_Allele_Assoc_create.object | tee -a ${LOG}
${SCHEMA}/index/SEQ_GeneTrap_create.object | tee -a ${LOG}
${SCHEMA}/index/ALL_CellLine_Derivation_create.object | tee -a ${LOG}
${SCHEMA}/index/ALL_Allele_CellLine_create.object | tee -a ${LOG}
${SCHEMA}/index/ALL_Marker_Assoc_create.object | tee -a ${LOG}

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
${SCHEMA}/trigger/MRK_Marker_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/MRK_Marker_create.object | tee -a ${LOG}

# add keys for new tables (done after existing tables have been modified)

date | tee -a ${LOG}
echo "--- Creating new keys" | tee -a ${LOG}

${SCHEMA}/key/SEQ_Allele_Assoc_create.object | tee -a ${LOG}
${SCHEMA}/key/ALL_CellLine_Derivation_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

declare @existsAsDefault integer	-- use "Not Specified" as a default
select @existsAsDefault = 3982949

/* populate new GXD_Genotype with default value for existsAs - 3.15a */

insert into GXD_Genotype
select _Genotype_key, _Strain_key, isConditional, note, @existsAsDefault,
	_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
from GXD_Genotype_Old
go

/* two updates for GXD_Genotype, per Cindy:
 * 	1. if a genotype has MP annotations, then it exists as a mouse line
 * 	2. if a genotype has GXD annotations, then it exists as a mouse line
 */

declare @mouseLine integer
select @mouseLine = 3982946			-- mouseLine

update GXD_Genotype
set _ExistsAs_key = @mouseLine
from GXD_Genotype g, VOC_Annot a
where g._Genotype_key = a._Object_key
	and a._AnnotType_key = 1002		-- MP/Genotype

update GXD_Genotype
set _ExistsAs_key = @mouseLine
from GXD_Genotype g, GXD_Expression e
where g._Genotype_key = e._Genotype_key
	and e.isForGXD = 1			-- not recombinase "assays"

/* populate new ALL_Allele with non-extinct as a default - 3.8, 3.15 */

insert ALL_Allele
select _Allele_key, _Marker_key, _Strain_key, _Mode_key,
	_Allele_Type_key, _Allele_Status_key,
	symbol, name, nomenSymbol, isWildType, 0,
	_CreatedBy_key, _ModifiedBy_key, _ApprovedBy_key,
	approval_date, creation_date, modification_date
from ALL_Allele_Old
go

/* populate new ALL_Allele_CellLine join table - 3.8 */

select i = identity(8), _Allele_key, _MutantESCellLine_key
into #tmp_all_cellline
from ALL_Allele_Old
where _MutantESCellLine_key != null
go

insert into ALL_Allele_CellLine (_Assoc_key, _Allele_key, _MutantCellLine_key)
select i, _Allele_key, _MutantESCellLine_key
from #tmp_all_cellline
go

/* populate new ALL_Marker_Assoc join table - 3.4 */

select i = identity(8), _Allele_key, _Marker_key
into #tmp_mrk_assoc
from ALL_Allele_Old
where _Marker_key != null
go

declare @qualifierKey integer			-- should be from vocab 70
select @qualifierKey = 3983019			-- "Not Specified"

insert into ALL_Marker_Assoc (_Assoc_key, _Allele_key, _Marker_key, _Qualifier_key)
select i, _Allele_key, _Marker_key, @qualifierKey
from #tmp_mrk_assoc
go

/* populate new ALL_CellLine - 3.9, 3.12, 3.13, 3.14 */

declare @esCellLine integer
select @esCellLine = vt._Term_key
	from VOC_Vocab vv, VOC_Term vt
	where vv.name = "Cell Line Type"
		and vt.term = "Embryonic Stem Cell"
		and vv._Vocab_key = vt._Vocab_key

insert into ALL_CellLine
select _CellLine_key, cellLine, _CellLineType_key = @esCellLine, _Strain_key,
	null, isMutant, 0,
	_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
from ALL_CellLine_Old
go

/* populate ALL_CellLine_Derivation - 3.10, 3.11 */

/* get temp table of derivation-related data:
 * note that we do not need derivations for cases where the mutant cell line
 * and the parental cell line are both unknown
 */

select distinct i = identity(8), a._ESCellLine_key, a._MutantESCellLine_key,
	a._Allele_Type_key, a._Allele_Type_key as _DerivationType_key,
	c.provider, a._ESCellLine_key as _Creator_key
into #tmp_derivation
from ALL_Allele_Old a, ALL_CellLine_Old c
where a._ESCellLine_key >= 0
	and a._MutantESCellLine_key >= 0
	and a._MutantESCellLine_key = c._CellLine_key
go

alter table #tmp_derivation modify _Creator_key null
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

/* reset the creator key field to be null; we simply picked an int to fill it
 * with initially so it would be the right size
 */

update #tmp_derivation
set _Creator_key = null
go

/* cleanup of provider field, per email from Richard to Sharon... */

create index #tmp_indexProvider on #tmp_derivation (provider)
go

update #tmp_derivation
set provider = "GGTC"
where _ESCellLine_key = 1098 and provider = "IGTC"

update #tmp_derivation
set provider = "FHCRC"
where provider = "Fred Hutchinson Cancer Research Center"

update #tmp_derivation
set provider = "EGTC"
where provider = "Institute of Molecular Embryology and Genetics"

update #tmp_derivation
set provider = "Lexicon"
where provider = "Lexicon Genetics"

update #tmp_derivation
set provider = "ESDB"
where provider = "Mammalian Functional Genomics Centre"

update #tmp_derivation
set provider = "SIGTR"
where provider = "Sanger Institute"
	or provider = "Sanger Institute Gene Trap Resource"

update #tmp_derivation
set provider = "CMHD"
where provider = "The Centre for Modeling Human Disease"

update #tmp_derivation
set provider = "GGTC"
where provider = "The German Genetrap Consortium"

update #tmp_derivation
set provider = "BayGenomics"
where provider = "William C Skarnes"
go

/* now populate the creator key with an appropriate value where we can match
 * the provider to a creator
 */

update #tmp_derivation
set t._Creator_key = vt._Term_key
from #tmp_derivation t, VOC_Term vt, VOC_Vocab vv
where vv.name = "Cell Line Creator"
	and vv._Vocab_key = vt._Vocab_key
	and (vt.term = t.provider or vt.abbreviation = t.provider)
go

/* report how many providers matched to creators, and how many did not */

select provider, count(1) as "matched creators"
from #tmp_derivation
where provider != null
	and _Creator_key != null
group by provider
go

select provider, count(1) as "unmatched creators"
from #tmp_derivation
where provider != null
	and _Creator_key = null
group by provider
go

/* fill new derivation table */

declare @vecTypeDefault integer		-- "Not Specified"
select @vecTypeDefault = 3982979

declare @vecNameDefault integer		-- "Not Specified"
select @vecNameDefault = 3982979	-- should be from vocab 72

insert ALL_CellLine_Derivation (_Derivation_key, _ParentCellLine_key,
	_DerivationType_key, _Creator_key, _Vector_key, _VectorType_key)
select i, _ESCellLine_key, _DerivationType_key, _Creator_key,
	@vecNameDefault, @vecTypeDefault
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

/* add two new reference association types, to be used in flagging certain
 * references for alleles
 */

declare @nextType integer
select @nextType = max(_RefAssocType_key) + 1
from MGI_RefAssocType

insert MGI_RefAssocType (_RefAssocType_key, _MGIType_key, assocType,
    allowOnlyOne)
values (@nextType, 11, "Chimera Generation", 1)

insert MGI_RefAssocType (_RefAssocType_key, _MGIType_key, assocType,
    allowOnlyOne)
values (@nextType + 1, 11, "Germ Line Transmission", 1)
go

/* updates to logical dbs and actual dbs, per item 3 of "Handling Gene Trap
 * Identifiers" document by rmb
 */

update ACC_ActualDB
set url = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Search&db=nucgss&doptcmdl=GenBank&term=@@@@"
where _ActualDB_key in (96, 67)		-- TIGM, Lexicon Genetics

update ACC_ActualDB
set name = "Lexicon Genetics"
where _ActualDB_key = 67

update ACC_LogicalDB
set description = "Lexicon Genetics Cell Line"
where _LogicalDB_key = 96
go

/* migrate existing mutant cell line IDs to new logical databases, based on
 * their cell line creators
 */

update ACC_Accession
set _LogicalDB_key = 96			-- Lexicon Genetics Cell Line
where _MGIType_key = 28			-- cell line
	and _LogicalDB_key = 67		-- Lexicon Genetics
go

update ACC_Accession
set _LogicalDB_key = 95
from ACC_Accession a,
	ALL_CellLine c, 
	ALL_CellLine_Derivation d,
	VOC_Term t
where a._MGIType_key = 28			-- cell line
	and a._LogicalDB_key = 66		-- IGTC
	and a._Object_key = c._CellLine_key
	and c._Derivation_key = d._Derivation_key
	and d._Creator_key = t._Term_key
	and t.term = "BayGenomics"
go

update ACC_Accession
set _LogicalDB_key = 95
from ACC_Accession a,
	ALL_CellLine c, 
	ALL_CellLine_Derivation d,
	VOC_Term t
where a._MGIType_key = 28			-- cell line
	and a._LogicalDB_key = 66		-- IGTC
	and a._Object_key = c._CellLine_key
	and c._Derivation_key = d._Derivation_key
	and d._Creator_key = t._Term_key
	and t.term = "TIGEM"
go

update ACC_Accession
set _LogicalDB_key = 99
from ACC_Accession a,
	ALL_CellLine c, 
	ALL_CellLine_Derivation d,
	VOC_Term t
where a._MGIType_key = 28			-- cell line
	and a._LogicalDB_key = 66		-- IGTC
	and a._Object_key = c._CellLine_key
	and c._Derivation_key = d._Derivation_key
	and d._Creator_key = t._Term_key
	and t.term = "CMHD"
go

update ACC_Accession
set _LogicalDB_key = 100
from ACC_Accession a,
	ALL_CellLine c, 
	ALL_CellLine_Derivation d,
	VOC_Term t
where a._MGIType_key = 28			-- cell line
	and a._LogicalDB_key = 66		-- IGTC
	and a._Object_key = c._CellLine_key
	and c._Derivation_key = d._Derivation_key
	and d._Creator_key = t._Term_key
	and t.term = "ESDB"
go

update ACC_Accession
set _LogicalDB_key = 101
from ACC_Accession a,
	ALL_CellLine c, 
	ALL_CellLine_Derivation d,
	VOC_Term t
where a._MGIType_key = 28			-- cell line
	and a._LogicalDB_key = 66		-- IGTC
	and a._Object_key = c._CellLine_key
	and c._Derivation_key = d._Derivation_key
	and d._Creator_key = t._Term_key
	and t.term = "EGTC"
go

update ACC_Accession
set _LogicalDB_key = 102
from ACC_Accession a,
	ALL_CellLine c, 
	ALL_CellLine_Derivation d,
	VOC_Term t
where a._MGIType_key = 28			-- cell line
	and a._LogicalDB_key = 66		-- IGTC
	and a._Object_key = c._CellLine_key
	and c._Derivation_key = d._Derivation_key
	and d._Creator_key = t._Term_key
	and t.term = "GGTC"
go

update ACC_Accession
set _LogicalDB_key = 103
from ACC_Accession a,
	ALL_CellLine c, 
	ALL_CellLine_Derivation d,
	VOC_Term t
where a._MGIType_key = 28			-- cell line
	and a._LogicalDB_key = 66		-- IGTC
	and a._Object_key = c._CellLine_key
	and c._Derivation_key = d._Derivation_key
	and d._Creator_key = t._Term_key
	and t.term = "SIGTR"
go
update ACC_Accession
set _LogicalDB_key = 104
from ACC_Accession a,
	ALL_CellLine c, 
	ALL_CellLine_Derivation d,
	VOC_Term t
where a._MGIType_key = 28			-- cell line
	and a._LogicalDB_key = 66		-- IGTC
	and a._Object_key = c._CellLine_key
	and c._Derivation_key = d._Derivation_key
	and d._Creator_key = t._Term_key
	and t.term = "FHCRC"
go

declare @tigm integer
select @tigm = _LogicalDB_key
from ACC_LogicalDB
where name = "TIGM"

update ACC_Accession
set _LogicalDB_key = @tigm
from ACC_Accession a,
	ALL_CellLine c, 
	ALL_CellLine_Derivation d,
	VOC_Term t
where a._MGIType_key = 28			-- cell line
	and a._LogicalDB_key = 66		-- IGTC
	and a._Object_key = c._CellLine_key
	and c._Derivation_key = d._Derivation_key
	and d._Creator_key = t._Term_key
	and t.term = "TIGM"
go
EOSQL

# create triggers for new tables

date | tee -a ${LOG}
echo "--- Adding triggers to new tables" | tee -a ${LOG}

${SCHEMA}/trigger/SEQ_Allele_Assoc_create.object | tee -a ${LOG}
${SCHEMA}/trigger/ALL_Marker_Assoc_create.object | tee -a ${LOG}

# recreate revised keys

date | tee -a ${LOG}
echo "--- Updating revised keys on old tables" | tee -a ${LOG}

${SCHEMA}/key/VOC_Term_drop.object | tee -a ${LOG}
${SCHEMA}/key/VOC_Term_create.object | tee -a ${LOG}
${SCHEMA}/key/BIB_Refs_drop.object | tee -a ${LOG}
${SCHEMA}/key/BIB_Refs_create.object | tee -a ${LOG}
${SCHEMA}/key/MGI_User_drop.object | tee -a ${LOG}
${SCHEMA}/key/MGI_User_create.object | tee -a ${LOG}
${SCHEMA}/key/MRK_Marker_drop.object | tee -a ${LOG}
${SCHEMA}/key/MRK_Marker_create.object | tee -a ${LOG}
${SCHEMA}/key/ACC_Accession_drop.object | tee -a ${LOG}
${SCHEMA}/key/ACC_Accession_create.object | tee -a ${LOG}

# recreate revised triggers

date | tee -a ${LOG}
echo "--- Updating revised triggers on old tables" | tee -a ${LOG}

${SCHEMA}/trigger/ACC_Accession_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/ACC_Accession_create.object | tee -a ${LOG}
${SCHEMA}/trigger/VOC_Term_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/VOC_Term_create.object | tee -a ${LOG}
${SCHEMA}/trigger/BIB_Refs_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/BIB_Refs_create.object | tee -a ${LOG}

# adding new stored procedures

date | tee -a ${LOG}
echo "--- Adding new procedure(s)" | tee -a ${LOG}

${SCHEMA}/procedure/ALL_associateCellLine_create.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/ALL_associateCellLine_grant.object | tee -a ${LOG}
${SCHEMA}/procedure/ALL_updateCache_create.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/ALL_updateCache_grant.object | tee -a ${LOG}
${SCHEMA}/procedure/ALL_cacheMarker_create.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/ALL_cacheMarker_grant.object | tee -a ${LOG}

# create indexes, keys, and triggers on re-created tables

date | tee -a ${LOG}
echo "--- Adding indexes, keys, triggers on re-created tables" | tee -a ${LOG}

${SCHEMA}/key/ALL_Allele_create.object | tee -a ${LOG}
${SCHEMA}/key/ALL_CellLine_create.object | tee -a ${LOG}
${SCHEMA}/key/GXD_Genotype_create.object | tee -a ${LOG}
${SCHEMA}/index/ALL_Allele_create.object | tee -a ${LOG}
${SCHEMA}/index/ALL_CellLine_create.object | tee -a ${LOG}
${SCHEMA}/index/GXD_Genotype_create.object | tee -a ${LOG}
${SCHEMA}/trigger/ALL_CellLine_create.object | tee -a ${LOG}
${SCHEMA}/trigger/ALL_Allele_create.object | tee -a ${LOG}
${SCHEMA}/trigger/GXD_Genotype_create.object | tee -a ${LOG}

# update statistics for the new tables, so the indexes will be optimal

date | tee -a ${LOG}
echo "--- Updating statistics on new tables (to optimize indexes)" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update statistics ALL_Cache
update statistics SEQ_Allele_Assoc
update statistics SEQ_GeneTrap
update statistics ALL_CellLine_Derivation
update statistics ALL_Allele_CellLine
update statistics ALL_Marker_Assoc
go
EOSQL

date | tee -a ${LOG}
echo "--- Adding permissions on re-created tables" | tee -a ${LOG}

${PERMS}/public/table/ALL_Allele_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/ALL_Allele_grant.object | tee -a ${LOG}
${PERMS}/public/table/ALL_CellLine_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/ALL_CellLine_grant.object | tee -a ${LOG}
${PERMS}/public/table/GXD_Genotype_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/GXD_Genotype_grant.object | tee -a ${LOG}

# populate new ALL_Cache cache table

date | tee -a ${LOG}
echo "--- Populating ALL_Cache" | tee -a ${LOG}

cd ${MGICACHELOAD}
./allcache.csh | tee -a ${LOG}
cd ${CWD}

# population of SEQ_Allele_Assoc is done by the GT data load (sc)
# population of SEQ_GeneTrap is done by the GT data load (sc)

###--------------------###
###--- add new view ---###
###--------------------###

date | tee -a ${LOG}
echo "--- Adding new view(s)" | tee -a ${LOG}

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

${PERMS}/public/view/ALL_Allele_View_revoke.object | tee -a ${LOG}
${SCHEMA}/view/ALL_Allele_View_drop.object | tee -a ${LOG}
${SCHEMA}/view/ALL_Allele_View_create.object | tee -a ${LOG}
${PERMS}/public/view/ALL_Allele_View_grant.object | tee -a ${LOG}

${PERMS}/public/view/GXD_AllelePair_View_revoke.object | tee -a ${LOG}
${SCHEMA}/view/GXD_AllelePair_View_drop.object | tee -a ${LOG}
${SCHEMA}/view/GXD_AllelePair_View_create.object | tee -a ${LOG}
${PERMS}/public/view/GXD_AllelePair_View_grant.object | tee -a ${LOG}

${PERMS}/public/view/GXD_Genotype_View_revoke.object | tee -a ${LOG}
${SCHEMA}/view/GXD_Genotype_View_drop.object | tee -a ${LOG}
${SCHEMA}/view/GXD_Genotype_View_create.object | tee -a ${LOG}
${PERMS}/public/view/GXD_Genotype_View_grant.object | tee -a ${LOG}

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

${PERMS}/public/procedure/GXD_checkDuplicateGenotype_revoke.object | tee -a ${LOG}
${SCHEMA}/procedure/GXD_checkDuplicateGenotype_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/GXD_checkDuplicateGenotype_create.object | tee -a ${LOG}
${PERMS}/public/procedure/GXD_checkDuplicateGenotype_grant.object | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

#dump_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/jsb/tr7493.merged. | tee -a ${LOG}
#date | tee -a ${LOG}
#echo "--- Finished database dump" | tee -a ${LOG}
