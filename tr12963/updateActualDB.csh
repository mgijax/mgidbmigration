#!/bin/csh -fx

#
# update urls in ACC_ActualDB
#
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting update actuallDB' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- actualDB updates
update acc_actualdb set url = 'https://www.ncbi.nlm.nih.gov/nuccore/@@@@?report=genbank' where _actualdb_key = 67
;
update acc_actualdb set url = 'https://www.ncbi.nlm.nih.gov/nuccore/@@@@?report=genbank' where _actualdb_key = 96
;
update acc_actualdb set url = 'https://www.ncbi.nlm.nih.gov/nuccore/@@@@?report=genbank' where _actualdb_key = 128
;
update acc_actualdb set url = 'https://www.ncbi.nlm.nih.gov/nuccore/@@@@?report=genbank' where _actualdb_key = 129
;


EOSQL
date | tee -a ${LOG}
echo '--- finished actualDB' | tee -a ${LOG}

