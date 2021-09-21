#!/bin/csh -fx

#
# (part 1 running schema changes)
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting part 1' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG 
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG 
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG 
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG 

#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec radar /bhmgidevdb01/dump/radar.dump
#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec mgd /bhmgidevdb01/dump/mgd.dump

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
update MGI_dbinfo set schema_version = '6-0-18', public_version = 'MGI 6.18';

-- obsolete procedure
DROP FUNCTION IF EXISTS GXD_duplicateAssay(int,int,int);
DROP FUNCTION IF EXISTS GXD_replaceGenotype(int,int,int,int);
DROP FUNCTION IF EXISTS GXD_addEMAPASet(int,int);

-- make Cell Ontology DAG
update VOC_Vocab set issimple = 0 where _vocab_key = 102;

EOSQL


echo "--- Create tables ---" | tee -a $LOG
date | tee -a ${LOG}
${PG_MGD_DBSCHEMADIR}/table/GXD_HTRawSample_drop.object
${PG_MGD_DBSCHEMADIR}/table/GXD_HTRawSample_create.object

${PG_MGD_DBSCHEMADIR}/table/MGI_KeyValue_drop.object
${PG_MGD_DBSCHEMADIR}/table/MGI_KeyValue_create.object

${PG_MGD_DBSCHEMADIR}/table/GXD_ISResultCellType_drop.object
${PG_MGD_DBSCHEMADIR}/table/GXD_ISResultCellType_create.object

echo "--- Drop/Create gxd_expression and all_cre_cache tables ---" | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/table/GXD_Expression_drop.object
${PG_MGD_DBSCHEMADIR}/table/GXD_Expression_create.object

${PG_MGD_DBSCHEMADIR}/table/ALL_Cre_Cache_drop.object
${PG_MGD_DBSCHEMADIR}/table/ALL_Cre_Cache_create.object

#
# only run the ones needed per schema changes
#

date | tee -a ${LOG}
echo 'step ??: creating indexes, triggers' | tee -a $LOG
echo "--- Create keys --- " | tee -a $LOG

# primary keys for new tables
${PG_MGD_DBSCHEMADIR}/key/GXD_HTRawSample_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_HTRawSample_create.object

${PG_MGD_DBSCHEMADIR}/key/MGI_KeyValue_drop.object
${PG_MGD_DBSCHEMADIR}/key/MGI_KeyValue_create.object

${PG_MGD_DBSCHEMADIR}/key/GXD_ISResultCellType_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_ISResultCellType_create.object

# primary keys for caches
${PG_MGD_DBSCHEMADIR}/key/GXD_Expression_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_Expression_create.object

${PG_MGD_DBSCHEMADIR}/key/ALL_Cre_Cache_drop.object
${PG_MGD_DBSCHEMADIR}/key/ALL_Cre_Cache_create.object

# foreign keys 
${PG_MGD_DBSCHEMADIR}/key/ACC_MGIType_drop.object
${PG_MGD_DBSCHEMADIR}/key/ACC_MGIType_create.object

${PG_MGD_DBSCHEMADIR}/key/GXD_HTExperiment_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_HTExperiment_create.object

${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object

${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object

${PG_MGD_DBSCHEMADIR}/key/BIB_Refs_drop.object
${PG_MGD_DBSCHEMADIR}/key/BIB_Refs_create.object

${PG_MGD_DBSCHEMADIR}/key/GXD_Assay_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_Assay_create.object

${PG_MGD_DBSCHEMADIR}/key/GXD_AssayType_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_AssayType_create.object

${PG_MGD_DBSCHEMADIR}/key/GXD_GelLane_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_GelLane_create.object

${PG_MGD_DBSCHEMADIR}/key/GXD_Genotype_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_Genotype_create.object

${PG_MGD_DBSCHEMADIR}/key/GXD_Specimen_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_Specimen_create.object

${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_create.object

${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_create.object

${PG_MGD_DBSCHEMADIR}/key/ALL_Allele_drop.object
${PG_MGD_DBSCHEMADIR}/key/ALL_Allele_create.object

echo "--- Create indexes --- " | tee -a $LOG

${PG_MGD_DBSCHEMADIR}/index/GXD_HTRawSample_drop.object
${PG_MGD_DBSCHEMADIR}/index/GXD_HTRawSample_create.object

${PG_MGD_DBSCHEMADIR}/index/MGI_KeyValue_drop.object
${PG_MGD_DBSCHEMADIR}/index/MGI_KeyValue_create.object

${PG_MGD_DBSCHEMADIR}/index/GXD_ISResultCellType_drop.object
${PG_MGD_DBSCHEMADIR}/index/GXD_ISResultCellType_create.object

${PG_MGD_DBSCHEMADIR}/index/GXD_Expression_drop.object
${PG_MGD_DBSCHEMADIR}/index/GXD_Expression_create.object

${PG_MGD_DBSCHEMADIR}/index/ALL_Cre_Cache_drop.object
${PG_MGD_DBSCHEMADIR}/index/ALL_Cre_Cache_create.object

echo "--- Recreate all autosequence --- " | tee -a $LOG

${PG_MGD_DBSCHEMADIR}/autosequence/autosequence_drop.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/autosequence/autosequence_create.sh | tee -a $LOG

#${PG_MGD_DBSCHEMADIR}/key/key_drop.sh | tee -a $LOG 
#${PG_MGD_DBSCHEMADIR}/key/key_create.sh | tee -a $LOG 
#${PG_MGD_DBSCHEMADIR}/index/index_drop.sh | tee -a $LOG 
#${PG_MGD_DBSCHEMADIR}/index/index_create.sh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/procedure/procedure_drop.sh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/view/view_drop.sh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/view/view_create.sh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/procedure/procedure_create.sh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/trigger/trigger_drop.sh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/trigger/trigger_create.sh | tee -a $LOG 

#
# reconfig.sh
# Drop and re-create database triggers, stored procedures, views and comments
# always a good idea to do to make sure that nothing was missed with schema changes
#
date | tee -a ${LOG}
echo 'step ??: Running comments permissions, objectCounter' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/reconfig.csh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/comments/comments.sh | tee -a $LOG 
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG 
#${PG_DBUTILS}/bin/vacuumDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG 
#${PG_DBUTILS}/bin/analyzeDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG 

date | tee -a ${LOG}
echo 'step ??: running vocab.csh' | tee -a $LOG
#./vocab.csh | tee -a ${LOG}

# delete desired GEO experiments so they may be reloaded
# save notes for those that have them for later reloading
date | tee -a ${LOG}
echo 'step ??: running expt_delete.csh' | tee -a $LOG
./expt_delete.csh | tee -a ${LOG}

#
# cleanobjects.sh : removing stray mgi_notes
#
date | tee -a ${LOG}
echo 'data cleanup' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/test/cleanobjects.sh | tee -a $LOG 
#${PG_MGD_DBSCHEMADIR}/test/deletejnum.csh | tee -a $LOG 

#
# rebuild the java dla, if needed due to schema changes
# this can be commented out if not necessary
#
#${MGI_JAVALIB}/lib_java_core/Install | tee -a $LOG
#${MGI_JAVALIB}/lib_java_dbsmgd/Install | tee -a $LOG
#${MGI_JAVALIB}/lib_java_dbsrdr/Install | tee -a $LOG
#${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

