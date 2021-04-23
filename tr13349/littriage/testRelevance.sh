#!/bin/csh -f

#
# Mon
#
# 1. load production backup into mgi-testdb4/lec
#
# 2. run migration part 1: sets 'keep', 'discard', 'Not Specified'
#       bibrelevance.csh.log is time stamped
#
# 3. run migration part 2:  littriageload/bin/processRelevance.sh
#       find all of the bib_workflow_relevance = 'Not Specified'
#       output/littriageload.relevance.predicted
#
# Sun
#
# 4. copy Mon-Sat production inputs (/data/loads/mgi/littriageload/input.last, etc) to lec
#
# 5. run littriageload; archive input, logs, output folders
#
# 6. run Production report:
#       list of MGI ids, J:, pubmedid, isDiscard, creation_date, short citation where creation_date >= Monday date Jan 11
#       bhmgiapp01:/data/loads/mgi/littriageload/testrelevance
#
# Mon : check Production/QC report
# Mon : check lori/output folders
#

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select c.mgiID, c.jnumid, c.pubmedid, t.term, v.confidence, r.creation_date, u.login, c.short_citation
from bib_citation_cache c, bib_refs r, bib_workflow_relevance v, voc_term t, mgi_user u
where r.creation_date::date >= '01/11/2021'
and r._refs_key = c._refs_key
and r._refs_key = v._refs_key
and v.isCurrent = 1
and v._relevance_key = t._term_key
and v._createdby_key = u._user_key
order by c.short_citation
;

EOSQL

date |tee -a $LOG

