#!/bin/csh -f

#
# Migration for MGI 2.6
#

setenv SYBASE	/opt/sybase
setenv PYTHONPATH       /usr/local/mgi/lib/python
set path = ($path $SYBASE/bin)

setenv DSQUERY $1
setenv MGD $2
setenv NOMEN $3
setenv STRAINS $4

setenv LOG MGI.log

cd $SYBASE/admin/migration/MGI2.6

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

#
# For integration testing purposes...comment out before production load
#

/opt/sybase/admin/utilities/load_devdb.sh $MGD mgd.backup mgd_dbo >>& $LOG
/opt/sybase/admin/utilities/load_devdb.sh $NOMEN nomen.backup mgd_dbo >>& $LOG
/opt/sybase/admin/utilities/load_devdb.sh $STRAINS strains.backup mgd_dbo >>& $LOG

#
# Re-run all triggers, sps, views....
#

$scripts/triggers/mgd/triggers.sh $DSQUERY $MGD >>& $LOG
$scripts/views/mgd/views.sh $DSQUERY $MGD >>& $LOG
$scripts/procedures/mgd/procedures.sh $DSQUERY $MGD >>& $LOG

$scripts/triggers/nomen/triggers.sh $DSQUERY $NOMEN $MGD >>& $LOG
$scripts/views/nomen/views.sh $DSQUERY $NOMEN $MGD >>& $LOG
$scripts/procedures/nomen/procedures.sh $DSQUERY $NOMEN $MGD >>& $LOG

$scripts/triggers/strains/triggers.sh $DSQUERY $STRAINS $MGD >>& $LOG
$scripts/views/strains/views.sh $DSQUERY $STRAINS $MGD >>& $LOG
$scripts/procedures/strains/procedures.sh $DSQUERY $STRAINS $MGD >>& $LOG

echo "Data Migration..." >> $LOG
./tr2193.sql $DSQUERY $MGD >>& $LOG
./tr1467.sql $DSQUERY $MGD $NOMEN >>& $LOG

echo "LocusLink Load..." >> $LOG
/usr/local/mgi/dataload/locuslinkload/LLloadAll.sh

#
# For integration testing purposes...comment out before production load
#
echo "RIKEN Load..." >> $LOG
/usr/local/mgi/dataload/rikenloadpostpub/rikenload.sh

echo "SWISS-PROT Load..." >> $LOG
/usr/local/mgi/dataload/swissload/preswissload.csh
/usr/local/mgi/dataload/swissload/swissload.csh
/usr/local/mgi/dbutils/mrkrefload/mrkref.sh

echo "Update MGI DB Info..." >> $LOG
./updateMGI.sql $DSQUERY $MGD $NOMEN $STRAINS >>& $LOG

date >> $LOG

