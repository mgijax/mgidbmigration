#!/bin/csh -f

#
# Migration for Look & Feel
#
# updated:  
# Tables:	
# Procedures:	
# Triggers:	
# Views:	
#

cd `dirname $0`

setenv SYBASE		/opt/sybase/12.5
setenv DBUTILITIESDIR	/usr/local/mgi/dbutils/mgidbutilities
setenv PYTHONPATH	/usr/local/mgi/lib/python

setenv newmgddb /usr/local/mgi/dbutils/mgd_release
setenv newnomendb /usr/local/mgi/dbutils/nomen_release
#setenv newmgddb /home/lec/db
#setenv newnomendb /home/lec/db
setenv newmgddbschema ${newmgddb}/mgddbschema
setenv newmgddbperms ${newmgddb}/mgddbperms

source ${newmgddbschema}/Configuration
setenv NOMEN	nomen_release

setenv LOG $0.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
#
# For integration testing purposes...comment out before production load
#

$DBUTILITIESDIR/bin/dev/load_devdb.csh $DBNAME mgd.backup mgd_dbo >>& $LOG
${newmgddbperms}/developers/perm_grant.csh
date >> $LOG
$DBUTILITIESDIR/bin/dev/load_devdb.csh $NOMEN nomen.backup mgd_dbo >>& $LOG
date >> $LOG
$DBUTILITIESDIR/bin/dev/reconfig_nomen.csh $newnomendb >>& $LOG
date >> $LOG

echo "Update MGI DB Info..." >> $LOG
$DBUTILITIESDIR/bin/updatePublicVersion.csh $DBSERVER $DBNAME "MGI 2.9" >>& $LOG
$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-3-0-0" >>& $LOG
$DBUTILITIESDIR/bin/turnonbulkcopy.csh $DBSERVER $DBNAME >>& $LOG

echo "Data Migration..." >> $LOG

./tr3802.csh >>& $LOG
./tr3588.csh >>& $LOG
./tr3516.csh >>& $LOG

echo "Drop and re-create Triggers..." >> $LOG
${newdbschema}/trigger/trigger_drop.csh >> $LOG
${newdbschema}/trigger/trigger_create.csh >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

exec MGI_Table_Column_Cleanup
go

checkpoint
go

quit
 
EOSQL

date >> $LOG

