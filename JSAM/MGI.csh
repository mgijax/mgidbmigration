#!/bin/csh -f

#
# Migration for JSAM
#
# updated:  
# Defaults:	  6
# Tables:	190
# Procedures:	100
# Rules:	  5
# Triggers:	150
# Views:	197
#
# For this release, we need a copy of the schema for both
# the current release and the new release.
#
# Full Test: 12/03/2003
# Time: 9:11-12:43 (3.5 hours)
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
 
# old way
#${DBUTILITIESDIR}/bin/dev/load_devdb.csh ${DBNAME} mgd_release.backup mgd_dbo | tee -a $LOG
#date | tee -a  $LOG

########################################
# need to start with a MGI 2.98 database
#
# new way
# load an empty database and fill it with current MGI 2.98 data
#./loadData.csh

# OR

# load a backup of pre-loaded MGI 2.98 database
./load_dev2db.csh dev2mgd.backup

date | tee -a  $LOG

########################################

#${DBUTILITIESDIR}/bin/load_db.csh ${DBSERVER} ${NOMEN} /extra2/sybase/nomen_release.backup mgd_dbo | tee -a $LOG
date | tee -a  $LOG

echo "Update MGI DB Info..." | tee -a  $LOG
${DBUTILITIESDIR}/bin/updatePublicVersion.csh ${DBSERVER} ${DBNAME} ${PUBLIC_VERSION} | tee -a $LOG
${DBUTILITIESDIR}/bin/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a $LOG
${DBUTILITIESDIR}/bin/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a $LOG

echo "Reconfigure Nomen..." | tee -a  $LOG
#${DBUTILITIESDIR}/bin/dev/reconfig_nomen.csh ${newnomendb} | tee -a $LOG
date | tee -a  $LOG
exit 0

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
${DBUTILITIESDIR}/bin/dev/reconfig_mgd.csh ${newmgddb} | tee -a $LOG

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

date | tee -a  $LOG

