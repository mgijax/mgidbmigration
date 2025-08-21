#!/bin/csh -f

#
# mirror_wget
# strainmarkerload
# straingenemodelload
# reports_db
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
 
#$${MGD_DBSCHEMADIR}/autosequence/MGI_Translation_drop.object
#$${MGD_DBSCHEMADIR}/autosequence/MGI_Translation_create.object
#$cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#$insert into MGI_Translation values(nextval('mgi_translation_seq'),1021,69579,'JF1_MsJ',39,1000,1000,now(),now());
#$EOSQL
#$exit 0

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- Mouse Genome Project (MGP)
select * from map_coord_collection where _collection_key = 125;

select * from map_coordinate where _collection_key = 125;

select * from acc_accession where accid = 'MGP_129S1SvImJ_G0005049';

select mc.*, mf.*
from map_coordinate mc, map_coord_feature mf
where mc._map_key = mf._map_key
and mc._collection_key = 125
and mf._object_key in (8705273,53081321)
;

select a.accid, mf.*
from map_coordinate mc, map_coord_feature mf, acc_accession a
where mc._collection_key = 125
and mc._map_key = mf._map_key
and mf._object_key = a._object_key
and a._mgitype_key = 19
--and mf._object_key in (8705273,53081321)
limit 50
;

EOSQL

date |tee -a $LOG

