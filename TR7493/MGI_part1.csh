#!/bin/csh -fx

#
# Migration for TR7493 -- gene trap LF
# (part 1 - migration of existing data into new structures)

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

${PERMS}/public/table/SEQ_Allele_Assoc_grant.object | tee -a ${LOG}
${PERMS}/public/table/SEQ_GeneTrap_grant.object | tee -a ${LOG}
${PERMS}/public/table/ALL_CellLine_Derivation_grant.object | tee -a ${LOG}
${PERMS}/public/table/ALL_Allele_CellLine_grant.object | tee -a ${LOG}
${PERMS}/public/table/ALL_Marker_Assoc_grant.object | tee -a ${LOG}
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

${SCHEMA}/key/ALL_Allele_CellLine_create.object | tee -a ${LOG}
${SCHEMA}/key/ALL_Marker_Assoc_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding indexes" | tee -a ${LOG}

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

/* remove Derivation Type vocabulary which had been previously added
 * to production, if it still exists
 */
delete from VOC_Vocab where name = "Derivation Type"
go

/* add a derivationload user if there isn't already one
 */

if not exists (select 1 from MGI_User where login = "derivationload")
begin
  declare @maxUser integer
  select @maxUser = max(_User_key) from MGI_User

  insert MGI_User (_User_key, login, name, _UserStatus_key, _UserType_key)
  values (@maxUser + 1, "derivationload", "Derivation Load", 316350, 316353)
end
go

select derivationload_user_key = _User_key
from MGI_User
where login = "derivationload"
go

/* add a new MGI Note Type for derivation notes */

declare @nextNoteType integer
select @nextNoteType = max(_NoteType_key) + 1 from MGI_NoteType

declare @mgiTypeDer integer
select @mgiTypeDer = _MGIType_key
from ACC_MGIType
where name = "Cell Line Derivation"

insert MGI_NoteType (_NoteType_key, _MGIType_key, noteType, private)
values (@nextNoteType, @mgiTypeDer, "General", 0)
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
drop trigger ALL_CellLine_Update
go
EOSQL

# create new versions of old tables

date | tee -a ${LOG}
echo "--- Adding new versions of old tables" | tee -a ${LOG}

${SCHEMA}/table/ALL_Allele_create.object | tee -a ${LOG}
${SCHEMA}/table/ALL_CellLine_create.object | tee -a ${LOG}
${SCHEMA}/table/GXD_Genotype_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding permissions on re-created tables" | tee -a ${LOG}

${PERMS}/public/table/ALL_Allele_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/ALL_Allele_grant.object | tee -a ${LOG}
${PERMS}/public/table/ALL_CellLine_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/ALL_CellLine_grant.object | tee -a ${LOG}
${PERMS}/public/table/GXD_Genotype_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/GXD_Genotype_grant.object | tee -a ${LOG}

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

/* populate new ALL_Allele with non-extinct and non-mixed as defaults -
 * 3.8, 3.15 */

/* default transmission is 'Unknown'; we will later override with other
 * values
 */
declare @transKey integer
select @transKey = 3982953

insert ALL_Allele
select _Allele_key, _Marker_key, _Strain_key, _Mode_key,
	_Allele_Type_key, _Allele_Status_key, @transKey,
	symbol, name, nomenSymbol, isWildType, 0, 0,
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

declare @qualifierKey integer
select @qualifierKey = 4268547			-- "Not Specified"

declare @statusKey integer
select @statusKey = t._Term_key
from VOC_Term t
where t.term = "Curated" and t._Vocab_key = 73

insert into ALL_Marker_Assoc (_Assoc_key, _Allele_key, _Marker_key, _Qualifier_key, _Status_key)
select i, _Allele_key, _Marker_key, @qualifierKey, @statusKey
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
	null, isMutant,
	_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
from ALL_CellLine_Old
go

/* cleanup of provider field, per email from Richard to Sharon... */

update ALL_CellLine_Old
set provider = "GGTC"
where _CellLine_key = 1098 and provider = "IGTC"

update ALL_CellLine_Old
set provider = "FHCRC"
where provider = "Fred Hutchinson Cancer Research Center"

