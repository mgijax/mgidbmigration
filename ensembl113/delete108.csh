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
and not exists (select 1 from MGI_Relationship r where m._marker_key = r._object_key_1 and r._category_key in (1000,1002,1003,1004,1006,1008,1009,1010,1012,1013))
and not exists (select 1 from MGI_Relationship r where m._marker_key = r._object_key_2 and r._category_key in (1000,1002,1003,1004,1006,1008,1009,1010,1012,1013))
;

select * from toDelete;

delete from mld_expt_marker using toDelete where toDelete._marker_key = mld_expt_marker._marker_key;
delete from mld_expts e1 where not exists (select 1 from mld_expt_marker e2 where e1._expt_key = e2._expt_key);
delete from mrk_marker using toDelete where toDelete._marker_key = mrk_marker._marker_key;

select s.*
from seq_marker_cache s, mrk_marker m, acc_accession a
where s._logicaldb_key = 222
and s._marker_key = m._marker_key
and m._marker_key = a._object_key
and a._mgitype_key = 2
and a._logicaldb_key = 1
and a.preferred = 1
and not exists (select 1 from all_allele a where a._marker_key = s._marker_key )
;

--
-- MAP & SEQ tables
-- let genemodeload do this
--select count(s.*) from seq_sequence s where s._sequenceprovider_key = 102032586;
--delete from map_coord_collection where _collection_key = 150;
--delete from seq_sequence s where s._sequenceprovider_key = 102032586;
--select count(s.*) from seq_sequence s where s._sequenceprovider_key = 102032586;

EOSQL

date |tee -a $LOG

