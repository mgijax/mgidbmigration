#!/bin/csh -f

#
# Migration for Fantom
#

cd `dirname $0`

setenv SYBASE	/opt/sybase
setenv DBUTILITIESDIR	/usr/local/mgi/dbutils/mgidbutilities
setenv PYTHONPATH	/usr/local/mgi/lib/python

#setenv newmgddb /usr/local/mgi/dbutils/mgd
setenv newmgddb /home/lec/db
setenv newmgddbschema ${newmgddb}/mgddbschema
setenv newmgddbperms ${newmgddb}/mgddbperms

source ${newmgddbschema}/Configuration

setenv LOG $0.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
#
# For integration testing purposes...comment out before production load
#

#$DBUTILITIESDIR/bin/dev/load_devdb.csh $DBNAME mgd.backup mgd_dbo >>& $LOG
#date >> $LOG

echo "Update MGI DB Info..." >> $LOG
#$DBUTILITIESDIR/bin/updatePublicVersion.csh $DBSERVER $DBNAME "MGI 2.8" >>& $LOG
#$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-2-0-27" >>& $LOG
$DBUTILITIESDIR/bin/turnonbulkcopy.csh $DBSERVER $DBNAME >>& $LOG

echo "Data Migration..." >> $LOG
./mgifantom.csh >>& $LOG

#
# drop old/obsolete objects
#

#cat - <<EOSQL | doisql.csh $0 >> $LOG
  
#use ${DBNAME}
#go

#drop table MGI_Fantom2_Old
#go

#checkpoint
#go

#quit
 
#EOSQL
  
date >> $LOG

#
# Re-create all triggers, sps, views....
#

${newmgddbschema}/index/MGI_Fantom2_drop.logical >>& $LOG
${newmgddbschema}/index/MGI_Fantom2_create.logical >>& $LOG
${newmgddbschema}/key/MGI_Fantom2_drop.logical >>& $LOG
${newmgddbschema}/key/MGI_Fantom2_create.logical >>& $LOG
${newmgddbperms}/curatorial/table/MGI_Fantom2_revoke.logical >>& $LOG
${newmgddbperms}/curatorial/table/MGI_Fantom2_grant.logical >>& $LOG

date >> $LOG

