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

-- no property at all
select m.symbol, a.accid, substring(t.term,1,30) as term, u.orcid, e.*
into temp table toAdd
from voc_annot v, voc_evidence e, mgi_user u, mrk_marker m, acc_accession a, voc_term t
where v._annottype_key = 1000
and v._annot_key = e._annot_key
and e._createdby_key = u._user_key and u.orcid is not null
and v._object_key = m._marker_key
and v._term_key = a._object_key
and a._mgitype_key = 13
and a.preferred = 1
and v._term_key = t._term_key
and not exists (select 1 from voc_evidence_property p where e._annotevidence_key = p._annotevidence_key)
union
select m.symbol, a.accid, substring(t.term,1,30) as term, u.orcid, e.*
from voc_annot v, voc_evidence e, mgi_user u, mrk_marker m, acc_accession a, voc_term t
where v._annottype_key = 1000
and v._annot_key = e._annot_key
and e._modifiedby_key = u._user_key and u.orcid is not null
and v._object_key = m._marker_key
and v._term_key = a._object_key
and a._mgitype_key = 13
and a.preferred = 1
and v._term_key = t._term_key
and not exists (select 1 from voc_evidence_property p where e._annotevidence_key = p._annotevidence_key)
;

select last_value from voc_evidence_property_seq;

select _annotevidence_key, symbol, accid, term, orcid from toAdd order by symbol, accid ;
insert into voc_evidence_property
select nextval('voc_evidence_property_seq'), _annotevidence_key, 18583062, 1, 1, orcid, _createdby_key, _modifiedby_key
from toAdd
;

select last_value from voc_evidence_property_seq;

--delete from voc_evidence_property where _evidenceproperty_key >

EOSQL

date |tee -a $LOG
