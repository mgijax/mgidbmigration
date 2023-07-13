#!/bin/csh -f

#
# have Dave retire 'strainload'
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

# remove old bin scripts
rm -rf ${MGIBIN}/publishStrain
rm -rf ${MGIBIN}/runStrainQC
# remove old inputs 
rm -rf ${DATALOADSOUTPUT}/mgi/curatorstrainload/input/*

ls -l ${MGIBIN}

date |tee -a $LOG

