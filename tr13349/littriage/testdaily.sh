#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

#setenv LOG $0.log
#rm -rf $LOG
#touch $LOG

#dumpTableData.csh mgi-testdb4 lec mgd BIB_Workflow_Relevance /home/mgi/dataload/littriageload-trunk/bin/BIB_Workflow_Relevance.bcp "|"
#dumpTableData.csh mgi-testdb4 lec mgd BIB_Workflow_Status /home/mgi/dataload/littriageload-trunk/bin/BIB_Workflow_Status.bcp "|"

cd ${DATALOADSOUTPUT}/mgi/littriageload
rm -rf lec.tar
scp bhmgiapp01:/data/loads/mgi/littriageload/input.tar .
cd input
tar -xvf ../input.tar
rm -rf lit*/*

${LITTRIAGELOAD}/bin/littriageload.sh

${PUBMED2GENELOAD}/bin/pubmed2geneload.sh

cd ${MGI_LIVE}/dbutils/mgidbmigration/littriage
./testRelevance.sh
./testStatus.sh
cp testRelevance.sh.log ${DATALOADSOUTPUT}/mgi/littriageload/output
cp testStatus.sh.log ${DATALOADSOUTPUT}/mgi/littriageload/output

cd ${MGI_LIVE}/qcreports_db
source ./Configuration
cd weekly
$PYTHON WF_GXD_secondary.py

