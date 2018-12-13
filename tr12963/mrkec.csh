#!/bin/csh -f

#
# add J:23000 to EC accessions that don't have any
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

select m.symbol, a.accid
from ACC_Accession a, MRK_Marker m
where a._logicaldb_key = 8
and not exists (select 1 from acc_accessionreference r where a._accession_key = r._accession_key)
and a._Object_key = m._Marker_key
order by m.symbol
;

insert into ACC_AccessionReference 
select a._accession_key, 22864, 1001, 1001, now(), now()
from ACC_Accession a
where a._logicaldb_key = 8
and not exists (select 1 from acc_accessionreference r where a._accession_key = r._accession_key)
and exists (select 1 from mrk_marker r where a._object_key = r._marker_key)
;

select m.symbol, a.accid
from ACC_Accession a, MRK_Marker m
where a._logicaldb_key = 8
and not exists (select 1 from acc_accessionreference r where a._accession_key = r._accession_key)
and a._Object_key = m._Marker_key
order by m.symbol
;

EOSQL

date |tee -a $LOG

