#!/bin/csh -fx

#
# Migration for TR11423
# (part 0 - load new HDP annotation type & data)
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/scrum-dog/mgiconfig
	#setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update MGI_dbinfo set 
        schema_version = '5-1-6', 
        public_version = 'MGI 5.16'
go

EOSQL
date | tee -a ${LOG}

#
# sto128
#
date | tee -a ${LOG}
./sto128.csh | tee -a ${LOG}
date | tee -a ${LOG}

#
# sto88
#
date | tee -a ${LOG}
./sto88.csh | tee -a ${LOG}
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

