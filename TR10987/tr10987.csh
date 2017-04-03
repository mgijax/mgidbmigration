#!/bin/csh -fx

#
# Migration for TR10987 loading new probe raw seqeuence notes
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${PG_DBSERVER}"
echo "Database: ${PG_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}


date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

delete from MGI_Note where _NoteType_key = 1037

EOSQL

${NOTELOAD}/mginoteload.csh /mgi/all/wts_projects/10900/10987/noteload.config

date | tee -a ${LOG}

