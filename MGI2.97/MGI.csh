#!/bin/csh -f

#
# MGI 2.97
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
$DBUTILITIESDIR/bin/dev/load_devdb.csh $DBNAME mgd_release.backup mgd_dbo | tee -a $LOG
date | tee -a $LOG
#$DBUTILITIESDIR/bin/dev/load_devdb.csh $NOMEN nomen.backup mgd_dbo | tee -a $LOG
#date | tee -a $LOG

echo "Update MGI DB Info..." | tee -a $LOG
$DBUTILITIESDIR/bin/updatePublicVersion.csh $DBSERVER $DBNAME "MGI 2.97" | tee -a $LOG
$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-6-0-0" | tee -a $LOG
$DBUTILITIESDIR/bin/turnonbulkcopy.csh $DBSERVER $DBNAME | tee -a $LOG

#echo "Reconfigure Nomen..." | tee -a $LOG
#$DBUTILITIESDIR/bin/dev/reconfig_nomen.csh ${newnomendb} | tee -a $LOG
#date | tee -a $LOG

accmgitype.csh | tee -a $LOG
loadVoc.csh | tee -a $LOG
tr2459.csh | tee -a $LOG
tr3710.csh | tee -a $LOG
tr3432.csh | tee -a $LOG

# reconfiguration
${newmgddbschema}/key/key_drop.csh | tee -a $LOG
${newmgddbschema}/key/key_create.csh | tee -a $LOG
$DBUTILITIESDIR/bin/dev/reconfig_mgd.csh ${newmgddb} | tee -a $LOG

#echo "Install Developer's Permissions..." >>$LOG
${newmgddbperms}/developers/perm_grant.csh | tee -a $LOG

#cat - <<EOSQL | doisql.csh $0 | tee -a $LOG

#use $DBNAME
#go

#drop table GXD_Index_Old
#go

#drop table GXD_Index_Stages_Old
#go

#drop table GXD_Structure_Old
#go

#drop table GXD_Assay_Old
#go

#end

#EOSQL

date | tee -a $LOG

