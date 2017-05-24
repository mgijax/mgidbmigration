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

echo 'MGD_DBNAME='$MGD_DBNAME | text -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | text -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | text -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | text -a $LOG || exit 1

#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec radar /bhmgidevdb01/dump/radar.dump
#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec mgd /bhmgidevdb01/dump/mgd.dump
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
update MGI_dbinfo set schema_version = '6-0-10', public_version = 'MGI 6.010';
EOSQL
date | tee -a ${LOG}

#
# indexes
# only run the ones needed per schema changes
#
date | tee -a ${LOG}
echo 'running indexes' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/index_drop.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/index_create.sh | tee -a $LOG || exit 1

#
# reconfig.sh:
# Drop and re-create database triggers, stored procedures, views and comments
# always a good idea to do to make sure that nothing was missed with schema changes
#
date | tee -a ${LOG}
echo 'step ??: running triggers, procedures, views, comments' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/reconfig.sh | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

#
# cleanobjects.sh : removing stray mgi_notes
#
date | tee -a ${LOG}
echo 'data cleanup' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/test/cleanobjects.sh | tee -a $LOG || exit 1

#
# run the measurements for are later used for the front-end
#
date | tee -a ${LOG}
echo 'step ??: run statistics' | tee -a $LOG
${PG_DBUTILS}/bin/measurements/addMeasurements.csh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

