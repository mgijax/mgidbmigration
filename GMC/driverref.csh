#!/bin/csh -f

#
# driver notes
#
# no original or molecular reference
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

select distinct a._allele_key, a.symbol, substring(c.note,1,25) as note
from mgi_note n, mgi_notechunk c, all_allele a
where n._notetype_key = 1034 
and n._note_key = c._note_key
and n._object_key = a._allele_key
and not exists (select 1 from mgi_reference_assoc r
	where a._allele_key = r._object_key
	and r._mgitype_key = 11
	and r._refassoctype_key in (1012)
	)
order by a.symbol
;

EOSQL

date |tee -a $LOG

