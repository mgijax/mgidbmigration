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
update MGI_dbinfo set schema_version = '6-0-17', public_version = 'MGI 6.17';
EOSQL
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'dropping indexes, procedures, views, triggers' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/autosequence/autosequence_drop.sh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/procedure/procedure_drop.sh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/view/view_drop.sh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/trigger/trigger_drop.sh | tee -a $LOG 

${PG_MGD_DBSCHEMADIR}/key/ALL_drop.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/BIB_drop.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_drop.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MLD_drop.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MRK_drop.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_drop.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_drop.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/ACC_MGIType_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/BIB_drop.logical | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/MLD_drop.logical | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/PRB_drop.logical | tee -a $LOG 

date | tee -a ${LOG}
./probe.csh | tee -a $LOG 

date | tee -a ${LOG}
./bib.csh | tee -a $LOG 

date | tee -a ${LOG}
./mld.csh | tee -a $LOG 

date | tee -a ${LOG}
./mgi.csh | tee -a $LOG 

#
# indexes
# only run the ones needed per schema changes
#
date | tee -a ${LOG}
echo 'creating indexes, procedures, views, triggers' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/autosequence/autosequence_create.sh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/ALL_create.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/BIB_create.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_create.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MLD_create.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MRK_create.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_create.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_create.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/ACC_MGIType_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/BIB_create.logical | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/MLD_create.logical | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/PRB_create.logical | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/view/view_create.sh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/procedure/procedure_create.sh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/trigger/trigger_create.sh | tee -a $LOG 

#
# reconfig.sh:
# Drop and re-create database triggers, stored procedures, views and comments
# always a good idea to do to make sure that nothing was missed with schema changes
#
date | tee -a ${LOG}
echo 'running triggers, procedures, views, comments' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/reconfig.csh | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/comments/comments.sh | tee -a $LOG 
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG 
#${PG_DBUTILS}/bin/vacuumDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG 
#${PG_DBUTILS}/bin/analyzeDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG 

date | tee -a ${LOG}
./vocab.csh | tee -a $LOG 

# must be run after autosequence/procedure/etc.
date | tee -a ${LOG}
./bibrelevance.csh | tee -a $LOG

date | tee -a ${LOG}
./journal.csh | tee -a $LOG 

date | tee -a ${LOG}
./prostatus.csh | tee -a $LOG 

${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG 

#
# cleanobjects.sh : removing stray mgi_notes
#
#date | tee -a ${LOG}
#echo 'data cleanup' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/test/cleanobjects.sh | tee -a $LOG 
#${PG_MGD_DBSCHEMADIR}/test/deletejnum.csh | tee -a $LOG 

#
# rebuild the java dla, if needed due to schema changes
# this can be commented out if not necessary
#
${MGI_JAVALIB}/lib_java_core/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dbsmgd/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dbsrdr/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

