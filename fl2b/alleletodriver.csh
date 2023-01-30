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
insert into dag_dag values(53,207078,13,'driver_component','drive',now(),now());
insert into voc_vocabdag values(96,53,now(),now());
EOSQL

cd /data/loads/mgi/rvload/input
scp bhmgiapp01:/data/loads/mgi/rvload/input/RelationshipVocab.obo .
${RVLOAD}/bin/rvload.sh | tee -a $LOG

#${PG_MGD_DBSCHEMADIR}/view/MGI_Relationship_FEAR_View_create.object | tee -a $LOG
#${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG

date |tee -a $LOG

