#!/bin/csh -f

#
# tssgeneload
# ei
#

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG

rm -rf ${DATALOADSOUTPUT}/mgi/tssgeneload/input/last*

date | tee -a $LOG
echo "before counts..." | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from MGI_Relationship where _Category_key = 1008;
EOSQL

date |tee -a $LOG
echo ${TSSGENELOAD}/bin/tssgeneload.sh | tee -a $LOG
${TSSGENELOAD}/bin/tssgeneload.sh | tee -a $LOG

date | tee -a $LOG
echo "after counts..." | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from MGI_Relationship where _Category_key = 1008;
EOSQL

