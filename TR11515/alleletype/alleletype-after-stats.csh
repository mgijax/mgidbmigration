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

-- update MGI_StatisticSql
update MGI_StatisticSql set sqlChunk =
'SELECT COUNT(_Allele_key) FROM ALL_Allele WHERE _Allele_Type_key = 847116 AND _Allele_Status_key in (847114, 3983021) '
where _Statistic_key = 17
go

update MGI_StatisticSql set sqlChunk =
'SELECT COUNT(_Allele_key) FROM ALL_Allele WHERE _Allele_Type_key = 847126 AND _Allele_Status_key = 847114'
where _Statistic_key = 18
go

update MGI_StatisticSql set sqlChunk =
'select count(distinct(_Marker_key)) from all_allele WHERE _Allele_Type_key = 847116 AND _Allele_Status_key in  (847114, 3983021)'
where _Statistic_key = 69 and sequenceNum = 1
delete from MGI_StatisticSql where _Statistic_key = 69 and sequenceNum > 1
go

update MGI_StatisticSql set sqlChunk =
'SELECT COUNT(_Allele_key) FROM ALL_Allele WHERE _Allele_Type_key = 847116 AND _Allele_Status_key in (847114, 3983021) and _Transmission_key != 3982953'
where _Statistic_key = 76
go

EOSQL
date | tee -a ${LOG}

#
# run MGI_Statistics
#
${MGI_DBUTILS}/bin/addMeasurements.csh | tee -a ${LOG}

#
# get latest stats
#
date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select * from MGI_Measurement 
where isLatest = 1 
and _Statistic_key in (17,18,22,69,70,71,76,77,78,81,85,86,88,89)
order by _Statistic_key
go

EOSQL
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

