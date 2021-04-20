#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

#dumpTableData.csh mgi-testdb4 lec mgd BIB_Workflow_Relevance /home/mgi/dataload/littriageload-trunk/bin/BIB_Workflow_Relevance.bcp "|"
#dumpTableData.csh mgi-testdb4 lec mgd BIB_Workflow_Status /home/mgi/dataload/littriageload-trunk/bin/BIB_Workflow_Status.bcp "|"

cd ${DATALOADSOUTPUT}/littriageload
rm -rf lec.tar
scp bhmgiapp01:/data/loads/mgi/littriageload/lec.tar .
cd input
tar -xvf ../lec.tar
rm -rf lit*/*

${LITTRIAGELOAD}/bin/littriageload.sh

cd ${MGI_LIVE}/dataload/littriageload-trunk/bin
testRelevance.sh
testStatus.sh
cp testRelevance.sh.log ${DATALOADSOUTPUT}/littriageload/output
cp testStatus.sh.log ${DATALOADSOUTPUT}/littriageload/output
cp ${DATALOADSOUTPUT}/littriageload/output/* ${DATALOADSOUTPUT}/littriageload/output
cp ${DATALOADSOUTPUT}/littriageload/logs/* ${DATALOADSOUTPUT}/littriageload/logs

cd ${MGI_LIVE}/qcreports_db
source ./Configuration
cd weekly
$PYTHON WF_GXD_secondary.py

