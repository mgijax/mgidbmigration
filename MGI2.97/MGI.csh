#!/bin/csh -f

#
# MGI 2.97
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
#
# For integration testing purposes...comment out before production load
#

#$DBUTILITIESDIR/bin/dev/load_devdb.csh $DBNAME mgd.backup mgd_dbo >>& $LOG
#$DBUTILITIESDIR/bin/dev/load_devdb.csh $DBNAME mgd_release.backup mgd_dbo >>& $LOG
#date >> $LOG
#$DBUTILITIESDIR/bin/dev/load_devdb.csh $NOMEN nomen.backup mgd_dbo >>& $LOG
#date >> $LOG

echo "Update MGI DB Info..." >> $LOG
$DBUTILITIESDIR/bin/updatePublicVersion.csh $DBSERVER $DBNAME "MGI 2.97" >>& $LOG
$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-6-0-0" >>& $LOG
$DBUTILITIESDIR/bin/turnonbulkcopy.csh $DBSERVER $DBNAME >>& $LOG

#echo "Reconfigure Nomen..." >> $LOG
#$DBUTILITIESDIR/bin/dev/reconfig_nomen.csh ${newnomendb} >>& $LOG
#date >> $LOG

#accmgitype.csh >>& $LOG
#loadVoc.csh >>& $LOG
tr2459.csh >>& $LOG
exit 0

# reconfiguration
${newmgddbschema}/key/key_drop.csh
${newmgddbschema}/key/key_create.csh
$DBUTILITIESDIR/bin/dev/reconfig_mgd.csh ${newmgddb} >>& $LOG

echo "Install Developer's Permissions..." >>$LOG
${newmgddbperms}/developers/perm_grant.csh >> $LOG

date >> $LOG

