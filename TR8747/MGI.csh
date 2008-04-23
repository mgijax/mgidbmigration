#!/bin/csh -fx

#
# Migration for TR8747 -- 4.0x maintenance release
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration
setenv CWD `pwd`	# current working directory

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "Starting in ${CWD}..." | tee -a ${LOG}

# load a backup

load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}
date | tee -a ${LOG}

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

date | tee -a ${LOG}
echo "Updating version numbers in db..." | tee -a ${LOG}

# number references in comments are to sections of schema doc GeneTrapLF.pdf

${UTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.02" | tee -a ${LOG}
${UTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-0-2-0" | tee -a ${LOG}

###----------------------------###
###--- load new vocab terms ---###
###----------------------------###

setenv JNUM "J:1"
setenv DB_PARMS "${MGD_DBUSER} ${MGI_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME}"

date | tee -a ${LOG}
echo "Loading vocabularies..." | tee -a ${LOG}

cd ${CWD}

./loadSimpleVocab.py assayTypes.txt "GXD Assay Types" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}
./loadSimpleVocab.py strainTypes.txt "New Strain Type" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}
./loadSimpleVocab.py needsReview.txt "Needs Review" ${JNUM} 1 ${DB_PARMS} | tee -a ${LOG}

###---------------------------------###
###--- Build Set of recombinases ---###
###---------------------------------###

date | tee -a ${LOG}
echo "Building set of recombinases" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

declare @termType integer
select @termType = _MGIType_key
from ACC_MGIType
where name = "Vocabulary Term"

declare @setKey integer
select @setKey = max(_Set_key) + 1 from MGI_Set

insert MGI_Set (_Set_key, _MGIType_key, name, sequenceNum)
values (@setKey, @termType, "Recombinases", 1)
go

declare termCursor cursor for
select vt._Term_key
from VOC_Term vt, VOC_Vocab vv
where vv.name = "GXD Reporter Genes"
	and vv._Vocab_key = vt._Vocab_key
	and vt.term in ("Cre")			-- add others here
for read only
go

declare @termKey integer

declare @recombinaseSet integer
select @recombinaseSet = _Set_key from MGI_Set where name = "Recombinases"

declare @setMemberKey integer
select @setMemberKey = max(_SetMember_key) from MGI_SetMember

declare @seqNum integer
select @seqNum = 1

open termCursor
fetch termCursor into @termKey

while (@@sqlstatus = 0)
begin
    insert MGI_SetMember (_SetMember_key, _Set_key, _Object_key, sequenceNum)
    values (@setMemberKey + @seqNum, @recombinaseSet, @termKey, @seqNum)

    select @seqNum = @seqNum + 1
    fetch termCursor into @termKey
end

close termCursor
deallocate cursor termCursor

go
EOSQL

###-----------------------------------------------------###
###--- Restructure MGI_Set and MGI_SetMember indexes ---###
###-----------------------------------------------------###

date | tee -a ${LOG}
echo "Restructuring MGI_Set and MGI_SetMember indexes" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

/* drop old indexes */

drop index MGI_SetMember.index_SetMember_key
go

drop index MGI_SetMember.index_Set_key
go

drop index MGI_SetMember.index_Object_key
go

drop index MGI_Set.index_Set_key
go

drop index MGI_Set.index_MGIType_key
go
EOSQL

# create new indexes
${SCHEMA}/index/MGI_Set_create.object | tee -a ${LOG}
${SCHEMA}/index/MGI_SetMember_create.object | tee -a ${LOG}

###-----------------------------------###
###--- update GXD_Expression table ---###
###-----------------------------------###

date | tee -a ${LOG}
echo "Renaming old GXD_Expression" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* We could drop the existing GXD_Expression cache table, recreate it, and
 * repopulate it using the GXD_loadCacheAll stored procedure.  That's very
 * slow (about an hour), though, so instead we will:
 * 	1. rename existing table
 * 	2. create new table
 * 	3. use old table to populate new table, plus two new columns
 * 	4. drop old table
 * 	5. add indexes, keys, etc. to new table
 */

sp_rename GXD_Expression, GXD_Expression_Old
go
EOSQL

