#!/bin/csh -f

#
# delete Ensembl Reg 108
# delete Ensembl Reg 108 Markers that do not have Alleles, or any other object
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

delete from map_coord_collection where _collection_key = 150;
delete from seq_sequence s where s._sequenceprovider_key = 102032586;

select count(s.*) from seq_sequence s where s._sequenceprovider_key = 102032586;

select count(s.*)
from seq_sequence s, seq_sequence_raw sr
where s._sequenceprovider_key = 102032586
and s._sequence_key = sr._sequence_key
;

select m.symbol, a.accid as mgiId
into temp table toDelete
from seq_marker_cache s, mrk_marker m
where s._logicaldb_key = 222
and s._marker_key = m._marker_key
and not exists (select 1 from all_allele a where a._marker_key = s._marker_key )
;

delete from mrk_marker using toDelete where toDelete._marker_key = mrk_marker._marker_key;

EOSQL

date |tee -a $LOG

