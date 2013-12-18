#!/bin/csh -fx

#
# Migration for TR11515
#
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

#source ${MGICONFIG}/master.config.csh

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select _Vocab_key, substring(name,1,50) from VOC_Vocab where _Vocab_key in (38, 40, 41)
go

-- allele type vocabulary
select _Term_key, substring(term,1,50) from VOC_Term where _Vocab_key = 38 order by term
go

-- allele catetory 1
select _Term_key, substring(term,1,50) from VOC_Term where _Vocab_key = 40 order by term
go

-- allele catetory 2
select _Term_key, substring(term,1,50) from VOC_Term where _Vocab_key = 41 order by term
go

EOSQL
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

