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
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}

### ACCRef_insert

--select a.accID from ACC_Accession a 
--where not exists (select 1 from ACC_AccessionReference r where a._Accession_key = r._Accession_key)
--and a._LogicalDB_key = 9;

select * from ACC_AccessionReference where _Accession_key = 2619603;

select ACCRef_insert(2619603,100);

select * from ACC_AccessionReference where _Accession_key = 2619603;

delete from ACC_AccessionReference where _Accession_key = 2619603;

### ACC_setMax

select * from ACC_AccessionMax;

select ACC_setMax(10);
select ACC_setMax(10, 'J:');

EOSQL
date | tee -a ${LOG}

