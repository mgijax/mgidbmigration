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

-- 69
delete from MGI_StatisticSql where _Statistic_key = 69
go

insert into MGI_StatisticSql values(69,1,
'select count(distinct(_Marker_key)) from all_allele WHERE _Allele_Type_key = 847116 AND _Allele_Status_key in  (847114, 3983021)')
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

-- remove SQL that are not used in the Statistics

select distinct ms._Statistic_key, ms.name
from MGI_Statistic ms
where not exists (select 1 from MGI_Set mset, MGI_SetMember msm
	where mset._MGIType_key = (select _MGIType_key
	from ACC_MGIType
	where name = 'Statistic')
and msm._Set_key = mset._Set_key
and ms._Statistic_key = msm._Object_key
)
order by ms.name
go

delete MGI_Statistic
from MGI_Statistic ms
where not exists (select 1 from MGI_Set mset, MGI_SetMember msm
	where mset._MGIType_key = (select _MGIType_key
	from ACC_MGIType
	where name = 'Statistic')
and msm._Set_key = mset._Set_key
and ms._Statistic_key = msm._Object_key
)
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
order by s.name
go

select distinct ms.name, mset.name, ms.abbreviation
from MGI_Set mset, MGI_SetMember msm, MGI_Statistic ms
where mset._MGIType_key = (select _MGIType_key
	from ACC_MGIType
	where name = 'Statistic')
and msm._Set_key = mset._Set_key
and ms._Statistic_key = msm._Object_key
and ms._Statistic_key in (17,18,22,69,70,71,76,77,78,81,85,86,88,89)
order by ms.name
go

EOSQL
date | tee -a ${LOG}

# for testing, run on VALINOR
# mgi-testdb4; configdev
# exportDB.sh mgd postgres "MGI_Statistic MGI_StatisticSQL MGI_Measurement"
# valinor
# ${USRLOCALMGI}/mgihome/admin/gen_stats
echo "AFTER EXPORTER IS RUN, RUN: ${USRLOCALMGI}/mgihome/admin/gen_stats" | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

