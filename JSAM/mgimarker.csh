#!/bin/csh -f

#
# Migration for MGI Marker
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "Marker Migration..." | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename MRK_Marker, MRK_Marker_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/MRK_Marker_create.object >> $LOG
${newmgddbschema}/default/MRK_Marker_bind.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

/* insert all markers into new table */

declare @curKey integer
select @curKey = _Term_key from VOC_Term where term = 'internal'
insert into MRK_Marker
select m._Marker_key, m._Species_key, m._Marker_Status_key, m._Marker_Type_key, 
@curKey, m.symbol, m.name, m.chromosome,
m.cytogeneticOffset, ${CREATEDBY}, ${CREATEDBY}, m.creation_date, m.modification_date
from MRK_Marker_Old  m
go

dump tran ${DBNAME} with truncate_only
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/MRK_Marker_create.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

/* set MRK_Marker._CreatedBy_key from Nomen, where possible */

update MRK_Marker
set _CreatedBy_key = n._CreatedBy_key
from MRK_Marker m, MRK_Acc_View a, NOM_Acc_View a2, NOM_Marker n
where m._Marker_key = a._Object_key
and a._LogicalDB_key = 1
and a.prefixPart = "MGI:"
and a.accID = a2.accID
and a2._Object_key = n._Nomen_key
go

dump tran ${DBNAME} with truncate_only
go

checkpoint
go

quit

EOSQL

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

drop table MRK_Marker_Old
go

end

EOSQL

date >> $LOG

