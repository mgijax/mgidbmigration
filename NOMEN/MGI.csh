#!/bin/csh -f

#
# Migration for NomenDB
#
# updated:  
# Defaults:	  6
# Tables:	190
# Procedures:	100
# Rules:	  5
# Triggers:	150
# Views:	197
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a  $LOG
 
${DBUTILITIESDIR}/bin/load_db.csh ${DBSERVER} ${DBNAME} /extra2/sybase/mgd.backup mgd_dbo | tee -a $LOG
date | tee -a  $LOG

${DBUTILITIESDIR}/bin/load_db.csh ${DBSERVER} ${NOMEN} /extra2/sybase/nomen.backup mgd_dbo | tee -a $LOG
date | tee -a  $LOG

echo "Update MGI DB Info..." | tee -a  $LOG
${DBUTILITIESDIR}/bin/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a $LOG
${DBUTILITIESDIR}/bin/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a $LOG

echo "Reconfigure Nomen..." | tee -a  $LOG
${DBUTILITIESDIR}/bin/dev/reconfig_nomen.csh ${newnomendb} | tee -a $LOG
date | tee -a  $LOG

# order is important!
echo "Data Migration..." | tee -a  $LOG
./loadVoc.csh | tee -a $LOG
./mgiref.csh | tee -a $LOG
./nomen.csh | tee -a $LOG

date | tee -a  $LOG

#
# Re-create all triggers, sps, views....
#

${DBUTILITIESDIR}/bin/dev/reconfig_mgd.csh ${newmgddb} | tee -a $LOG

echo "Install Developer's Permissions..." | tee -a $LOG
${newmgddbperms}/developers/perm_grant.csh | tee -a  $LOG
date | tee -a  $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

exec MGI_Table_Column_Cleanup
go

checkpoint
go

quit
 
EOSQL

updateStatisticsAll.csh ${newmgddbschema}

date | tee -a  $LOG

