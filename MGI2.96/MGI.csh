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

$DBUTILITIESDIR/bin/dev/load_devdb.csh $DBNAME mgd.backup mgd_dbo >>& $LOG
date >> $LOG
$DBUTILITIESDIR/bin/dev/load_devdb.csh $NOMEN nomen.backup mgd_dbo >>& $LOG
date >> $LOG

echo "Update MGI DB Info..." >> $LOG
$DBUTILITIESDIR/bin/updatePublicVersion.csh $DBSERVER $DBNAME "MGI 2.96" >>& $LOG
$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-5-0-0" >>& $LOG
$DBUTILITIESDIR/bin/turnonbulkcopy.csh $DBSERVER $DBNAME >>& $LOG

echo "Reconfigure Nomen..." >> $LOG
$DBUTILITIESDIR/bin/dev/reconfig_nomen.csh ${newnomendb} >>& $LOG
date >> $LOG

./tr4705.csh >> $LOG

${newmgddbschema}/table/MGI_Note_create.object >>& $LOG
${newmgddbschema}/table/MGI_NoteChunk_create.object >>& $LOG
${newmgddbschema}/table/MGI_NoteType_create.object >>& $LOG
${newmgddbschema}/table/MGI_Set_create.object >>& $LOG
${newmgddbschema}/table/MGI_SetMember_create.object >>& $LOG

${newmgddbschema}/default/MGI_Note_bind.object >>& $LOG
${newmgddbschema}/default/MGI_NoteChunk_bind.object >>& $LOG
${newmgddbschema}/default/MGI_NoteType_bind.object >>& $LOG
${newmgddbschema}/default/MGI_Set_bind.object >>& $LOG
${newmgddbschema}/default/MGI_SetMember_bind.object >>& $LOG

${newmgddbschema}/index/MGI_Note_create.object >>& $LOG
${newmgddbschema}/index/MGI_NoteChunk_create.object >>& $LOG
${newmgddbschema}/index/MGI_NoteType_create.object >>& $LOG
${newmgddbschema}/index/MGI_Set_create.object >>& $LOG
${newmgddbschema}/index/MGI_SetMember_create.object >>& $LOG

${newmgddbschema}/key/MGI_Note_create.object >>& $LOG
${newmgddbschema}/key/MGI_NoteChunk_create.object >>& $LOG
${newmgddbschema}/key/MGI_NoteType_create.object >>& $LOG
${newmgddbschema}/key/MGI_Set_create.object >>& $LOG
${newmgddbschema}/key/MGI_SetMember_create.object >>& $LOG

${newmgddbschema}/trigger/MGI_Note_create.object >>& $LOG
${newmgddbschema}/trigger/MGI_NoteType_create.object >>& $LOG
${newmgddbschema}/trigger/MGI_Set_create.object >>& $LOG
${newmgddbschema}/trigger/ACC_Accession_drop.object >>& $LOG
${newmgddbschema}/trigger/ACC_Accession_create.object >>& $LOG

${newmgddbschema}/view/MGI_Note_MRKGO_View_create.object >>& $LOG
${newmgddbschema}/view/MGI_NoteType_MRKGO_View_create.object >>& $LOG
${newmgddbschema}/view/MGI_Set_CloneSet_View_create.object >>& $LOG

${newmgddbperms}/public/table/MGI_Note_grant.object >>& $LOG
${newmgddbperms}/public/table/MGI_NoteChunk_grant.object >>& $LOG
${newmgddbperms}/public/table/MGI_NoteType_grant.object >>& $LOG
${newmgddbperms}/public/table/MGI_Set_grant.object >>& $LOG
${newmgddbperms}/public/table/MGI_SetMember_grant.object >>& $LOG
${newmgddbperms}/public/view/MGI_Note_MRKGO_View_grant.object >>& $LOG
${newmgddbperms}/public/view/MGI_NoteType_MRKGO_View_grant.object >>& $LOG
${newmgddbperms}/public/view/MGI_Set_CloneSet_View_grant.object >>& $LOG

${newmgddbperms}/curatorial/table/MGI_Note_grant.object >>& $LOG
${newmgddbperms}/curatorial/table/MGI_NoteChunk_grant.object >>& $LOG
${newmgddbperms}/curatorial/table/MGI_NoteType_grant.object >>& $LOG
${newmgddbperms}/curatorial/table/MGI_Set_grant.object >>& $LOG
${newmgddbperms}/curatorial/table/MGI_SetMember_grant.object >>& $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into MGI_NoteType values (1000, 13, "Public Vocabulary Term Comment", 0, "dbo", "dbo", getdate(), getdate())
go

insert into MGI_NoteType values (1001, 13, "Private Vocabulary Term Comment", 1, "dbo", "dbo", getdate(), getdate())
go

insert into MGI_NoteType values (1002, 2, "GO Annotation", 1, "dbo", "dbo", getdate(), getdate())
go

insert into ACC_MGIType values (15, 'Logical DB', 'ACC_LogicalDB', '_LogicalDB_key', null, getdate(), getdate(), getdate())
go

insert into MGI_Set values(1000, 15, 'Clone Set', user_name(), user_name(), getdate(), getdate())
go

insert into MGI_SetMember values(1000, 1000, 17, 1, user_name(), user_name(), getdate(), getdate())
go

insert into MGI_SetMember values(1001, 1000, 26, 2, user_name(), user_name(), getdate(), getdate())
go

update ACC_ActualDB set name = 'IMAGE home page' where _ActualDB_key = 25
go

EOSQL

echo "Data Migration..." >> $LOG
${VOCLOAD}/runDAGIncLoad.sh GO.config >>& $LOG

echo "Install Developer's Permissions..." >>$LOG
${newmgddbperms}/developers/perm_grant.csh >> $LOG

date >> $LOG

