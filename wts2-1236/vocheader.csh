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
 
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MPheno_OBO.ontology ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.header ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.note ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP
scp bhmgiapp01:/data/loads/mgi/vocload/runTimeMP/MP.synonym ${DATALOADSOUTPUT}/mgi/vocload/runTimeMP

${PG_MGD_DBSCHEMADIR}/autosequence/VOC_AnnotHeader_create.object
${PG_MGD_DBSCHEMADIR}/procedure/VOC_processAnnotHeaderAll_create.object
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd
${PG_MGD_DBSCHEMADIR}/objectCounter.sh

# comment out before creating tag for Dave
# for testing
${PG_MGD_DBSCHEMADIR}/table/VOC_AnnotHeader_truncate.object
loadTableData.csh mgi-testdb4 lec mgd VOC_AnnotHeader /home/lec/mgi/dbutils/mgidbmigration-trunk/wts2-1236/VOC_AnnotHeader.bcp "|"

# before/after
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from voc_annotheader;
EOSQL
${VOCLOAD}/runOBOIncLoad.sh MP.config
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from voc_annotheader;
EOSQL

date |tee -a $LOG

