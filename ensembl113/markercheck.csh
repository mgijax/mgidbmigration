#!/bin/csh -f

#
# check markers
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

--
-- MRK and MLD tables
-- do this before deleting the sequences
--

select m._marker_key, m.symbol, a.accid as mgiId
into temp table toDelete
from seq_marker_cache s, mrk_marker m, acc_accession a
where s._logicaldb_key = 222
and s._marker_key = m._marker_key
and m._marker_key = a._object_key
and a._mgitype_key = 2
and a._logicaldb_key = 1
and a.preferred = 1
and not exists (select 1 from all_allele a where a._marker_key = s._marker_key )
;

select m.*
from toDelete m
where exists (select 1 from MGI_Relationship r where m._marker_key = r._object_key_1 and r._category_key in (1000,1002,1003,1004,1006,1008,1009,1010,1012,1013))
or exists (select 1 from MGI_Relationship r where m._marker_key = r._object_key_2 and r._category_key in (1000,1002,1003,1004,1006,1008,1009,1010,1012,1013))
;

EOSQL

date |tee -a $LOG

