#!/bin/csh -fx

# Migration for TR9924 -- fall 2009 maintenance release

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

${UTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.32" | tee -a ${LOG}
${UTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-3-2-0" | tee -a ${LOG}

setenv DB_PARMS "${MGD_DBUSER} ${MGI_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME}"

cd ${CWD}

###--------------------###
###--- data changes ---###
###--------------------###

date | tee -a ${LOG}
echo "--- Update MouseFunc to be FuncBase" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update ACC_LogicalDB set name = "FuncBase" where _LogicalDB_key = 124
update ACC_ActualDB set name = "FuncBase" where _ActualDB_key = 110
go
EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
