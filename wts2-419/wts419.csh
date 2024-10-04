#!/bin/csh -f

#
# wts2-419/Regulatory region and cluster member to marker relationship (TR12804)
#
# mgidbmigration
# rvload
# pgmgddbschema
# mgd_java_api
# pwi
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
 
rm -rf ${DATALOADSOUTPUT}/mgi/rvload/input/lastrun
scp bhmgiapp01:/data/loads/mgi/rvload/input/RelationshipVocab.obo ${DATALOADSOUTPUT}/mgi/rvload/input

# already installed on production
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#insert into dag_dag values(54, 207078, 13, 'regulates_expression', 'regul', now(), now());
#insert into voc_vocabdag values(96, 54, now(), now());
#insert into mgi_relationship_category values(1013,'regulates_expression', 96, 54, 2, 2, 94, 95, 1001, 1001, now(), now());
#EOSQL

${PG_MGD_DBSCHEMADIR}/view/MGI_Relationship_FEARByMarker_View_create.object
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd
${RVLOAD}/bin/rvload.sh

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
delete from MGI_Relationship where _category_key = 1013;
EOSQL
rm -rf ${DATALOADSOUTPUT}/mgi/fearload/input/lastrun
cp /mgi/all/wts2_projects/400/WTS2-419/Updated_RR_testdata.txt ${DATALOADSOUTPUT}/mgi/fearload/input/fearload.txt
./fearload.sh

date |tee -a $LOG

