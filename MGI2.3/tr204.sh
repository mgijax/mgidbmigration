#!/bin/csh -f

#
# Migration for TR 204
#

setenv DSQUERY $1
setenv MGD $2
setenv STRAINS $3

setenv LOG `pwd`/tr204.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

# run schema change scripts first

echo "Schema TR 204 Strains..." >> $LOG
./migration_script_204_strains.sh $DSQUERY $STRAINS >>& $LOG

# Run SLMS one more time for TR 204

echo "SLMS..." >> $LOG
cd $scripts/utilities/strains
./slms.sh master.mgi.in all >>& $LOG
cp -r master.mgi.out $scripts/migration/MGI2.3
cd $scripts/migration/MGI2.3

echo "TR 204 CV load..." >> $LOG
./tr204a.py >>& $LOG

echo "TR 204 Strain load..." >> $LOG
./tr204b.py >>& $LOG

echo "TR 204 Notes load..." >> $LOG
./tr204c.py >>& $LOG

echo "Strain triggers/procedures/views..." >> $LOG
$scripts/views/strains/views.sh $DSQUERY $STRAINS $MGD >> $LOG
$scripts/procedures/strains/procedures.sh $DSQUERY $STRAINS $MGD >> $LOG
$scripts/triggers/strains/triggers.sh $DSQUERY $STRAINS $MGD >> $LOG

./tr204.sql $DSQUERY $STRAINS $MGD >> $LOG

date >> $LOG

