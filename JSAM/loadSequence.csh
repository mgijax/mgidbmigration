#!/bin/csh -f

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a  $LOG
 
# drop indexes

${newmgddbschema}/index/ACC_Accessione_drop.object
${newmgddbschema}/index/SEQ_Sequence_drop.object
${newmgddbschema}/index/SEQ_Source_Assoc_drop.object

# un-partition tables

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

# re-build indexes

${newmgddbschema}/index/ACC_Accessione_create.object
${newmgddbschema}/index/SEQ_Sequence_create.object
${newmgddbschema}/index/SEQ_Source_Assoc_create.object

# re-partition tables

# load Sequence Cache tables

${CACHELOAD}/seqmarker.csh | tee -a $LOG
${CACHELOAD}/seqprobe.csh | tee -a $LOG
${MRKREFLOAD}/mrkrefjsam.sh | tee -a $LOG

date | tee -a  $LOG

