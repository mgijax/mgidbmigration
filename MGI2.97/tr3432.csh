#!/bin/csh -f

#
# Migration for TR 3432 (GXD_Structure)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename GXD_Structure, GXD_Structure_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/GXD_Structure_create.object >> $LOG
${newmgddbschema}/default/GXD_Structure_bind.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into GXD_Structure 
select _Structure_key, _Parent_key, _StructureName_key, _Stage_key, 
edinburghKey, printName, treeDepth, printStop, 0, structureNote, creation_date, modification_date
from GXD_Structure_Old
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/GXD_Structure_create.object >> $LOG

topoSort.py
chmod +x topoSort.csh
topoSort.csh

#cat - <<EOSQL | doisql.csh $0 >> $LOG
#
#use $DBNAME
#go
#
#drop table GXD_Structure_Old
#go
#
#end
#
#EOSQL

date >> $LOG

