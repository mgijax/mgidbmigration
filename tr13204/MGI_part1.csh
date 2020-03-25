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

# create autosequence on VOC_Term table
${PG_MGD_DBSCHEMADIR}/autosequence/autosequence_drop.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/autosequence_create.sh | tee -a $LOG || exit 1

# remove term accession ids and the voc_term insert trigger that creates them
./deleteTermIDs.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
delete from VOC_Term where _vocab_key in (145, 146);
DROP TRIGGER IF EXISTS VOC_Term_insert_trigger ON VOC_Term;

-- done in API
DROP TRIGGER IF EXISTS VOC_Annot_update_trigger ON VOC_Annot;
DROP FUNCTION IF EXISTS VOC_Annot_update();

EOSQL
date | tee -a ${LOG}

# clean up go-annotations
./goannot.csh | tee -a $LOG || exit 1

# add real primary key to GXD_AntibodyMarker
./gxd_all.csh | tee -a $LOG || exit 1

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
update MGI_dbinfo set schema_version = '6-0-16', public_version = 'MGI 6.16';
EOSQL
date | tee -a ${LOG}

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
echo 'running triggers, procedures, views, comments' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/reconfig.csh | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/comments/comments.sh | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1
#${PG_DBUTILS}/bin/vacuumDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#${PG_DBUTILS}/bin/analyzeDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1

#
# cleanobjects.sh : removing stray mgi_notes
#
#date | tee -a ${LOG}
#echo 'data cleanup' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/test/cleanobjects.sh | tee -a $LOG || exit 1

#
# rebuild the java dla, if needed due to schema changes
# this can be commented out if not necessary
#
${MGI_JAVALIB}/lib_java_dbsmgd/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

