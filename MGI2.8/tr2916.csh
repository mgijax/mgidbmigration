#!/bin/csh -f

#
# Migration for TR 2916
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

sp_rename GXD_GelLane, GXD_GelLane_Old
go

checkpoint
go

quit
 
EOSQL
  
#
# Use new schema product to create new tables
#
${newmgddbschema}/table/GXD_GelLane_create.object
${newmgddbschema}/default/GXD_GelLane_bind.object
${newmgddbschema}/key/GXD_GelLane_create.object

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

insert into GXD_GelLane
(_GelLane_key, _Assay_key, _Genotype_key, _GelRNAType_key, _GelControl_key, sequenceNum,
laneLabel, sampleAmount, sex, age, ageMin, ageMax, ageNote, laneNote, creation_date, modification_date)
select _GelLane_key, _Assay_key, _Genotype_key, _GelRNAType_key, _GelControl_key, sequenceNum,
laneLabel, ltrim(str(sampleAmount,10,2)), sex, 
age, ageMin, ageMax, ageNote, laneNote, creation_date, modification_date
from GXD_GelLane_Old
go

checkpoint
go

quit
 
EOSQL
  
${newmgddbschema}/index/GXD_GelLane_create.object

date >> $LOG
