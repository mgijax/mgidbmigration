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

echo "Update MGI DB Info..." >> $LOG
$DBUTILITIESDIR/bin/updatePublicVersion.csh $DBSERVER $DBNAME "MGI 2.96" >>& $LOG
$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-5-0-0" >>& $LOG
$DBUTILITIESDIR/bin/turnonbulkcopy.csh $DBSERVER $DBNAME >>& $LOG

echo "Data Migration..." >> $LOG
${VOCLOAD}/runSimpleFullLoad.sh IP.config >>& $LOG

#
# Re-create all triggers, sps, views....
#

${newmgddbschema}/default/default_unbind.csh >>& $LOG
${newmgddbschema}/default/default_bind.csh >>& $LOG
${newmgddbschema}/key/key_drop.csh >>& $LOG
${newmgddbschema}/key/key_create.csh >>& $LOG
$DBUTILITIESDIR/bin/dev/reconfig_mgd.csh ${newmgddb} >>& $LOG

echo "Install Developer's Permissions..." >>$LOG
${newmgddbperms}/developers/perm_grant.csh >> $LOG

date >> $LOG

