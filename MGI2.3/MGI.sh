#!/bin/csh -f

#
# Migration for MGI 2.3 release
#
# Modification Notes:
# Nov. 5, 1999 JCG
# added line to rerun rules i.e. regenerate checkDNAType (without EST)

setenv DSQUERY $1
setenv MGD $2
setenv STRAINS $3
setenv NOMEN $4

setenv LOG `pwd`/MGI.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

# run schema change scripts first

echo "Schema TR 153..." >> $LOG
./migration_script_153.sh $DSQUERY $MGD >>& $LOG

echo "Schema TR 204 PRB..." >> $LOG
./migration_script_204_PRB.sh $DSQUERY $MGD >>& $LOG

echo "Schema TR 375..." >> $LOG
./migration_script_375.sh $DSQUERY $MGD >>& $LOG

echo "Schema triggers/stored procedures/views..." >> $LOG
$scripts/views/views.sh $DSQUERY $MGD >> $LOG
$scripts/procedures/procedures.sh $DSQUERY $MGD >> $LOG
$scripts/triggers/triggers.sh $DSQUERY $MGD >> $LOG
$scripts/views/nomen/views.sh $DSQUERY $NOMEN $MGD >> $LOG
$scripts/procedures/nomen/procedures.sh $DSQUERY $NOMEN $MGD >> $LOG
$scripts/triggers/nomen/triggers.sh $DSQUERY $NOMEN $MGD >> $LOG
$scripts/rules/rules.sh $DSQUERY $MGD >> $LOG

echo "TR 204..." >> $LOG
./tr204.sh $DSQUERY $MGD $STRAINS >>& $LOG

echo "TR 375 load..." >> $LOG
./tr375.py >>& $LOG

echo "MLC conversion..." >> $LOG
./mlc_convert.py -S $DSQUERY -D $MGD -U mgd_dbo -P `cat $SYBASE/admin/.mgd_dbo_password` >>& $LOG

echo "" >> $LOG
echo "TR 487/554/611 EST migration..." >> $LOG
./migrateEST.sh $DSQUERY $MGD
echo "See migrateEST.$DSQUERY.$MGD.log for details of EST migration" >> $LOG

# Get most current UniGene data file for putative regeneration
echo "" >> $LOG
echo "TR 487: Get UniGene cluster data..." >> $LOG
set ugDir = $scripts/utilities/UniGene
pushd ugDir
# reroute any stderr messages into the log file via a sub-shell
(fileByUrl.py ftp://ftp.ncbi.nlm.nih.gov/repository/UniGene/Mm.data.Z | \
	uncompress > ./Mm.data) >>& $LOG

echo "" >>$LOG
echo "Load UniGene cluster associations..." >>$LOG
./UniGeneLoad.py --input=./Mm.data -S $DSQUERY -D $MGD \
		-U mgd_dbo -P $scripts/.mgd_dbo_password >>& $LOG
popd

# Regenerate Putatives
echo "" >> $LOG
echo "TR 487: Regenerate putatives based on UniGene cluster data..." >> $LOG
pushd $scripts/utilities/EST
./putatives.sh $DSQUERY $MGD mgd_dbo $scripts/.mgd_dbo_password >>& $LOG
popd

# Rebuild MRK tables (specifically MRK_Reference)

echo "Rebuild MRK tables..." >> $LOG
cd $scripts/utilities/MRK
./createMRK.sh $DSQUERY $MGD >>& $LOG

date >> $LOG

