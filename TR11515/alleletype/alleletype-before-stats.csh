#!/bin/csh -f

#
# Migration for TR11515/Allele Type
#
# Update/Run MGI_Statistic/Measurements
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

cd ${DBUTILS}/mgidbmigration/TR11515/alleletype

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select s._Statistic_key, substring(s.name,1,50), m.intValue
from MGI_Statistic s, MGI_Measurement m
where m.isLatest = 1 
and m._Statistic_key in (17,18,22,69,70,71,76,77,78,81,85,86,88,89)
and m._Statistic_key = s._Statistic_key
order by _Statistic_key
go

EOSQL
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}