#!/bin/csh -f

#
# Migration for TR 2902
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

sp_rename GXD_AllelePair, GXD_AllelePair_Old
go

checkpoint
go

quit
 
EOSQL
  
#
# Use new schema product to create new tables
#
${newmgddbschema}/table/GXD_AllelePair_create.object
${newmgddbschema}/default/GXD_AllelePair_bind.object
${newmgddbschema}/key/GXD_AllelePair_create.object

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

insert into GXD_AllelePair
select *
from GXD_AllelePair_Old
where _Allele_key_2 is not null
go

checkpoint
go

quit
 
EOSQL
  
${newmgddbschema}/index/GXD_AllelePair_create.object

date >> $LOG