date | tee -a ${LOG}
echo "Creating and populating GXD_Expression" | tee -a ${LOG}
${SCHEMA}/table/GXD_Expression_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* To load the new table initially, we will assume (isRecombinase = 0),
 * (isForGXD = 1), and (hasImage = 0).  We will then adjust the other cases
 * as needed.
 */
insert GXD_Expression
select _Expression_key, _Assay_key, _Refs_key, _AssayType_key, _Genotype_key,
	_Marker_key, _Structure_key, expressed, age, ageMin, ageMax,
	0, 1, 0, creation_date, modification_date
from GXD_Expression_Old
go
EOSQL

# Before doing the follow-up queries to fix the new isForGXD and isRecombinase
# fields, we add the indexes onto the new table.  This should help the
# performance of the follow-up queries.

date | tee -a ${LOG}
echo "Adding indexes for GXD_Expression" | tee -a ${LOG}
${SCHEMA}/index/GXD_Expression_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "Fixing new isForGXD and isRecombinase fields" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update GXD_Expression
set isForGXD = 0
where _Expression_key in (select ge._Expression_key
	from GXD_Expression ge, GXD_AssayType t
	where ge._AssayType_key = t._AssayType_key
		and t.assayType in ("in situ transgenic",
			"indirect transgenic", "indirect knock-in") )
go

update GXD_Expression
set isRecombinase = 1
where (isForGXD = 0)
	or _Assay_key in (select ga._Assay_key
		from GXD_Assay ga, MGI_SetMember msm, MGI_Set ms
		where ga._ReporterGene_key = msm._Object_key
			and msm._Set_key = ms._Set_key
			and ms.name = "Recombinases")
go

/* gels */
update GXD_Expression
set hasImage = 1
where _Assay_key in (select _Assay_key
		from GXD_Assay
		where _ImagePane_key != null)
go

/* in situ */
update GXD_Expression
set hasImage = 1
where _Expression_key in (select ge._Expression_key
		from GXD_Expression ge,
			GXD_Specimen gs, 
			GXD_InSituResult ir,
			GXD_ISResultStructure irs,
			GXD_InSituResultImage iri
		where ge._Assay_key = gs._Assay_key
			and ge._Genotype_key = gs._Genotype_key
			and gs._Specimen_key = ir._Specimen_key
			and ge._Structure_key = irs._Structure_key
			and ir._Result_key = irs._Result_key
			and ir._Result_key = iri._Result_key)
go
EOSQL

