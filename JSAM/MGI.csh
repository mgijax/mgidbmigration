#!/bin/csh -f

#
# Migration for JSAM
#
# updated:  
# Tables:	
# Procedures:	
# Triggers:	
# Views:	
#

cd `dirname $0`

#setenv NOMEN nomen
setenv NOMEN nomen_lec

setenv SYBASE	/opt/sybase
setenv DBUTILITIESDIR	/usr/local/mgi/dbutils/mgidbutilities
setenv PYTHONPATH	/usr/local/mgi/lib/python

#setenv newmgddb /usr/local/mgi/dbutils/mgd
setenv newmgddb /home/lec/db
#setenv newmgddbschema ${newmgddb}/mgddbschema
setenv newmgddbschema ${newmgddb}/dbsao
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
#$DBUTILITIESDIR/bin/dev/load_devdb.csh $NOMEN nomen.backup mgd_dbo >>& $LOG
#date >> $LOG

echo "Update MGI DB Info..." >> $LOG
#$DBUTILITIESDIR/bin/updatePublicVersion.csh $DBSERVER $DBNAME "MGI 2.8" >>& $LOG
#$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-2-0-12" >>& $LOG
#$DBUTILITIESDIR/bin/turnonbulkcopy.csh $DBSERVER $DBNAME >>& $LOG

echo "Data Migration..." >> $LOG

#
# drop old/obsolete objects
#

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

checkpoint
go

quit
 
EOSQL
  
date >> $LOG

#
# Re-create all triggers, sps, views....
#

${newmgddbschema}/key/key_drop.csh
${newmgddbschema}/key/key_create.csh
$DBUTILITIESDIR/bin/dev/reconfig_mgd.csh ${newmgddb} >>& $LOG

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

