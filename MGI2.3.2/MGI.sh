#!/bin/csh -f

#
# Migration for MGI 2.3.2 release
#

setenv SYBASE	/opt/sybase
setenv PYTHONPATH       /usr/local/lib/python1.4:/usr/local/etc/httpd/python
set path = ($path $SYBASE/bin)

setenv DSQUERY $1
setenv MGD $2
setenv NOMEN $3
setenv STRAINS $4

setenv LOG MGI.log

cd $SYBASE/admin/migration/MGI2.3.2

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

#
# Re-run all triggers, sps, views....
# Run procedures twice since some ACC procedures depend on MRK procedures
# and the ACC.pr runs BEFORE the MRK.pr...
#

$scripts/triggers/triggers.sh $DSQUERY $MGD >>& $LOG
$scripts/procedures/procedures.sh $DSQUERY $MGD >>& $LOG
$scripts/procedures/procedures.sh $DSQUERY $MGD >>& $LOG
$scripts/views/views.sh $DSQUERY $MGD >>& $LOG

$scripts/triggers/nomen/triggers.sh $DSQUERY $NOMEN $MGD >>& $LOG
$scripts/procedures/nomen/procedures.sh $DSQUERY $NOMEN $MGD >>& $LOG
$scripts/views/nomen/views.sh $DSQUERY $NOMEN $MGD >>& $LOG

$scripts/triggers/strains/triggers.sh $DSQUERY $STRAINS $MGD >>& $LOG
$scripts/procedures/strains/procedures.sh $DSQUERY $STRAINS $MGD >>& $LOG
$scripts/views/strains/views.sh $DSQUERY $STRAINS $MGD >>& $LOG

echo "TR 1278..." >> $LOG
./tr1278.sql $DSQUERY $MGD >>& $LOG

echo "TR 1284..." >> $LOG
./tr1284.sql $DSQUERY $MGD >>& $LOG

./mlc_convert_italics.py -S $DSQUERY -D $MGD -P `cat $scripts/.mgd_dbo_password` -u update >> $LOG

date >> $LOG

