#!/bin/csh -f

#
# Migration for EI TR 2618
#

setenv SYBASE	/opt/sybase
setenv PYTHONPATH       /usr/local/mgi/lib/python
set path = ($path $SYBASE/bin)

setenv DSQUERY $1
setenv MGD $2
setenv NOMEN $3
setenv STRAINS $4

setenv LOG MGI.log

cd $SYBASE/admin/migration/TR2618

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = /usr/local/mgi/dbutils/dbschema/dev

#
# For integration testing purposes...comment out before production load
#

#/opt/sybase/admin/utilities/load_devdb.sh $MGD mgd.backup mgd_dbo >>& $LOG
#/opt/sybase/admin/utilities/load_devdb.sh $NOMEN nomen.backup mgd_dbo >>& $LOG
#/opt/sybase/admin/utilities/load_devdb.sh $STRAINS strains.backup mgd_dbo >>& $LOG

#
# Re-run all triggers, sps, views....
#

$scripts/triggers/mgd/triggers.sh $DSQUERY $MGD >>& $LOG
$scripts/views/mgd/views.sh $DSQUERY $MGD >>& $LOG
$scripts/procedures/mgd/procedures.sh $DSQUERY $MGD >>& $LOG

$scripts/triggers/nomen/triggers.sh $DSQUERY $NOMEN $MGD >>& $LOG
$scripts/views/nomen/views.sh $DSQUERY $NOMEN $MGD >>& $LOG
$scripts/procedures/nomen/procedures.sh $DSQUERY $NOMEN $MGD >>& $LOG

echo "Data Migration..." >> $LOG
./tr2488.sql $DSQUERY $MGD $NOMEN >>& $LOG

echo "Update MGI DB Info..." >> $LOG
./updateMGI.sql $DSQUERY $MGD $NOMEN $STRAINS >>& $LOG

date >> $LOG

