#!/bin/csh -f

#
# status a Sequence as Deleted
#

setenv SCHEMADIR $1
source ${SCHEMADIR}/Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a  $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

declare @statusKey integer
select @statusKey from VOC_Term_SequenceStatus_View where term = "DELETED"

declare @seqKey integer
select @seqKey = _Object_key from ACC_Accession
where accID = "AF356350" and _MGIType_key = 19

update SEQ_Sequence
set _SequenceStatus_key = @statusKey
where _Sequence_key = @seqKey
go

checkpoint
go

quit
 
EOSQL

date | tee -a  $LOG