update ALL_CellLine_Old
set provider = "EGTC"
where provider = "Institute of Molecular Embryology and Genetics"

/* update ALL_CellLine_Old
 * set provider = "Lexicon"
 * where provider = "Lexicon Genetics"
 */

update ALL_CellLine_Old
set provider = "Lexicon Genetics"
where provider = "Lexicon Genetic"

update ALL_CellLine_Old
set provider = "ESDB"
where provider = "Mammalian Functional Genomics Centre"

update ALL_CellLine_Old
set provider = "SIGTR"
where provider = "Sanger Institute"
	or provider = "Sanger Institute Gene Trap Resource"

update ALL_CellLine_Old
set provider = "CMHD"
where provider = "The Centre for Modeling Human Disease"

update ALL_CellLine_Old
set provider = "GGTC"
where provider = "The German Genetrap Consortium"

update ALL_CellLine_Old
set provider = "BayGenomics"
where provider = "William C Skarnes"
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
EOSQL

# run Sharon's derivation load

date | tee -a ${LOG}
echo "--- Loading generic derivations" | tee -a ${LOG}

${DERIVATIONLOAD}/bin/createDerivationInputFile.sh ${DERIVATIONLOAD}/file1.out | tee -a ${LOG}
${DERIVATIONLOAD}/bin/derivationload.sh ${DERIVATIONLOAD}/file1.out | tee -a ${LOG}
${DERIVATIONLOAD}/bin/derivationload.sh /mgi/all/wts_projects/7400/7493/CleanUp_Migration/DER_load_Creators.txt | tee -a ${LOG}

# create new mutant cell lines, map mutant cell lines to derivations
# (must be done before deleting old tables)

date | tee -a ${LOG}
echo "--- Reconciling mutant cell lines / derivations" | tee -a ${LOG}

./mclDerivations.py ${MGD_DBUSER} ${MGI_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME} | tee -a ${LOG} 

# must load this third file of derivations AFTER reconciling with the generics

date | tee -a ${LOG}
echo "--- Loading dbGSS derivations" | tee -a ${LOG}

#${DERIVATIONLOAD}/bin/derivationload.sh /home/jsb/tr7493/dbutils/mgidbmigration/TR7493/GB_abbrev.txt | tee -a ${LOG}
${DERIVATIONLOAD}/bin/derivationload.sh /mgi/all/wts_projects/7400/7493/CleanUp_Migration/GB_DER_load.txt | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Splitting MCL with multiple IDs" | tee -a ${LOG}

./mclSplit.py ${MGD_DBUSER} ${MGI_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME} | tee -a ${LOG} 

# continue onward...

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* drop old versions of tables */

drop table ALL_Allele_Old
go
drop table ALL_CellLine_Old
go
drop table GXD_Genotype_Old
go

/* add a new reference association type, to be used in flagging a transmission
 * reference for alleles
 */

declare @nextType integer
select @nextType = max(_RefAssocType_key) + 1
from MGI_RefAssocType

insert MGI_RefAssocType (_RefAssocType_key, _MGIType_key, assocType,
    allowOnlyOne)
values (@nextType, 11, "Transmission", 1)

insert MGI_RefAssocType (_RefAssocType_key, _MGIType_key, assocType,
    allowOnlyOne)
values (@nextType + 1, 11, "Mixed", 1)

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
EOSQL

# create indexes and keys on re-created tables

date | tee -a ${LOG}
echo "--- Adding indexes and keys on re-created tables" | tee -a ${LOG}

${SCHEMA}/key/ALL_Allele_create.object | tee -a ${LOG}
${SCHEMA}/key/ALL_CellLine_create.object | tee -a ${LOG}
${SCHEMA}/key/GXD_Genotype_create.object | tee -a ${LOG}
${SCHEMA}/index/ALL_Allele_create.object | tee -a ${LOG}
${SCHEMA}/index/ALL_CellLine_create.object | tee -a ${LOG}
${SCHEMA}/index/GXD_Genotype_create.object | tee -a ${LOG}

