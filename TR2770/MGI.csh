#!/bin/csh -f

#
# Migration for TR 2770
#

cd `dirname $0`

setenv SYBASE	/opt/sybase
set path = ($path $SYBASE/bin)

setenv DSQUERY $1
setenv MGD $2
setenv NOMEN $3
setenv STRAINS	$4
setenv MGDDBSCHEMA /usr/local/mgi/dbutils/mgd_release/mgddbschema
setenv MGDDBPERMS /usr/local/mgi/dbutils/mgd_release/mgddbperms
setenv NOMENDBSCHEMA /usr/local/mgi/dbutils/nomen_release/nomendbschema
setenv NOMENDBPERMS /usr/local/mgi/dbutils/nomen_release/nomendbperms
setenv STRAINSDBSCHEMA /usr/local/mgi/dbutils/strains_release/strainsdbschema
setenv STRAINSDBPERMS /usr/local/mgi/dbutils/strains_release/strainsdbperms

setenv LOG MGI.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
/usr/local/mgi/dbutils/mgidbutilities/current/bin/dev/load_devdb.csh $MGD mgd.backup
/usr/local/mgi/dbutils/mgidbutilities/current/bin/dev/load_devdb.csh $NOMEN nomen.backup
/usr/local/mgi/dbutils/mgidbutilities/current/bin/dev/load_devdb.csh $STRAINS strains.backup

/usr/local/mgi/dbutils/mgidbutilities/current/bin/updateSchemaVersion.csh $DSQUERY $MGD mgddbschema-1-0-9
/usr/local/mgi/dbutils/mgidbutilities/current/bin/updateSchemaVersion.csh $DSQUERY $NOMEN nomendbschema-3-0-1
/usr/local/mgi/dbutils/mgidbutilities/current/bin/updateSchemaVersion.csh $DSQUERY $STRAINS strainsdbschema-1-0-2

${MGDDBSCHEMA}/trigger/trigger_drop.csh
${MGDDBSCHEMA}/trigger/trigger_create.csh
${MGDDBSCHEMA}/procedure/procedure_drop.csh
${MGDDBSCHEMA}/procedure/procedure_create.csh
${MGDDBSCHEMA}/view/view_drop.csh
${MGDDBSCHEMA}/view/view_create.csh
${MGDDBPERMS}/all_grant.csh

${NOMENDBSCHEMA}/trigger/trigger_drop.csh
${NOMENDBSCHEMA}/trigger/trigger_create.csh
${NOMENDBSCHEMA}/procedure/procedure_drop.csh
${NOMENDBSCHEMA}/procedure/procedure_create.csh
${NOMENDBSCHEMA}/view/view_drop.csh
${NOMENDBSCHEMA}/view/view_create.csh
${NOMENDBPERMS}/all_grant.csh

${STRAINSDBSCHEMA}/trigger/trigger_drop.csh
${STRAINSDBSCHEMA}/trigger/trigger_create.csh
${STRAINSDBSCHEMA}/procedure/procedure_drop.csh
${STRAINSDBSCHEMA}/procedure/procedure_create.csh
${STRAINSDBSCHEMA}/view/view_drop.csh
${STRAINSDBSCHEMA}/view/view_create.csh
${STRAINSDBPERMS}/all_grant.csh

date >> $LOG

