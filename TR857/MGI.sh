#!/bin/csh -f

#
# Migration for TR 857
#

setenv DSQUERY $1
setenv MGD $2
setenv NOMEN $3

setenv LOG `pwd`/MGI.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin
 
$scripts/procedures/procedures.sh $DSQUERY $MGD
$scripts/triggers/triggers.sh $DSQUERY $MGD
$scripts/views/views.sh $DSQUERY $MGD

$scripts/procedures/nomen/procedures.sh $DSQUERY $NOMEN $MGD
$scripts/triggers/nomen/triggers.sh $DSQUERY $NOMEN $MGD
$scripts/views/nomen/views.sh $DSQUERY $NOMEN $MGD

#
# TR 696
#

$scripts/utilities/MRK/createMRK.sh $DSQUERY $MGD

date >> $LOG

