#!/bin/csh -f

#
# Migration for TR 2718
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

sp_rename GXD_Antibody, GXD_Antibody_Old
go

checkpoint
go

quit
 
EOSQL
  
#
# Use new schema product to create new tables
#
${newmgddbschema}/table/GXD_Antibody_create.object
${newmgddbschema}/default/GXD_Antibody_bind.object
${newmgddbschema}/key/GXD_Antibody_create.object

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

insert into GXD_Antibody
select *
from GXD_Antibody_Old
go

checkpoint
go

quit
 
EOSQL
  
${newmgddbschema}/index/GXD_Antibody_create.object

date >> $LOG
