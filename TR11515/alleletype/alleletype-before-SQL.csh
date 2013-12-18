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

-- count of allele types
select a._Allele_Type_key, substring(t.term,1,30) as term, count(a._Allele_key)
from ALL_Allele a, VOC_Term t
where a._Allele_Type_key = t._Term_key
group by a._Allele_Type_key, t.term
order by term
go

(
select aa.accID, 
substring(a.symbol,1,50) as symbol,
substring(t.term,1,50) as alleleType 
from ALL_Allele a, ACC_Accession aa, VOC_Term t
where a._Allele_Type_key = t._Term_key
and t.term in (
'Targeted (knock-out)',
'Targeted (knock-in)',
'Targeted (Floxed/Frt)',
'Targeted (Reporter)',
'Targeted (other)',
'Transgenic (Cre/Flp)',
'Transgenic (random, expressed)',
'Transgenic (random, gene disruption)',
'Transgenic (Reporter)',
'Transgenic (Transposase)'
)
and a._Allele_key = aa._Object_key
and aa._MGIType_key = 11
and aa._LogicalDB_key = 1

)
order by a.symbol, alleleType
go

EOSQL
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

