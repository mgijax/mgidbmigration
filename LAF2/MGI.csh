#!/bin/csh -f

#
# LAF 2
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
$DBUTILITIESDIR/bin/updatePublicVersion.csh $DBSERVER $DBNAME "MGI 2.9" >>& $LOG
$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-4-0-0" >>& $LOG
$DBUTILITIESDIR/bin/turnonbulkcopy.csh $DBSERVER $DBNAME >>& $LOG

echo "Reconfigure Nomen..." >> $LOG
$DBUTILITIESDIR/bin/dev/reconfig_nomen.csh ${newnomendb} >>& $LOG
date >> $LOG

echo "Data Migration..." >> $LOG
./tr1892.csh >>& $LOG
./tr4378.csh >>& $LOG
./tr4298.csh >>& $LOG

#
# drop old/obsolete objects
#

#cat - <<EOSQL | doisql.csh $0 >> $LOG
  
#use ${DBNAME}
#go

#drop table PRB_Strain_Marker_Old
#go

#checkpoint
#go

#quit
 
#EOSQL
  
date >> $LOG

#
# Re-create all triggers, sps, views....
#

${newmgddbschema}/default/default_unbind.csh >>& $LOG
${newmgddbschema}/default/default_bind.csh >>& $LOG
${newmgddbschema}/key/key_drop.csh >>& $LOG
${newmgddbschema}/key/key_create.csh >>& $LOG
${newmgddbschema}/rule/GXD_Specimen_unbind.object >>& $LOG
${newmgddbschema}/rule/check_Hybridization_drop.object >>& $LOG
${newmgddbschema}/rule/check_Hybridization_create.object >>& $LOG
${newmgddbschema}/rule/GXD_Specimen_bind.object >>& $LOG
$DBUTILITIESDIR/bin/dev/reconfig_mgd.csh ${newmgddb} >>& $LOG

echo "Install Developer's Permissions..." >>$LOG
${newmgddbperms}/developers/perm_grant.csh >> $LOG
date >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

update GXD_Specimen
set hybridization = 'section'
where hybridization = 'sections'
go

update ACC_MGIType
set dbView = "PRB_Source_Summary_View"
where _MGIType_key = 5
go

exec MGI_Table_Column_Cleanup
go

checkpoint
go

quit
 
EOSQL

date >> $LOG

