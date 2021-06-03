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

-- 4    RatMap
-- 25   RIKEN Clusters
-- 80   UniSTS
-- 81   HomoloGene
-- 156  Europhenome
delete from acc_accession where _logicaldb_key in (4,25);
delete from acc_logicaldb where _logicaldb_key in (4,25,80,81,156)
;

-- Rat ids
-- 47 | Rat Genome Database
update acc_accession set private = 0 where _logicaldb_key in (47) and private = 1;

--strain/must check with Michelle
select a.*
into temp table toStrain1
from acc_accession a, acc_logicaldb l, prb_strain s, mgi_user u
where a._logicaldb_key not in (22)
and a._mgitype_key = 10
and a._logicaldb_key = l._logicaldb_key
and a._object_key = s._strain_key
and s.private = 1
and s.private != a.private
and s._createdby_key = u._user_key
;
update acc_accession a
set private = 1 
from toStrain1 t
where t._accession_key = a._accession_key
;
select a.*
into temp table toStrain2
from acc_accession a, acc_logicaldb l, prb_strain s, mgi_user u
where a._logicaldb_key not in (22)
and a._mgitype_key = 10
and a._logicaldb_key = l._logicaldb_key
and a._object_key = s._strain_key
and s.private = 0
and s.private != a.private
and s._createdby_key = u._user_key
;
update acc_accession a
set private = 0 
from toStrain2 t
where t._accession_key = a._accession_key
;
select substring(s.strain,1,50), a.accid, a._logicaldb_key, l.name, s.private, a.private, u.login
from acc_accession a, acc_logicaldb l, prb_strain s, mgi_user u
where a._logicaldb_key not in (22)
and a._mgitype_key = 10
and a._logicaldb_key = l._logicaldb_key
and a._object_key = s._strain_key
and s.private != a.private
and s._createdby_key = u._user_key
order by l.name, s.strain
;

EOSQL

date |tee -a $LOG

