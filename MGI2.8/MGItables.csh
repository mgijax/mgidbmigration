#!/bin/csh -f

#
# Migration for MGI_Tables/MGI_Columns
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

sp_rename MGI_Columns, MGI_Columns_Old
go

sp_rename MGI_Tables, MGI_Tables_Old
go

checkpoint
go

quit
 
EOSQL
  
#
# Use new schema product to create new tables
#
${newmgddbschema}/table/MGI_Tables_create.object
${newmgddbschema}/table/MGI_Columns_create.object
${newmgddbschema}/default/MGI_Tables_bind.object
${newmgddbschema}/default/MGI_Columns_bind.object

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

insert into MGI_Tables (table_name, description, creation_date, modification_date)
select o.name, t.description, t.creation_date, t.modification_date
from sysobjects o, MGI_Tables_Old t
where o.type = "U"
and o.id = t._Table_id
go

insert into MGI_Columns (table_name, column_name, description, example, creation_date, modification_date)
select o.name, c.name, mc.description, mc.example, mc.creation_date, mc.modification_date
from sysobjects o, syscolumns c, MGI_Columns_Old mc
where o.type = "U"
and o.id = mc._Table_id
and mc._Table_id = mc._Table_id
and mc._Column_id = c.colid
and c.id = o.id
go

checkpoint
go

quit
 
EOSQL
  
${newmgddbschema}/key/MGI_Tables_create.object
${newmgddbschema}/key/MGI_Columns_create.object
${newmgddbschema}/index/MGI_Tables_create.object
${newmgddbschema}/index/MGI_Columns_create.object

date >> $LOG

