#!/bin/csh -f

#
# Migration for JSAm
#
# updated:  
# Defaults:	  6
# Tables:	190
# Procedures:	101
# Rules:	  5
# Triggers:	150
# Views:	197
#
# For this release, we need a copy of the schema for both
# the current release and the new release.
#
# Full Test: 10/21/2003
# Time: 9:04-12:04 (3 hours)
#
# Full Test: 10/10/2003
# Time: 9:07-11:04 (2 hours)
#
# Full Test: 09/08/2003
# Time: 12:24:36AM - 14:02 (1 hour, 38 minutes)
#
# Full Test: 08/27/2003
# Time: 11:45AM - 13:20 (2 hours)
#
# Full Test: 05/23/2003
# Time: 8AM-10AM (2 hours)
#
# Full Test: 07/14/2003
# Time: 11:13-13:43 (2.5 hours)
#
# Full Test: 07/28/2003
# Time: 14:36-16:07 (2 hours)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a  $LOG
 
#
# For integration testing purposes...comment out before production load
#

$DBUTILITIESDIR/bin/dev/load_devdb.csh $DBNAME mgd_release.backup mgd_dbo | tee -a $LOG
date | tee -a  $LOG
$DBUTILITIESDIR/bin/dev/load_devdb.csh $NOMEN nomen_release.backup mgd_dbo | tee -a $LOG
date | tee -a  $LOG

echo "Update MGI DB Info..." | tee -a  $LOG
$DBUTILITIESDIR/bin/updatePublicVersion.csh $DBSERVER $DBNAME "MGI 3.0" | tee -a $LOG
$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-8-0-0" | tee -a $LOG
$DBUTILITIESDIR/bin/turnonbulkcopy.csh $DBSERVER $DBNAME | tee -a $LOG

echo "Reconfigure Nomen..." | tee -a  $LOG
#$DBUTILITIESDIR/bin/dev/reconfig_nomen.csh ${newnomendb} | tee -a $LOG
date | tee -a  $LOG

# order is important!
echo "Data Migration..." | tee -a  $LOG
./accmgitype.csh | tee -a $LOG
./loadVoc.csh | tee -a $LOG
./mgiuserdefault.csh | tee -a $LOG
./mgiuser.csh | tee -a $LOG
./mgimisc.csh | tee -a $LOG
./mginote.csh | tee -a $LOG
./mgispecies.csh | tee -a $LOG
./mgimarker.csh | tee -a $LOG
./mgiprbmarker.csh | tee -a $LOG
exit 0
./mgiref.csh | tee -a $LOG
./mgisequence.csh | tee -a $LOG
./mginew.csh | tee -a $LOG
./nomen.csh | tee -a $LOG
./acc.csh | tee -a $LOG
./mgiset.csh | tee -a $LOG
./mgimap.csh | tee -a $LOG

date | tee -a  $LOG

#
# Re-create all triggers, sps, views....
#

${newmgddbschema}/default/default_unbind.csh | tee -a $LOG
${newmgddbschema}/default/default_bind.csh | tee -a $LOG
${newmgddbschema}/key/key_drop.csh | tee -a $LOG
${newmgddbschema}/key/key_create.csh | tee -a $LOG
$DBUTILITIESDIR/bin/dev/reconfig_mgd.csh ${newmgddb} | tee -a $LOG

echo "Install Developer's Permissions..." | tee -a $LOG
${newmgddbperms}/developers/perm_grant.csh | tee -a  $LOG
date | tee -a  $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

drop table ACC_Accession_Old
go

drop table ACC_AccessionReference_Old
go

drop table ACC_AccessionMax_Old
go

drop rule check_DNAtype
go

drop rule check_labelType
go

drop table GXD_AntibodySpecies
go

drop table MRK_Species
go

drop table PRB_Species
go

drop table PRB_Vector_Types
go

exec MGI_Table_Column_Cleanup
go

checkpoint
go

quit
 
EOSQL

# add indexes not added before
${newmgddbschema}/index/MGI_Note_create.object | tee -a $LOG
${newmgddbschema}/index/MGI_NoteChunk_create.object | tee -a $LOG
${newmgddbschema}/index/MGI_Reference_Assoc_create.object | tee -a $LOG
${oldmgddbschema}/procedure/GEN_rowcount_drop.object | tee -a $LOG

updateStatisticsAll.csh ${newmgddbschema}

# load translations

./loadTrans.csh | tee -a $LOG

# load some sequence data for testing

tr4849.csh | tee -a $LOG

# load Sequence Cache tables

${CACHELOAD}/seqmarker.csh | tee -a $LOG
${CACHELOAD}/seqprobe.csh | tee -a $LOG
${MRKREFLOAD}/mrkref.csh | tee -a $LOG

date | tee -a  $LOG

