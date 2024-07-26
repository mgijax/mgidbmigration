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

select a._allele_key, a.symbol, aa.accid, n._note_key, n.note
from ALL_Allele a, MGI_Note n, ACC_Accession aa
where a._allele_key = n._object_key
and n._notetype_key = 1020
and n._mgitype_key = 11
and n.note like '%http://mmrrc.mousebiology.or%'
and a._allele_key = aa._object_key
and aa._mgitype_key = 11
and aa._logicaldb_key = 1
order by a.symbol
;

EOSQL

date |tee -a $LOG

