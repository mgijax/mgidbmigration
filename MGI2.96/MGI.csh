#!/bin/csh -f

#
# MGI 2.96
#

cd `dirname $0` && source Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
#
# For integration testing purposes...comment out before production load
#

#$DBUTILITIESDIR/bin/dev/load_devdb.csh $DBNAME mgd.backup mgd_dbo >>& $LOG
#date >> $LOG
$DBUTILITIESDIR/bin/dev/load_devdb.csh $NOMEN nomen.backup mgd_dbo >>& $LOG
date >> $LOG

echo "Update MGI DB Info..." >> $LOG
$DBUTILITIESDIR/bin/updatePublicVersion.csh $DBSERVER $DBNAME "MGI 2.96" >>& $LOG
$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-5-0-0" >>& $LOG
$DBUTILITIESDIR/bin/turnonbulkcopy.csh $DBSERVER $DBNAME >>& $LOG

echo "Reconfigure Nomen..." >> $LOG
$DBUTILITIESDIR/bin/dev/reconfig_nomen.csh ${newnomendb} >>& $LOG
date >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename MRK_History, MRK_History_Old
go

end

EOSQL

${newmgddbschema}/table/MGI_Note_create.object >>& $LOG
${newmgddbschema}/table/MGI_NoteChunk_create.object >>& $LOG
${newmgddbschema}/table/MGI_NoteType_create.object >>& $LOG
${newmgddbschema}/table/MGI_Set_create.object >>& $LOG
${newmgddbschema}/table/MGI_SetMember_create.object >>& $LOG
${newmgddbschema}/table/MRK_History_create.object >> $LOG

${newmgddbschema}/default/MGI_Note_bind.object >>& $LOG
${newmgddbschema}/default/MGI_NoteChunk_bind.object >>& $LOG
${newmgddbschema}/default/MGI_NoteType_bind.object >>& $LOG
${newmgddbschema}/default/MGI_Set_bind.object >>& $LOG
${newmgddbschema}/default/MGI_SetMember_bind.object >>& $LOG
${newmgddbschema}/default/MRK_History_bind.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into MRK_History
select _Marker_key, _Marker_Event_key, _Marker_EventReason_key, _History_key, _Refs_key, sequenceNum,
name, event_date, "dbo", "dbo", creation_date, modification_date
from MRK_History_Old
go

insert into MGI_NoteType values (1000, 13, "Public Vocabulary Term Comment", 0, "dbo", "dbo", getdate(), getdate())
go

insert into MGI_NoteType values (1001, 13, "Private Vocabulary Term Comment", 1, "dbo", "dbo", getdate(), getdate())
go

insert into MGI_NoteType values (1002, 2, "GO Annotation", 1, "dbo", "dbo", getdate(), getdate())
go

insert into ACC_MGIType values (15, 'Logical DB', 'ACC_LogicalDB', '_LogicalDB_key', null, getdate(), getdate(), getdate())
go

insert into ACC_MGIType values (16, 'Actual DB', 'ACC_ActualDB', '_ActualDB_key', null, getdate(), getdate(), getdate())
go

insert into MGI_Set values(1000, 15, 'Clone Set', user_name(), user_name(), getdate(), getdate())
go

insert into MGI_Set values(1001, 16, 'Marker Sequence Actual DBs', user_name(), user_name(), getdate(), getdate())
go

insert into MGI_SetMember values(1000, 1000, 17, 1, user_name(), user_name(), getdate(), getdate())
go

insert into MGI_SetMember values(1001, 1000, 26, 2, user_name(), user_name(), getdate(), getdate())
go

insert into MGI_SetMember values(1002, 1001, 35, 1, user_name(), user_name(), getdate(), getdate())
go

insert into MGI_SetMember values(1003, 1001, 12, 2, user_name(), user_name(), getdate(), getdate())
go

insert into MGI_SetMember values(1004, 1001, 20, 3, user_name(), user_name(), getdate(), getdate())
go

insert into MGI_SetMember values(1005, 1001, 44, 4, user_name(), user_name(), getdate(), getdate())
go

insert into MGI_SetMember values(1006, 1001, 42, 5, user_name(), user_name(), getdate(), getdate())
go

insert into MGI_SetMember values(1007, 1001, 43, 6, user_name(), user_name(), getdate(), getdate())
go

update ACC_ActualDB set name = 'IMAGE home page' where _ActualDB_key = 25
go

dump tran $DBNAME with truncate_only
go

EOSQL

${newmgddbschema}/index/MRK_History_create.object >> $LOG
${newmgddbschema}/index/MGI_Note_create.object >>& $LOG
${newmgddbschema}/index/MGI_NoteChunk_create.object >>& $LOG
${newmgddbschema}/index/MGI_NoteType_create.object >>& $LOG
${newmgddbschema}/index/MGI_Set_create.object >>& $LOG
${newmgddbschema}/index/MGI_SetMember_create.object >>& $LOG

# reconfiguration
${newmgddbschema}/key/key_drop.csh >>& $LOG
${newmgddbschema}/key/key_create.csh >>& $LOG
$DBUTILITIESDIR/bin/dev/reconfig_mgd.csh ${newmgddb} >>& $LOG

echo "Install Developer's Permissions..." >>$LOG
${newmgddbperms}/developers/perm_grant.csh >> $LOG

echo "Data Migration..." >> $LOG
${VOCLOAD}/runDAGIncLoad.sh GO.config >>& $LOG

date >> $LOG

