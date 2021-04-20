#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select c._refs_key, c.mgiID, c.jnumid, c.pubmedid, t.term as relvance, v.confidence, 
t2.term as status, t3.term as group, r.creation_date, 
u.login as relevanceuser, u2.login as littriageuser, c.short_citation
from bib_citation_cache c, bib_refs r, bib_workflow_relevance v, voc_term t, mgi_user u,
        bib_workflow_status s, voc_term t2, voc_term t3, mgi_user u2
where r.creation_date::date >= '04/16/2021'
and r._refs_key = c._refs_key
and r._refs_key = v._refs_key
and v.isCurrent = 1
and v._relevance_key = 70594667
and v._relevance_key = t._term_key
and v._createdby_key = u._user_key
and r._refs_key = s._refs_key
and s.isCurrent = 1
--and s._status_key = 71027551
and s._status_key = t2._term_key
and s._group_key = t3._term_key
and s._createdby_key = u2._user_key
and s._group_key not in (75601866)
order by c.short_citation, t3.term
;

EOSQL

date |tee -a $LOG