# do cleanup of logical databases for certain cell lines

date | tee -a ${LOG}
echo "--- Cleaning up logical dbs for certain cell lines" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

-- create an index just for the purposes of this migration, which will be
-- deleted later on

create nonclustered index idx_derivation_temp on ALL_CellLine (_Derivation_key, _CellLine_key)
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

/* set transmission = "germline" for alleles which either:
 * 1. have a "gene trapped" type, or
 * 2. have a mutant cell line with an ID and have MP annotations
 */

declare @germlineKey int
select @germlineKey = 3982951

declare @geneTrapped int
select @geneTrapped = vt._Term_key
    from VOC_Term vt, VOC_Vocab vv
    where vv.name = "Allele Type"
	and vv._Vocab_key = vt._Vocab_key
	and vt.term = "Gene trapped"

update ALL_Allele
set _Transmission_key = @germlineKey
from ALL_Allele a
where (a._Allele_Type_key = @geneTrapped) or
(exists (select 1 from ALL_Allele_CellLine c, ACC_Accession aa
	where a._Allele_key = c._Allele_key
		and c._MutantCellLine_key = aa._Object_key
		and aa._MGIType_key = 28)
and exists (select 1 from GXD_AlleleGenotype g, VOC_Annot va
		where a._Allele_key = g._Allele_key
			and g._Genotype_key = va._Object_key
			and va._AnnotType_key = 1002) )
go

/* set transmission = "not applicable" for alleles which have no cell lines
 * or which have no cell lines with IDs
 */
declare @notappKey int
select @notappKey = 3982955

update ALL_Allele
set _Transmission_key = @notappKey
from ALL_Allele a
where not exists (select 1 from ALL_Allele_CellLine c, ACC_Accession aa
	where a._Allele_key = c._Allele_key
		and c._MutantCellLine_key = aa._Object_key
		and aa._MGIType_key = 28)
go

/* delete mutant cell lines which have no associated alleles */

delete ALL_CellLine
from ALL_CellLine c
where c.isMutant = 1
and not exists (select 1 from ALL_Allele_CellLine a
	where c._CellLine_key = a._MutantCellLine_key)
go

/* ensure that all mutant cell lines have the same strain as their parent
 * cell lines
 */

select d._Derivation_key, p._Strain_key	
into #tmp_derivStrain
from ALL_CellLine_Derivation d, ALL_CellLine p
where d._ParentCellLine_key = p._CellLine_key
go

create nonclustered index idx_derStrain on #tmp_derivStrain (_Derivation_key, _Strain_key)
go

update ALL_CellLine
set _Strain_key = d._Strain_key
from ALL_CellLine c, #tmp_derivStrain d
where c._Derivation_key = d._Derivation_key
  and c._Strain_key != d._Strain_key
go

drop table #tmp_derivStrain
go

drop index ALL_CellLine.idx_derivation_temp
go
EOSQL

# delete old, now-defunct gene trap lite IDs associated with markers

date | tee -a ${LOG}
echo "--- Removing old gene trap lite IDs for markers" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

delete ACC_Accession
from ACC_Accession a,
	MGI_Set s,
	MGI_SetMember m
where a._MGIType_key = 2		-- marker
	and a._LogicalDB_key = m._Object_key
	and m._Set_key = s._Set_key
	and s.name = "Gene Traps"
go
EOSQL

# for "gene trap" alleles which do not have mutation type "Insertion of gene
# trap vector", add it

date | tee -a ${LOG}
echo "--- Adding mutation type for some gene trap alleles" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

declare @geneTrapType integer
select @geneTrapType = _Term_key
from VOC_Term
where _Vocab_key = 38
and term = "Gene Trapped"

declare @mutation integer
select @mutation = _Term_key
from VOC_Term
where _Vocab_key = 36
and term = "Insertion of gene trap vector"

insert ALL_Allele_Mutation
select a._Allele_key, @mutation, a.creation_date, a.modification_date
from ALL_Allele a
where a._Allele_Type_key = @geneTrapType
and not exists (select 1 from ALL_Allele_Mutation m
	where a._Allele_key = m._Allele_key
	and m._Mutation_key = @mutation)
