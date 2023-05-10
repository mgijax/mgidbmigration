#!/bin/csh -fx

#
# delete all mapview data
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting mapview.csh' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG 
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG 
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG 
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG 


date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) 
from map_coord_feature f, map_coordinate c, map_coord_collection cc
where f._map_key = c._map_key
and c._collection_key = 92
and c._collection_key = cc._collection_key
;

delete from MAP_Coord_Collection
where _Collection_key = 92
; 

select count(*) 
from map_coord_feature f, map_coordinate c, map_coord_collection cc
where f._map_key = c._map_key
and c._collection_key = 92
and c._collection_key = cc._collection_key
;

EOSQL
date | tee -a ${LOG}

echo '--- finished mapview.csh' | tee -a ${LOG}

