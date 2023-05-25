#!/bin/csh -f

#
# wts2-1178/fl2-369/New simple vocab 'GXD color'
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

insert into VOC_Vocab values(187,22864,1,1,0,'GXD color',now(),now());

EOSQL

date |tee -a $LOG

