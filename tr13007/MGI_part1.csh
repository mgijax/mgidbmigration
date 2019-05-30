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

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec radar /bhmgidevdb01/dump/radar.dump
#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec mgd /bhmgidevdb01/dump/mgd.dump
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
update MGI_dbinfo set schema_version = '6-0-15', public_version = 'MGI 6.13';
EOSQL
date | tee -a ${LOG}

#
# gxd_htsample
#
date | tee -a ${LOG}
echo 'step 1: GXD_HTSample tables' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/procedure/procedure_create.sh | tee -a $LOG || exit 1
./gxdhtsample.csh | tee -a $LOG
date | tee -a ${LOG}

#
# add new RNA Seq tables
#
date | tee -a ${LOG}
echo 'step 2: adding new RNA Seq tables' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_RNASeq_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_RNASeqCombined_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_RNASeqSet_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_RNASeqSetMember_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_HTSample_RNASeq_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_HTSample_RNASeqCombined_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_HTSample_RNASeqSet_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_HTSample_RNASeqSetMember_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeq_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqCombined_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSet_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSetMember_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_RNASeq_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_RNASeqCombined_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_RNASeqSet_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_RNASeqSetMember_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

ALTER TABLE mgd.GXD_HTSample_RNASeq ADD FOREIGN KEY (_Sample_key) REFERENCES mgd.GXD_HTSample ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeq ADD FOREIGN KEY (_Marker_key) REFERENCES mgd.MRK_Marker DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeq ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeq ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;

ALTER TABLE mgd.GXD_HTSample_RNASeqCombined ADD FOREIGN KEY (_Marker_key) REFERENCES mgd.MRK_Marker DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqCombined ADD FOREIGN KEY (_Level_key) REFERENCES mgd.VOC_Term DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqCombined ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqCombined ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;

ALTER TABLE mgd.GXD_HTSample_RNASeqSet ADD FOREIGN KEY (_Experiment_key) REFERENCES mgd.GXD_HTExperiment ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqSet ADD FOREIGN KEY (_Organism_key) REFERENCES mgd.MGI_Organism DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqSet ADD FOREIGN KEY (_Sex_key) REFERENCES mgd.VOC_Term DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqSet ADD FOREIGN KEY (_Emapa_key) REFERENCES mgd.VOC_Term DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqSet ADD FOREIGN KEY (_Stage_key) REFERENCES mgd.GXD_TheilerStage DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqSet ADD FOREIGN KEY (_Genotype_key) REFERENCES mgd.GXD_Genotype DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqSet ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqSet ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;

ALTER TABLE mgd.GXD_HTSample_RNASeqSetMember ADD FOREIGN KEY (_Sample_key) REFERENCES mgd.GXD_HTSample ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqSetMember ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqSetMember ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;

EOSQL
date | tee -a ${LOG}

#
# img_image stuff
#
date | tee -a ${LOG}
echo 'step 3: IMG tables' | tee -a $LOG
./imgimage.csh | tee -a $LOG
date | tee -a ${LOG}

#
# elsevier/going out to production asap
#
#date | tee -a ${LOG}
#echo 'step ?: elsevier stuff' | tee -a $LOG
#./elsevier.csh | tee -a $LOG
#date | tee -a ${LOG}

#
# indexes
# only run the ones needed per schema changes
#
#date | tee -a ${LOG}
#echo 'running indexes' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/index/index_drop.sh | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/index/index_create.sh | tee -a $LOG || exit 1

#
# reconfig.sh:
# Drop and re-create database triggers, stored procedures, views and comments
# always a good idea to do to make sure that nothing was missed with schema changes
#
date | tee -a ${LOG}
echo 'step 4: running triggers, procedures, views, comments' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/reconfig.csh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/trigger_create.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/comments.sh | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1
#${PG_DBUTILS}/bin/vacuumDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#${PG_DBUTILS}/bin/analyzeDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1

# obsolete qcreports
rm -rf /data/reports/qcreports_db/output/GXD_HTSampleIncompAgeAndTS.rpt
rm -rf /data/reports/qcreports_db/output/GXD_HTSampleNoAge.rpt
rm -rf /data/reports/qcreports_db/output/GXD_HTSampleWrongAge.sql.rpt

#
# cleanobjects.sh : removing stray mgi_notes
#
date | tee -a ${LOG}
echo 'data cleanup' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/test/cleanobjects.sh | tee -a $LOG || exit 1

#
# rebuild the java dla, if needed due to schema changes
# this can be commented out if not necessary
#
#${MGI_JAVALIB}/lib_java_dbsmgd/Install | tee -a $LOG
#${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

