#!/bin/csh -f

#
# Migration for TR 3516
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
./tr3516.py $DBSERVER $DBNAME tr3516.data/PhenoSentences1.tab >>& $LOG
cat $DBPASSWORDFILE | bcp $DBNAME..MRK_Notes in MRK_Notes.bcp -c -t"|" -S$DBSERVER -U$DBUSER >>& $LOG

./tr3516.py $DBSERVER $DBNAME tr3516.data/PhenoSentences2.tab >>& $LOG
cat $DBPASSWORDFILE | bcp $DBNAME..MRK_Notes in MRK_Notes.bcp -c -t"|" -S$DBSERVER -U$DBUSER >>& $LOG

date >> $LOG
