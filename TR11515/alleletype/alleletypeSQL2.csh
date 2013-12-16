#!/bin/csh -fx

#
# Migration for TR11515
#
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

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

-- should return (?) results
(
select a.symbol, substring(t.term,1,20) as term, substring(tt.term,1,50) as subtype
from ALL_Allele a, VOC_Term t, VOC_Annot va, VOC_Term tt
where a._Allele_Type_key = t._Term_key
and t.term in (
 'Targeted',
 'Endonuclease-mediated',
 'Transposon Concatemer',
 'Transgenic'
)
and a._Allele_key = va._Object_key
and va._AnnotType_key = 1014
and va._Term_key = tt._Term_key

union

select a.symbol, substring(t.term,1,20) as term, null
from ALL_Allele a, VOC_Term t
where a._Allele_Type_key = t._Term_key
and t.term in (
 'Targeted',
 'Endonuclease-mediated',
 'Transposon Concatemer',
 'Transgenic'
)
and not exists (select 1 from VOC_Annot va
	where a._Allele_key = va._Object_key and va._AnnotType_key = 1014
	)
)
order by a.symbol, t.term, subtype
go

EOSQL
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

