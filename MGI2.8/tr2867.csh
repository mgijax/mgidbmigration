#!/bin/csh -f

#
# Migration for TR 2867
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
# Save BIB_Refs data
bcpout.csh ${newmgddbschema} BIB_Refs `pwd`

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename BIB_Refs, BIB_Refs_Old
go

sp_rename ACC_MGIType, ACC_MGIType_Old
go

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/BIB_Refs_create.object
${newmgddbschema}/default/BIB_Refs_bind.object
${newmgddbschema}/table/ACC_MGIType_create.object
${newmgddbschema}/default/ACC_MGIType_bind.object

# New VOC and DAG tables

${newmgddbschema}/table/DAG_create.logical
${newmgddbschema}/table/VOC_create.logical
${newmgddbschema}/key/DAG_create.logical
${newmgddbschema}/key/VOC_create.logical
${newmgddbschema}/index/DAG_create.logical
${newmgddbschema}/index/VOC_create.logical
${newmgddbschema}/default/DAG_bind.logical
${newmgddbschema}/default/VOC_bind.logical

${newmgddbschema}/key/BIB_Refs_create.object
${newmgddbschema}/index/BIB_Refs_create.object
${newmgddbschema}/key/ACC_MGIType_create.object
${newmgddbschema}/index/ACC_MGIType_create.object

bcpin.csh ${newmgddbschema} BIB_Refs

date >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into ACC_MGIType
(_MGIType_key, name, tableName, primaryKeyName, dbView, creation_date, modification_date, release_date)
select _MGIType_key, name, tableName, primaryKeyName, null, creation_date, modification_date, release_date
from ACC_MGIType_Old
go

update ACC_MGIType
set dbView = "MRK_Summary_View" where name = "Marker"
go

update ACC_MGIType
set dbView = "GXD_Genotype_Summary_View" where name = "Genotype"
go

insert into ACC_MGIType 
values (13, 'Vocabulary Term', 'VOC_Term', '_Term_key', NULL, getdate(), getdate(), getdate())
go

insert into ACC_MGIType 
values (14, 'Vocabulary', 'VOC_Vocab', '_Vocab_key', NULL, getdate(), getdate(), getdate())
go

insert into ACC_LogicalDB
values (-1, 'Not Specified', 'Not Specified', NULL, getdate(), getdate(), getdate())
go

insert into DAG_Label
values (-1, 'Not Specified', getdate(), getdate())
go

insert into DAG_Label
values (1, 'is-a', getdate(), getdate())
go

insert into DAG_Label
values (2, 'part-of', getdate(), getdate())
go

insert into VOC_AnnotType
values(1000,,,,"GO/Marker", getdate(), getdate())
go

insert into VOC_AnnotType
values(1001,,,,"PhenoSlim/Genotype", getdate(), getdate())
go

end

EOSQL

# Load VOC tables

set SIMPLELOAD /home/lec/loads/simplevocload
cd ${SIMPLELOAD}
${SIMPLELOAD}/simplevocload.csh ${DBSERVER} ${DBNAME} phenoslim.out PhenoSlim 72460 P
${SIMPLELOAD}/simplevocload.csh ${DBSERVER} ${DBNAME} go.ecodes "GO Evidence Codes" 73041 N
${SIMPLELOAD}/simplevocload.csh ${DBSERVER} ${DBNAME} ps.ecodes "PhenoSlim Evidence Codes" 72460 N

date >> $LOG

