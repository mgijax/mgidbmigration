#!/bin/csh -f

#
# Migrate MGD3.3 data into MGI1.0 structures
# Run IDDS setup/checkup on database
#

setenv DSQUERY $1
setenv MGD $2
setenv CREATEIDX $3

setenv LOG `pwd`/MGI.log
 
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

# Drop triggers
cd $scripts/triggers
foreach i (`ls *.drop`)
$i $DSQUERY $MGD | tee -a $LOG
end

cd $scripts/migration/MGI1.0

Homology.sh $DSQUERY $MGD $CREATEIDX | tee -a $LOG
Misc.sh $DSQUERY $MGD | tee -a $LOG
Strains.sh $DSQUERY $MGD $CREATEIDX | tee -a $LOG

# Rebuild MRK_Reference table

$scripts/utilities/createMRK_Reference.sql $DSQUERY $MGD | tee -a $LOG

# Rebuild views, triggers, stored procedures

cd $scripts/views
foreach i (`ls *.view`)
$i $DSQUERY $MGD | tee -a $LOG
end

cd $scripts/triggers
foreach i (`ls *.tr`)
$i $DSQUERY $MGD | tee -a $LOG
end

cd $scripts/procedures
foreach i (`ls *.pr`)
$i $DSQUERY $MGD | tee -a $LOG
end

#
# Run IDDS Setup for System Tables only
#

cd $scripts/utilities/IDDS
./IDDSsetup.py -S$DSQUERY -D$MGD -Umgd_dbo -P$SYBASE/admin/.mgd_dbo_password -X | tee -a $LOG
./IDDScheckup.py -S$DSQUERY -D$MGD -Umgd_dbo -P$SYBASE/admin/.mgd_dbo_password | tee -a $LOG

cd $scripts/migration/MGI1.0

date >> $LOG

