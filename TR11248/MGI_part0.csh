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
	setenv MGICONFIG /usr/local/mgi/scrum-dog/mgiconfig
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
${MGDDBSCHEMADIR}/trigger/ALL_Allele_drop.object | tee -a ${LOG}
${MGDDBSCHEMADIR}/trigger/ALL_Allele_create.object | tee -a ${LOG}
${MGDDBSCHEMADIR}/procedure/GXD_loadCacheByAssay_drop.object | tee -a ${LOG}
${MGDDBSCHEMADIR}/procedure/GXD_loadCacheByAssay_create.object | tee -a ${LOG}
${MGDDBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

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

update GXD_Expression
set isForGXD = 1, isRecombinase = 0
from GXD_Expression
where _AssayType_key not in (10,11)
go

update GXD_Expression
set isForGXD = 0, isRecombinase = 1
from GXD_Expression
where _AssayType_key in (10,11)
go

update GXD_Expression
set isForGXD = 1, isRecombinase = 1
from GXD_Expression e, GXD_Assay a, VOC_Term t
where e._AssayType_key in (9)
and e._Assay_key = a._Assay_key
and a._ReporterGene_key = t._Term_key
and t.term in ('Cre', 'FLP')
go

select count(*) from GXD_Expression where isForGXD = 1 and isRecombinase = 0
go
select count(*) from GXD_Expression where isForGXD = 0 and isRecombinase = 1
go
select count(*) from GXD_Expression where isForGXD = 0 and isRecombinase = 1 and _AssayType_key = 10
go
select count(*) from GXD_Expression where isForGXD = 0 and isRecombinase = 1 and _AssayType_key = 11
go
select count(*) from GXD_Expression where isForGXD = 1 and isRecombinase = 0
go
select count(*) from GXD_Expression where isForGXD = 1 and isRecombinase = 1
go

EOSQL
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

