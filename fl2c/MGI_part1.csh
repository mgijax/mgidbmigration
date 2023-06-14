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
#06/14 done on production
#date | tee -a ${LOG}
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 >>& $LOG
#update MGI_dbinfo set schema_version = '6-0-20', public_version = 'MGI 6.13';
#drop sequence if exists gxd_antibodyclass_seq;
#drop sequence if exists gxd_embedding_seq;
#drop sequence if exists gxd_fixation_seq;
#drop sequence if exists gxd_gelcontrol_seq;
#drop sequence if exists gxd_label_seq;
#drop sequence if exists gxd_pattern_seq;
#drop sequence if exists gxd_visualization_seq;
#EOSQL
#date | tee -a ${LOG}

#
# only run the ones needed per schema changes
#
#date | tee -a ${LOG}
#echo 'running autosequence, indexes, key, procedure, trigger, view' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/autosequence/autosequence_drop.sh >>&  $LOG
#${PG_MGD_DBSCHEMADIR}/autosequence/autosequence_create.sh >>& $LOG
#${PG_MGD_DBSCHEMADIR}/key/key_drop.sh | >>& LOG 
#${PG_MGD_DBSCHEMADIR}/key/key_create.sh >>& $LOG 
#${PG_MGD_DBSCHEMADIR}/index/index_drop.sh >>& $LOG 
#${PG_MGD_DBSCHEMADIR}/index/index_create.sh >>& $LOG 
#${PG_MGD_DBSCHEMADIR}/procedure/procedure_drop.sh >>& $LOG 
#${PG_MGD_DBSCHEMADIR}/view/view_drop.sh >>& $LOG 
#${PG_MGD_DBSCHEMADIR}/view/view_create.sh >>& $LOG 
#${PG_MGD_DBSCHEMADIR}/procedure/procedure_create.sh >>& $LOG 
#${PG_MGD_DBSCHEMADIR}/trigger/trigger_drop.sh >>& $LOG 
#${PG_MGD_DBSCHEMADIR}/trigger/trigger_create.sh >>& $LOG 
#06/14 done on production
#${PG_MGD_DBSCHEMADIR}/view/GXD_Assay_DLTemplate_View_create.object >>& $LOG 

#
# reconfig.sh:
# Drop and re-create database triggers, stored procedures, views and comments
# always a good idea to do to make sure that nothing was missed with schema changes
#
date | tee -a ${LOG}
echo 'setting public permissions, check objectCount, etc' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/reconfig.csh >>& $LOG 
#${PG_MGD_DBSCHEMADIR}/comments/comments.sh >>& $LOG 
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd >>& $LOG 
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG 
#${PG_DBUTILS}/bin/vacuumDB.csh ${PG_DBSERVER} ${PG_DBNAME} >>& $LOG 
#${PG_DBUTILS}/bin/analyzeDB.csh ${PG_DBSERVER} ${PG_DBNAME} >>& $LOG 

#
# cleanobjects.sh : removing stray mgi_notes
#
date | tee -a ${LOG}
echo 'data cleanup' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/test/cleanobjects.sh >>& $LOG 
#${PG_MGD_DBSCHEMADIR}/test/deletejnum.csh >>& $LOG 

#
# rebuild the java dla, if needed due to schema changes
# this can be commented out if not necessary
#
#${MGI_JAVALIB}/lib_java_core/Install >>& $LOG
#${MGI_JAVALIB}/lib_java_dbsmgd/Install >>& $LOG
#${MGI_JAVALIB}/lib_java_dbsrdr/Install >>& $LOG
#${MGI_JAVALIB}/lib_java_dla/Install >>& $LOG

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

