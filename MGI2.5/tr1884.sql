#!/bin/csh -f

#
# Migration for TR 1884
#

setenv SYBASE   /opt/sybase

setenv DSQUERY	$1
setenv MGD	$2
setenv NOMEN	$3
setenv STRAINS	$4
setenv WTS	$5

setenv LOG $0.log

set scripts = $SYBASE/admin

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
tr1884_a.sql $DSQUERY $MGD "on mgd_seg_0" "on mgd_seg_1" MGI_dbinfo_MGD.bcp >> $LOG
tr1884_a.sql $DSQUERY $NOMEN "" "" MGI_dbinfo_Nomen.bcp >> $LOG
tr1884_a.sql $DSQUERY $STRAINS "" "" MGI_dbinfo_Strains.bcp >> $LOG
tr1884_a.sql $DSQUERY $WTS "" "" MGI_dbinfo_WTS.bcp >> $LOG

date >> $LOG