go
EOSQL

# add the transmission references

date | tee -a ${LOG}
echo "--- Adding transmission references" | tee -a ${LOG}
./updateTransmissionRefs.py ${MGD_DBUSER} ${MGI_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME} > transmissionRefs.txt

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
${SCHEMA}/procedure/ALL_cacheMarker_create.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/ALL_cacheMarker_grant.object | tee -a ${LOG}

# create triggers on re-created tables

date | tee -a ${LOG}
echo "--- Adding triggers on re-created tables" | tee -a ${LOG}

${SCHEMA}/trigger/ALL_CellLine_create.object | tee -a ${LOG}
${SCHEMA}/trigger/ALL_Allele_create.object | tee -a ${LOG}
${SCHEMA}/trigger/GXD_Genotype_create.object | tee -a ${LOG}

# since some ALL_* triggers seem to be missing, recreate them all

${SCHEMA}/trigger/ALL_drop.logical | tee -a ${LOG}
${SCHEMA}/trigger/ALL_create.logical | tee -a ${LOG}

# update statistics for the new tables, so the indexes will be optimal

date | tee -a ${LOG}
echo "--- Updating statistics on new tables (to optimize indexes)" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update statistics SEQ_Allele_Assoc
update statistics SEQ_GeneTrap
update statistics ALL_CellLine_Derivation
update statistics ALL_Allele_CellLine
update statistics ALL_Marker_Assoc
update statistics ALL_Allele
update statistics ALL_CellLine
update statistics GXD_Genotype
go
EOSQL

# population of SEQ_Allele_Assoc is done by the GT data load (sc)
# population of SEQ_GeneTrap is done by the GT data load (sc)

###--------------------###
###--- add new view ---###
###--------------------###

date | tee -a ${LOG}
echo "--- Adding new view(s)" | tee -a ${LOG}

# add other new views and their permissions

${SCHEMA}/view/ALL_Allele_CellLine_View_create.object | tee -a ${LOG}
${PERMS}/public/view/ALL_Allele_CellLine_View_grant.object | tee -a ${LOG}

${SCHEMA}/view/ALL_CellLine_Derivation_View_create.object | tee -a ${LOG}
${PERMS}/public/view/ALL_CellLine_Derivation_View_grant.object | tee -a ${LOG}

${SCHEMA}/view/ALL_CellLine_Summary_View_create.object | tee -a ${LOG}
${PERMS}/public/view/ALL_CellLine_Summary_View_grant.object | tee -a ${LOG}

${SCHEMA}/view/ALL_Derivation_Summary_View_create.object | tee -a ${LOG}
${PERMS}/public/view/ALL_Derivation_Summary_View_grant.object | tee -a ${LOG}

${SCHEMA}/view/ALL_Allele_Strain_View_create.object | tee -a ${LOG}
${PERMS}/public/view/ALL_Allele_Strain_View_grant.object | tee -a ${LOG}

${SCHEMA}/view/ALL_Marker_Assoc_View_create.object | tee -a ${LOG}
${PERMS}/public/view/ALL_Marker_Assoc_View_grant.object | tee -a ${LOG}

${SCHEMA}/view/ALL_CellLine_Strain_View_create.object | tee -a ${LOG}
${PERMS}/public/view/ALL_CellLine_Strain_View_grant.object | tee -a ${LOG}

${SCHEMA}/view/MAP_Feature_View_create.object | tee -a ${LOG}
${PERMS}/public/view/MAP_Feature_View_grant.object | tee -a ${LOG}

${SCHEMA}/view/SEQ_Allele_View_create.object | tee -a ${LOG}
${PERMS}/public/view/SEQ_Allele_View_grant.object | tee -a ${LOG}

${SCHEMA}/view/SEQ_Allele_Assoc_View_create.object | tee -a ${LOG}
${PERMS}/public/view/SEQ_Allele_Assoc_View_grant.object | tee -a ${LOG}

