#!/bin/csh -f

#
# Migration for TR 4708
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
${newmgddbschema}/trigger/MRK_Marker_drop.object
${newnomendbschema}/trigger/MRK_Nomen_drop.object

cat - <<EOSQL | doisql.csh $0 | tee -a $LOG

use $DBNAME
go

insert into MRK_Status values (3, 'interim', getdate(), getdate())
go

update MRK_Status set status = 'official' where _Marker_Status_key = 1
go

update MRK_Marker
set symbol = substring(symbol, 1, charindex("-pending", symbol) - 1),
    _Marker_Status_key = 3
where _Species_key = 1
and symbol like '%-pending'
go

use $NOMEN
go

insert into MRK_Status values (7, 'Broadcast - Interim', getdate(), getdate())
go

update MRK_Status set status = 'Broadcast - Official' where _Marker_Status_key = 5
go

update MRK_Nomen
set symbol = substring(symbol, 1, charindex("-pending", symbol) - 1),
    _Marker_Status_key = 7
where symbol like '%-pending'
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/trigger/MRK_Marker_create.object
${newnomendbschema}/trigger/MRK_Nomen_create.object

date | tee -a $LOG

