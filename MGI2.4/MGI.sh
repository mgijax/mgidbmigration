#!/bin/csh -f

#
# Migration for MGI 2.4
#

setenv SYBASE	/opt/sybase
setenv PYTHONPATH       /usr/local/mgi/lib/python:/usr/local/etc/httpd/python
set path = ($path $SYBASE/bin)

setenv DSQUERY $1
setenv MGD $2
setenv NOMEN $3
setenv STRAINS $4

setenv LOG MGI.log

cd $SYBASE/admin/migration/MGI2.4

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

echo "Schema Migration..." >> $LOG
./mgi2.4_migration_jcg.sql $DSQUERY $MGD >>& $LOG
./mgi2.4_migration_nomen_jcg.sql $DSQUERY $NOMEN >>& $LOG

echo "TR 1291..." >> $LOG
./tr1291.sql $DSQUERY $MGD $NOMEN >>& $LOG

echo "TR 1177..." >> $LOG
./tr1177.sql $DSQUERY $MGD >>& $LOG

echo "TR 148..." >> $LOG
./tr148.sql $DSQUERY $MGD >>& $LOG

echo "TR 1404..." >> $LOG
./tr1404.sql $DSQUERY $MGD >>& $LOG

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

echo "Load MiniGO.." >> $LOG
/usr/local/mgi/dataload/minigoload/minigoload.sh $DSQUERY $MGD mgd_dbo $scripts/.mgd_dbo_password /usr/local/mgi/dataload/minigoload/ontology.txt >>& $LOG

date >> $LOG

