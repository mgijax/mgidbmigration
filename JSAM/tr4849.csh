#!/bin/csh -fx

#
# Create and Load Test Sequence data
#
# Usage:  tr4849.csh
#

cd `dirname $0` && source ./Configuration

setenv DBNAME mgd_jsamlec

setenv LOG      $0.log
rm -rf $LOG
touch $LOG

date >> $LOG

tr4849.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} >> $LOG
cat $DBPASSWORDFILE | bcp $DBNAME..SEQ_Sequence in seqFile.SEQ_Sequence.bcp -c -t\\t -U$DBUSER >> $LOG
cat $DBPASSWORDFILE | bcp $DBNAME..PRB_Source in seqFile.PRB_Source.bcp -c -t\\t -U$DBUSER >> $LOG
cat $DBPASSWORDFILE | bcp $DBNAME..SEQ_Source_Assoc in seqFile.SEQ_Source_Assoc.bcp -c -t\\t -U$DBUSER >> $LOG
cat $DBPASSWORDFILE | bcp $DBNAME..ACC_Accession in seqFile.ACC_Accession.bcp -c -t\\t -U$DBUSER >> $LOG
cat $DBPASSWORDFILE | bcp $DBNAME..ACC_AccessionReference in seqFile.ACC_AccessionReference.bcp -c -t\\t -U$DBUSER >> $LOG
cat $DBPASSWORDFILE | bcp $DBNAME..MGI_Reference_Assoc in seqFile.MGI_Reference_Assoc.bcp -c -t\\t -U$DBUSER >> $LOG

date >> $LOG
