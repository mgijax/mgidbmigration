#!/bin/csh -fx

#
# Migration for TR11515
# epic 4 : allele type
# sto? : ?
#
# _Vocab_key = 38
#
# 1) migration existing _Vocab_key = 38 to new terms
#
# 2) create new vocabulary for "Allele Attribute" (see TR11515/epic4 directory)
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

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

#
# create new vocabulary for "Allele Attribute"
#
${VOCLOAD}/runSimpleFullLoadNoArchive.sh ${DBUTILS}/mgidbmigration/TR11248/fxnClass/subHandleVocab.config | tee -a ${LOG}

# add new synonym type
date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

EOSQL
date | tee -a ${LOG}

${MGD_DBSCHEMADIR}/all_perms.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

