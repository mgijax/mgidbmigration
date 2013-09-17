#!/bin/csh -fx

#
# Migration for TR11423
# sto128 : add Disease Cluster vocabulary/dag
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/scrum-dog/mgiconfig
	#setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
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

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

