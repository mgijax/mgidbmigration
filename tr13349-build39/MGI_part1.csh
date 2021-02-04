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
echo "deleting coordinate collections RIKEN, MGI, miRBase, GtRNAdb, ePCR BLAST, UniSTS, Tom Sproule, UCSC, MGI_Curation, djr"
echo "deleting B38 location notes, these were all created on 2017-04-25 and are noteKey 633229215 through 633229231"
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

delete from MAP_Coord_Collection where _collection_key in (96, 64, 57, 58, 68, 59, 62, 85, 56, 94)
;

delete from MGI_Note where _note_key between 633229215 and 633229231
;

EOSQL

#
# date | tee -a ${LOG}
# echo 'Run Molecular note load'| tee -a ${LOG}
# ${NOTELOAD}/mginotload.csh /mgi/all/wts_projects/13300/13349/Build39/MolecularNotes/molecularnote.config
#
#
date | tee -a ${LOG}
echo "deleting Homologene, HGNC and Hybrid clusters"
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

delete from MRK_Cluster where _clustersource_key in (9272151, 13437099, 13764519)
;

delete from VOC_Term where _vocab_key = 89 and _term_key in (9272151, 13437099, 13764519)
;
EOSQL

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
update MGI_dbinfo set schema_version = '6-0-17', public_version = 'MGI 6.17';
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

#
# reconfig.sh:
# Drop and re-create database triggers, stored procedures, views and comments
# always a good idea to do to make sure that nothing was missed with schema changes
#
date | tee -a ${LOG}
#echo 'running triggers, procedures, views, comments' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/reconfig.csh | tee -a $LOG 
#${PG_MGD_DBSCHEMADIR}/comments/comments.sh | tee -a $LOG 
#${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG 
#${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG 
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
#${MGI_JAVALIB}/lib_java_dbsmgd/Install | tee -a $LOG
#${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

