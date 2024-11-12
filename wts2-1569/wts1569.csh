#!/bin/csh -f

#
# wts2-1569/Rr overlap automatic calculation using existing algorithm 
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

# add to production
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#insert into dag_dag values(55, 207078, 13, 'coordinates_overlap_with', 'regul', now(), now());
#insert into voc_vocabdag values(97, 55, now(), now());
#insert into mgi_relationship_category values(1014,'coordinates_overlap_with', 97, 55, 2, 2, 94, 95, 1001, 1001, now(), now());
#EOSQL

${PG_MGD_DBSCHEMADIR}/view/MGI_Relationship_FEARByMarker_View_create.object
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd
${RVLOAD}/bin/rvload.sh

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
delete from MGI_Relationship where _category_key = 1014;
EOSQL
rm -rf ${DATALOADSOUTPUT}/mgi/fearload/input/lastrun
cp /mgi/all/wts2_projects/1500/WTS2-1569/?.txt ${DATALOADSOUTPUT}/mgi/fearload/input/fearload.txt
${FEARLOAD}/bin/fearload.sh

date |tee -a $LOG

