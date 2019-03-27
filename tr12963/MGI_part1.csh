#!/bin/csh -fx

#
# (part 1 running schema changes)
#
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
update MGI_dbinfo set schema_version = '6-0-14', public_version = 'MGI 6.14';

-- remove not applicable/not specified
delete from MRK_Status where _Marker_Status_key < 0;

-- obsolete
drop view if exists mgd.MRK_AccRef3_View;
DROP FUNCTION IF EXISTS ACC_insertNoChecks(int,int,text,int,text,int,int,int,int);
drop table MGI_ApiLog_Object;
drop table MGI_ApiLog_Event;
DROP FUNCTION IF EXISTS MGI_insertSynonym(int,int,int,int,text,int);

-- gxd ordering
update voc_term set sequencenum = 1 where _term_key = 20225941;
update voc_term set sequencenum = 2 where _term_key =  20225942;
update voc_term set sequencenum = 3 where _term_key =  20225943;
update voc_term set sequencenum = 4 where _term_key =  20225944;

update voc_term set sequencenum = 10 where _term_key = 20475447;
update voc_term set sequencenum = 11 where _term_key = 20475448;
update voc_term set sequencenum = 12 where _term_key = 20475449;
update voc_term set sequencenum = 13 where _term_key = 32413494;
update voc_term set sequencenum = 14 where _term_key = 32413495;
update voc_term set sequencenum = 15 where _term_key = 32413496;

delete from MGI_UserRole where _Role_key = 6763215 and _User_key not in (1000,1001,1401);

-- reference types
--insert into mgi_notetype values(1051, 45, 'Public', 0, 1001, 1001, now(), now());
--update mgi_notetype set notetype = 'Curated' where _notetype_key = 1050;

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

date | tee -a ${LOG}
echo 'mrkec migration' | tee -a $LOG
./mrkec.csh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'mrkoffset migration' | tee -a $LOG
./mrkoffset.csh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'mrkhistory migration' | tee -a $LOG
./mrkhistory.csh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'new autosequences' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/autosequence/MGI_Synonym_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/VOC_Annot_create.object | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'add variant tables' | tee -a $LOG
./vartables.csh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'delete marker feature types : VOC_Evidence' | tee -a $LOG
./mrkfeaturetypes.csh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'update actualDB url from nucgss to nuccore' | tee -a $LOG
./updateActualDB.csh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'bib_workflow_data changes' | tee -a $LOG
cd bibworkflow
./bibworkflow.csh | tee -a $LOG || exit 1
cd ..

date | tee -a ${LOG}
echo 'views/stored procedures' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/view_drop.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/view_create.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/procedure_drop.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/procedure_create.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/GXD_HTExperiment_create.object | tee -a $LOG || exit 1

#
# reconfig.sh:
# Drop and re-create database triggers, stored procedures, views and comments
# always a good idea to do to make sure that nothing was missed with schema changes
#
date | tee -a ${LOG}
echo 'running triggers, procedures, views, comments' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/reconfig.csh | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/comments/comments.sh | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1

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

#${PG_MGD_DBSCHEMADIR}/test/autosequencecheck.csh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1
#${PG_DBUTILS}/bin/vacuumDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
#${PG_DBUTILS}/bin/analyzeDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

