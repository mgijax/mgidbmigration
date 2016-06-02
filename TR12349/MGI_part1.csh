#!/bin/csh -fx

#
# Migration for TR12349
#
# 1. add Orc ids to MGI_User table
# 2. add gene/isoform relationships
#
# new tags:
# pgmgddbschema
#
# obsolete:
# gaf_fprocessor
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec radar /bhmgidevdb01/dump/radar.dump
#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec mgd /bhmgidevdb01/dump/mgd.dump

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
update MGI_dbinfo set schema_version = '6-0-6', public_version = 'MGI 6.06';
EOSQL
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 1 : orc ids' | tee -a $LOG || exit 1
./orcids.csh | tee -a $LOG || exit 1

date | tee -a ${LOG}

${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