date | tee -a ${LOG}
echo "Adding defaults for GXD_Expression" | tee -a ${LOG}
${SCHEMA}/default/GXD_Expression_bind.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "Adding keys for GXD_Expression" | tee -a ${LOG}
${SCHEMA}/key/GXD_Expression_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "Adding permissions for GXD_Expression" | tee -a ${LOG}
${PERMS}/public/table/GXD_Expression_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/GXD_Expression_grant.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "Recreating triggers which use GXD_Expression" | tee -a ${LOG}
${SCHEMA}/trigger/GXD_Expression_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/GXD_AssayType_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/GXD_Assay_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/GXD_Genotype_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/GXD_Structure_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/GXD_Expression_create.object | tee -a ${LOG}
${SCHEMA}/trigger/GXD_AssayType_create.object | tee -a ${LOG}
${SCHEMA}/trigger/GXD_Assay_create.object | tee -a ${LOG}
${SCHEMA}/trigger/GXD_Genotype_create.object | tee -a ${LOG}
${SCHEMA}/trigger/GXD_Structure_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "Recreating foreign key relationships for GXD_Expression" | tee -a ${LOG}
${SCHEMA}/key/BIB_Refs_drop.object | tee -a ${LOG}
${SCHEMA}/key/GXD_AssayType_drop.object | tee -a ${LOG}
${SCHEMA}/key/GXD_Assay_drop.object | tee -a ${LOG}
${SCHEMA}/key/GXD_Genotype_drop.object | tee -a ${LOG}
${SCHEMA}/key/GXD_Structure_drop.object | tee -a ${LOG}
${SCHEMA}/key/MRK_Marker_drop.object | tee -a ${LOG}
${SCHEMA}/key/BIB_Refs_create.object | tee -a ${LOG}
${SCHEMA}/key/GXD_AssayType_create.object | tee -a ${LOG}
${SCHEMA}/key/GXD_Assay_create.object | tee -a ${LOG}
${SCHEMA}/key/GXD_Genotype_create.object | tee -a ${LOG}
${SCHEMA}/key/GXD_Structure_create.object | tee -a ${LOG}
${SCHEMA}/key/MRK_Marker_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "Recreating procedures that use GXD_Expression" | tee -a ${LOG}
${SCHEMA}/procedure/GXD_getGenotypesDataSets_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/GXD_loadCacheAll_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/GXD_loadCacheByAssay_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/MGI_resetAgeMinMax_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/MGI_searchGenotypeByRef_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/PRB_getStrainByReference_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/PRB_getStrainReferences_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/GXD_getGenotypesDataSets_create.object | tee -a ${LOG}
${SCHEMA}/procedure/GXD_loadCacheByAssay_create.object | tee -a ${LOG}
${SCHEMA}/procedure/GXD_loadCacheAll_create.object | tee -a ${LOG}
${SCHEMA}/procedure/MGI_resetAgeMinMax_create.object | tee -a ${LOG}
${SCHEMA}/procedure/MGI_searchGenotypeByRef_create.object | tee -a ${LOG}
${SCHEMA}/procedure/PRB_getStrainByReference_create.object | tee -a ${LOG}
${SCHEMA}/procedure/PRB_getStrainReferences_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "Adding permissions for those procedures" | tee -a ${LOG}
${PERMS}/public/procedure/GXD_getGenotypesDataSets_grant.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/GXD_loadCacheAll_grant.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/GXD_loadCacheByAssay_grant.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/MGI_resetAgeMinMax_grant.object | tee -a ${LOG}
${PERMS}/public/procedure/MGI_searchGenotypeByRef_grant.object | tee -a ${LOG}
${PERMS}/public/procedure/PRB_getStrainByReference_grant.object | tee -a ${LOG}
${PERMS}/public/procedure/PRB_getStrainReferences_grant.object | tee -a ${LOG}

###---------------------------###
###--- image cache updates ---###
###---------------------------###

# Alter the IMG_Cache table to also accommodate phenotype images by:
# 	1. allowing _AssayType_key to be null
# 	2. allowing assayType to be null
# Note that paneLabel already allows null values, which is good for this.

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

alter table IMG_Cache modify _AssayType_key null
go

alter table IMG_Cache modify assayType null
go
EOSQL

###-------------------------------###
###--- update PRB_Strain table ---###
###-------------------------------###

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* To update the PRB_Strain cache table, we will:
 * 	1. rename existing table
 * 	2. create new table
 * 	3. use old table to populate new table
 * 	4. drop old table
 * 	5. add indexes, keys, etc. to new table
 */

sp_rename PRB_Strain, PRB_Strain_Old
go
EOSQL

date | tee -a ${LOG}
echo "Creating and populating PRB_Strain" | tee -a ${LOG}
${SCHEMA}/table/PRB_Strain_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update VOC_Vocab
set name = "Strain Attributes"
where name = "Strain Type"
go

update VOC_Vocab
set name = "Strain Type"
where name = "New Strain Type"
go

declare @notSpecifiedType integer
select @notSpecifiedType = vt._Term_key
from VOC_Vocab vv, VOC_Term vt
where vv.name = "Strain Type"
and vv._Vocab_key = vt._Vocab_key
and vt.term = "Not Specified"

insert PRB_Strain
select _Strain_key, _Species_key, @notSpecifiedType, strain, standard,
	private, _CreatedBy_key, _ModifiedBy_key, creation_date,
	modification_date
from PRB_Strain_Old
go

declare @needsReviewType integer
select @needsReviewType = max(_AnnotType_key) + 1
from VOC_AnnotType

declare @strainAttributesType integer
select @strainAttributesType = max(_AnnotType_key) + 2
from VOC_AnnotType

declare @strainType integer
select @strainType = _MGIType_key
from ACC_MGIType
where name = "Strain"

declare @needsReviewVocab integer
select @needsReviewVocab = _Vocab_key
from VOC_Vocab
where name = "Needs Review"

