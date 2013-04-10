#!/bin/csh -f

#
# The script will create alleles for TR11223 (US144).
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

declare markerCursor cursor for
select m._Marker_key, m.symbol
from MRK_Marker m
where m._Marker_Status_key in (1,3)
and _Marker_Type_key = 1
and _Organism_key = 1
and (m.symbol like '%Rik' or m.name like 'RIKEN%'
or m.name like '%expressed%'
or m.name like '%mitochondrial ribosomal protein%'
or m.name like 'ribosomal protein%')
and m.symbol not like 'mt-%'
and m.name not like 'withdrawn, =%'
and m.name not like '%dna segment%'
and m.name not like 'EST %'
and m.name not like '%expressed sequence%'
and m.name not like '%cDNA sequence%'
and m.name not like '%gene model%'
and m.name not like '%hypothetical protein%'
and m.name not like '%ecotropic viral integration site%'
and not exists (select 1 from ALL_Allele a
where m._Marker_key = a._Marker_key
and a.isWildType = 1)
for read only
go

declare @markerKey integer
declare @symbol varchar(50)

open markerCursor
fetch markerCursor into @markerKey, @symbol

while (@@sqlstatus = 0)
begin
select @markerKey, @symbol
exec ALL_createWildType @markerKey, @symbol
fetch markerCursor into @markerKey, @symbol
end

close markerCursor
deallocate cursor markerCursor

checkpoint
go

EOSQL

date | tee -a ${LOG}
