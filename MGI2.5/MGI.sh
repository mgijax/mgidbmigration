#!/bin/csh -f

#
# Migration for MGI 2.5
#

setenv SYBASE	/opt/sybase
setenv PYTHONPATH       /usr/local/mgi/lib/python
set path = ($path $SYBASE/bin)

setenv DSQUERY $1
setenv MGD $2
setenv NOMEN $3
setenv STRAINS $4
setenv WTS $5

setenv LOG MGI.log

cd $SYBASE/admin/migration/MGI2.5

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

echo "Schema Migration..." >> $LOG
./tr1003.sql $DSQUERY $MGD >>& $LOG
./tr1027.sql $DSQUERY $MGD >>& $LOG
./tr1884.sql $DSQUERY $MGD $NOMEN $STRAINS $WTS >>& $LOG
./tr1916.sql $DSQUERY $NOMEN >>& $LOG
./tr1963_alt.sql $DSQUERY $MGD >>& $LOG

#
# Re-run all triggers, sps, views....
#

$scripts/triggers/mgd/triggers.sh $DSQUERY $MGD >>& $LOG
$scripts/views/mgd/views.sh $DSQUERY $MGD >>& $LOG
$scripts/procedures/mgd/procedures.sh $DSQUERY $MGD >>& $LOG

$scripts/triggers/nomen/triggers.sh $DSQUERY $NOMEN $MGD >>& $LOG
$scripts/views/nomen/views.sh $DSQUERY $NOMEN $MGD >>& $LOG
$scripts/procedures/nomen/procedures.sh $DSQUERY $NOMEN $MGD >>& $LOG

./mgd_set_perms_dev $DSQUERY $MGD
./mgd_set_perms_prod $DSQUERY $MGD
./mgd_set_perms_public $DSQUERY $MGD

date >> $LOG

