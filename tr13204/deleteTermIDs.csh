#!/bin/csh -fx

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
echo '---  deleting term IDs' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG 
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG 
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG 
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG 

# remove the term insert trigger, delete all term accession ids
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
    DROP TRIGGER IF EXISTS VOC_Term_insert_trigger ON VOC_Term;

    DROP FUNCTION IF EXISTS VOC_Term_insert();

    delete from ACC_Accession where _mgitype_key = 13 and _logicaldb_key = 1;

EOSQL

date | tee -a ${LOG}

