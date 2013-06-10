#!/bin/csh -fx

#
###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/scrum-dog/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

cat - <<EOSQL | ${MGI_DBUTILS}/bin/doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

select * from MGI_StatisticSql where _Statistic_key in (43,44)
go

delete from MGI_StatisticSql where _Statistic_key in (43,44)
go

update MGI_Measurement set intValue = 15908632, timeRecorded = getdate() where _Statistic_key = 43
go

EOSQL

${MGI_DBUTILS}/bin/loadMeasurements.csh | tee -a ${LOG}

date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