declare @strainAttributesVocab integer
select @strainAttributesVocab = _Vocab_key
from VOC_Vocab
where name = "Strain Attributes"

/* 53 = "generic annotation qualifier" vocab
 *
 * Follow precendent of super standard strains -- if no evidence vocab is
 * needed, just refer to the same vocab
 */

insert VOC_AnnotType (_AnnotType_key, _MGIType_key, _Vocab_key,
	_EvidenceVocab_key, _QualifierVocab_key, name)
values (@needsReviewType, @strainType, @needsReviewVocab, 
	@needsReviewVocab, 53, "Strain/Needs Review")

insert VOC_AnnotType (_AnnotType_key, _MGIType_key, _Vocab_key,
	_EvidenceVocab_key, _QualifierVocab_key, name)
values (@strainAttributesType, @strainType, @strainAttributesVocab, 
	@strainAttributesVocab, 53, "Strain/Attributes")
go

-- migrate PRB_Strain.needsReview to VOC_Annot

declare needsReviewCursor cursor for
select _Strain_key
from PRB_Strain_Old
where needsReview = 1
for read only
go

declare @nrAnnotType integer
select @nrAnnotType = _AnnotType_key
from VOC_AnnotType
where name = "Strain/Needs Review"

declare @needsReviewTerm integer
select @needsReviewTerm = vt._Term_key
from VOC_Vocab vv, VOC_Term vt
where vv.name = "Needs Review"
and vv._Vocab_key = vt._Vocab_key
and vt.term = "Needs Review - nomen"

declare @qualifierKey integer
select @qualifierKey = vt._Term_key
from VOC_Vocab vv, VOC_Term vt
where vv.name = "Generic Annotation Qualifier"
and vv._Vocab_key = vt._Vocab_key
and vt.term = null

declare @strainKey integer

declare @annotKey integer
select @annotKey = max(_Annot_key) from VOC_Annot

declare @seqNum integer
select @seqNum = 1

open needsReviewCursor
fetch needsReviewCursor into @strainKey

while (@@sqlstatus = 0)
begin
    insert VOC_Annot (_Annot_key, _AnnotType_key, _Object_key, 
	_Term_key, _Qualifier_key)
    values (@annotKey + @seqNum, @nrAnnotType, @strainKey, 
	@needsReviewTerm, @qualifierKey)

    select @seqNum = @seqNum + 1
    fetch needsReviewCursor into @strainKey
end

close needsReviewCursor
deallocate cursor needsReviewCursor
go

-- migrate PRB_Strain_Type to VOC_Annot

declare strainTypeCursor cursor for
select _Strain_key, _StrainType_key
from PRB_Strain_Type
for read only
go

declare @strainTypeKey integer
declare @strainKey integer

declare @seqNum integer
select @seqNum = 1

declare @annotKey integer
select @annotKey = max(_Annot_key) from VOC_Annot

declare @qualifierKey integer
select @qualifierKey = vt._Term_key
from VOC_Vocab vv, VOC_Term vt
where vv.name = "Generic Annotation Qualifier"
and vv._Vocab_key = vt._Vocab_key
and vt.term = null

declare @strainAttributesType integer
select @strainAttributesType = _AnnotType_key
from VOC_AnnotType
where name = "Strain/Attributes"

open strainTypeCursor
fetch strainTypeCursor into @strainKey, @strainTypeKey

while (@@sqlstatus = 0)
begin
    insert VOC_Annot (_Annot_key, _AnnotType_key, _Object_key, 
	_Term_key, _Qualifier_key)
    values (@annotKey + @seqNum, @strainAttributesType, @strainKey, 
	@strainTypeKey, @qualifierKey)

    select @seqNum = @seqNum + 1
    fetch strainTypeCursor into @strainKey, @strainTypeKey
end

close strainTypeCursor
deallocate cursor strainTypeCursor
go
EOSQL

date | tee -a ${LOG}
echo "Adding indexes to PRB_Strain" | tee -a ${LOG}

${SCHEMA}/index/PRB_Strain_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "(Re)Creating procedures and views" | tee -a ${LOG}

