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
#date | tee -a ${LOG}
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#update MGI_dbinfo set schema_version = '6-0-15', public_version = 'MGI 6.13';
#EOSQL
#date | tee -a ${LOG}

#
# add new RNA Seq Set Cache table
#
date | tee -a ${LOG}
echo 'step 2: adding new RNA Seq tables' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_RNASeqSet_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_HTSample_RNASeqSet_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSet_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_RNASeqSet_Cache_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

ALTER TABLE mgd.GXD_HTSample_RNASeqSet_Cache ADD FOREIGN KEY (_RNASeqSet_key) REFERENCES mgd.GXD_HTSample_RNASeqSet ON DELETE CASCADE DEFERRABLE;

ALTER TABLE mgd.GXD_HTSample_RNASeqSet_Cache ADD FOREIGN KEY (_RNASeqCombined_key) REFERENCES mgd.GXD_HTSample_RNASeqCombined ON DELETE CASCADE DEFERRABLE;

ALTER TABLE mgd.GXD_HTSample_RNASeqSet_Cache ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;

ALTER TABLE mgd.GXD_HTSample_RNASeqSet_Cache ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;

EOSQL
date | tee -a ${LOG}

#
# reconfig.sh:
# Drop and re-create database triggers, stored procedures, views and comments
# always a good idea to do to make sure that nothing was missed with schema changes
#
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSet_Cache_drop.object  | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeq_drop.object  | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSetMember_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSet_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqCombined_drop.object | tee -a $LOG

${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqCombined_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSet_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSetMember_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeq_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSet_Cache_create.object | tee -a $LOG


date | tee -a ${LOG}
echo 'running comments, perms, objectCounter' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/comments/comments.sh | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1
#${PG_DBUTILS}/bin/vacuumDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#${PG_DBUTILS}/bin/analyzeDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

