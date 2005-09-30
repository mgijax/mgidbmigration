#!/bin/csh -fx

#
# TR 7094/SEQ_Sequence split into SEQ_Sequence and SEQ_Sequence_Raw
#

source ./Configuration

setenv FIELDDELIM	"&=&"

setenv LOG	`basename $0`.log
rm -rf $LOG
touch $LOG

date | tee -a ${LOG}

${newmgddbschema}/table/SEQ_Sequence_drop.object | tee -a ${LOG}
${newmgddbschema}/table/SEQ_Sequence_create.object | tee -a ${LOG}
${newmgddbschema}/table/SEQ_Sequence_Raw_create.object | tee -a ${LOG}
${newmgddbschema}/default/SEQ_Sequence_bind.object | tee -a ${LOG}
${newmgddbschema}/default/SEQ_Sequence_Raw_bind.object | tee -a ${LOG}
${newmgddbschema}/key/SEQ_Sequence_create.object | tee -a ${LOG}
${newmgddbschema}/key/SEQ_Sequence_Raw_create.object | tee -a ${LOG}
${newmgddbperms}/public/table/SEQ_Sequence_grant.object | tee -a ${LOG}
${newmgddbperms}/public/table/SEQ_Sequence_Raw_grant.object | tee -a ${LOG}

# Create the bcp file

./mgiseqraw.py >>& ${LOG}

# BCP new data into tables
cat ${DBPASSWORDFILE} | bcp ${DBNAME}..SEQ_Sequence in SEQ_Sequence.bcp -e SEQ_Sequence.bcp.error -c -t${FIELDDELIM} -S${DBSERVER} -U${DBUSER} | tee -a ${LOG}
cat ${DBPASSWORDFILE} | bcp ${DBNAME}..SEQ_Sequence_Raw in SEQ_Sequence_Raw.bcp -e SEQ_Sequence_Raw.bcp.error -c -t${FIELDDELIM} -S${DBSERVER} -U${DBUSER} | tee -a ${LOG}

# Create indexes
${newmgddbschema}/index/SEQ_Sequence_create.object | tee -a ${LOG}
${newmgddbschema}/index/SEQ_Sequence_Raw_create.object | tee -a ${LOG}

date | tee -a ${LOG}
