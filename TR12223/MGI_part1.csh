#!/bin/csh -fx

#
# Migration for TR12223
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

#
# update schema-version and public-version
#
#date | tee -a ${LOG}
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#update MGI_dbinfo set schema_version = '6-0-2', public_version = 'MGI 6.02';
#EOSQL
#date | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

