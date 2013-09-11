#!/bin/csh -f

#
# Migration for TR11423
# (part 0 - load new HDP annotation type & data)
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /home/lec/mgi/mgiconfig
	#setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh
echo $MGICONFIG
env | grep MGD

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
# change VOC_AnnotType.idx_MGITypeVocabEvidence index to non-unique
${MGD_DBSCHEMADIR}/index/VOC_AnnotType_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/VOC_AnnotType_create.object | tee -a ${LOG}
date | tee -a ${LOG}

# add new annotation type
date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update MGI_dbinfo set 
	schema_version = '5-1-6', 
	public_version = 'MGI 5.16'
go

delete from VOC_AnnotType where name = "OMIM/Human Marker/Phenotype"
go

declare @annotType integer
select @annotType = max(_AnnotType_key) + 1
from VOC_AnnotType

insert VOC_AnnotType (_AnnotType_key, _MGIType_key, _Vocab_key,
        _EvidenceVocab_key, _QualifierVocab_key, name)
values (@annotType, 2, 44, 43, 53, "OMIM/Human Marker/Phenotype")
go

EOSQL
date | tee -a ${LOG}

#
# entrezgeneload
#
#${ENTREZGENELOAD}/human/annotations.csh | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

