#!/bin/csh -f

#
# Migration for TR 2770
#

cd `dirname $0`

setenv SYBASE	/opt/sybase
set path = ($path $SYBASE/bin)

setenv DSQUERY $1
setenv MGD $2
setenv DBSCHEMA /home/lec/dbschema
#setenv DBSCHEMA /usr/local/mgi/dbutils/dbschema

setenv LOG MGI.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
${DBSCHEMA}/triggers/mgd/MRK.tr $DSQUERY $MGD >>& $LOG
${DBSCHEMA}/views/mgd/GXD.view $DSQUERY $MGD >>& $LOG

date >> $LOG

