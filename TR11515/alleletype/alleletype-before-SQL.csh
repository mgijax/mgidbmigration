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

# use the AFTERLOG for some of the counts
setenv AFTERLOG ${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletype-after-SQL.csh.log
rm -rf ${AFTERLOG}
touch ${AFTERLOG}

# use the BEFORELOG for other things
setenv BEFORELOG ${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletype-before-SQL.csh.log
rm -rf ${BEFORELOG}
touch ${BEFORELOG}

date | tee -a ${BEFORELOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${AFTERLOG}

use ${MGD_DBNAME}
go

-- BEFORE-COUNTS

-- count of allele types
select a._Allele_Type_key, substring(t.term,1,30) as term, count(a._Allele_key)
from ALL_Allele a, VOC_Term t where a._Allele_Type_key = t._Term_key
group by a._Allele_Type_key, t.term
order by term
go

-- count of allele types totals
select term = 'Targeted', count(a._Allele_key)
from ALL_Allele a, VOC_Term t where a._Allele_Type_key = t._Term_key and t.term like 'Targeted %'
go

-- count of allele types totals
select term = 'Transgenic', count(a._Allele_key)
from ALL_Allele a, VOC_Term t where a._Allele_Type_key = t._Term_key and t.term like 'Transgenic %'
go

-- count of allele derivation
select a._DerivationType_key, substring(t.term,1,30) as term, count(a._Derivation_key)
from ALL_CellLine_Derivation a, VOC_Term t where a._DerivationType_key = t._Term_key
group by a._DerivationType_key, t.term
order by term
go

-- count of allele derivation totals
select term = 'Targeted', count(a._Derivation_key)
from ALL_CellLine_Derivation a, VOC_Term t where a._DerivationType_key = t._Term_key and t.term like 'Targeted %'
go

-- count of allele derivation totals
select term = 'Transgenic', count(a._Derivation_key)
from ALL_CellLine_Derivation a, VOC_Term t where a._DerivationType_key = t._Term_key and t.term like 'Transgenic %'
go

-- count of all_cre_cache
select count(*) from ALL_Cre_Cache
go

-- count of all_cre_cache/allele types
select t.term, count(a._Allele_key)
from ALL_Cre_Cache a, VOC_Term t
where a._Allele_Type_key = t._Term_key
group by a._Allele_Type_key, t.term
go

-- allele categories 40, 41
select substring(tt.name,1,20) as name, t._Term_key, substring(t.term,1,30) as term 
from VOC_Term t, VOC_Vocab tt 
where t._Vocab_key in (40,41) and t._Vocab_key = tt._Vocab_key
order by name, term
go

EOSQL

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${BEFORELOG}

use ${MGD_DBNAME}
go

-- temp tables for the next query
select _Allele_key, hasDriver = 1
into #hasDriver 
from ALL_Allele a
where exists (select 1 from MGI_Note n where n._MGIType_key = 11 and n._NoteType_key = 1034
	and a._Allele_key = n._Object_key)
union
select _Allele_key, hasDriver = 0
from ALL_Allele a
where not exists (select 1 from MGI_Note n where n._MGIType_key = 11 and n._NoteType_key = 1034
	and a._Allele_key = n._Object_key)
go

select _Allele_key, hasInducible = 1
into #hasInducible 
from ALL_Allele a
where exists (select 1 from MGI_Note n where n._MGIType_key = 11 and n._NoteType_key = 1032
	and a._Allele_key = n._Object_key)
union
select _Allele_key, hasInducible = 0
from ALL_Allele a
where not exists (select 1 from MGI_Note n where n._MGIType_key = 11 and n._NoteType_key = 1032
	and a._Allele_key = n._Object_key)
go

create index idx1 on #hasDriver(_Allele_key)
go
create index idx2 on #hasInducible(_Allele_key)
go

-- alleles of type 'Targeted' and 'Transgenic'
(
select aa.accID, 
substring(a.symbol,1,50) as symbol,
substring(t.term,1,50) as alleleType,
h1.hasDriver, h2.hasInducible
from ALL_Allele a, ACC_Accession aa, VOC_Term t, 
	#hasDriver h1, #hasInducible h2
where a._Allele_Type_key = t._Term_key
and a._Term_key in (847116,847117,847118,847119,847120,847126,847127,847128,847129,2327160)
and a._Allele_key = aa._Object_key
and aa._MGIType_key = 11
and aa._LogicalDB_key = 1
and a._Allele_key = h1._Allele_key
and a._Allele_key = h2._Allele_key
)
order by a.symbol, alleleType
go

-- allele derivation
select a._DerivationType_key, a.name, substring(t.term,1,30) as term
from ALL_CellLine_Derivation a, VOC_Term t where a._DerivationType_key = t._Term_key
and a._DerivationType_key in (847116,847117,847118,847119,847120,847126,847127,847128,847129,2327160)
order by term
go

EOSQL

#
# before-statistics
#
./alleletype-before-stats.csh | tee -a ${LOG}

date | tee -a ${BEFORELOG}
echo "--- Finished" | tee -a ${BEFORELOG}

