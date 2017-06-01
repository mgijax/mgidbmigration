#!/bin/csh -f

#
# migration of bib_dataset/bib_dataset_assoc to bib_workflow_status, bib_workflow_tag
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

setenv COLDELIM "|"
setenv LINEDELIM  "\n"

date | tee -a ${LOG}
echo 'migrating data sets to workflow'
rm -rf *bcp
./datasets.py | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/table/BIB_Workflow_Status_truncate.object | tee -a ${LOG}
${PG_MGD_DBSCHEMADIR}/table/BIB_Workflow_Tag_truncate.object | tee -a ${LOG}

${PG_MGD_DBSCHEMADIR}/index/BIB_Workflow_Status_drop.object | tee -a ${LOG}
${PG_MGD_DBSCHEMADIR}/index/BIB_Workflow_Tag_drop.object | tee -a ${LOG}

${PG_DBUTILS}/bin/bcpin.csh ${PG_DBSERVER} ${PG_DBNAME} BIB_Workflow_Status ${DBUTILS}/mgidbmigration/LitTriage/datasets wf_status_chosen.bcp ${COLDELIM} ${LINEDELIM} mgd | tee -a ${LOG}
${PG_DBUTILS}/bin/bcpin.csh ${PG_DBSERVER} ${PG_DBNAME} BIB_Workflow_Status ${DBUTILS}/mgidbmigration/LitTriage/datasets wf_status_indexed.bcp ${COLDELIM} ${LINEDELIM} mgd | tee -a ${LOG}
${PG_DBUTILS}/bin/bcpin.csh ${PG_DBSERVER} ${PG_DBNAME} BIB_Workflow_Status ${DBUTILS}/mgidbmigration/LitTriage/datasets wf_status_rejected.bcp ${COLDELIM} ${LINEDELIM} mgd | tee -a ${LOG}

${PG_DBUTILS}/bin/bcpin.csh ${PG_DBSERVER} ${PG_DBNAME} BIB_Workflow_Tag ${DBUTILS}/mgidbmigration/LitTriage/datasets wf_tag_apincomplete.bcp ${COLDELIM} ${LINEDELIM} mgd | tee -a ${LOG}
${PG_DBUTILS}/bin/bcpin.csh ${PG_DBSERVER} ${PG_DBNAME} BIB_Workflow_Tag ${DBUTILS}/mgidbmigration/LitTriage/datasets wf_tag_gxdloads.bcp ${COLDELIM} ${LINEDELIM} mgd | tee -a ${LOG}

${PG_MGD_DBSCHEMADIR}/index/BIB_Workflow_Status_create.object | tee -a ${LOG}
${PG_MGD_DBSCHEMADIR}/index/BIB_Workflow_Tag_create.object | tee -a ${LOG}

date | tee -a $LOG

