#!/bin/csh -f

#
# Template
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

update mgi_statisticsql
set sqlchunk = regexp_replace(sqlchunk, 'IN \(1,3\)', '= 1', 'g')
where sqlchunk like '%IN (1,3)%'
;

update mgi_statisticsql
set sqlchunk = regexp_replace(sqlchunk, 'in \(1,3\)', '= 1', 'g')
where sqlchunk like '%in (1,3)%'
;

update mgi_statisticsql
set sqlchunk = regexp_replace(sqlchunk, '!= 2', '= 1', 'g')
where sqlchunk like '%!= 2%'
;

select _statistic_key, sqlchunk
from mgi_statisticsql
where sqlchunk like '%(1,3)%'
;

select _statistic_key, sqlchunk
from mgi_statisticsql
where sqlchunk like '%_Marker_Status_key = 1%'
;

EOSQL

${PG_DBUTILS}/bin/measurements/addMeasurements.csh | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

SELECT m.*
FROM MGI_Measurement m, MGI_StatisticSql s
where m.isLatest = 1
and m._Statistic_key = s._Statistic_key
and s.sqlchunk like '%_Marker_Status_key = 1%'
order by m._Statistic_key
;

EOSQL

date |tee -a $LOG

