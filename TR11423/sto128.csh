#!/bin/csh -fx

#
# Migration for TR11423
# sto128 : add Disease Cluster vocabulary/dag
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/scrum-dog/mgiconfig
	#setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

declare @ldbKey integer
select @ldbKey = max(_LogicalDB_key) + 1 from ACC_LogicalDB

declare @vocabKey integer
select @vocabKey = max(_Vocab_key) + 1 from VOC_Vocab

declare @dagKey integer
select @dagKey = max(_DAG_key) + 1 from DAG_DAG

insert ACC_LogicalDB (_LogicalDB_key, name, description, _Organism_key)
values (@ldbKey, 'Disease Cluster', 'Disease Cluster', null)
go

insert VOC_Vocab (_Vocab_key, _Refs_key, _LogicalDB_key, isSimple, isPrivate, name)
values (@vocabKey, ???, @ldbKey, 0, 0, 'Disease Cluster')
go

insert DAG_DAG (_DAG_key, _Refs_key, _MGIType_key, name, abbreviation)
values (@dagKey, ???, 13, 'Disease Cluster', 'DC')
go

insert VOC_VocabDAG (_Vocab_key, _DAG_key)
values (@vocabKey, @dagKey)
go

EOSQL
date | tee -a ${LOG}

#
# load the DC vocabulary/dag
# 
#${VOCLOAD}/runOBOIncLoad.sh DC.config | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

