#!/bin/csh -f

#
# Migration for TR 2770
#

cd `dirname $0`

setenv SYBASE	/opt/sybase
set path = ($path $SYBASE/bin)

setenv DSQUERY MGD_DEV
setenv MGD mgd_release
setenv NOMEN nomen_release
setenv STRAINS strains_release
setenv MGDDB /usr/local/mgi/dbutils/mgd_release
setenv NOMENDB /usr/local/mgi/dbutils/nomen_release
setenv STRAINSDB /usr/local/mgi/dbutils/strains_release

setenv LOG MGI.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
/usr/local/mgi/dbutils/mgidbutilities/current/bin/dev/load_devdb.csh $MGD mgd.backup >>& $LOG
/usr/local/mgi/dbutils/mgidbutilities/current/bin/dev/load_devdb.csh $NOMEN nomen.backup >>& $LOG
/usr/local/mgi/dbutils/mgidbutilities/current/bin/dev/load_devdb.csh $STRAINS strains.backup >>& $LOG

/usr/local/mgi/dbutils/mgidbutilities/current/bin/updateSchemaVersion.csh $DSQUERY $MGD mgddbschema-1-0-11 >>& $LOG
/usr/local/mgi/dbutils/mgidbutilities/current/bin/updateSchemaVersion.csh $DSQUERY $NOMEN nomendbschema-3-0-1 >>& $LOG
/usr/local/mgi/dbutils/mgidbutilities/current/bin/updateSchemaVersion.csh $DSQUERY $STRAINS strainsdbschema-1-0-2 >>& $LOG

/usr/local/mgi/dbutils/mgidbutilities/current/bin/dev/reconfig_mgd.csh ${MGDDB} >>& $LOG
/usr/local/mgi/dbutils/mgidbutilities/current/bin/dev/reconfig_nomen.csh ${NOMENDB} >>& $LOG
/usr/local/mgi/dbutils/mgidbutilities/current/bin/dev/reconfig_strains.csh ${STRAINSDB} >>& $LOG

date >> $LOG

