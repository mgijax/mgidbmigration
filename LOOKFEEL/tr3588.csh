#!/bin/csh -f

#
# Migration for TR 3588
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
#
# Use new schema product to create new objects
#
${newmgddbschema}/procedure/ALL_createWildType_drop.object
${newmgddbschema}/procedure/ALL_createWildType_create.object
${newmgddbschema}/trigger/MRK_Marker_drop.object
${newmgddbschema}/trigger/MRK_Marker_create.object
${newmgddbperms}/curatorial/procedure/ALL_createWildType_grant.object

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

declare mrk_cursor cursor for
select m._Marker_key, m.symbol
from MRK_Marker m
where m._Species_key = 1
and m._Marker_Status_key = 1
and m._Marker_Type_key = 1
and m.name not like '%dna segment%'
and m.name not like 'EST %'
and m.name not like '%expressed%'
and m.name not like '%cDNA sequence%'
and m.name not like '%gene model%'
and m.name not like '%hypothetical protein%'
and m.name not like '%ecotropic viral integration site%'
and m.name not like '%mitochondrial ribosomal protein%'
and m.name not like '%viral polymerase%'
and m.name not like 'ribosomal protein%'
and m.symbol not like 'mt-%'
and m.symbol not like '%rik'
and not exists (select 1 from ALL_Allele a
where m._Marker_key = a._Marker_key
and a.symbol = m.symbol + "<+>")
for read only
go

begin transaction

declare @key int
declare @symbol varchar(30)

open mrk_cursor
fetch mrk_cursor into @key, @symbol

while (@@sqlstatus = 0)
begin
        select @symbol
        exec ALL_createWildType @key, @symbol
        fetch mrk_cursor into @key, @symbol
end

close mrk_cursor
deallocate cursor mrk_cursor
commit transaction
go

checkpoint
go

quit

EOSQL

date >> $LOG

