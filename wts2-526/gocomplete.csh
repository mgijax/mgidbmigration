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

-- withdrawn genes
select distinct gt._marker_key, m.symbol, mt.name, gt.completion_date, u.login
into temp table toDelete1
from go_tracking gt, mrk_marker m, mgi_user u, mrk_types mt
where gt._completedby_key is not null
and gt._marker_key = m._marker_key
and m._marker_status_key in (2)
and gt._completedby_key = u._user_key
and m._marker_type_key = mt._marker_type_key
;

select * from toDelete1;

delete from go_tracking g
using toDelete1 d
where d._marker_key = g._marker_key
;

--
-- completed dates 
-- no annotations 
-- no lit triage references
--
select distinct m.symbol, mt.name, gt._marker_key, gt.completion_date, u.login
from go_tracking gt, mrk_marker m, mgi_user u, mrk_types mt
where gt._completedby_key is not null
and gt._marker_key = m._marker_key
and gt._completedby_key = u._user_key
and m._marker_type_key = mt._marker_type_key
and not exists (select 1 from voc_annot v
        where v._annottype_key = 1000
        and gt._marker_key = v._object_key
        )
and not exists (select 1 from BIB_GOXRef_View r where m._marker_key = r._Marker_key)
;

EOSQL

rm -rf gored.annot
$PYTHON gored.py > gored.annot
$ANNOTLOAD/annotload.csh gored.config lec

