#!/bin/csh -fx

#
# SQL reports for TR11515
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv COLLSQLLOG $0.log
rm -rf ${COLLSQLLOG}
touch ${COLLSQLLOG}

date | tee -a ${COLLSQLLOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${COLLSQLLOG}

use ${MGD_DBNAME}
go

-- all collections
select v._Term_key, substring(v.term,1,50)
from VOC_Term v 
where v._Vocab_key = 92
order by v.term
go

-- collection terms used
--select v._Term_key, substring(v.term,1,50)
--from VOC_Term v 
--where v._Vocab_key = 92
--and exists (select 1 from ALL_Allele a where v._Term_key = a._Collection_key)
--order by v.term
--go

-- collection terms not used
select v._Term_key, substring(v.term,1,50)
from VOC_Term v 
where v._Vocab_key = 92
and not exists (select 1 from ALL_Allele a where v._Term_key = a._Collection_key)
order by v.term
go

-- collection counts
select a._Collection_key, substring(t.term,1,20) as term, count(a._Allele_key)
from ALL_Allele a, VOC_Term t
where a._Collection_key = t._Term_key
group by a._Collection_key, t.term
go

EOSQL

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${COLLSQLLOG}
echo "--- Finished" | tee -a ${COLLSQLLOG}

