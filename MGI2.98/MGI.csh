#!/bin/csh -f

#
# MGI 2.98
#
# procedures: 87
# triggers:  140
# tables:    177
# views:     149
#
#
# 11/05/2003	12:41PM - 13:10PM = 30 minutes
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
#
# For integration testing purposes...comment out before production load
#

$DBUTILITIESDIR/bin/dev/load_devdb.csh $DBNAME mgd.backup mgd_dbo | tee -a $LOG
date | tee -a $LOG
$DBUTILITIESDIR/bin/dev/load_devdb.csh $NOMEN nomen.backup mgd_dbo | tee -a $LOG
date | tee -a $LOG

echo "Update MGI DB Info..." | tee -a $LOG
$DBUTILITIESDIR/bin/updatePublicVersion.csh $DBSERVER $DBNAME "MGI 2.98" | tee -a $LOG
$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-7-0-0" | tee -a $LOG
$DBUTILITIESDIR/bin/turnonbulkcopy.csh $DBSERVER $DBNAME | tee -a $LOG

echo "Reconfigure Nomen..." | tee -a $LOG
$DBUTILITIESDIR/bin/dev/reconfig_nomen.csh ${newnomendb} | tee -a $LOG
date | tee -a $LOG

tr4579.csh | tee -a $LOG
tr5260.csh | tee -a $LOG

# reconfiguration
${newmgddbschema}/key/key_drop.csh | tee -a $LOG
${newmgddbschema}/key/key_create.csh | tee -a $LOG
$DBUTILITIESDIR/bin/dev/reconfig_mgd.csh ${newmgddb} | tee -a $LOG

echo "Install Developer's Permissions..." >>$LOG
${newmgddbperms}/developers/perm_grant.csh | tee -a $LOG

cat - <<EOSQL | doisql.csh $0 | tee -a $LOG

use $DBNAME
go

drop table VOC_Evidence_Old
go

end

EOSQL

date | tee -a $LOG

