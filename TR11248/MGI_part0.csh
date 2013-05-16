#!/bin/csh -fx

#
# Migration for TR11248
# (part 0 - load new SNP vocabularies/translations into MGD/Sybase
#
# on Sybase: load new vocabularies
# dbsnpload/bin/loadTranslations.sh
# dbsnpload/bin/loadVoc.sh
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

#
# load Sybase/MGD backup into scrum-dog
# may need to load Sybase/SNP backup into scrum-dog
#
#date | tee -a ${LOG}
#${MGI_DBUTILS}/bin/load_db.csh ${MGDEXP_DBSERVER} ${MGDEXP_DBNAME} /backups/rohan/scrum-dog/mgd.backup | tee -a ${LOG}
#${MGI_DBUTILS}/bin/load_db.csh ${SNPEXP_DBSERVER} ${SNPEXP_DBNAME} /backups/rohan/scrum-dog/snp.backup | tee -a ${LOG}
#date | tee -a ${LOG}

#
# schema fix
#
date | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/ALL_Cre_Cache_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/ALL_Cre_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/ALL_Cre_Cache_bind.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/ALL_Cre_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/ALL_Cre_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/ALL_Allele_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Assay_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/GXD_Structure_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ALL_Allele_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ALL_Allele_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Assay_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_loadCacheByAssay_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_loadCacheByAssay_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/VOC_Cache_MP_Alleles_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/VOC_Cache_MP_Alleles_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/VOC_Cache_OMIM_Alleles_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/VOC_Cache_OMIM_Alleles_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/MGI_NoteType_Image_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/MGI_NoteType_Image_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/MGI_NoteType_Allele_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/MGI_NoteType_Allele_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/MGI_NoteType_AllDriver_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/MGI_NoteType_AllDriver_View_create.object | tee -a ${LOG}

# permissions
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

date | tee -a ${LOG}

# load new SNP Function Class
# load new SNP handler
date | tee -a ${LOG}
${VOCLOAD}/runDAGFullLoad.sh ${DBUTILS}/mgidbmigration/TR11248/fxnClass/fxnClassDag.config | tee -a ${LOG}
${VOCLOAD}/runSimpleFullLoadNoArchive.sh ${DBUTILS}/mgidbmigration/TR11248/fxnClass/subHandleVocab.config | tee -a ${LOG}
date | tee -a ${LOG}

# load new Translations (fxnClass.goodbad)
date | tee -a ${LOG}
${TRANSLATIONLOAD}/translationload.csh ${DBUTILS}/mgidbmigration/TR11248/fxnClass/fxnClassTrans.config | tee -a ${LOG}
date | tee -a ${LOG}

# make backup of mgd with snp changes
#date | tee -a ${LOG}
#${MGI_DBUTILS}/bin/dump_db.csh ${MGDEXP_DBSERVER} ${MGDEXP_DBNAME} /backups/rohan/scrum-dog/mgd-TR11248.backup
#date | tee -a ${LOG}

# update the MGI_dbinfo information
date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update MGI_dbinfo set 
	schema_version = '5-1-4', 
	public_version = 'MGI 5.14',
	snp_data_version = 'dbSNP Build 137'
go

/* create new note type */

declare @nextType integer
select @nextType = max(_NoteType_key) + 1 from MGI_NoteType
insert MGI_NoteType (_NoteType_key, _MGIType_key, noteType, private)
values (@nextType, 11, "User (Cre)", 0)
go

-- delete children prb_strain_marker where no parent
delete PRB_Strain_Marker
from PRB_Strain_Marker p
where not exists (select 1 from ALL_Allele a where p._Allele_key = a._Allele_key)
go

-- delete 'Recombinases' from MGI_Set
delete from MGI_Set where _Set_key = 1041

-- 1/0 if NOT 10,11
update GXD_Expression
set isForGXD = 1, isRecombinase = 0
from GXD_Expression
where _AssayType_key not in (10,11)
go

-- 0/1 if 10,11
update GXD_Expression
set isForGXD = 0, isRecombinase = 1
from GXD_Expression
where _AssayType_key in (10,11)
go

-- 1/0 if 9
update GXD_Expression
set isForGXD = 1, isRecombinase = 0
from GXD_Expression
where _AssayType_key in (9)
go

-- 1/1 if 9 with recombinase
update GXD_Expression
set isForGXD = 1, isRecombinase = 1
from GXD_Expression e, GXD_Assay a, VOC_Term t
where e._AssayType_key in (9)
and e._Assay_key = a._Assay_key
and a._ReporterGene_key = t._Term_key
and t.term in ('Cre', 'FLP')
go

EOSQL
date | tee -a ${LOG}

#
# allele-cre-cache
#
${ALLCACHELOAD}/allelecrecache.csh | tee -a ${LOG}

#
# sto135/migration Assay Notes/Specimen Notes
#
${DBUTILS}/mgidbmigration/TR11248/sto135.csh | tee -a ${LOG}

#
# some reports
#
${DBUTILS}/mgidbmigration/TR11248/cre.csh | tee -a ${LOG}
${DBUTILS}/mgidbmigration/TR11248/age.csh | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

