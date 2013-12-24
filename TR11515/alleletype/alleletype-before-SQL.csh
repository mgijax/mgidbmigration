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

# use the AFTERLOG for some of the counts
setenv AFTERLOG ${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletype-after-SQL.csh.log
rm -rf ${AFTERLOG}
touch ${AFTERLOG}

# use the BEFORELOG for other things
setenv BEFORELOG $0.log
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
and a._Allele_key = h1._Allele_key
and a._Allele_key = h2._Allele_key
)
order by a.symbol, alleleType
go

EOSQL

date | tee -a ${BEFORELOG}
echo "--- Finished" | tee -a ${BEFORELOG}

