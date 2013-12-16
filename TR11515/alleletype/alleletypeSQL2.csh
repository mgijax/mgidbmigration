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

-- verify
select _Term_key, substring(term,1,50) from VOC_Term where _Vocab_key = 38 order by term
go

select vv._Term_key, substring(vv.term,1,50)
from VOC_Vocab v, VOC_Term vv 
where v.name = 'Allele Subtype' 
and v._Vocab_key = vv._Vocab_key
go

-- should return (0) results
select a.symbol, a._Allele_key, a._Allele_Type_key, t.term
from ALL_Allele a, VOC_Term t
where a._Allele_Type_key = t._Term_key
and t.term in (
 'Targeted (Floxed/Frt)',
 'Targeted (knock-in)',
 'Targeted (knock-out)',
 'Targeted (other)',
 'Targeted (Reporter)',
 'Transgenic (Cre/Flp)',
 'Transgenic (random, expressed)',
 'Transgenic (random, gene disruption)',
 'Transgenic (Reporter)',
 'Transgenic (Transposase)'
)
order by a.symbol
go

-- should return (0) results
select a.name, a._Derivation_key, a._DerivationType_key, t.term
from ALL_CellLine_Derivation a, VOC_Term t
where a._DerivationType_key = t._Term_key
and t.term in (
 'Targeted (Floxed/Frt)',
 'Targeted (knock-in)',
 'Targeted (knock-out)',
 'Targeted (other)',
 'Targeted (Reporter)',
 'Transgenic (Cre/Flp)',
 'Transgenic (random, expressed)',
 'Transgenic (random, gene disruption)',
 'Transgenic (Reporter)',
 'Transgenic (Transposase)'
)
order by a.name
go

-- should return (?) results
select count(a._Allele_key)
from ALL_Allele a, VOC_Term t
where a._Allele_Type_key = t._Term_key
and t.term in (
 'Targeted',
 'Endonuclease-mediated',
 'Transposon Concatemer',
 'Transgenic'
)
go

-- should return (2) results
select distinct t.term
from ALL_CellLine_Derivation a, VOC_Term t
where a._DerivationType_key = t._Term_key
and t.term in (
 'Targeted',
 'Endonuclease-mediated',
 'Transposon Concatemer',
 'Transgenic',
 'Other (see notes)'
)
go

-- should return (0) results
select t.*
from VOC_Term t
where t._Vocab_key = 38
and not exists (select 1 from ALL_Allele a where t._Term_key = a._Allele_Type_key)
and not exists (select 1 from ALL_CellLine_Derivation a where t._Term_key = a._DerivationType_key)
and t.term not in ('Endonuclease-mediated', 'Transposon Concatemer', 'Other (see notes)')
go

EOSQL
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

