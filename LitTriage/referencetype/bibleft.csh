#!/bin/csh -f

#
# migrates bib_refs._referencetype_key
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

#
# there should be no reference associated with Reference Type 'Not Specified'
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select distinct substring(title,1,50), journal 
from BIB_Refs r, VOC_Vocab v, VOC_Term t
where v.name = 'Reference Type' 
and v._Vocab_key = t._Vocab_key 
and t.term = 'Not Specified'
and t._Term_key = r._ReferenceType_key
order by journal
;

--delete from VOC_Term t using VOC_Vocab v where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key and t.term = 'Not Specified';
EOSQL

