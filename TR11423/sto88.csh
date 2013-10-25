#!/bin/csh -fx

#
# Migration for TR11423
# sto88 : add new annotation type
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

# add new annotation type
date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

delete from VOC_AnnotType where name = "OMIM/Human Marker/Pheno"
go

declare @annotType integer
select @annotType = max(_AnnotType_key) + 1
from VOC_AnnotType

insert VOC_AnnotType (_AnnotType_key, _MGIType_key, _Vocab_key,
        _EvidenceVocab_key, _QualifierVocab_key, name)
values (@annotType, 2, 44, 43, 53, "OMIM/Human Marker/Pheno")
go

select * from VOC_AnnotType where name = "OMIM/Human Marker/Pheno"
go


EOSQL
date | tee -a ${LOG}

#
# entrezgeneload
#
${ENTREZGENELOAD}/human/annotations.csh | tee -a ${LOG}

# some femover/gather-ers use cache table(s)
${MRKCACHELOAD}/mrkomim.csh | tee -a ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select distinct a.accID, m.symbol
from VOC_Annot v, ACC_Accession a, MRK_Marker m
where v._AnnotType_key = 1013
and v._Term_key = a._Object_key
and a._LogicalDB_key = 15
and v._Object_key = m._Marker_key
order by m.symbol
go

EOSQL
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

