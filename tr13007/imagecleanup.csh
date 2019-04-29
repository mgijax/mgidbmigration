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

select a.jnumid, i.* 
from img_image i, bib_citation_cache a
where i._mgitype_key = 8 
and i._refs_key = a._refs_key 
and i._imagetype_key = 1072159 
;

update img_image i
set _mgitype_key = 11
where i._mgitype_key = 8
and i._imagetype_key = 1072159
;

select a.jnumid, i.* 
from img_image i, bib_citation_cache a
where i._mgitype_key = 8 
and i._refs_key = a._refs_key 
and _imageclass_key in (6481782, 6481783);
;

update img_image i
set _mgitype_key = 11
where i._mgitype_key = 8
and _imageclass_key in (6481782, 6481783);
;

EOSQL

date |tee -a $LOG

