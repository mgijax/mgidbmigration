#!/bin/csh -f

#
# If a PMID has an associated done HT Index Experiment, its GXDHT LitTriage status should = Indexed.
#
# If a PMID has been set to GXDHT=Indexed and it is not done, then its status should be changed to Chosen.
#
# PMIDs whose GXDHT status=Not Routed should be set to New.  
# (This is because this data type is not included in the LitTriage Classifier; 
# I picked an incorrect status when we set the system up originally.)
#
# There are PMIDs whose current GXDHT status = Chosen.  
# Some will become Indexed when you do the cleanup; otherwise leave them alone; Chosen is a perfectly acceptable status.
#
# None of the other GXDHT statuses --Routed, Full-Coded, Rejected--should be in use.
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

$PYTHON cleanup.py | tee -a $LOG

date |tee -a $LOG

