#!/bin/csh -f

#
# Migration for MGI 2.8
#

cd `dirname $0`

setenv SYBASE	/opt/sybase
setenv PYTHONPATH       /usr/local/mgi/lib/python
set path = ($path $SYBASE/bin /usr/local/mgi/dbutils/mgidbutilities/bin /usr/local/mgi/dbutils/mgidbutilities/bin/dev)

setenv oldmgddbschema /mgd_lec/mgddbschema
setenv oldstrainsdbschema /usr/local/mgi/dbutils/strains/strainsdbschema

setenv newmgddbschema /home/lec/db/mgd_lec
setenv newmgddbperms /home/lec/db/mgd_lec_perms

source ${newmgddbschema}/Configuration

setenv LOG MGI.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
#
# For integration testing purposes...comment out before production load
#

#load_devdb.csh $MGD mgd.backup mgd_dbo >>& $LOG
#load_devdb.csh $NOMEN nomen.backup mgd_dbo >>& $LOG
#load_devdb.csh $STRAINS strains.backup mgd_dbo >>& $LOG

echo "Data Migration..." >> $LOG
./tr256.csh >>& $LOG
./tr2714.csh >>& $LOG
./tr2718.csh >>& $LOG
./tr2902.csh >>& $LOG
./tr2916.csh >>& $LOG
./tr2358.csh >>& $LOG

#
# Re-run all triggers, sps, views....
#

${newmgddbschema}/trigger/trigger_create.csh
${newmgddbschema}/view/view_drop.csh
${newmgddbschema}/view/view_create.csh
${newmgddbschema}/procedure/procedure_drop.csh
${newmgddbschema}/procedure/procedure_create.csh
${newmgddbperms}/all_grant.csh

#$newnomendbschema/trigger/trigger_create.csh
#$newnomendbschema/view/view_create.csh
#$newnomendbschema/procedure/procedure_create.csh

echo "Update MGI DB Info..." >> $LOG
#updateSchemaVersion.csh $DSQUERY $MGD "mgddbschema-2-0-0" >>& $LOG
#updateSchemaVersion.csh $DSQUERY $NOMEN "nomendbschema-2-0-0" >>& $LOG

date >> $LOG

