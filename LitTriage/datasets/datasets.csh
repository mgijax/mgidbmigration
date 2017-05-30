#!/bin/csh -f

#
# migration of bib_dataset/bib_dataset_assoc to bib_workflow_status, bib_workflow_tag
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
EOSQL

date | tee -a ${LOG}
echo 'migrating data sets to workflow'
./datasets.py | tee -a $LOG || exit 1

date | tee -a $LOG

