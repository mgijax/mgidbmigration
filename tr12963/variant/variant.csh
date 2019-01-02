#!/bin/csh -f

#
# load variants to VAR tables
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

${PG_MGD_DBSCHEMADIR}/table/ALL_Variant_truncate.object | tee -a $LOG

./variant.py | tee -a $LOG

${PG_MGD_DBSCHEMADIR}/autosequence/ALL_Variant_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/autosequence/ALL_Variant_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/autosequence/ALL_Variant_Sequence_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/autosequence/ALL_Variant_Sequence_create.object | tee -a $LOG

date |tee -a $LOG

