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

-- allele types
select t._Term_key, substring(t.term,1,30) as term
from VOC_Term t
where t._Vocab_key = 38
order by term
go

-- allele subtype
select t._Term_key, substring(t.term,1,30) as term
from VOC_Term t
where t._Vocab_key = 93
order by term
go

-- count of allele types
select a._Allele_Type_key, substring(t.term,1,30) as term, count(a._Allele_key)
from ALL_Allele a, VOC_Term t
where a._Allele_Type_key = t._Term_key
group by a._Allele_Type_key, t.term
order by term
go

EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

