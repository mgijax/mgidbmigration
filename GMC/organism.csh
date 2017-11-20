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

--delete from MGI_Organism_MGIType where _MGIType_key = 11;

-- create one for alleles
insert into MGI_Organism_MGIType
select o._organism_key, 11, 4, 1001, 1001, now(), now() 
from MGI_Organism o
where o.commonname in ('bacteria')
;
insert into MGI_Organism_MGIType
select o._organism_key, 11, 5, 1001, 1001, now(), now() 
from MGI_Organism o
where o.commonname in ('virus')
;
insert into MGI_Organism_MGIType
select o._organism_key, 11, 6, 1001, 1001, now(), now() 
from MGI_Organism o
where o.commonname in ('Not Specified')
;
insert into MGI_Organism_MGIType
select o._organism_key, 11, 7, 1001, 1001, now(), now() 
from MGI_Organism o
where o.commonname in ('chicken')
;

select o.commonname, t.*
from MGI_Organism o, MGI_Organism_MGIType t
where o._Organism_key = t._Organism_key
and t._MGIType_key = 2
order by t.sequenceNum
;


EOSQL

date |tee -a $LOG

