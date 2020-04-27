#!/bin/csh -f

#
# Template
#

# The task will be to search the 
#
# evidence = IPA
# createdby = MGI curator
# inferred-from value = see file
#
# replace the UniProtKB:$$$$$$ with PR:$$$$$$$$
#
# the value in the 'inferred from' field is in the list of identifiers in the
# file, then replace the UniProtKB:$$$$$$ with PR:$$$$$$$$. 

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

#${PYTHON} inferredfrom.py | tee -a $LOG
./inferredfrom.py | tee -a $LOG

date |tee -a $LOG
