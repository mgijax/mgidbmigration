#!/bin/csh -f

#
# Migration for MGI References
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "MGI References Migration..." | tee -a $LOG
 
#
# Use new schema product to create new table
#
${newmgddbschema}/table/MGI_Reference_Assoc_create.object >> $LOG
${newmgddbschema}/default/MGI_Reference_Assoc_bind.object >> $LOG
${newmgddbschema}/table/MGI_RefAssocType_create.object >> $LOG
${newmgddbschema}/default/MGI_RefAssocType_bind.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into MGI_RefAssocType values(1000, NULL, 'Original', 1, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

insert into MGI_RefAssocType values(1002, NULL, 'General', 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

insert into MGI_RefAssocType values(1003, 21, 'Primary', 1, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

insert into MGI_RefAssocType values(1004, 21, 'Broadcast to MGD', 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

insert into MGI_RefAssocType values(1005, 21, 'Do Not Broadcast to MGD', 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

insert into MGI_RefAssocType values(1006, 19, 'Provider', 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

insert into MGI_RefAssocType values(1007, 19, 'Curator', 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/MGI_RefAssocType_create.object >> $LOG

# do this later, after data is loaded into the table
#${newmgddbschema}/index/MGI_Reference_Assoc_create.object

date >> $LOG

