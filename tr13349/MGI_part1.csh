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

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
EOSQL

date | tee -a ${LOG}
./probe.csh | tee -a $LOG 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- delete "Not Loaded" terms
--_segmenttype_key
--select * from voc_term where _vocab_key = 10;
delete from voc_term where _term_key = 74802;
--_vector_key
--select * from voc_term where _vocab_key = 24;
delete from voc_term where _term_key = 316371;
--select * from voc_term where _vocab_key = 147;
--age
delete from voc_term where _term_key = 64242117;

--select * from voc_term where _vocab_key = 17;
update prb_source set _gender_key = 315168 where _gender_key = 315170;
delete from voc_term where _term_key = 315170;

EOSQL

# create autosequence
${PG_MGD_DBSCHEMADIR}/autosequence/autosequence_drop.sh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/autosequence/autosequence_create.sh | tee -a $LOG 

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
#${PG_MGD_DBSCHEMADIR}/index/index_drop.sh | tee -a $LOG 
#${PG_MGD_DBSCHEMADIR}/index/index_create.sh | tee -a $LOG 

date | tee -a ${LOG}
echo 'running procedures/views' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/procedure/PRB_insertReference_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/procedure/PRB_insertReference_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/view/PRB_Marker_View_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/view/PRB_Marker_View_create.object | tee -a $LOG 

#
# reconfig.sh:
# Drop and re-create database triggers, stored procedures, views and comments
# always a good idea to do to make sure that nothing was missed with schema changes
#
date | tee -a ${LOG}
echo 'running triggers, procedures, views, comments' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/reconfig.csh | tee -a $LOG 
#${PG_MGD_DBSCHEMADIR}/comments/comments.sh | tee -a $LOG 
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG 
#${PG_DBUTILS}/bin/vacuumDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG 
#${PG_DBUTILS}/bin/analyzeDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG 

#
# cleanobjects.sh : removing stray mgi_notes
#
date | tee -a ${LOG}
echo 'data cleanup' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/test/cleanobjects.sh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/test/deletejnum.csh | tee -a $LOG 

#
# rebuild the java dla, if needed due to schema changes
# this can be commented out if not necessary
#
${MGI_JAVALIB}/lib_java_dbsmgd/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

