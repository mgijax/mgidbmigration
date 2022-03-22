#!/bin/csh -f

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

-- zebrafish
insert into mgi_relationship_property 
select nextval('mgi_relationship_property_seq'), v._relationship_key, 100655559, aa.accid, 4, 1000, 1000, now(), now()
from mgi_relationship r, mgi_relationship_property v, acc_accession a, acc_accession aa
where r._category_key = 1004
and r._relationship_key = v._relationship_key
and v.value = a.accid
and a._logicaldb_key = 55
and a._object_key = aa._object_key
and aa._logicaldb_key = 172
;

-- rat
insert into mgi_relationship_property 
select nextval('mgi_relationship_property_seq'), v._relationship_key, 100655558, aa.accid, 4, 1000, 1000, now(), now()
from mgi_relationship r, mgi_relationship_property v, acc_accession a, acc_accession aa
where r._category_key = 1004
and r._relationship_key = v._relationship_key
and v.value = a.accid
and a._logicaldb_key = 55
and a._object_key = aa._object_key
and aa._logicaldb_key = 47
;

-- human/hgnc
insert into mgi_relationship_property 
select nextval('mgi_relationship_property_seq'), v._relationship_key, 100655557, aa.accid, 4, 1000, 1000, now(), now()
from mgi_relationship r, mgi_relationship_property v, acc_accession a, acc_accession aa
where r._category_key = 1004
and r._relationship_key = v._relationship_key
and v.value = a.accid
and a._logicaldb_key = 55
and a._object_key = aa._object_key
and aa._logicaldb_key = 64
;

EOSQL

date |tee -a $LOG