${SCHEMA}/view/VOC_Term_ALLTransmission_View_create.object | tee -a ${LOG}
${PERMS}/public/view/VOC_Term_ALLTransmission_View_grant.object | tee -a ${LOG}

# hook up the new summary views to their respective objects

date | tee -a ${LOG}
echo "--- Link MGI Type to new summary views for derivations and cell lines" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update ACC_MGIType
set dbView = "ALL_Derivation_Summary_View"
where name = "Cell Line Derivation"

update ACC_MGIType
set dbView = "ALL_CellLine_Summary_View"
where name = "ES Cell Line"
go
EOSQL

# run the translation loads, now that we have the new views hooked up

date | tee -a ${LOG}
echo "--- Running translation load (twice)" | tee -a ${LOG}

${TRANSLATIONLOAD}/translationload.csh /mgi/all/wts_projects/7400/7493/CleanUp_Migration/deriv_translationload/input/derivation.config | tee -a ${LOG}
${TRANSLATIONLOAD}/translationload.csh /mgi/all/wts_projects/7400/7493/CleanUp_Migration/parent_translationload/input/parent.config | tee -a ${LOG}

# update old views and recreate their permissions

date | tee -a ${LOG}
echo "--- Updating old view(s)" | tee -a ${LOG}

${PERMS}/public/view/ALL_Allele_View_revoke.object | tee -a ${LOG}
${SCHEMA}/view/ALL_Allele_View_drop.object | tee -a ${LOG}
${SCHEMA}/view/ALL_Allele_View_create.object | tee -a ${LOG}
${PERMS}/public/view/ALL_Allele_View_grant.object | tee -a ${LOG}

${PERMS}/public/view/ALL_CellLine_View_revoke.object | tee -a ${LOG}
${SCHEMA}/view/ALL_CellLine_View_drop.object | tee -a ${LOG}
${SCHEMA}/view/ALL_CellLine_View_create.object | tee -a ${LOG}
${PERMS}/public/view/ALL_CellLine_View_grant.object | tee -a ${LOG}

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

${PERMS}/public/view/IMG_ImagePane_Assoc_View_revoke.object | tee -a ${LOG}
${SCHEMA}/view/IMG_ImagePane_Assoc_View_drop.object | tee -a ${LOG}
${SCHEMA}/view/IMG_ImagePane_Assoc_View_create.object | tee -a ${LOG}
${PERMS}/public/view/IMG_ImagePane_Assoc_View_grant.object | tee -a ${LOG}

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

${SCHEMA}/procedure/MGI_deletePrivateData_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/MGI_deletePrivateData_create.object | tee -a ${LOG}

${PERMS}/curatorial/procedure/MRK_updateKeys_revoke.object | tee -a ${LOG}
${SCHEMA}/procedure/MRK_updateKeys_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/MRK_updateKeys_create.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/MRK_updateKeys_grant.object | tee -a ${LOG}

${PERMS}/curatorial/procedure/NOM_transferToMGD_revoke.object | tee -a ${LOG}
${SCHEMA}/procedure/NOM_transferToMGD_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/NOM_transferToMGD_create.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/NOM_transferToMGD_grant.object | tee -a ${LOG}

###------------------------------------------------------------------------###
###--- give up and re-do everything, since Sybase randomly loses pieces ---###
###------------------------------------------------------------------------###

date | tee -a ${LOG}
echo "--- Remove mgddbschema logs" | tee -a ${LOG}
${SCHEMA}/removelogs.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Run reconfig.csh" | tee -a ${LOG}
${SCHEMA}/reconfig.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Revoke perms" | tee -a ${LOG}
${PERMS}/all_revoke.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Grant perms" | tee -a ${LOG}
${PERMS}/all_grant.csh | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

# load the lab codes (fake for now)

date | tee -a ${LOG}
echo "--- Loading lab codes" | tee -a ${LOG}
cd mockups
./loadFakeLabCodes.csh | tee -a ${LOG}
cd ..
echo "--- Returned from loading lab codes" | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

#dump_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/jsb/tr7493.merged. | tee -a ${LOG}
#date | tee -a ${LOG}
#echo "--- Finished database dump" | tee -a ${LOG}
