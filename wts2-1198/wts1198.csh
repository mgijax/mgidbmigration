#!/bin/csh -f

#
# Template
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

rm -rf ${MGI_LIVE}/bin/publishStrain
rm -rf ${MGI_LIVE}/bin/runStrainQC
rm -rf ${DATALOADSOUTPUT}/mgi/curatorstrainload/input/*

#ls -l ${MGI_LIVE}/bin/publishStrain
#ls -l ${MGI_LIVE}/bin/runStrainQC

date |tee -a $LOG

