#!/bin/csh -f

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
delete from VOC_Term where _vocab_key in (166,135);
insert into VOC_Term values((select max(_Term_key) + 1 from VOC_Term),166,'embryo',null,null,1,0,1001,1001,now(),now());
insert into VOC_Term values((select max(_Term_key) + 1 from VOC_Term),166,'the expression of',null,null,2,0,1001,1001,now(),now());
EOSQL

${PYTHON} vocabulary.py | tee -a $LOG

date |tee -a $LOG

