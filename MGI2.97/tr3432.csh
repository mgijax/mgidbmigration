#!/bin/csh -f

#
# Migration for TR 3432 (GXD_Structure)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG

cat - <<EOSQL | doisql.csh $0 | tee -a $LOG

use $DBNAME
go

sp_rename GXD_Structure, GXD_Structure_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/GXD_Structure_create.object | tee -a $LOG
${newmgddbschema}/default/GXD_Structure_bind.object | tee -a $LOG

cat - <<EOSQL | doisql.csh $0 | tee -a $LOG

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

${newmgddbschema}/index/GXD_Structure_create.object | tee -a $LOG

# topoSort.py needs public permission to read GXD_Structure
${newmgddbperms}/public/table/GXD_Structure_grant.object | tee -a $LOG

# generate SQL updates for topological sorting

topoSort.py | tee -a $LOG
chmod +x topoSort.csh
topoSort.csh | tee -a $LOG

date | tee -a $LOG

