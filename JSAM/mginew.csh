#!/bin/csh -f

#
# Migration to add:
#
# Add:
#	MGI_DeletedObject
#	MGI_AttributeHistory
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "MGI new tables..." | tee -a $LOG
 
#
# Use new schema product to create new table
#
#${newmgddbschema}/table/MGI_DeletedObject_drop.object >>& $LOG
#${newmgddbschema}/table/MGI_AttributeHistory_drop.object >>& $LOG

${newmgddbschema}/table/MGI_DeletedObject_create.object >>& $LOG
${newmgddbschema}/default/MGI_DeletedObject_bind.object >>& $LOG
${newmgddbschema}/key/MGI_DeletedObject_create.object >>& $LOG
${newmgddbschema}/table/MGI_AttributeHistory_create.object >>& $LOG
${newmgddbschema}/default/MGI_AttributeHistory_bind.object >>& $LOG
${newmgddbschema}/key/MGI_AttributeHistory_create.object >>& $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into MGI_AttributeHistory
select _Source_key, 5, "_SegmentType_key", ${UNKNOWNEDITOR}, ${UNKNOWNEDITOR}, creation_date, modification_date
from PRB_Source
go

insert into MGI_AttributeHistory
select _Source_key, 5, "_Vector_key", ${UNKNOWNEDITOR}, ${UNKNOWNEDITOR}, creation_date, modification_date
from PRB_Source
go

insert into MGI_AttributeHistory
select _Source_key, 5, "_Refs_key", ${UNKNOWNEDITOR}, ${UNKNOWNEDITOR}, creation_date, modification_date
from PRB_Source
go

insert into MGI_AttributeHistory
select _Source_key, 5, "_Organism_key", ${UNKNOWNEDITOR}, ${UNKNOWNEDITOR}, creation_date, modification_date
from PRB_Source
go

insert into MGI_AttributeHistory
select _Source_key, 5, "_Strain_key", ${UNKNOWNEDITOR}, ${UNKNOWNEDITOR}, creation_date, modification_date
from PRB_Source
go

insert into MGI_AttributeHistory
select _Source_key, 5, "_Tissue_key", ${UNKNOWNEDITOR}, ${UNKNOWNEDITOR}, creation_date, modification_date
from PRB_Source
go

insert into MGI_AttributeHistory
select _Source_key, 5, "_Gender_key", ${UNKNOWNEDITOR}, ${UNKNOWNEDITOR}, creation_date, modification_date
from PRB_Source
go

insert into MGI_AttributeHistory
select _Source_key, 5, "_CellLine_key", ${UNKNOWNEDITOR}, ${UNKNOWNEDITOR}, creation_date, modification_date
from PRB_Source
go

insert into MGI_AttributeHistory
select _Source_key, 5, "name", ${UNKNOWNEDITOR}, ${UNKNOWNEDITOR}, creation_date, modification_date
from PRB_Source
go

insert into MGI_AttributeHistory
select _Source_key, 5, "description", ${UNKNOWNEDITOR}, ${UNKNOWNEDITOR}, creation_date, modification_date
from PRB_Source
go

insert into MGI_AttributeHistory
select _Source_key, 5, "age", ${UNKNOWNEDITOR}, ${UNKNOWNEDITOR}, creation_date, modification_date
from PRB_Source
go

insert into MGI_AttributeHistory
select _SequenceType_key, 19, "_SequenceType_key", ${UNKNOWNEDITOR}, ${UNKNOWNEDITOR}, creation_date, modification_date
from SEQ_Sequence
go

dump tran ${DBNAME} with truncate_only
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/MGI_DeletedObject_create.object >>& $LOG
${newmgddbschema}/index/MGI_AttributeHistory_create.object >>& $LOG

date >> $LOG