${SCHEMA}/view/PRB_Strain_View_drop.object | tee -a ${LOG}
${SCHEMA}/view/PRB_Strain_View_create.object | tee -a ${LOG}
${SCHEMA}/procedure/PRB_setStrainReview_create.object | tee -a ${LOG}
${SCHEMA}/view/PRB_Strain_NeedsReview_View_create.object | tee -a ${LOG}
${SCHEMA}/view/PRB_Strain_Attribute_View_create.object | tee -a ${LOG}
${SCHEMA}/view/VOC_Term_NeedsReview_View_create.object | tee -a ${LOG}
${SCHEMA}/view/VOC_Term_StrainAttribute_View_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "Recreating strains-related triggers" | tee -a ${LOG}

${SCHEMA}/trigger/ALL_Allele_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/ALL_Allele_create.object | tee -a ${LOG}
${SCHEMA}/trigger/PRB_Strain_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/PRB_Strain_create.object | tee -a ${LOG}
${SCHEMA}/trigger/VOC_Term_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/VOC_Term_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "Adding defaults to PRB_Strain" | tee -a ${LOG}

${SCHEMA}/default/PRB_Strain_bind.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "Recreating procedures that used needsReview bit" | tee -a ${LOG}

${SCHEMA}/procedure/PRB_mergeStrain_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/PRB_mergeStrain_create.object | tee -a ${LOG}
${SCHEMA}/procedure/MRK_simpleWithdrawal_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/MRK_simpleWithdrawal_create.object | tee -a ${LOG}
${SCHEMA}/procedure/MRK_updateKeys_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/MRK_updateKeys_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "Adding permissions for newly created structures" | tee -a ${LOG}

${PERMS}/public/table/PRB_Strain_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/PRB_Strain_grant.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/MRK_updateKeys_grant.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/MRK_simpleWithdrawal_grant.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/PRB_mergeStrain_grant.object | tee -a ${LOG}
${PERMS}/curatorial/procedure/PRB_setStrainReview_grant.object | tee -a ${LOG}
${PERMS}/public/view/PRB_Strain_NeedsReview_View_grant.object | tee -a ${LOG}
${PERMS}/public/view/PRB_Strain_Attribute_View_grant.object | tee -a ${LOG}
${PERMS}/public/view/PRB_Strain_View_grant.object | tee -a ${LOG}
${PERMS}/public/view/VOC_Term_NeedsReview_View_grant.object | tee -a ${LOG}
${PERMS}/public/view/VOC_Term_StrainAttribute_View_grant.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "Removing old tables and views" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

drop table GXD_Expression_Old
go

drop table PRB_Strain_Type
go

drop table PRB_Strain_Old
go

drop view PRB_Strain_Type_View
go
EOSQL

###--------------------------------###
###--- load "inferred from" IDs ---###
###--------------------------------###

date | tee -a ${LOG}
echo "Loading InferredFrom IDs to ACC_Accession" | tee -a ${LOG}

${MGICACHELOAD}/inferredfrom.py -U ${MGI_DBUSER} -P ${MGI_DBPASSWORDFILE} -S ${MGD_DBSERVER} -D ${MGD_DBNAME} -v | tee -a ${LOG}

###--------------------------###
###--- reload image cache ---###
###--------------------------###

date | tee -a ${LOG}
echo "Reloading image cache (IMG_Cache)" | tee -a ${LOG}

${MGICACHELOAD}/imgcache.csh | tee -a ${LOG}

###--------------------------------------###
###--- updating GXD stats definitions ---###
###--------------------------------------###

date | tee -a ${LOG}
echo "Updating GXD stats definitions" | tee -a ${LOG}

./updateStats.py ${MGD_DBSERVER} ${MGD_DBNAME} ${MGI_DBUSER} ${MGI_DBPASSWORDFILE} | tee -a ${LOG}

###----------------------------------###
###--- load Allen Brain Atlas IDs ---###
###----------------------------------###

date | tee -a ${LOG}
echo "Loading Allen Brain Atlas IDs" | tee -a ${LOG}

${ABALOAD}/abaload.sh /data/downloads/www.brain-map.org/pdf/allGenes.csv | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "Finished migration" | tee -a ${LOG}

dump_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/jsb/tr8747. | tee -a ${LOG}
date | tee -a ${LOG}
echo "Finished database dump" | tee -a ${LOG}

