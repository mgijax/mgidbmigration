#!/bin/csh -f

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a  $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

exec SEQ_createDummyTest
go

update statistics SEQ_Sequence
go

update statistics SEQ_Source_Assoc
go

update statistics ACC_Accession
go

checkpoint
go

quit
 
EOSQL

# load Sequence Cache tables

${CACHELOAD}/seqmarker.csh | tee -a $LOG
${CACHELOAD}/seqprobe.csh | tee -a $LOG
${MRKREFLOAD}/mrkref.csh | tee -a $LOG

date | tee -a  $LOG

