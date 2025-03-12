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

select s.*, mp.*, mc.*
from seq_sequence s, map_coord_feature mf, map_coordinate mp, map_coord_collection mc
where s._sequence_key = mf._object_key
and mf._mgitype_key = 19
and mf._map_key = mp._map_key
and mp._collection_key = mc._collection_key
and mc.name = 'Ensembl Reg Gene Model'
;

EOSQL

date |tee -a $LOG

