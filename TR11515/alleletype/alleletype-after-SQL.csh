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

# concatenate the "after" counts

setenv AFTERLOG ${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletype-after-SQL.csh.log
#rm -rf ${AFTERLOG}
#touch ${AFTERLOG}

date | tee -a ${AFTERLOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${AFTERLOG}

use ${MGD_DBNAME}
go

-- AFTER-COUNTS

-- count of allele types
select a._Allele_Type_key, substring(t.term,1,30) as term, count(a._Allele_key)
from ALL_Allele a, VOC_Term t where a._Allele_Type_key = t._Term_key
group by a._Allele_Type_key, t.term
order by term
go

-- count of allele derivation
select a._DerivationType_key, substring(t.term,1,30) as term, count(a._Derivation_key)
from ALL_CellLine_Derivation a, VOC_Term t where a._DerivationType_key = t._Term_key
group by a._DerivationType_key, t.term
order by term
go

-- count of allele subtypes
select a._Term_key, substring(t.term,1,30) as term, count(a._Object_key)
from VOC_Annot a, VOC_Term t where a._AnnotType_key = 1014 and a._Term_key = t._Term_key
group by a._Term_key, t.term
order by term
go

-- allele types
select t._Term_key, substring(t.term,1,30) as term
from VOC_Term t
where t._Vocab_key = 38
order by term
go

-- allele subtype
select t._Term_key, substring(t.term,1,30) as term
from VOC_Term t where t._Vocab_key = 93
order by term
go

-- all collections
select v._Term_key, substring(v.term,1,50)
from VOC_Term v 
where v._Vocab_key = 92
order by v.term
go

-- collection counts
select a._Collection_key, substring(t.term,1,20) as term, count(a._Allele_key)
from ALL_Allele a, VOC_Term t
where a._Collection_key = t._Term_key
group by a._Collection_key, t.term
go

-- count of all_cre_cache
select count(*) from ALL_Cre_Cache
go

-- count of all_cre_cache/allele types
--select t.term, count(a._Allele_key)
--from ALL_Cre_Cache a, VOC_Term t
--where a._Allele_Type_key = t._Term_key
--group by a._Allele_Type_key, t.term
--go

-- allele categories 40, 41 (should be 0)
select substring(tt.name,1,20) as name, t._Term_key, substring(t.term,1,30) as term 
from VOC_Term t, VOC_Vocab tt 
where t._Vocab_key in (40,41) and t._Vocab_key = tt._Vocab_key
order by name, term
go

EOSQL

date | tee -a ${AFTERLOG}
echo "--- Finished" | tee -a ${AFTERLOG}

