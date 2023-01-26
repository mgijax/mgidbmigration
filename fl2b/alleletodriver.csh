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
insert into VOC_Term values(nextval('voc_term_seq'), 96, 'driver_component', null, null, null, 0, 1001, 1001, now(), now());
EOSQL

${PG_MGD_DBSCHEMADIR}/view/MGI_Relationship_FEAR_View_create.object | tee -a $LOG

date |tee -a $LOG

