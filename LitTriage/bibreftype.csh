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

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- Peer Reviewed Article
update BIB_Refs r
set _ReferenceType_key = t._Term_key
from VOC_Vocab v, VOC_Term t
where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
and t.term = 'Peer Reviewed Article'
and lower(r.journal) in ('exp eye res', 'plos biol')
;
update BIB_Refs r
set _ReferenceType_key = t._Term_key
from VOC_Vocab v, VOC_Term t
where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
and t.term = 'Peer Reviewed Article'
and lower(r.journal) like 'skrifter %'
;

update BIB_Refs r
set _ReferenceType_key = t._Term_key
from VOC_Vocab v, VOC_Term t
where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
and t.term = 'Dissertation/Thesis'
and lower(r.journal) like '% thesis%'
;

update BIB_Refs r
set _ReferenceType_key = t._Term_key
from VOC_Vocab v, VOC_Term t
where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
and t.term = 'Conference Proceedings/Abstracts'
and lower(r.pgs) like '%abstr%'
;

update BIB_Refs r
set _ReferenceType_key = t._Term_key
from VOC_Vocab v, VOC_Term t
where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
and t.term = 'Conference Proceedings/Abstracts'
and lower(r.title) like '%abstract%'
;

update BIB_Refs r
set _ReferenceType_key = t._Term_key
from VOC_Vocab v, VOC_Term t
where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
and t.term = 'MGI Data Load'
and lower(r.title) in ('Mammalian Orthology Load', 'Protein SuperFamily Classification Load', 'HCOP Orthology Load',
	'Allen Brain Atlas [Internet] database Load', 'MouseFuncLoad', 'Wikipedia Gene Summary Load')
;

update BIB_Refs r
set _ReferenceType_key = t._Term_key
from VOC_Vocab v, VOC_Term t
where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
and t.term = 'MGI Data Load'
and lower(r.title) like '%fantom2%' and lower(r.authors) like 'mouse genome informatics%'
;

update BIB_Refs r
set _ReferenceType_key = t._Term_key
from VOC_Vocab v, VOC_Term t
where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key 
and t.term = 'Personal Communication'
and lower(r.title) like '%personal communication%'
;

EOSQL

#
# there should be no reference associated with Reference Type 'Not Specified'
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
--select r.* from BIB_Refs r, VOC_Vocab v, VOC_Term t
--where v.name = 'Reference Type' 
--and v._Vocab_key = t._Vocab_key 
--and t.term = 'Not Specified'
--and t._Term_key = r._ReferenceType_key
--;

--delete from VOC_Term t using VOC_Vocab v where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key and t.term = 'Not Specified';
EOSQL

