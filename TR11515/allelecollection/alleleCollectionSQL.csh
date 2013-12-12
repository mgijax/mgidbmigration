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

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select v.name, vv._Term_key, vv.term
from VOC_Vocab v, VOC_Term vv 
where v._Vocab_key = 92
and v._Vocab_key = vv._Vocab_key
go

--select a.symbol, vv.term
--from VOC_Vocab v, VOC_Term vv, ALL_Allele a
--where v._Vocab_key = 92
--and v._Vocab_key = vv._Vocab_key
--and vv._Term_key = a._Collection_key
--go

EOSQL

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

