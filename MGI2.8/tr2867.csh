#!/bin/csh -f

#
# Migration for TR 2867
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename BIB_Refs, BIB_Refs_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/BIB_Refs_create.object
${newmgddbschema}/default/BIB_Refs_bind.object

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into BIB_Refs
select *
from BIB_Refs_Old
go

EOSQL

${newmgddbschema}/key/BIB_Refs_create.object
${newmgddbschema}/index/BIB_Refs_create.object

date >> $LOG

# New VOC and DAG tables

${newmgddbschema}/table/DAG_create.logical
${newmgddbschema}/table/VOC_create.logical
${newmgddbschema}/key/DAG_create.logical
${newmgddbschema}/key/VOC_create.logical
${newmgddbschema}/index/DAG_create.logical
${newmgddbschema}/index/VOC_create.logical
${newmgddbschema}/default/DAG_bind.logical
${newmgddbschema}/default/VOC_bind.logical

date >> $LOG

