#!/bin/csh -f

#
# Load Sets
#

cd `dirname $0` && source ./Configuration
cd setload

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "Set Migration..." | tee -a $LOG
 
${SETLOAD}/runnamedsource.csh ${DBSERVER} ${DBNAME} namedsource_set.txt load >>& $LOG

date >> $LOG
