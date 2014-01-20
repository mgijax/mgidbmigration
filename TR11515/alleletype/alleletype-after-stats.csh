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

-- 17
update MGI_StatisticSql set sqlChunk =
'select count(_Allele_key) FROM ALL_Allele WHERE _Allele_Type_key = 847116 AND _Allele_Status_key in (847114, 3983021) '
where _Statistic_key = 17
go

-- 18
update MGI_StatisticSql set sqlChunk =
'select count(_Allele_key) FROM ALL_Allele WHERE _Allele_Type_key = 847126 AND _Allele_Status_key = 847114'
where _Statistic_key = 18
go

-- 22
update MGI_StatisticSql set sqlChunk =
'select count(distinct _Allele_key) FROM ALL_Cre_Cache'
where _Statistic_key = 22
go

-- 69
delete from MGI_StatisticSql where _Statistic_key = 69
go

insert into MGI_StatisticSql values(69,1,
'select count(distinct(_Marker_key)) from all_allele WHERE _Allele_Type_key = 847116 AND _Allele_Status_key in  (847114, 3983021)')
go

-- 70
update MGI_StatisticSql set sqlChunk =
'select count(_Allele_key) FROM ALL_Allele a WHERE _Allele_Type_key = 847116 AND _Allele_Status_key in (847114, 3983021) AND exists (select 1 from VOC_Annot va where a._Allele_key = va._Object_key and va._AnnotType_key = 1014 and va._Term_key = 11025593)'
where _Statistic_key = 70
go

-- 71
delete from MGI_StatisticSql where _Statistic_key = 71
go

insert into MGI_StatisticSql values(71,1,
'select count(distinct(_Marker_key)) from ALL_Allele a where _Allele_Type_key = 847116 AND _Allele_Status_key in (847114, 3983021)')

insert into MGI_StatisticSql values(71,2,
' AND exists (select 1 from VOC_Annot va where a._Allele_key = va._Object_key and va._AnnotType_key = 1014 and va._Term_key = 11025593)')
go

-- 76
update MGI_StatisticSql set sqlChunk =
'SELECT COUNT(_Allele_key) FROM ALL_Allele WHERE _Allele_Type_key = 847116 AND _Allele_Status_key in (847114, 3983021) and _Transmission_key != 3982953'
where _Statistic_key = 76
go

-- 77
delete from MGI_StatisticSql where _Statistic_key = 77
go

insert into MGI_StatisticSql values(77,1,
'SELECT COUNT(_Allele_key) FROM ALL_Allele a WHERE _Allele_Type_key = 847116 AND _Allele_Status_key in (847114, 3983021) and _Transmission_key != 3982953'
)

insert into MGI_StatisticSql values(77,2,
' AND exists (select 1 from VOC_Annot va where a._Allele_key = va._Object_key and va._AnnotType_key = 1014 and va._Term_key = 11025593)')
go

-- 78
delete from MGI_StatisticSql where _Statistic_key = 78
go

insert into MGI_StatisticSql values(78,1,
'SELECT COUNT(_Allele_key) FROM ALL_Allele a WHERE _Allele_Type_key = 847116 AND _Allele_Status_key in (847114, 3983021) and _Transmission_key = 3982953')

insert into MGI_StatisticSql values(78,2,
' AND exists (select 1 from VOC_Annot va where a._Allele_key = va._Object_key and va._AnnotType_key = 1014 and va._Term_key = 11025593)')
go

-- 81

delete from MGI_StatisticSql where _Statistic_key = 81
go

insert into MGI_StatisticSql values(81,1,
'select count(distinct(_Marker_key)) from all_allele a where  _Allele_Type_key = 847116 AND _Allele_Status_key in (847114, 3983021) and _Transmission_key != 3982953')

insert into MGI_StatisticSql values(81,2,
' AND exists (select 1 from VOC_Annot va where a._Allele_key = va._Object_key and va._AnnotType_key = 1014 and va._Term_key = 11025593)')
go

-- 82
delete from MGI_StatisticSql where _Statistic_key = 82
go

insert into MGI_StatisticSql values(82,1,
'select count(distinct(a._Marker_key)) from all_allele a WHERE a._Allele_Type_key = 847116 AND a._Allele_Status_key in (847114, 3983021)')

insert into MGI_StatisticSql values(82,2,
' and exists (select (1) from all_allele a2 where a._Allele_key = a2 ._Allele_key and a2._Transmission_key = 3982953)')

insert into MGI_StatisticSql values(82,3,
' and not exists (select (1) from all_allele a3 where a._Allele_key = a3._Allele_key and a3._Transmission_key != 3982953)')

insert into MGI_StatisticSql values(82,4,
' AND exists (select 1 from VOC_Annot va where a._Allele_key = va._Object_key and va._AnnotType_key = 1014 and va._Term_key = 11025593)')

go

-- 85

update MGI_StatisticSql set sqlChunk =
'select count(distinct _Allele_key) from ALL_Cre_Cache where _Allele_Type_key = 847116'
where _Statistic_key = 85
go

-- 86

update MGI_StatisticSql set sqlChunk =
'select count(distinct _Allele_key) from ALL_Cre_Cache where _Allele_Type_key = 847126'
where _Statistic_key = 86
go

-- 88

update MGI_StatisticSql set sqlChunk =
'select count (distinct driverNote) from ALL_Cre_Cache where _Allele_Type_key = 847126'
where _Statistic_key = 88
go

-- 89

update MGI_StatisticSql set sqlChunk =
'select count(distinct driverNote) from ALL_Cre_Cache where _Allele_Type_key = 847116'
where _Statistic_key = 89
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

select s._Statistic_key, substring(s.name,1,50), m.intValue
from MGI_Statistic s, MGI_Measurement m
where m.isLatest = 1 
and m._Statistic_key in (17,18,22,69,70,71,76,77,78,81,85,86,88,89)
and m._Statistic_key = s._Statistic_key
order by _Statistic_key
go

EOSQL
date | tee -a ${LOG}

# for testing, run on VALINOR
echo "AFTER EXPORTER IS RUN, RUN: ${USRLOCALMGI}/mgihome/admin/gen_stats" | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

