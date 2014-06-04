#!/bin/csh -fx

#
# Migration for Feature Relationship (FeaR) project
# (part 1 - optionally load dev database. etc)
#
# Products:
# mgddbschema
# rvload
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

echo "--- create tempdb table ---" | tee -a ${LOG}
#cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}
cat - <<EOSQL | isql -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGI_PUBLICUSER} -P`cat ${MGI_PUBPASSWORDFILE}` -e  >> ${LOG}


use tempdb
go

create table MGI_ID (
    mgiID1 int not null,
    mgiID1TypeKey int not null,
    mgiID2 int not null,
    mgiID2TypeKey int not null,
)
go

grant all on MGI_ID to public
go

quit

EOSQL

# load the table and create indexes
./test_tempdb.py
date | tee -a ${LOG}
