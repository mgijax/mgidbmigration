#!/bin/csh -fx

#
# TR12662/GMC/MGI 6.12
#
# /mgi/all/wts_projects/12600/12662/drivernotes
#
# (part 1 running schema changes)
#
# tr12262 branches:
# pgmgddbschema
# ei
# pgdbutilities
# mgipython
# alleleload : no branch; just add comments
# allcacheload
# assayload : on demand
# probeload : on demand
# mappingload : nomenload
#
# run on production when ready to add "Allele" organisms
# organism.csh : done
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

update MGI_dbinfo set schema_version = '6-0-12', public_version = 'MGI 6.12';

drop view MRK_Classes_View;
drop table MRK_Classes;
drop table MRK_Class;

ALTER TABLE mgd.GXD_Index ADD FOREIGN KEY (_ConditionalMutants_key) REFERENCES mgd.VOC_Term DEFERRABLE;

EOSQL
date | tee -a ${LOG}

#
# Notes
#
./notes.csh | tee -a $LOG || exit 1

#
# triggers
# only run the ones needed per schema changes
#
date | tee -a ${LOG}
echo 'running triggers/views' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/trigger/trigger_drop.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/trigger_create.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/view_drop.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/view_create.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_drop.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_create.logical | tee -a $LOG || exit 1

#
# reconfig.sh:
# Drop and re-create database triggers, stored procedures, views and comments
# always a good idea to do to make sure that nothing was missed with schema changes
#
date | tee -a ${LOG}
#${PG_MGD_DBSCHEMADIR}/reconfig.csh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/comments.sh | tee -a $LOG || exit 1
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
#${MGI_JAVALIB}/lib_java_dbsmgd/Install | tee -a $LOG
#${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

