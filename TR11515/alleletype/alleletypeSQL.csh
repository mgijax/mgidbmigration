#!/bin/csh -f

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

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

-- allele type vocabulary
select _Term_key, substring(term,1,50) from VOC_Term where _Vocab_key = 38 order by term
go

-- not every allele has a subtype/attribute
select count(*)
from ALL_Allele a
where not exists (select 1 from VOC_Annot va 
	where va._AnnotType_key = 1014
	and va._Object_key = a._Allele_key)
go
select count(*)
from ALL_Allele a
where exists (select 1 from VOC_Annot va 
	where va._AnnotType_key = 1014
	and va._Object_key = a._Allele_key)
go

-- count of allele types
select a._Allele_Type_key, substring(t.term,1,30) as term, count(a._Allele_key)
from ALL_Allele a, VOC_Term t
where a._Allele_Type_key = t._Term_key
group by a._Allele_Type_key, t.term
go

-- count of allele subtype/attribute
select va._Term_key, substring(t.term,1,30) as term, count(a._Allele_key)
from ALL_Allele a, VOC_Annot va, VOC_Term t
where a._Allele_key = va._Object_key
and va._AnnotType_key = 1014
and va._Term_key = t._Term_key
group by va._Term_key, t.term
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

-- should return (2) results
select distinct t.term
from ALL_CellLine_Derivation a, VOC_Term t
where a._DerivationType_key = t._Term_key
and t.term in (
 'Targeted',
 'Transgenic',
 'Endonuclease-mediated',
 'Other (see notes)'
)
go

-- should return (0) results
select t.*
from VOC_Term t
where t._Vocab_key = 38
and not exists (select 1 from ALL_Allele a where t._Term_key = a._Allele_Type_key)
and not exists (select 1 from ALL_CellLine_Derivation a where t._Term_key = a._DerivationType_key)
and t.term not in ('Endonuclease-mediated', 'Other (see notes)')
go

--
-- duplicate 
---
select _Object_key, _Term_key from VOC_Annot where _AnnotType_key = 1014
group by _Object_key, _Term_key having count(*) > 1
order by _Term_key, _Object_key
go

-- count of allele subtype/attribute
-- should match 'wc -l VOC_Annot.bcp'
select count(*) from VOC_Annot where _AnnotType_key = 1014
go

EOSQL

# should match last count
/usr/bin/wc -l VOC_Annot.bcp | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

