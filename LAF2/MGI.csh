#!/bin/csh -f

#
# LAF 2
#

cd `dirname $0`

setenv DBUTILITIESDIR	/usr/local/mgi/dbutils/mgidbutilities
setenv PYTHONPATH	/usr/local/mgi/lib/python

#setenv newmgddb /usr/local/mgi/dbutils/mgd
setenv newmgddb /home/lec/db
#setenv newmgddb /home/lec/db/sao
setenv newmgddbschema ${newmgddb}/mgddbschema
setenv newmgddbperms ${newmgddb}/mgddbperms

setenv newnomendb /home/lec/db
setenv newnomendbschema ${newmgddb}/nomendbschema
setenv newnomendbperms ${newmgddb}/nomendbperms

# sets database stuff (DBSERVER, DBNAME)
source ${newmgddbschema}/Configuration

setenv LOG $0.log

#setenv labelload /usr/local/mgi/dbutils/mrklabelload
setenv labelload /home/lec/loads/mrklabelload

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

#echo "Update MGI DB Info..." >> $LOG
#$DBUTILITIESDIR/bin/updatePublicVersion.csh $DBSERVER $DBNAME "MGI 3.0" >>& $LOG
#$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-4-0-0" >>& $LOG
#$DBUTILITIESDIR/bin/turnonbulkcopy.csh $DBSERVER $DBNAME >>& $LOG

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

${newmgddbschema}/view/VOC_Term_View_drop.object >>& $LOG
${newmgddbschema}/view/VOC_Term_View_create.object >>& $LOG
${newmgddbperms}/public/perm_grant.csh >> $LOG

${newmgddbschema}/default/default_unbind.csh >>& $LOG
${newmgddbschema}/default/default_bind.csh >>& $LOG
${newmgddbschema}/key/key_drop.csh >>& $LOG
${newmgddbschema}/key/key_create.csh >>& $LOG
$DBUTILITIESDIR/bin/dev/reconfig_mgd.csh ${newmgddb} >>& $LOG

echo "Install Developer's Permissions..." >>$LOG
${newmgddbperms}/developers/perm_grant.csh >> $LOG
date >> $LOG

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

