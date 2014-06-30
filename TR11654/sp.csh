#!/bin/csh -fx

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

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select a.accID from ACC_Accession a, BIB_DataSet_Assoc ba
        where a._MGIType_key = 1
        and a._LogicalDB_key = 1
        and a.prefixPart = "J:"
        and a._Object_key = ba._Refs_key
        and ba._DataSet_key = 1005
        and ba.isNeverUsed = 1
go

EOSQL
date | tee -a ${LOG}

