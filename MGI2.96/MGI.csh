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
#$DBUTILITIESDIR/bin/dev/load_devdb.csh $NOMEN nomen.backup mgd_dbo >>& $LOG
#date >> $LOG

echo "Update MGI DB Info..." >> $LOG
$DBUTILITIESDIR/bin/updatePublicVersion.csh $DBSERVER $DBNAME "MGI 2.96" >>& $LOG
$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-5-0-0" >>& $LOG
$DBUTILITIESDIR/bin/turnonbulkcopy.csh $DBSERVER $DBNAME >>& $LOG

#echo "Reconfigure Nomen..." >> $LOG
#$DBUTILITIESDIR/bin/dev/reconfig_nomen.csh ${newnomendb} >>& $LOG
#date >> $LOG

echo "Data Migration..." >> $LOG
#${VOCLOAD}/runSimpleFullLoad.sh IP.config >>& $LOG

${newmgddbschema}/table/MGI_Note_create.object >>& $LOG
${newmgddbschema}/table/MGI_NoteChunk_create.object >>& $LOG
${newmgddbschema}/table/MGI_NoteType_create.object >>& $LOG
${newmgddbschema}/default/MGI_Note_bind.object >>& $LOG
${newmgddbschema}/default/MGI_NoteChunk_bind.object >>& $LOG
${newmgddbschema}/default/MGI_NoteType_bind.object >>& $LOG
${newmgddbschema}/index/MGI_Note_create.object >>& $LOG
${newmgddbschema}/index/MGI_NoteChunk_create.object >>& $LOG
${newmgddbschema}/index/MGI_NoteType_create.object >>& $LOG
${newmgddbschema}/key/MGI_Note_create.object >>& $LOG
${newmgddbschema}/key/MGI_NoteChunk_create.object >>& $LOG
${newmgddbschema}/key/MGI_NoteType_create.object >>& $LOG
${newmgddbschema}/trigger/MGI_Note_create.object >>& $LOG
${newmgddbschema}/trigger/MGI_NoteType_create.object >>& $LOG
${newmgddbperms}/public/table/MGI_Note_grant.object >>& $LOG
${newmgddbperms}/public/table/MGI_NoteChunk_grant.object >>& $LOG
${newmgddbperms}/public/table/MGI_NoteType_grant.object >>& $LOG
${newmgddbperms}/curatorial/table/MGI_Note_grant.object >>& $LOG
${newmgddbperms}/curatorial/table/MGI_NoteChunk_grant.object >>& $LOG
${newmgddbperms}/curatorial/table/MGI_NoteType_grant.object >>& $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into MGI_NoteType values (1000, 13, "Public Vocabulary Term Comment", 0, "dbo", "dbo", getdate(), getdate())
go

insert into MGI_NoteType values (1001, 13, "Private Vocabulary Term Comment", 1, "dbo", "dbo", getdate(), getdate())
go

EOSQL

echo "Install Developer's Permissions..." >>$LOG
${newmgddbperms}/developers/perm_grant.csh >> $LOG

date >> $LOG

