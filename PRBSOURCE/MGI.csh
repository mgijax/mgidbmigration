#!/bin/csh -f

#
# PRB_Source changes
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
#
# For integration testing purposes...comment out before production load
#

#$DBUTILITIESDIR/bin/dev/load_devdb.csh $DBNAME mgd.backup mgd_dbo | tee -a $LOG
#date | tee -a $LOG

#loadVoc.csh | tee -a $LOG
prbsource.csh | tee -a $LOG

# reconfiguration
${newmgddbschema}/key/key_drop.csh | tee -a $LOG
${newmgddbschema}/key/key_create.csh | tee -a $LOG
$DBUTILITIESDIR/bin/dev/reconfig_mgd.csh ${newmgddb} | tee -a $LOG

#echo "Install Developer's Permissions..." >>$LOG
#${newmgddbperms}/developers/perm_grant.csh | tee -a $LOG

date | tee -a $LOG

